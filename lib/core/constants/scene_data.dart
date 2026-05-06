import 'package:flutter/material.dart';

enum SceneId {
  classicHearth,
  midnightForest,
  himalayanCabin,
  coastalBreeze,
  zenGarden,
  deepSpace,
  rainyCafe,
  autumnBreeze,
  crystalCave,
  cherryBlossom,
  underwaterReef,
  desertNight
}

class AudioTrack {
  final String id;
  final String name;
  final String emoji;
  final String? assetPath;
  final String? networkUrl;
  double volume;

  AudioTrack({
    required this.id,
    required this.name,
    required this.emoji,
    this.assetPath,
    this.networkUrl,
    this.volume = 0.0,
  });

  AudioTrack copyWith({double? volume}) {
    return AudioTrack(
      id: id,
      name: name,
      emoji: emoji,
      assetPath: assetPath,
      networkUrl: networkUrl,
      volume: volume ?? this.volume,
    );
  }
}

class SceneDefinition {
  final SceneId id;
  final String name;
  final String tagline;
  final String emoji;
  final Color primaryColor;
  final Color accentColor;
  final Gradient gradient;
  final String? videoUrl;
  final String? imageAsset;
  final List<AudioTrack> availableAudioTracks;
  final bool isPremium;

  const SceneDefinition({
    required this.id,
    required this.name,
    required this.tagline,
    required this.emoji,
    required this.primaryColor,
    required this.accentColor,
    required this.gradient,
    this.videoUrl,
    this.imageAsset,
    required this.availableAudioTracks,
    this.isPremium = false,
  });
}

class SceneData {
  static List<AudioTrack> hearth() => [
        AudioTrack(
          id: 'fire_crackle',
          name: 'Crackling Fire',
          emoji: '🔥',
          networkUrl:
              'https://soundbible.com/grab.php?id=1543&type=mp3',
          volume: 0.8,
        ),
        AudioTrack(
          id: 'wind_hearth',
          name: 'Gentle Wind',
          emoji: '🌬️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.0,
        ),
        AudioTrack(
          id: 'rain_light',
          name: 'Light Rain',
          emoji: '🌧️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.0,
        ),
      ];

  static List<AudioTrack> forest() => [
        AudioTrack(
          id: 'rain_heavy',
          name: 'Heavy Rain',
          emoji: '🌧️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.7,
        ),
        AudioTrack(
          id: 'thunder_distant',
          name: 'Thunder',
          emoji: '⛈️',
          networkUrl: 'https://soundbible.com/grab.php?id=2015&type=mp3',
          volume: 0.4,
        ),
        AudioTrack(
          id: 'leaves_rustle',
          name: 'Rustling Leaves',
          emoji: '🍃',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.5,
        ),
        AudioTrack(
          id: 'crickets',
          name: 'Night Crickets',
          emoji: '🦗',
          networkUrl: 'https://soundbible.com/grab.php?id=1253&type=mp3',
          volume: 0.0,
        ),
      ];

  static List<AudioTrack> cabin() => [
        AudioTrack(
          id: 'blizzard',
          name: 'Blizzard',
          emoji: '❄️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.5,
        ),
        AudioTrack(
          id: 'fire_soft',
          name: 'Soft Fireplace',
          emoji: '🔥',
          networkUrl:
              'https://soundbible.com/grab.php?id=1543&type=mp3',
          volume: 0.6,
        ),
        AudioTrack(
          id: 'wind_howl',
          name: 'Howling Wind',
          emoji: '🌪️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.3,
        ),
        AudioTrack(
          id: 'clock_tick',
          name: 'Clock Ticking',
          emoji: '⏰',
          networkUrl:
              'https://soundbible.com/grab.php?id=1418&type=mp3',
          volume: 0.0,
        ),
      ];

  static List<AudioTrack> coastal() => [
        AudioTrack(
          id: 'waves',
          name: 'Ocean Waves',
          emoji: '🌊',
          networkUrl: 'https://soundbible.com/grab.php?id=1936&type=mp3',
          volume: 0.8,
        ),
        AudioTrack(
          id: 'seagulls',
          name: 'Seagulls',
          emoji: '🐦',
          networkUrl: 'https://soundbible.com/grab.php?id=1477&type=mp3',
          volume: 0.3,
        ),
        AudioTrack(
          id: 'coastal_wind',
          name: 'Coastal Breeze',
          emoji: '🌬️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.2,
        ),
        AudioTrack(
          id: 'rain_coastal',
          name: 'Rain',
          emoji: '🌧️',
          networkUrl: 'https://soundbible.com/grab.php?id=2011&type=mp3',
          volume: 0.0,
        ),
      ];

  static List<SceneDefinition> get all => [
        const SceneDefinition(
          id: SceneId.classicHearth,
          name: 'Classic Hearth',
          tagline: 'Crackling oak wood, timeless warmth',
          emoji: '🔥',
          primaryColor: Color(0xFFD32F2F), // Muted red for a more premium look
          accentColor: Color(0xFFFFB300), // Warmer gold
          gradient: LinearGradient(
            colors: [
              Color(0xFF2B0A0A),
              Color(0xFF5E1717),
              Color(0xFF902424)
            ], // Deep crimson gradient
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          videoUrl:
              'https://cdn.coverr.co/videos/coverr-fireplace-1580/1080p.mp4',
          imageAsset: 'assets/images/fireplace.png',
          availableAudioTracks: [],
          isPremium: false,
        ),
        const SceneDefinition(
          id: SceneId.midnightForest,
          name: 'Midnight Forest',
          tagline: 'Soft rain on leaves, distant thunder',
          emoji: '🌲',
          primaryColor: Color(0xFF2D7D46),
          accentColor: Color(0xFF7DE8A0),
          gradient: LinearGradient(
            colors: [Color(0xFF001A0D), Color(0xFF003D1F), Color(0xFF006633)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          videoUrl:
              'https://cdn.coverr.co/videos/coverr-rain-in-the-forest-1580/1080p.mp4',
          imageAsset: 'assets/images/forest1.png',
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.himalayanCabin,
          name: 'Himalayan Cabin',
          tagline: 'Snowfall outside, warm glow within',
          emoji: '🏔️',
          primaryColor: Color(0xFF5B8AC4),
          accentColor: Color(0xFFB8D4F5),
          gradient: LinearGradient(
            colors: [Color(0xFF001525), Color(0xFF002040), Color(0xFF003366)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          videoUrl:
              'https://cdn.coverr.co/videos/coverr-winter-snow-landscape-1580/1080p.mp4',
          imageAsset: 'assets/images/himalayan.jpeg',
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.coastalBreeze,
          name: 'Coastal Breeze',
          tagline: 'Slow-motion waves, salty serenity',
          emoji: '🌊',
          primaryColor: Color(0xFF1A8FBE),
          accentColor: Color(0xFF7CE0F9),
          gradient: LinearGradient(
            colors: [Color(0xFF001A26), Color(0xFF003347), Color(0xFF005570)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          videoUrl:
              'https://cdn.coverr.co/videos/coverr-ocean-waves-crashing-1580/1080p.mp4',
          imageAsset: 'assets/images/costal breeze.png',
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.zenGarden,
          name: 'Zen Garden',
          tagline: 'Flowing water, bamboo chimes',
          emoji: '🍃',
          primaryColor: Color(0xFF4CAF50),
          accentColor: Color(0xFFA5D6A7),
          gradient: LinearGradient(
            colors: [Color(0xFF0A1A10), Color(0xFF1B3320), Color(0xFF2E4D34)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.deepSpace,
          name: 'Deep Space',
          tagline: 'Ambient hum, stellar wind',
          emoji: '🌌',
          primaryColor: Color(0xFF673AB7),
          accentColor: Color(0xFFBCAAA4),
          gradient: LinearGradient(
            colors: [Color(0xFF05001A), Color(0xFF19004D), Color(0xFF330080)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.rainyCafe,
          name: 'Rainy Cafe',
          tagline: 'Muffled chatter, rain on glass',
          emoji: '☕',
          primaryColor: Color(0xFF795548),
          accentColor: Color(0xFFD7CCC8),
          gradient: LinearGradient(
            colors: [Color(0xFF1E100A), Color(0xFF381C0F), Color(0xFF5C3317)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: false,
        ),
        const SceneDefinition(
          id: SceneId.autumnBreeze,
          name: 'Autumn Breeze',
          tagline: 'Swirling leaves, crisp air',
          emoji: '🍁',
          primaryColor: Color(0xFFE64A19),
          accentColor: Color(0xFFFFB74D),
          gradient: LinearGradient(
            colors: [Color(0xFF3E1303), Color(0xFF7A2A08), Color(0xFFC44D12)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.crystalCave,
          name: 'Crystal Cave',
          tagline: 'Echoing drops, glowing gems',
          emoji: '💎',
          primaryColor: Color(0xFF0097A7),
          accentColor: Color(0xFF80DEEA),
          gradient: LinearGradient(
            colors: [Color(0xFF001F24), Color(0xFF004D54), Color(0xFF00838F)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.cherryBlossom,
          name: 'Cherry Blossom',
          tagline: 'Falling petals, spring breeze',
          emoji: '🌸',
          primaryColor: Color(0xFFD81B60),
          accentColor: Color(0xFFF48FB1),
          gradient: LinearGradient(
            colors: [Color(0xFF42041D), Color(0xFF880E4F), Color(0xFFC2185B)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: false,
        ),
        const SceneDefinition(
          id: SceneId.underwaterReef,
          name: 'Underwater Reef',
          tagline: 'Muffled bubbles, ambient sea',
          emoji: '🐠',
          primaryColor: Color(0xFF0277BD),
          accentColor: Color(0xFF81D4FA),
          gradient: LinearGradient(
            colors: [Color(0xFF001B2E), Color(0xFF01436F), Color(0xFF0261A1)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: true,
        ),
        const SceneDefinition(
          id: SceneId.desertNight,
          name: 'Desert Night',
          tagline: 'Cool winds, quiet dunes',
          emoji: '🏜️',
          primaryColor: Color(0xFFF57C00),
          accentColor: Color(0xFFFFCC80),
          gradient: LinearGradient(
            colors: [Color(0xFF261200), Color(0xFF5A2A00), Color(0xFF9E4800)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          availableAudioTracks: [],
          isPremium: true,
        ),
      ];
}
