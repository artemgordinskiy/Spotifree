-- Setting the "playing" property to the constant returned by Spotify as a "player state" when it's playing.
property playing : Çconstant ****kPSPÈ
global currentVolume

-- Check if Spotifree is being run the first time and is in Login Items.
if (my isTheFirstRun() = true and my isInLoginItems() = false) then
	-- Tell the user how Spotifree runs and ask if he wants Spotifree to run automatically on startup.
	-- Assign a result to the variable 'userAnswer'.
	set userAnswer to the button returned of (display dialog "Hi, thanks for installing Spotifree!" & Â
		return & "Just so you know, Spotifree has no interface yet, and will work silently in the background." & return & return Â
		& "BTW, do you want it to run automatically on startup?" with title Â
		"You are awesome!" with icon 1 buttons {"No, thanks", "OK"} default button 2)
	-- Check if user agreed.
	if (userAnswer = "OK") then
		try
			-- Add Spotifree to the Login Items.
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
		-- Checking if Spotify is running, playing, and if current track is an advertisement.
		if (isRunning() and isPlaying() and isAnAd()) then
			try
				-- Mute Spotify.
				mute()
			end try
			repeat
				try
					-- Check if current track is an ad. Or if Spotify was paused during an advertisement.
					if (isAnAd()) then
						-- If Spotify was paused, or there is a second ad, this loop will continue to repeat.
					else
						-- If there's no more ads, pause for .5 seconds to let Spotify respond.
						-- Then, unmute and exit the loop.
						delay 0.5
						unmute()
						exit repeat
					end if
				end try
				delay 0.3
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

on addToLoginItems()
	try
		tell application "System Events"
			-- Add Spotifree to the Login Items.
			make login item at end with properties {name:"Spotifree", path:"/Applications/Spotifree.app", hidden:true}
		end tell
	on error
		return
	end try
end addToLoginItems

on isTheFirstRun()
	try
		-- Get the value of the key 'hasRanBefore' in the file "~/Library/Preferences/com.ArtemGordinsky.Spotifree"
		set hasRanBefore to do shell script "defaults read com.ArtemGordinsky.Spotifree 'hasRanBefore'"
	on error
		-- If the file not there yet, an error is going to be thrown. So it's the first run, probably.
		-- We are going to return 'true' even if it was some other error. Not a big deal, after all.
		return true
	end try
	
	if (hasRanBefore ­ "true") then
		return true
	else
		return false
	end if
end isTheFirstRun

on isInLoginItems()
	try
		-- Ask 'System Events' is 'Spotifree' is in 'Login Items'.
		tell application "System Events"
			if login item "Spotifree" exists then
				return true
			else
				return false
			end if
		end tell
	on error
		return false
	end try
end isInLoginItems