import AppKit
import ScriptingBridge

@objc public protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> AnyObject!
}

@objc public protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    var delegate: SBApplicationDelegate! { get set }
}

// MARK: SpotifyEPlS
@objc public enum SpotifyEPlS : AEKeyword {
    case Stopped = 0x6b505353 /* 'kPSS' */
    case Playing = 0x6b505350 /* 'kPSP' */
    case Paused = 0x6b505370 /* 'kPSp' */
}

// MARK: SpotifyApplication
@objc public protocol SpotifyApplication: SBApplicationProtocol {
    optional var currentTrack: SpotifyTrack { get } // The current playing track.
    optional var soundVolume: Int { get } // The sound output volume (0 = minimum, 100 = maximum)
    optional var playerState: SpotifyEPlS { get } // Is Spotify stopped, paused, or playing?
    optional var playerPosition: Double { get } // The player’s position within the currently playing track in seconds.
    optional var repeatingEnabled: Bool { get } // Is repeating enabled in the current playback context?
    optional var repeating: Bool { get } // Is repeating on or off?
    optional var shufflingEnabled: Bool { get } // Is shuffling enabled in the current playback context?
    optional var shuffling: Bool { get } // Is shuffling on or off?
    optional func nextTrack() // Skip to the next track.
    optional func previousTrack() // Skip to the previous track.
    optional func playpause() // Toggle play/pause.
    optional func pause() // Pause playback.
    optional func play() // Resume playback.
    optional func playTrack(x: String!, inContext: String!) // Start playback of a track in the given context.
    optional func setSoundVolume(soundVolume: Int) // The sound output volume (0 = minimum, 100 = maximum)
    optional func setPlayerPosition(playerPosition: Double) // The player’s position within the currently playing track in seconds.
    optional func setRepeating(repeating: Bool) // Is repeating on or off?
    optional func setShuffling(shuffling: Bool) // Is shuffling on or off?
    optional var name: String { get } // The name of the application.
    optional var frontmost: Bool { get } // Is this the frontmost (active) application?
    optional var version: String { get } // The version of the application.
}
extension SBApplication: SpotifyApplication {}

// MARK: SpotifyTrack
@objc public protocol SpotifyTrack: SBObjectProtocol {
    optional var artist: String { get } // The artist of the track.
    optional var album: String { get } // The album of the track.
    optional var discNumber: Int { get } // The disc number of the track.
    optional var duration: Int { get } // The length of the track in seconds.
    optional var playedCount: Int { get } // The number of times this track has been played.
    optional var trackNumber: Int { get } // The index of the track in its album.
    optional var starred: Bool { get } // Is the track starred?
    optional var popularity: Int { get } // How popular is this track? 0-100
    optional func id() -> String // The ID of the item.
    optional var name: String { get } // The name of the track.
    optional var artwork: NSImage { get } // The track's album cover.
    optional var albumArtist: String { get } // That album artist of the track.
    optional var spotifyUrl: String { get } // The URL of the track.
    optional func setSpotifyUrl(spotifyUrl: String!) // The URL of the track.
}
extension SBObject: SpotifyTrack {}

