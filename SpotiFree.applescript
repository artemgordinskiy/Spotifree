-- Setting the "playing" property to the constant returned by Spotify as a "player state" when it's playing.
property playing : «constant ****kPSP»
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
	-- Assign a result to the variable runAtStartupAnswer.
	set runAtStartupAnswer to the button returned of runAtStartupQuestion
	-- Check if user agreed.
	if (runAtStartupAnswer = dialogButtonYes) then
		try
			-- Add SpotiFree to the Login Items.
			my addToLoginItems(spotifreeAppName, spotifreeAppPath)
		end try
	end if
end if

repeat
	try
		-- Checking if Spotify is running and playing right now.
		if (isRunning() and isPlaying()) then
			tell application "Spotify"
				try
					-- Get the popularity of a current track and save it in a variable currentTrackPopularity.
					set currentTrackPopularity to popularity of current track
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
							-- Get the current track position and save it in a variable currentTrackPosition.
							set currentTrackPosition to player position
						end try
					end tell
					
					-- Mute Spotify.
					mute()
					
					-- Wait until the end of an ad + 1 sec. Then go forward.
					delay currentTrackDuration - currentTrackPosition + 1
				end try
				
				try
					repeat
						tell application "Spotify"
							try
								-- Get the popularity of a current track and save it in a variable currentTrackPopularity.
								set currentTrackPopularity to popularity of current track
								-- Get the duration of current track and save it in a variable currentTrackDuration.
								set currentTrackDuration to duration of current track
								-- Get the current track position and save it in a variable currentTrackPosition.
								set currentTrackPosition to player position
								
							on error number errorNumber
								-- Checking if Spotify returns "Can’t get current track." error.  It's being thrown when there's no track after an ad.
								-- Happens, for instance, when an ad has played after the last song on the playlist.
								if (errorNumber = -1728) then
									-- If it is, unmute Spotify and exit the loop.
									my unmute(currentVolume)
									exit repeat
								end if
							end try
						end tell
						
						-- Check if current track is an ad. Or if Spotify was paused during an advertisement.
						if (isAnAd(currentTrackPopularity, currentTrackDuration)) then
							-- Delay until the end of an ad + 1 sec. 
							-- If Spotify was paused, or there is a second ad, this loop will continue to repeat.
							delay currentTrackDuration - currentTrackPosition + 1
						else
							-- If there's no more ads, unmute and exit the loop.
							unmute(currentVolume)
							exit repeat
						end if
					end repeat
				end try
			end if
		end if
	end try
	-- This is how fast we are polling Spotify. 
	-- The only speed at which you will hear no sounds passing through.
	-- Fortunately, combined with the added load on Spotify, the CPU usage stays well below 1% even on an old dual-core 3.6 GHz processor.
	delay 0.3
end repeat

on mute()
	try
		tell application "Spotify"
			try
				-- This is the only way possible to mute Spotify during an advertisement. Otherwise it pauses when you mute the sound.
				pause
				set sound volume to 0
				play
			end try
		end tell
	end try
end mute

on unmute(volume)
	local currentVolume
	set currentVolume to volume
	
	tell application "Spotify"
		try
			-- Restore the volume to the level supplied to the parameter.
			set sound volume to currentVolume
		end try
	end tell
end unmute

on isAnAd(popularity, duration)
	local trackPopularity, trackDuration
	set trackPopularity to popularity
	set trackDuration to duration
	
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
		if spotifyProcesses ≠ 0 then
			return true
		else
			return false
		end if
	end try
end isRunning

on isInLoginItems(appName)
	local applicationName, allLoginItems
	set applicationName to appName
	try
		-- Get all apps in Login Items.
		tell application "System Events" to set allLoginItems to name of every login item as string
		-- Check if inputted app is in there.
		if applicationName is in allLoginItems then
			return true
		else
			return false
		end if
	end try
end isInLoginItems

on addToLoginItems(appName, appPath)
	local applicationName, applicationPath, posixAppPath
	set applicationName to appName
	set applicationPath to appPath
	
	try
		-- Translate a supplied application path to a POSIX standard (e.g. "/Applications/SpotiFree.app" to ":Applications:SpotiFree.app").
		set posixAppPath to POSIX path of alias applicationPath
		tell application "System Events"
			try
				-- Add inputted app to the Login Items.
				make login item at end with properties {path:posixAppPath, hidden:true}
			end try
		end tell
	end try
end addToLoginItems