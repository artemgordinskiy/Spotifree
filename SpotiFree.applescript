-- Setting the "playing" property to the constant returned by Spotify as a "player state" when it's playing.
property playing : Çconstant ****kPSPÈ
global currentVolume

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
		-- Checking if Spotify is running, playing, and if current track is an advertisement.
		if (isRunning() and isPlaying() and isAnAd()) then
			try
				-- Mute Spotify.
				mute()
			end try
			-- Wait until the end of an ad + 1 sec. Then go forward.
			delay untilTheEndOfTrack()
			
			repeat
				try
					-- Check if current track is an ad. Or if Spotify was paused during an advertisement.
					if (isAnAd()) then
						-- Delay until the end of an ad + 1 sec. 
						-- If Spotify was paused, or there is a second ad, this loop will continue to repeat.
						delay untilTheEndOfTrack()
					else
						-- If there's no more ads, unmute and exit the loop.
						unmute()
						exit repeat
					end if
				end try
			end repeat
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
			-- Get the current sound volume from Spotify and save it in a variable currentVolume.
			set currentVolume to sound volume
			-- This is the only way possible to mute Spotify during an advertisement. Otherwise it pauses when you mute the sound.
			pause
			set sound volume to 0
			play
		end tell
	end try
	return
end mute

on unmute()
	try
		tell application "Spotify"
			-- Restore the volume to the level supplied to the parameter.
			set sound volume to currentVolume
		end tell
	end try
	return
end unmute

on isAnAd()
	local currentTrackPopularity, currentTrackDuration
	try
		tell application "Spotify"
			-- Get the popularity of a current track and save it in a variable currentTrackPopularity.
			set currentTrackPopularity to popularity of current track
			-- Get the duration of current track and save it in a variable currentTrackDuration.
			set currentTrackDuration to duration of current track
		end tell
	on error
		return false
	end try
	-- If current track's popularity is 0 and its duration is less then 40, then it's almost certainly an ad.
	if (currentTrackPopularity = 0 and currentTrackDuration < 40) then
		return true
	else
		return false
	end if
end isAnAd

on untilTheEndOfTrack()
	local currentTrackDuration, currentTrackPosition
	try
		tell application "Spotify"
			-- Get the duration of current track and save it in a variable currentTrackDuration.
			set currentTrackDuration to duration of current track
			-- Get the current track position and save it in a variable currentTrackPosition.
			set currentTrackPosition to player position
		end tell
	on error
		return
	end try
	return currentTrackDuration - currentTrackPosition + 1.5
end untilTheEndOfTrack

on isPlaying()
	local playerState
	try
		tell application "Spotify"
			-- Hook the variable playerState to Spotify's state (playing, paused etc.).
			set playerState to player state
		end tell
	on error
		return false
	end try
	-- Compare Spotify's state with a constant saved in the property on line 1.
	if playerState = playing then
		return true
	else
		return false
	end if
end isPlaying

on isRunning()
	local spotifyProcesses
	try
		tell application "System Events"
			-- Check if there are any Spotify processes. Set to variable spotifyProcesses
			set spotifyProcesses to (count of (every process whose bundle identifier is "com.spotify.client"))
		end tell
	on error
		return false
	end try
	-- Check the variable spotifyProcesses, to see is Spotify running.
	if spotifyProcesses ­ 0 then
		return true
	else
		return false
	end if
end isRunning

on isInLoginItems(appName)
	try
		tell application "System Events"
			if login item appName exists then
				return true
			else
				return false
			end if
		end tell
	on error
		return false
	end try
end isInLoginItems

on addToLoginItems(appName, appPath)
	local applicationName, applicationPath, posixAppPath
	set applicationName to appName
	-- Translate a supplied application path to a POSIX standard (e.g. "/Applications/SpotiFree.app" to ":Applications:SpotiFree.app").
	set applicationPath to POSIX path of alias appPath
	try
		tell application "System Events"
			-- Add inputted app to the Login Items.
			make login item at end with properties {path:applicationPath, hidden:true}
		end tell
	on error
		return
	end try
end addToLoginItems