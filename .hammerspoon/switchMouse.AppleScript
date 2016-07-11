tell application "System Preferences"
	activate
	set the current pane to pane id "com.apple.preference.mouse"
	delay 0.3
end tell

tell application "System Events"
	tell process "System Preferences"
		get value of radio button 1 of radio group of window 1
		if value of radio button 1 of radio group of window 1 is {0} then
			click radio button 1 of radio group of window 1
		else
			click radio button 2 of radio group of window 1
		end if
	end tell
end tell

tell application "System Preferences"
	close window 1
end tell
