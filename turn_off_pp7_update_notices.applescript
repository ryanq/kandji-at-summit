tell application "ProPresenter" to activate

tell application "System Events"
	tell process "ProPresenter"
		
		-- Open the Updates preference pane
		tell menu bar 1
			tell menu of menu bar item "ProPresenter"
				tell menu of menu item "Preferences…"
					click menu item "Updates"
				end tell
			end tell
		end tell
		
		-- Turn off update notifications
		tell window "Updates"
			tell group 1 -- This is the tab group
				set toggle to first checkbox -- This is the toggle for update notices
				
				if (value of toggle) is 1 then
					click toggle
				end if
			end tell
		end tell
		
	end tell
end tell