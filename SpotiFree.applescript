property debug : false
property currentVolume : null

if (isTheFirstRun() and not isInLoginItems()) then
    set userAnswer to the button returned of (display dialog "Hi, thanks for installing Spotifree!" & ¬
        return & "Just so you know, Spotifree has no interface yet, and will work silently in the background." & return & return ¬
        & "BTW, do you want it to run automatically on startup?" with title ¬
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
        -- Adding a 5 seconds timeout instead of default 2 min. Prevents long unresponsiveness of the app.
        with timeout of (5) seconds
            if (isRunning() and isPlaying() and isAnAd()) then
                try
                    mute()
                end try
                repeat
                    delay 0.3
                    try
                        if (isRunning() and not isAnAd()) then
                            -- Have to delay a little bit, because Spotify may tell us about the next track too early,
                            -- and a user may to hear the last half-second of an ad.
                            delay 0.8
                            unmute()
                            exit repeat
                        end if
                    end try
                end repeat
            else
                -- Delaying, to get less of the crashing "connection is invalid" errors.
                delay 1
            end if
        end timeout
    on error errorMessage number errorNumber
        my log_error(errorNumber, errorMessage, "Somewhere in the outer loop.")
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
        my log_error(errorNumber, errorMessage, "mute()")
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
        my log_error(errorNumber, errorMessage, "unmute()")
    end try
    return
end unmute

on isAnAd()
    local currentTrackPopularity, currentTrackDuration
    set currentTrackPopularity to null
    set currentTrackDuration to null
    # Nesting "try" blocks is the only way to handle multiple errors in AppleScript
    try
        try
            try
                tell application "Spotify"
                    set currentTrackPopularity to popularity of current track
                    set currentTrackDuration to duration of current track
                end tell
            on error number -1728
                # Ignoring "can't get current track" error
            end try
        on error number -609
            # Ignoring the "invalid connection errors"
        end try
    on error errorMessage number errorNumber
        my log_error(errorNumber, errorMessage, "isAnAd()")
        return false
    end try
    if ((currentTrackPopularity ≠ null and currentTrackDuration ≠ null) and (currentTrackPopularity = 0 and currentTrackDuration ≤ 40)) then
        return true
    else
        return false
    end if
end isAnAd

on isPlaying()
    local playerState
    set playerState to null
    # Nesting "try" blocks is the only way to handle multiple errors in AppleScript
    try
        try
            tell application "Spotify"
                set playerState to player state
            end tell
        on error -609
            # Ignoring the "invalid connection" errors
        end try
    on error errorMessage number errorNumber
        my log_error(errorNumber, errorMessage, "isRunning()")
        return false
    end try
    if (playerState ≠ null and playerState = «constant ****kPSP») then
        return true
    else
        return false
    end if
end isPlaying

on isRunning()
    local spotifyProcesses
    # Nesting "try" blocks is the only way to handle multiple errors in AppleScript
    try
        try
            tell application "System Events"
                set spotifyProcesses to (count of (every process whose name is "Spotify"))
            end tell
        on error number -609
            # Ignoring the "invalid connection" errors
        end try
    on error errorMessage number errorNumber
        my log_error(errorNumber, errorMessage, "isRunning()")
        return false
    end try
    if spotifyProcesses is 1 then
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
        my log_error(errorNumber, errorMessage, "addToLoginItems()")
        return
    end try
end addToLoginItems

on isTheFirstRun()
    local isPrefFileExists, prefFilePath
    set prefFilePath to "~/Library/Preferences/com.ArtemGordinsky.Spotifree"
    try
        tell application "System Events"
            if exists file prefFilePath then
                set isPrefFileExists to true
            else
                set isPrefFileExists to false
            end if
        end tell
    on error errorMessage number errorNumber
        my log_error(errorNumber, errorMessage, "isTheFirstRun()")
        return true
    end try
    # "not" works like a bang sign here
    return not isPrefFileExists
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
        my log_error(errorNumber, errorMessage, "isInLoginItems()")
        return false
    end try
end isInLoginItems

on log_error(error_number, error_message, diag_message)
    local content
    if (debug = true) then
        set content to (return & "" & ¬
            return & my dateAndTime() & return & "Error number: " & error_number ¬
            & return & "Error message: " & error_message & return & ¬
            "Diagnostic message: " & diag_message & return ¬
            & "" & return)
        set log_file to (((path to desktop folder) as text) & "Spotifree_log.txt")
        my write_to_file(content, log_file, true)
    end if
end log_error

on write_to_file(this_data, target_file, append_data) -- (string, file path as string, boolean)
    try
        set the target_file to the target_file as text
        set the open_target_file to ¬
            open for access file target_file with write permission
        if append_data is false then ¬
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