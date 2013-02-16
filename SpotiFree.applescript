property debug : false
property currentVolume : null

if (my isTheFirstRun() = true and my isInLoginItems() = false) then
	set userAnswer to the button returned of (display dialog "Hi, thanks for installing Spotifree!" & Â
		return & "Just so you know, Spotifree has no interface yet, and will work silently in the background." & return & return Â
		& "BTW, do you want it to run automatically on startup?" with title Â
		"You are awesome!" with icon 1 buttons {"No, thanks", "OK"} default button 2)
	if (userAnswer = "OK") then
		try
			my addToLoginItems()
		end try
	end if
	try
		-- Save in the preferences that Spotifree has already ran.
		do shell script "defaults write com.ArtemGordinsky.Spotifree 'hasRanBefore' 'true'"
	end try
end if

repeat
	try
		if (isRunning() and isPlaying() and isAnAd()) then
			try
				mute()
			end try
			repeat
				try
					if (isAnAd() = false) then
						-- Have to delay a little bit, because Spotify may tell us about the next track too early,
						-- and a user has to hear the last half-second of an ad.
						delay 0.8
						unmute()
						exit repeat
					end if
				end try
				delay 0.3
			end repeat
		else
			-- Delaying, to get less of the crashing "connection is invalid" errors.
			delay 1
		end if
	on error errorMessage number errorNumber
		my log_error(errorNumber, errorMessage, "some unhandled error in the outer loop.")
	end try
	-- This is how fast we are polling Spotify.
	-- The only speed at which you will hear almost no sounds passing through.
	-- Fortunately, even combined with the added load on Spotify, the CPU usage is rather miniscule.
	delay 0.3
end repeat

on mute()
	try
		tell application "Spotify"
			set currentVolume to sound volume
			-- This is the only way possible to mute Spotify during an advertisement.
			-- Otherwise it pauses when you mute the sound.
			pause
			set sound volume to 0
			play
		end tell
	on error errorMessage number errorNumber
		my log_error(errorNumber, errorMessage, "trying to mute Spotify.")
	end try
	return
end mute

on unmute()
	try
		tell application "Spotify"
			-- Restore the volume to the level supplied to the parameter.
			set sound volume to currentVolume
		end tell
	on error errorMessage number errorNumber
		my log_error(errorNumber, errorMessage, "trying to restore Spotify's volume.")
	end try
	return
end unmute

on isAnAd()
	local currentTrackPopularity, currentTrackDuration
	set currentTrackPopularity to null
	set currentTrackDuration to null
	try
		tell application "Spotify"
			set currentTrackPopularity to popularity of current track
			set currentTrackDuration to duration of current track
		end tell
	on error errorMessage number errorNumber
		my log_error(errorNumber, errorMessage, "trying to get popularity and duration of the current track.")
		return false
	end try
	if ((currentTrackPopularity ­ null and currentTrackDuration ­ null) and (currentTrackPopularity = 0 and currentTrackDuration ² 40)) then
		return true
	else
		return false
	end if
end isAnAd

on isPlaying()
	local playerState
	set playerState to null
	-- Adding a 5 seconds timeout instead of default 2 min. Prevents long unresponsiveness of the app.
	with timeout of (5) seconds
		try
			tell application "Spotify"
				set playerState to player state
			end tell
		on error errorMessage number errorNumber
			my log_error(errorNumber, errorMessage, "counting Spotify processes.")
			return false
		end try
	end timeout
	if (playerState ­ null and playerState = Çconstant ****kPSPÈ) then
		return true
	else
		return false
	end if
end isPlaying

on isRunning()
	local spotifyProcesses
	-- Adding a 5 seconds timeout instead of default 2 min. Prevents long unresponsiveness of the app.
	with timeout of (5) seconds
		try
			tell application "System Events"
				set spotifyProcesses to (count of (every process whose name is "Spotify"))
			end tell
		on error errorMessage number errorNumber
			my log_error(errorNumber, errorMessage, "counting Spotify processes.")
			return false
		end try
	end timeout
	if spotifyProcesses = 1 then
		return true
	else
		return false
	end if
end isRunning

on addToLoginItems()
	try
		tell application "System Events"
			-- Add Spotifree to the Login Items.
			make login item at end with properties {name:"Spotifree", path:"/Applications/Spotifree.app", hidden:true}
		end tell
	on error errorMessage number errorNumber
		my log_error(errorNumber, errorMessage, "adding Spotifree to the Login Items")
		return
	end try
end addToLoginItems

on isTheFirstRun()
	try
		-- Get the value of the key 'hasRanBefore' in the file "~/Library/Preferences/com.ArtemGordinsky.Spotifree"
		set hasRanBefore to do shell script "defaults read com.ArtemGordinsky.Spotifree 'hasRanBefore'"
	on error errorMessage number errorNumber
		-- If the file not there yet, an error is going to be thrown. So it's the first run, probably.
		-- We are going to return 'true' even if it was some other error. Not a big deal, after all.
		my log_error(errorNumber, errorMessage, "checking is Spotify being run the first time.")
		return true
	end try
	
	if (hasRanBefore = "true") then
		return true
	else
		return false
	end if
end isTheFirstRun

on isInLoginItems()
	try
		tell application "System Events"
			if login item "Spotifree" exists then
				return true
			else
				return false
			end if
		end tell
	on error errorMessage number errorNumber
		my log_error(errorNumber, errorMessage, "checking if Spotify is in Login Items")
		return false
	end try
end isInLoginItems

on log_message(message)
	local content
	set content to (return & Â
		"-----------------------------------------------------------" & Â
		return & my dateAndTime() & return & message & return Â
		& "-----------------------------------------------------------" & return)
	set log_file to (((path to desktop folder) as text) & "Spotifree_log.txt")
	my write_to_file(content, log_file, true)
end log_message

on log_error(error_number, error_message, diag_message)
	local content
	if (debug = true) then
		set content to (return & "-----------------------------------------------------------" & Â
			return & my dateAndTime() & return & "Error number: " & error_number Â
			& return & "Error message: " & error_message & return & Â
			"Diagnostic message: " & diag_message & return Â
			& "-----------------------------------------------------------" & return)
		set log_file to (((path to desktop folder) as text) & "Spotifree_log.txt")
		my write_to_file(content, log_file, true)
	end if
end log_error

on write_to_file(this_data, target_file, append_data) -- (string, file path as string, boolean)
	try
		set the target_file to the target_file as text
		set the open_target_file to Â
			open for access file target_file with write permission
		if append_data is false then Â
			set eof of the open_target_file to 0
		write this_data to the open_target_file starting at eof
		close access the open_target_file
		return true
	on error
		try
			close access file target_file
		end try
	end try
end write_to_file

on dateAndTime()
	set currentDateAndTime to (current date) as string
	return currentDateAndTime
end dateAndTime