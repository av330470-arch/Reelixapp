import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ==========================================
// SUPABASE & CONFIGURATION CONSTANTS
// ==========================================
const String kSupabaseUrl = 'https://aryqhfwmrgoafveblmyq.supabase.co';
const String kSupabaseAnonKey = 'sb_publishable_JJgo4KjhEZz99eSpllIBwA_b6D-IoOa';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.amberAccent, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Instagram Reels Engine',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exceptionAsString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    try {
      await Supabase.initialize(
        url: kSupabaseUrl,
        anonKey: kSupabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase Note: $e');
    }

    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob Note: $e');
    }

    runApp(const InstagramReelsApp());
  }, (error, stackTrace) {
    debugPrint('Uncaught Error: $error');
  });
}

// ==========================================
// LOCALIZATION & LANGUAGE ENGINE
// ==========================================
enum AppLanguage { english, hindi, hinglish, spanish }

class AppTranslations {
  static final Map<AppLanguage, Map<String, String>> _strings = {
    AppLanguage.english: {
      'reels': 'Reels',
      'explore': 'Explore',
      'profile': 'Profile',
      'dm_chat': 'Direct Messages',
      'settings': 'Settings',
      'language': 'Language / भाषा बदलें',
      'creator_dashboard': 'Creator Dashboard',
      'monetization': 'AdMob Earnings',
      'followers': 'Followers',
      'likes': 'Likes',
      'comments': 'Comments',
    },
    AppLanguage.hindi: {
      'reels': 'रील्स (Reels)',
      'explore': 'खोजें',
      'profile': 'प्रोफाइल',
      'dm_chat': 'मैसेज (Chat)',
      'settings': 'सेटिंग्स',
      'language': 'भाषा बदलें',
      'creator_dashboard': 'क्रिएटर डैशबोर्ड',
      'monetization': 'AdMob कमाई',
      'followers': 'फॉलोअर्स',
      'likes': 'लाइक्स',
      'comments': 'कमेंट्स',
    },
    AppLanguage.hinglish: {
      'reels': 'Reels Feed',
      'explore': 'Explore Videos',
      'profile': 'Meri Profile',
      'dm_chat': 'Messages',
      'settings': 'Settings',
      'language': 'Bhasha Badlein',
      'creator_dashboard': 'Creator Dashboard',
      'monetization': 'Total Earnings',
      'followers': 'Followers',
      'likes': 'Likes',
      'comments': 'Comments',
    },
    AppLanguage.spanish: {
      'reels': 'Reels',
      'explore': 'Explorar',
      'profile': 'Perfil',
      'dm_chat': 'Mensajes',
      'settings': 'Ajustes',
      'language': 'Idioma',
      'creator_dashboard': 'Panel Creador',
      'monetization': 'Ganancias',
      'followers': 'Seguidores',
      'likes': 'Me gusta',
      'comments': 'Comentarios',
    }
  };

  static String getText(AppLanguage lang, String key) {
    return _strings[lang]?[key] ?? _strings[AppLanguage.english]![key] ?? key;
  }
}

class LanguageNotifier extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  String t(String key) => AppTranslations.getText(_currentLanguage, key);
}

final LanguageNotifier appLanguageNotifier = LanguageNotifier();

// ==========================================
// DATA MODELS
// ==========================================
class ReelModel {
  final String id;
  final String videoUrl;
  final String username;
  final String userAvatar;
  final String caption;
  final String musicTrack;
  int likesCount;
  int commentsCount;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.userAvatar,
    required this.caption,
    required this.musicTrack,
    required this.likesCount,
    required this.commentsCount,
  });
}

final List<ReelModel> kSampleReels = [
  ReelModel(
    id: 'reel-1',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-tokyo-city-street-traffic-at-night-41544-large.mp4',
    username: 'neon_dreams',
    userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    caption: 'Tokyo Cyberpunk Lights 🌃✨ #Tokyo #Vibes',
    musicTrack: 'Tokyo Synthwave Track',
    likesCount: 19840,
    commentsCount: 312,
  ),
  ReelModel(
    id: 'reel-2',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-beach-with-clear-blue-water-41551-large.mp4',
    username: 'ocean_breeze',
    userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    caption: 'Maldives Paradise 🏝️ Waters',
    musicTrack: 'Tropical Summer Beats',
    likesCount: 14200,
    commentsCount: 195,
  ),
];

// ==========================================
// APP ROOT WIDGET
// ==========================================
class InstagramReelsApp extends StatelessWidget {
  const InstagramReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLanguageNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Instagram Reels',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              surface: Colors.black,
            ),
          ),
          home: const ReelsMainShell(),
        );
      },
    );
  }
}

// ==========================================
// MAIN SHELL (NAV BAR)
// ==========================================
class ReelsMainShell extends StatefulWidget {
  const ReelsMainShell({super.key});

  @override
  State<ReelsMainShell> createState() => _ReelsMainShellState();
}

class _ReelsMainShellState extends State<ReelsMainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ReelsFeedPage(),
    const DirectMessagesPage(),
    const CreatorDashboardPage(),
    const ProfileAndSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie_creation_outlined),
            activeIcon: const Icon(Icons.movie_creation),
            label: t('reels'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble),
            label: t('dm_chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monetization_on_outlined),
            activeIcon: const Icon(Icons.monetization_on),
            label: t('creator_dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: t('profile'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. REELS FEED PAGE
// ==========================================
class ReelsFeedPage extends StatefulWidget {
  const ReelsFeedPage({super.key});

  @override
  State<ReelsFeedPage> createState() => _ReelsFeedPageState();
}

class _ReelsFeedPageState extends State<ReelsFeedPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: kSampleReels.length,
        itemBuilder: (context, index) {
          return SingleReelPlayer(reel: kSampleReels[index]);
        },
      ),
    );
  }
}

class SingleReelPlayer extends StatefulWidget {
  final ReelModel reel;
  const SingleReelPlayer({super.key, required this.reel});

  @override
  State<SingleReelPlayer> createState() => _SingleReelPlayerState();
}

class _SingleReelPlayerState extends State<SingleReelPlayer> {
  late VideoPlayerController _controller;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.amberAccent)),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
          ),
        ),
        Positioned(
          left: 16,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.reel.userAvatar)),
                  const SizedBox(width: 8),
                  Text(
                    '@${widget.reel.username}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.reel.caption, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(widget.reel.musicTrack, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 40,
          child: Column(
            children: [
              IconButton(
                icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white, size: 32),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _isLiked ? widget.reel.likesCount++ : widget.reel.likesCount--;
                  });
                },
              ),
              Text('${widget.reel.likesCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 16),
              const Icon(Icons.comment, color: Colors.white, size: 30),
              Text('${widget.reel.commentsCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 16),
              const Icon(Icons.send, color: Colors.white, size: 28),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. CHAT & CALLING PAGE
// ==========================================
class DirectMessagesPage extends StatelessWidget {
  const DirectMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
            ),
            title: const Text('neon_dreams', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Hey! Loved your recent video reel 🔥', style: TextStyle(color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.greenAccent),
                  onPressed: () => _startCall(context, 'Voice Call'),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.amberAccent),
                  onPressed: () => _startCall(context, 'Video Call'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startCall(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$type with neon_dreams', style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              const Text('Connecting...', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.call_end, color: Colors.white),
                label: const Text('End Call', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 3. CREATOR DASHBOARD PAGE
// ==========================================
class CreatorDashboardPage extends StatelessWidget {
  const CreatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('Estimated AdMob Revenue', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('\$1,240.50', style: TextStyle(color: Colors.amberAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payout request sent to Admin!')),
                );
              },
              child: const Text('Withdraw Payout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PROFILE & LANGUAGE SETTINGS PAGE
// ==========================================
class ProfileAndSettingsPage extends StatelessWidget {
  const ProfileAndSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile')),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('@alex_adventures', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.amberAccent),
            title: Text(t('language'), style: const TextStyle(color: Colors.white)),
            trailing: DropdownButton<AppLanguage>(
              value: appLanguageNotifier.currentLanguage,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              onChanged: (AppLanguage? newLang) {
                if (newLang != null) {
                  appLanguageNotifier.setLanguage(newLang);
                }
              },
              items: const [
                DropdownMenuItem(value: AppLanguage.english, child: Text('English')),
                DropdownMenuItem(value: AppLanguage.hindi, child: Text('हिंदी (Hindi)')),
                DropdownMenuItem(value: AppLanguage.hinglish, child: Text('Hinglish')),
                DropdownMenuItem(value: AppLanguage.spanish, child: Text('Español')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
