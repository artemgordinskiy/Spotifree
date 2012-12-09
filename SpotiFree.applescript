-- Setting the "playing" property to the constant returned by Spotify as a "player state" when it's playing.
property playing : Çconstant ****kPSPÈ
global currentVolume, currentTrackPopularity, currentTrackDuration, currentTrackPosition

if (isInLoginItems("SpotiFree", ":Applications:SpotiFree.app") = false) then -- Check if SpotiFree is login items.
	local dialogTitle, dialogMessage, dialogButtonYes, dialogButtonYes, spotifreeAppName, spotifreeAppPath
	set spotifreeAppName to "SpotiFree"
	set spotifreeAppPath to ":Applications:SpotiFree.app"
	set dialogTitle to "Open SpotiFree at login"
	set dialogMessage to "Do you want SpotiFree to run automatically on startup? You'll never notice it, seriously."
	set dialogButtonNo to "No, thanks"
	set dialogButtonYes to "OK"
	
	-- Run the dialog to a user.
	set runAtStartupQuestion to (display dialog dialogMessage with title dialogTitle with icon 1 buttons {dialogButtonNo, dialogButtonYes} default button 2)
	-- Assign the result to the variable runAtStartupAnswer.
	set runAtStartupAnswer to the button returned of runAtStartupQuestion
	-- Check if user agreed.
	if (runAtStartupAnswer = dialogButtonYes) then
		try
			-- Add SpotiFree to the Login Items.
			my addToLoginItems(spotifreeAppName, spotifreeAppPath)
		end try
	end if
end if

-- Repeat this entire block every .3 seconds. As set at the end.
repeat
	try
		if (isRunning() and isPlaying()) then -- Is Spotify running? Is it playing?
			tell application "Spotify"
				try
					-- Get the popularity of a current track and save it in a variable currentTrackPopularity.
					set currentTrackPopularity to popularity of current track
				end try
				try
					-- Get the duration of current track and save it in a variable currentTrackDuration.
					set currentTrackDuration to duration of current track
				end try
			end tell
			
			-- Check if current track is an advertisement.
			if (isAnAd(currentTrackPopularity, currentTrackDuration)) then
				try
					tell application "Spotify"
						try
							-- Get the current sound volume from Spotify and save it in a variable currentVolume.
							set currentVolume to sound volume
						end try
						try
							-- Get the current track position and save it in a variable currentTrackPosition.
							set currentTrackPosition to player position
						end try
					end tell
					
					-- Mute Spotify.
					mute()
					
					-- Wait until the end of an ad. Then go forward.
					delay currentTrackDuration - currentTrackPosition + 1
				end try
				
				try
					repeat
						tell application "Spotify"
							try
								-- Get the popularity of a current track and save it in a variable currentTrackPopularity.
								set currentTrackPopularity to popularity of current track
							end try
							try
								-- Get the duration of current track and save it in a variable currentTrackDuration.
								set currentTrackDuration to duration of current track
							end try
							try
								-- Get the current track position and save it in a variable currentTrackPosition.
								set currentTrackPosition to player position
							end try
						end tell
						
						if (isAnAd(currentTrackPopularity, currentTrackDuration) = false) then -- Check if current track is not an advertisement.
							unmute(currentVolume)
							exit repeat
						else
							delay currentTrackDuration - currentTrackPosition + 1
						end if
					end repeat
				end try
				
			end if
			
		end if
	end try
	delay 0.3
end repeat

on mute()
	try
		tell application "Spotify"
			try
				pause
				set sound volume to 0
				play
			end try
		end tell
	end try
end mute

on unmute(volume)
	tell application "Spotify"
		try
			-- Restore the volume to the level it was before muting.
			set sound volume to volume
		end try
	end tell
end unmute

on isAnAd(trackPopularity, trackDuration)
	try
		-- If current track's popularity is 0 and its duration is less then 40, then it's almost certainly an ad.
		if (trackPopularity = 0 and trackDuration < 40) then
			return true
		else
			return false
		end if
	end try
end isAnAd

on isPlaying()
	local playerState
	try
		tell application "Spotify"
			try
				-- Hook the variable playerState to Spotify's state (playing, paused etc.).
				set playerState to player state
			end try
		end tell
		-- Compare Spotify's state with a constant saved in the property on line 1.
		if playerState = playing then
			return true
		else
			return false
		end if
	end try
	
end isPlaying

on isRunning()
	local spotifyProcesses
	try
		tell application "System Events"
			try
				-- Check if there are any Spotify processes. Set to variable spotifyProcesses
				set spotifyProcesses to (count of (every process whose bundle identifier is "com.spotify.client"))
			end try
		end tell
		-- Check the variable spotifyProcesses, to see is Spotify running.
		if spotifyProcesses ­ 0 then
			return true
		else
			return false
		end if
	end try
end isRunning

on isInLoginItems(appName)
	local allLoginItems
	try
		-- Get all apps in Login Items.
		tell application "System Events" to set allLoginItems to name of every login item as string
		-- Check if inputted app is in there.
		if appName is in allLoginItems then
			return true
		else
			return false
		end if
	end try
end isInLoginItems

on addToLoginItems(appName, appPath)
	local posixAppPath
	try
		-- Get the POSIX (Portable Operating System Interface) path of inputted appPath.
		set posixAppPath to POSIX path of alias appPath
		tell application "System Events"
			try
				-- Add inputted app to the Login Items.
				make login item at end with properties {path:posixAppPath, hidden:true}
			end try
		end tell
	end try
end addToLoginItems