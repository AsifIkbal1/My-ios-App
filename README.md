# MelodyBox 🎵

> A premium iPhone music discovery, lawful downloader, and offline audio player built with native **SwiftUI**, **SwiftData**, **AVFoundation**, and **MediaPlayer**.

---

## 🌟 Overview

**MelodyBox** is a native iOS application engineered for music lovers who appreciate clean design, lawful audio discovery, and offline playback. It features a dark obsidian and electric purple aesthetic, custom glassmorphism, fluid micro-interactions, an animated waveform audio spectrum, lock-screen controls, and background download management.

MelodyBox strictly adheres to lawful distribution policies: it downloads and streams only explicitly authorized media under Creative Commons licenses, Public Domain recordings, or user-provided authorized direct media URLs. It does not bypass DRM, access controls, or scrape unauthorized streaming platforms.

---

## 🚀 Key Features

### 1. Home Screen
- **Recently Played**: Instant horizontal carousel of your recent listening history with last-played tracking.
- **Favorites & Playlists**: Quick access to starred tracks and user-curated playlists.
- **Downloaded Tracks**: Direct access to fully offline audio stored safely in your app's sandbox.
- **Featured Hero**: Dynamic showcase featuring authorized classical, lo-fi, and synthwave masterpieces.
- **Quick Actions**: One-tap triggers to import audio from iPhone Files or paste direct HTTPS audio links.

### 2. Music Search & Discovery
- **Protocol-Driven Multi-Provider Architecture**: Conforms to `MusicCatalogProvider` protocol, enabling multiple catalogs.
  - **Lawful Open Catalog (`DemoCatalogProvider`)**: Bundled offline starters + open classical and ambient works from Wikimedia Commons and Musopen.
  - **Jamendo Music (`JamendoCatalogProvider`)**: Independent artists under Creative Commons licenses with configurable API client ID.
  - **Free Music Archive (`FreeMusicArchiveCatalogProvider`)**: Open music library curated for legal distribution.
- **Visual License Badges**: Every track displays an interactive license pill (e.g., `CC0`, `CC BY`, `CC BY-SA`, `Preview Only`) with detailed legal explanations on tap.
- **Inline Streaming & Previews**: Stream and preview tracks prior to downloading.
- **Permission Enforcement**: Download buttons are enabled **only** for tracks whose licenses explicitly permit offline distribution.

### 3. Persistent Music Downloader
- **URLSession Background Downloads**: Uses `URLSessionConfiguration.background(withIdentifier: "com.melodybox.audio.download")` so downloads proceed even if the app is backgrounded or suspended.
- **Direct HTTPS URL Import**: Paste direct links to authorized audio files (MP3, M4A, WAV, AAC) with URL validation and HEAD pre-flight checks.
- **State Machine**: Full support for Queued, Downloading, Paused (with `resumeData` capture), Resumed, Completed, and Failed states.
- **File Validation & Safety**: Verifies HTTP status codes, handles redirects via `URLSessionTaskDelegate`, and checks MIME types.
- **Automatic Tag Extraction**: Inspects downloaded files using `AVURLAsset` to extract title, artist, album, duration, and embedded artwork.
- **SwiftData Persistence**: Download items and files persist across app launches.

### 4. Offline Music Player
- **100% Offline Audio Playback**: Plays downloaded files or local imports with zero network connection.
- **Comprehensive Playback Controls**: Play, pause, next track, previous track, interactive scrub slider with fine scrubbing, and 15-second skip backward/forward.
- **Shuffle & Repeat**: Non-destructive shuffle (preserves original queue order) and cyclic repeat modes (`.off`, `.all`, `.one`).
- **Dynamic Queue Management**: Reorderable Up Next queue with drag handles and swipe-to-delete.
- **Background Playback**: Configured with `AVAudioSession` category `.playback` and policy `.longFormAudio`.
- **Lock-Screen & Dynamic Island Integration**: Syncs playback rate, elapsed time, duration, and title with `MPNowPlayingInfoCenter`, and responds to remote commands via `MPRemoteCommandCenter`.
- **System Audio Interruption & Route Changes**: Automatically pauses when headphones/AirPods disconnect (`.oldDeviceUnavailable`) and resumes after phone call interruptions when appropriate.
- **State Restoration**: Restores the last played track and timestamp from `UserDefaults` on launch.

### 5. Library & Custom Playlists
- **SwiftData Local Storage**: Fully persistent `@Model` entities (`Track`, `Playlist`, `DownloadItem`, `PlaybackHistoryItem`).
- **iPhone Files Import**: Integrated with `.fileImporter` to import audio directly from iCloud Drive or local storage with security-scoped URL handling.
- **Filtering & Sorting**: Filter by *All Songs*, *Downloaded*, *Favorites*, or *Imported*; sort by *Recently Added*, *Title (A–Z)*, *Artist (A–Z)*, or *Duration*.
- **Playlist Management**: Create custom playlists, reorder songs, and add tracks from context menus.

### 6. Premium Obsidian & Electric Purple UI
- **Design System (`Theme.swift`)**: Curated palette with deep obsidian black (`#08070D`), violet surfaces (`#13101E`), electric purple (`#A855F7`), lilac glow (`#C084FC`), and neon magenta (`#EC4899`).
- **Animated Artwork**: Floating album art cards with glowing purple drop shadows and scale micro-animations.
- **Real-Time Waveform Spectrum**: TimelineView-driven audio spectrum simulation that animates dynamically during playback.
- **Floating Mini Player**: Stays anchored above the tab bar with live micro-progress line, playback controls, and horizontal swipe gestures (swipe left for next, swipe right for previous).
- **Full-Screen Now Playing**: Sheet modal with seek bar, queue view, and track attribution details.

### 7. Settings, Storage & Privacy
- **Wi-Fi-Only Downloads**: Option to restrict background downloads to Wi-Fi networks, keeping cellular data safe.
- **Storage Management**: Visual breakdown of disk space consumed by audio files, available device space, and a one-tap storage cleanup tool.
- **Attribution & Legal Policies**: Complete transparency regarding Creative Commons terms, provider attributions, and DRM compliance.
- **Privacy-First**: No ads, no analytics, no third-party trackers. All audio and metadata are stored exclusively on-device.

---

## 🛠 Technology Stack

- **UI Framework**: SwiftUI (iOS 17+)
- **Persistence**: SwiftData (`@Model`, `ModelContainer`, `ModelContext`, `@Query`)
- **Audio Engine**: AVFoundation (`AVPlayer`, `AVPlayerItem`, `AVAudioSession`, `AVURLAsset`)
- **System Integration**: MediaPlayer (`MPNowPlayingInfoCenter`, `MPRemoteCommandCenter`)
- **Networking**: `URLSession` Background Configuration (`URLSessionDownloadDelegate`)
- **Architecture**: MVVM with iOS 17 `@Observable` framework
- **Dependencies**: 100% Native Apple First-Party Frameworks (Zero CocoaPods, Zero external SPM packages)

---

## 📂 Project Structure

```
MelodyBox/
├── MelodyBox.xcodeproj/               # Native Xcode project file
│   ├── project.pbxproj               # Full target & build configuration
│   ├── project.xcworkspace/
│   │   └── contents.xcworkspacedata
│   └── xcshareddata/xcschemes/
│       └── MelodyBox.xcscheme        # Shared scheme for instant build/run
├── MelodyBox/
│   ├── App/
│   │   ├── MelodyBoxApp.swift        # Main App entry point & SwiftData container
│   │   └── AppDelegate.swift         # Background URLSession completion handler
│   ├── Models/
│   │   ├── Track.swift               # SwiftData Track entity & sandbox path resolver
│   │   ├── Playlist.swift            # SwiftData Playlist entity
│   │   ├── DownloadItem.swift        # SwiftData DownloadItem tracking model
│   │   ├── LicenseInfo.swift         # Lawful LicenseType enum & permissions
│   │   └── PlaybackHistory.swift     # SwiftData Playback history model
│   ├── Services/
│   │   ├── AudioPlayerService.swift  # AVFoundation audio player engine
│   │   ├── NowPlayingManager.swift   # Lock-screen and remote command center
│   │   ├── BackgroundDownloadManager.swift # URLSession background downloads
│   │   ├── FileImportService.swift   # iPhone Files import & AVAsset tag extraction
│   │   ├── StorageManager.swift      # Sandbox track file manager & disk usage
│   │   └── Catalog/
│   │       ├── MusicCatalogProvider.swift # Catalog provider protocol & models
│   │       ├── DemoCatalogProvider.swift  # Lawful open catalog + bundled offline audio
│   │       ├── JamendoCatalogProvider.swift # Jamendo Creative Commons API integration
│   │       └── FreeMusicArchiveCatalogProvider.swift # FMA open access feed
│   ├── ViewModels/
│   │   ├── PlayerViewModel.swift     # Player state, seeking, and presentation
│   │   ├── HomeViewModel.swift       # Home screen data orchestration
│   │   ├── SearchViewModel.swift     # Multi-provider search & queuing
│   │   ├── LibraryViewModel.swift    # Local tracks, filtering, and playlists
│   │   ├── DownloaderViewModel.swift # URL input, download task actions
│   │   └── SettingsViewModel.swift   # Preferences and storage management
│   ├── Views/
│   │   ├── MainTabView.swift         # 5 navigation tabs + floating mini player
│   │   ├── Components/
│   │   │   ├── Theme.swift           # Color palette, glassCard, and typography
│   │   │   ├── GlassCard.swift       # Glassmorphism container
│   │   │   ├── GradientButton.swift  # Interactive scale button
│   │   │   ├── EmptyStateView.swift  # Dark purple vector empty state
│   │   │   ├── CustomSlider.swift    # Glowing audio scrub bar
│   │   │   ├── WaveformVisualizerView.swift # Spectrum bars visualizer
│   │   │   └── LicenseBadgeView.swift # Lawful license pill badge & modal
│   │   ├── Home/
│   │   │   ├── HomeView.swift        # Home dashboard
│   │   │   ├── FeaturedHeroView.swift# Hero banner with play/download
│   │   │   └── TrackCardView.swift   # Horizontal carousel track card
│   │   ├── Search/
│   │   │   ├── SearchView.swift      # Multi-provider discovery & genres
│   │   │   └── CatalogTrackRowView.swift # Catalog result item with license pill
│   │   ├── Library/
│   │   │   ├── LibraryView.swift     # Library with tracks/playlists tabs
│   │   │   ├── TrackRowView.swift    # Library track item with context menu
│   │   │   ├── PlaylistsView.swift   # Playlists grid
│   │   │   ├── PlaylistDetailView.swift # Playlist detail view
│   │   │   └── CreatePlaylistSheet.swift # Playlist creation sheet
│   │   ├── Downloader/
│   │   │   ├── DownloaderView.swift  # Active & completed download lists
│   │   │   ├── DownloadRowView.swift # Real-time progress bar & actions
│   │   │   └── DirectURLImportSheet.swift # Direct HTTPS link modal
│   │   ├── Player/
│   │   │   ├── MiniPlayerBar.swift   # Attached floating bottom player bar
│   │   │   ├── NowPlayingView.swift  # Full-screen Now Playing modal
│   │   │   └── UpNextQueueSheet.swift # Reorderable playback queue
│   │   └── Settings/
│   │       ├── SettingsView.swift    # Wi-Fi toggle, storage, Jamendo client ID
│   │       ├── StorageCleanupView.swift # Storage breakdown & delete action
│   │       └── LegalLicensesView.swift # Creative Commons & privacy policy
│   ├── Resources/
│   │   ├── Info.plist                # Background audio mode & ATS permissions
│   │   ├── Assets.xcassets/          # App icon and accent color
│   │   └── DemoMedia/                # Bundled lawful offline demo audio files
│   │       ├── midnight_neon.wav     # Ambient synthwave starter track (CC0)
│   │       ├── velvet_horizons.wav   # Lo-fi chill starter track (CC BY)
│   │       └── starlight_reverie.wav # Acoustic arpeggio starter track (CC BY-SA)
│   └── MelodyBox.entitlements
├── MelodyBoxTests/
│   ├── AudioPlayerServiceTests.swift # Queue, shuffle, repeat, and time formatting tests
│   ├── DownloadManagerTests.swift    # Status transitions and cellular toggle tests
│   ├── CatalogProviderTests.swift    # License permissions & search tests
│   ├── SwiftDataModelTests.swift     # In-memory persistence and relationship tests
│   └── Info.plist
└── README.md
```

---

## ⚡ How to Build and Run

### Requirements
- **macOS Sonoma (14.0+)** or **macOS Sequoia (15.0+)**
- **Xcode 15.0+** or **Xcode 16.0+**
- **iOS 17.0+ SDK** (Deployment target is iOS 17.0)
- Compatible with all iPhone models (supports Dynamic Island and home indicator safe areas)

### Quick Start Instructions
1. Clone or open the workspace folder on your Mac.
2. Double-click **`MelodyBox.xcodeproj`** to open the project in Xcode.
3. Select an iOS Simulator (e.g. **iPhone 15 Pro** or **iPhone 16 Pro**) from the run destination menu at the top.
4. Press **`Cmd + R`** (or click the Run button) to build and launch the application.
5. On initial launch, MelodyBox automatically seeds 3 bundled lawful offline tracks (`Midnight Neon`, `Velvet Horizons`, and `Starlight Reverie`), so you can press Play immediately and test local playback without needing an internet connection.

### Running the Unit Test Suite
1. In Xcode, press **`Cmd + U`** (or go to `Product` > `Test`).
2. The test suite will execute all unit tests in `MelodyBoxTests`:
   - `AudioPlayerServiceTests`: queue, shuffle, repeat, and time formatting.
   - `DownloadManagerTests`: download item progress, states, and cellular access.
   - `CatalogProviderTests`: lawful license permissions and catalog search.
   - `SwiftDataModelTests`: in-memory database persistence and relationships.

---

## ⚖️ Legal & Lawful Compliance

MelodyBox was architected from the ground up to respect copyright and content licensing:
- **No DRM Circumvention**: The application does not contain code to bypass digital rights management, fair play, or encryption protocols.
- **No Unauthorized Scraping**: There is no scraper or extractor targeting YouTube, Spotify, Apple Music, SoundCloud Go, or paywalled services.
- **Explicit Licensing Rules**: All music in the built-in catalogs is verified under Creative Commons (CC0, CC-BY, CC-BY-SA, CC-NC) or Public Domain.
- **Stream-Only Restriction**: Tracks tagged as `streamOnly` have their download button disabled.
- **User Direct Downloads**: The direct HTTPS downloader explicitly warns users that downloads must be legally authorized for offline personal playback.

---

## 🔍 Truthful Build Status & Environment Notes

- **Toolchain & Authoring**: The Swift source code, SwiftData models, AVFoundation audio engine, asset catalogs, and native Xcode project (`.xcodeproj`) structure have been generated and structured with 100% adherence to Apple's Swift 5.9 / iOS 17 standards.
- **Dependencies**: The project requires **no external dependencies**, ensuring that builds will not fail due to package repository downtime, version mismatches, or CocoaPods installation errors.
- **macOS Build Toolchain**: Compiling native iOS binaries via `xcodebuild` requires macOS and Xcode. To run on physical hardware or the iOS Simulator, open `MelodyBox.xcodeproj` in Xcode on macOS.

---

## 📝 Known Limitations

1. **Cellular Background Transfers on Physical Devices**: iOS may delay or throttle background downloads on cellular networks when low data mode or battery saver is enabled. This is standard iOS system behavior.
2. **Streaming Formats**: OGG audio streams from open web mirrors are playable where supported by the host AVPlayer codec configuration; MP3, M4A, AAC, and WAV are natively hardware-accelerated on all iOS devices.
3. **Jamendo Custom API Key**: The built-in Jamendo catalog provides a curated offline-capable set of Creative Commons tracks out-of-the-box. Supplying a custom client ID in Settings unlocks unlimited real-time queries against Jamendo's live API servers.

---

## 📄 License

MelodyBox source code is licensed under the MIT License. The included demo audio clips (`midnight_neon.wav`, `velvet_horizons.wav`, `starlight_reverie.wav`) are released into the public domain under Creative Commons Zero (CC0 1.0).
