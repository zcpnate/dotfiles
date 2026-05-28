-- Hammerspoon script to automatically update your slack status when in a
-- Zoom or Google Meet meeting.
--
-- To use:
--
-- * Install and set up the slack_status.sh script (make sure it's in your
--   path)
-- * Ensure there is a 'zoom' preset (one is created by default during setup)
-- * Install hammerspoon (brew install hammerspoon) if you don't have it
--   already.
-- * Copy this file to ~/.config/hammerspoon
-- * Add the following line to ~/.config/hammerspoon/init.lua
--      local zoom_detect = require("zoom_detect")
-- * If it's a fresh `brew install` of Hammerspoon, start it and make sure
--   accessibility is enabled

-- Configuration
check_interval=20 -- How often to check if you're in a meeting, in seconds
meet_browsers = {"Dia"}
debug_log = false -- set true to print per-tick checks to Hammerspoon console

-- Allow hs.application.find() to match alternate/display names (e.g. Dia).
hs.application.enableSpotlightForNameSearches(true)

local function dbg(msg)
    if debug_log then hs.console.printStyledtext(msg) end
end

function update_status(status)
    -- Ensure there's a space between the script path and the status argument
    local command = hs.configdir .. "/slack_status.sh " .. status
    
    dbg("Updating Slack Status with command: " .. command)
    
    -- Execute the command and capture output and success status
    local output, success, _, _ = hs.execute(command, true)
    
    -- Check if the command was successful
    if success then
        dbg("Command executed successfully. Output: " .. output)
    else
        dbg("Command failed. Output: " .. output)
    end
end

function in_zoom_meeting()
    dbg("Checking for Zoom application...")
    local zoomApp = hs.application.find("zoom.us")

    if zoomApp then
        dbg("Zoom application found. Retrieving all menu items...")
        local allMenuItems = getAllMenuItems(zoomApp)

        for _, title in ipairs(allMenuItems) do
            if title == "Meeting" then  -- Changed from "Join Meeting…" to "Meeting"
                dbg("'Meeting' menu item found. You are in a Zoom meeting.")
                return true
            end
        end

        dbg("'Meeting' menu item not found. You are not in a Zoom meeting.")
        return false
    else
        -- Zoom isn't running
        dbg("Zoom application not found.")
        return false
    end
end

function getAllMenuItems(app)
    local allTitles = {}

    local function gatherTitles(menuItems)
        for _, item in ipairs(menuItems) do
            if type(item) == "table" and item.AXTitle then
                table.insert(allTitles, item.AXTitle)
            end
            if item.AXChildren then
                gatherTitles(item.AXChildren[1])
            end
        end
    end

    local menuItems = app:getMenuItems()
    if menuItems then
        gatherTitles(menuItems)
    end

    return allTitles
end

function in_meet_meeting()
    -- Google Meet URL pattern: meet.google.com/xxx-xxxx-xxx (code has dashes)
    -- Landing page meet.google.com/ (no code) is excluded.
    for _, browser in ipairs(meet_browsers) do
        local app = hs.application.find(browser)
        if app and app:isRunning() then
            local script = string.format([[
                tell application "%s"
                    set urlList to ""
                    try
                        repeat with w in windows
                            repeat with t in tabs of w
                                set urlList to urlList & (URL of t) & linefeed
                            end repeat
                        end repeat
                    end try
                    return urlList
                end tell
            ]], browser)
            local ok, result = hs.osascript.applescript(script)
            if ok and result then
                for url in string.gmatch(result, "[^\n]+") do
                    if string.match(url, "meet%.google%.com/[%a%-]+%-[%a%-]+") then
                        dbg("Google Meet tab found in " .. browser .. ": " .. url)
                        return true
                    end
                end
            end
        end
    end
    return false
end

in_meeting = false  -- false when idle, else preset name ("zoom" / "meet")
meetingTimer = hs.timer.doEvery(check_interval, function()
    local zoom = in_zoom_meeting()
    local meet = not zoom and in_meet_meeting()
    local preset = zoom and "zoom" or (meet and "meet" or nil)
    local kind = zoom and "Zoom" or (meet and "Google Meet" or nil)

    if preset then
        if in_meeting ~= preset then
            in_meeting = preset
            hs.notify.show("Started " .. kind .. " meeting", "Updating slack status", "")
            update_status(preset)
        end
    else
        if in_meeting then
            in_meeting = false
            hs.notify.show("Left meeting", "Updating slack status", "")
            update_status("none")
        end
    end
end)
meetingTimer:start()
