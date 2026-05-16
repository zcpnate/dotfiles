#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title paste as keystrokes
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Get the clipboard content
clipboard_content=$(pbpaste)

# Use osascript to paste the content as keystrokes
osascript <<EOF
on run
    # Escape double quotes in the clipboard content to prevent AppleScript errors
    set clipboard_content to "$(printf '%s' "$clipboard_content" | sed 's/"/\\"/g')"
    
    tell application "System Events"
        # Create a list of lists for symbol mapping
        # Each entry format: {ASCII code, key code, use shift key (true/false)}
        set symbol_map to {}
        
        # Add symbol mappings
        # Format: set end of symbol_map to {ASCII code, key code, use shift}
        set end of symbol_map to {46, 47, false}  # Period (.)
        set end of symbol_map to {44, 43, false}  # Comma (,)
        set end of symbol_map to {59, 41, false}  # Semicolon (;)
        set end of symbol_map to {58, 41, true}   # Colon (:)
        set end of symbol_map to {45, 27, false}  # Hyphen (-)
        set end of symbol_map to {61, 24, false}  # Equals (=)
        set end of symbol_map to {33, 18, true}   # Exclamation mark (!)
        set end of symbol_map to {64, 19, true}   # At symbol (@)
        set end of symbol_map to {35, 20, true}   # Hash (#)
        set end of symbol_map to {36, 21, true}   # Dollar sign ($)
        set end of symbol_map to {37, 23, true}   # Percent (%)
        set end of symbol_map to {94, 22, true}   # Caret (^)
        set end of symbol_map to {38, 26, true}   # Ampersand (&)
        set end of symbol_map to {42, 28, true}   # Asterisk (*)
        set end of symbol_map to {40, 25, true}   # Left parenthesis (()
        set end of symbol_map to {41, 29, true}   # Right parenthesis ())
        set end of symbol_map to {95, 27, true}   # Underscore (_)
        set end of symbol_map to {43, 24, true}   # Plus (+)
        set end of symbol_map to {91, 33, false}  # Left square bracket ([)
        set end of symbol_map to {93, 30, false}  # Right square bracket (])
        set end of symbol_map to {123, 33, true}  # Left curly brace ({)
        set end of symbol_map to {125, 30, true}  # Right curly brace (})
        set end of symbol_map to {124, 42, true}  # Vertical bar (|)
        set end of symbol_map to {92, 42, false}  # Backslash (\)
        set end of symbol_map to {47, 44, false}  # Forward slash (/)
        set end of symbol_map to {60, 43, true}   # Less than (<)
        set end of symbol_map to {62, 47, true}   # Greater than (>)
        set end of symbol_map to {63, 44, true}   # Question mark (?)
        
        # Iterate through each character in the clipboard content
        repeat with char in (characters of clipboard_content)
            set ascii_num to (ASCII number char)
            
            # Check if the character is a number (0-9)
            if ascii_num is in {48, 49, 50, 51, 52, 53, 54, 55, 56, 57} then
                # Convert ASCII to number (0-9) and get corresponding key code
                set num to ascii_num - 48
                set key_code to item (num + 1) of {29, 18, 19, 20, 21, 23, 22, 26, 28, 25}
                key code key_code
            else
                set found to false
                
                # Check if the character is in our symbol map
                repeat with symbol_item in symbol_map
                    if ascii_num is equal to item 1 of symbol_item then
                        set key_code to item 2 of symbol_item
                        set use_shift to item 3 of symbol_item
                        
                        # Press the key, with shift if necessary
                        if use_shift then
                            key code key_code using {shift down}
                        else
                            key code key_code
                        end if
                        
                        set found to true
                        exit repeat
                    end if
                end repeat
                
                # If the character wasn't in our symbol map, type it directly
                if not found then
                    keystroke char
                end if
            end if
            
            # Add a small delay between keystrokes for reliability
            delay 0.05
        end repeat
    end tell
end run
EOF

echo "Script completed"
