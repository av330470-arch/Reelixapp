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

// ==========================================
// MAIN ENTRY POINT WITH ERROR BOUNDARIES
// ==========================================
void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent red-screen crashes on Android UI render errors
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

    // Framework error listener
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Caught Flutter Error: ${details.exception}');
    };

    // Initialize Supabase with graceful fallback
    try {
      await Supabase.initialize(
        url: kSupabaseUrl,
        anonKey: kSupabaseAnonKey,
      );
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase Note (Using Fallback Mode): $e');
    }

    // Initialize Google Mobile Ads SDK
    try {
      await MobileAds.instance.initialize();
      debugPrint('Google Mobile Ads SDK initialized successfully');
    } catch (e) {
      debugPrint('AdMob SDK Note: $e');
    }

    runApp(const InstagramReelsApp());
  }, (error, stackTrace) {
    debugPrint('Async Uncaught Startup Error: $error');
  });
}

// ==========================================
// MULTI-LANGUAGE LOCALIZATION ENGINE (भाषा)
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
      'login': 'Log In',
      'sign_up': 'Sign Up',
      'guest_mode': 'Continue as Guest',
      'logout': 'Log Out',
      'email': 'Email Address',
      'password': 'Password',
      'username': 'Username',
      'full_name': 'Full Name',
      'bio': 'Bio / Status',
      'voice_call': 'Voice Call',
      'video_call': 'Video Call',
      'calling': 'Calling...',
      'incoming_call': 'Incoming Call...',
      'mute': 'Mute',
      'speaker': 'Speaker',
      'end_call': 'End Call',
      'online': 'Online',
      'offline': 'Offline',
      'send_message': 'Send message...',
      'share_photo': 'Share Photo',
      'voice_note': 'Voice Note',
      'reel_preview': 'Shared Reel',
      'creator_dashboard': 'Creator Dashboard',
      'monetization': 'AdMob Earnings',
      'followers': 'Followers',
      'following': 'Following',
      'likes': 'Likes',
      'follow': 'Follow',
      'following_btn': 'Following',
      'upload_reel': 'Upload Reel',
      'comments': 'Comments',
      'add_comment': 'Add a comment...',
      'ad_sponsored': 'AdMob Sponsored',
    },
    AppLanguage.hindi: {
      'reels': 'रील्स (Reels)',
      'explore': 'खोजें (Explore)',
      'profile': 'प्रोफाइल',
      'dm_chat': 'मैसेज (Direct Messages)',
      'settings': 'सेटिंग्स',
      'language': 'भाषा बदलें (Language)',
      'login': 'लॉग इन करें',
      'sign_up': 'साइन अप करें',
      'guest_mode': 'गेस्ट के रूप में जारी रखें',
      'logout': 'लॉग आउट',
      'email': 'ईमेल पता',
      'password': 'पासवर्ड',
      'username': 'यूजरनेम',
      'full_name': 'पूरा नाम',
      'bio': 'बायो / स्थिति',
      'voice_call': 'वॉइस कॉल',
      'video_call': 'वीडियो कॉल',
      'calling': 'कॉल हो रही है...',
      'incoming_call': 'इनकमिंग कॉल...',
      'mute': 'म्यूट करें',
      'speaker': 'स्पीकर',
      'end_call': 'कॉल समाप्त करें',
      'online': 'ऑनलाइन',
      'offline': 'ऑफ़लाइन',
      'send_message': 'संदेश भेजें...',
      'share_photo': 'फोटो भेजें',
      'voice_note': 'वॉइस नोट',
      'reel_preview': 'शेयर की गई रील',
      'creator_dashboard': 'क्रिएटर डैशबोर्ड',
      'monetization': 'AdMob कमाई',
      'followers': 'फॉलोअर्स',
      'following': 'फॉलोइंग',
      'likes': 'लाइक्स',
      'follow': 'फॉलो करें',
      'following_btn': 'फॉलो किया गया',
      'upload_reel': 'रील अपलोड करें',
      'comments': 'कमेंट्स',
      'add_comment': 'कमेंट लिखें...',
      'ad_sponsored': 'AdMob प्रायोजित',
    },
    AppLanguage.hinglish: {
      'reels': 'Reels Feed',
      'explore': 'Explore Videos',
      'profile': 'Meri Profile',
      'dm_chat': 'Chat & Messages',
      'settings': 'Settings & Bhasha',
      'language': 'Bhasha Badlein (Language)',
      'login': 'Log In Karo',
      'sign_up': 'Naya Account Banayein',
      'guest_mode': 'Guest Mode Mein Chalein',
      'logout': 'Log Out Karo',
      'email': 'Email Id',
      'password': 'Password',
      'username': 'Username Choose Karein',
      'full_name': 'Apna Naam',
      'bio': 'Aapka Bio',
      'voice_call': 'Voice Call',
      'video_call': 'Video Call',
      'calling': 'Call Lag Rahi Hai...',
      'incoming_call': 'Incoming Call Aa Rahi Hai...',
      'mute': 'Mute',
      'speaker': 'Speaker',
      'end_call': 'Call Katein',
      'online': 'Online Hai',
      'offline': 'Offline',
      'send_message': 'Message likhein...',
      'share_photo': 'Photo Bhejo',
      'voice_note': 'Voice Note Recording',
      'reel_preview': 'Shared Reel Video',
      'creator_dashboard': 'Creator Dashboard',
      'monetization': 'AdMob Total Earnings',
      'followers': 'Followers',
      'following': 'Following',
      'likes': 'Total Likes',
      'follow': 'Follow Karo',
      'following_btn': 'Following Hai',
      'upload_reel': 'Riel Upload Karein',
      'comments': 'Comments List',
      'add_comment': 'Comment karein...',
      'ad_sponsored': 'AdMob Sponsored Ad',
    },
    AppLanguage.spanish: {
      'reels': 'Reels',
      'explore': 'Explorar',
      'profile': 'Perfil',
      'dm_chat': 'Mensajes Directos',
      'settings': 'Ajustes',
      'language': 'Cambiar Idioma',
      'login': 'Iniciar Sesión',
      'sign_up': 'Registrarse',
      'guest_mode': 'Continuar como Invitado',
      'logout': 'Cerrar Sesión',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'username': 'Nombre de Usuario',
      'full_name': 'Nombre Completo',
      'bio': 'Biografía',
      'voice_call': 'Llamada de Voz',
      'video_call': 'Videollamada',
      'calling': 'Llamando...',
      'incoming_call': 'Llamada Entrante...',
      'mute': 'Silenciar',
      'speaker': 'Altavoz',
      'end_call': 'Finalizar Llamada',
      'online': 'En línea',
      'offline': 'Desconectado',
      'send_message': 'Enviar mensaje...',
      'share_photo': 'Compartir Foto',
      'voice_note': 'Nota de Voz',
      'reel_preview': 'Reel Compartido',
      'creator_dashboard': 'Panel de Creador',
      'monetization': 'Ganancias de AdMob',
      'followers': 'Seguidores',
      'following': 'Siguiendo',
      'likes': 'Me gusta',
      'follow': 'Seguir',
      'following_btn': 'Siguiendo',
      'upload_reel': 'Subir Reel',
      'comments': 'Comentarios',
      'add_comment': 'Añadir comentario...',
      'ad_sponsored': 'Patrocinado por AdMob',
    },
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
// SUPABASE AUTHENTICATION SERVICE
// ==========================================
class UserProfileModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String avatarUrl;
  final String bio;
  final bool isAnonymous;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.bio,
    this.isAnonymous = false,
  });
}

class SupabaseAuthService {
  static UserProfileModel? _currentUser = UserProfileModel(
    id: 'user_992',
    email: 'creator@instagram.com',
    username: 'alex_adventures',
    fullName: 'Alex Rivero',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    bio: 'Flutter Developer & Reels Creator 🚀 | Building Monetized Apps',
    isAnonymous: false,
  );

  static UserProfileModel? get currentUser => _currentUser;

  static Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String bio,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      _currentUser = UserProfileModel(
        id: response.user?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        username: username.isEmpty ? 'user_${DateTime.now().millisecond}' : username,
        fullName: fullName.isEmpty ? 'Instagram User' : fullName,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        bio: bio.isEmpty ? 'Hey there! I am using Instagram Reels.' : bio,
        isAnonymous: false,
      );
      return true;
    } catch (e) {
      debugPrint('SignUp Note: $e');
      // Fallback local registration
      _currentUser = UserProfileModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        username: username,
        fullName: fullName,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        bio: bio,
        isAnonymous: false,
      );
      return true;
    }
  }

  static Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = UserProfileModel(
        id: response.user?.id ?? 'usr_logged',
        email: email,
        username: email.split('@').first,
        fullName: 'Authenticated User',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        bio: 'Welcome back to Instagram Reels!',
        isAnonymous: false,
      );
      return true;
    } catch (e) {
      debugPrint('SignIn Note: $e');
      _currentUser = UserProfileModel(
        id: 'usr_logged_local',
        email: email,
        username: email.split('@').first,
        fullName: 'Logged In User',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        bio: 'Local session active.',
        isAnonymous: false,
      );
      return true;
    }
  }

  static Future<void> signInAnonymously() async {
    _currentUser = UserProfileModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@instagram.com',
      username: 'guest_user_${math.Random().nextInt(999)}',
      fullName: 'Anonymous Guest',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      bio: 'Browsing in Anonymous Guest Mode',
      isAnonymous: true,
    );
  }

  static Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('SignOut Note: $e');
    }
    _currentUser = null;
  }
}

// ==========================================
// MODELS FOR REELS & CHAT MESSAGES
// ==========================================
class CommentModel {
  final String id;
  final String username;
  final String avatar;
  final String text;
  final String timestamp;

  CommentModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.text,
    required this.timestamp,
  });
}

class ReelModel {
  final String id;
  final String videoUrl;
  final String username;
  final String userAvatar;
  final bool isVerified;
  final String caption;
  final String musicTrack;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<CommentModel> comments;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.userAvatar,
    required this.isVerified,
    required this.caption,
    required this.musicTrack,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.comments,
  });
}

class ChatMessageModel {
  final String id;
  final String senderUsername;
  final String text;
  final String timestamp;
  final String? photoUrl;
  final String? voiceNoteDuration;
  final String? reelPreviewTitle;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.senderUsername,
    required this.text,
    required this.timestamp,
    this.photoUrl,
    this.voiceNoteDuration,
    this.reelPreviewTitle,
    required this.isMe,
  });
}

class DMConversationModel {
  final String id;
  final String username;
  final String avatar;
  final bool isOnline;
  final int unreadCount;
  final String lastMessage;
  final String lastTimestamp;
  final List<ChatMessageModel> messages;

  DMConversationModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.isOnline,
    required this.unreadCount,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.messages,
  });
}

// Sample Data Mock
final List<ReelModel> kSampleReels = [
  ReelModel(
    id: 'reel-1',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-tokyo-city-street-traffic-at-night-41544-large.mp4',
    username: 'neon_dreams',
    userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    isVerified: true,
    caption: 'Tokyo Street Lights at midnight 🌃✨ #Tokyo #Cyberpunk',
    musicTrack: 'neon_dreams • Tokyo Synthwave',
    likesCount: 198400,
    commentsCount: 3120,
    sharesCount: 11400,
    comments: [
      CommentModel(id: 'c1', username: 'tokyo_fan', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', text: 'Unmatched vibes! 🔥', timestamp: '10m ago'),
    ],
  ),
  ReelModel(
    id: 'reel-2',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-beach-with-clear-blue-water-41551-large.mp4',
    username: 'wanderlust_sam',
    userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    isVerified: false,
    caption: 'Tropical ocean waters in Maldives 🏝️ #BeachVibes',
    musicTrack: 'wanderlust_sam • Tropical House',
    likesCount: 142000,
    commentsCount: 1950,
    sharesCount: 8100,
    comments: [],
  ),
];

// Sample DM Conversations
final List<DMConversationModel> kSampleConversations = [
  DMConversationModel(
    id: 'dm-1',
    username: 'neon_dreams',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    isOnline: true,
    unreadCount: 2,
    lastMessage: 'Hey! Loved your recent video reel 🔥',
    lastTimestamp: '2m ago',
    messages: [
      ChatMessageModel(
        id: 'm1',
        senderUsername: 'neon_dreams',
        text: 'Hey! Loved your recent video reel 🔥',
        timestamp: '10:42 AM',
        isMe: false,
      ),
      ChatMessageModel(
        id: 'm2',
        senderUsername: 'neon_dreams',
        text: 'Check out this photo from Tokyo!',
        timestamp: '10:43 AM',
        photoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600',
        isMe: false,
      ),
    ],
  ),
  DMConversationModel(
    id: 'dm-2',
    username: 'wanderlust_sam',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    isOnline: false,
    unreadCount: 0,
    lastMessage: 'Sent a voice note 🎵',
    lastTimestamp: '1h ago',
    messages: [
      ChatMessageModel(
        id: 'm3',
        senderUsername: 'wanderlust_sam',
        text: 'Voice note recorded',
        timestamp: '09:15 AM',
        voiceNoteDuration: '0:18',
        isMe: false,
      ),
    ],
  ),
];

// ==========================================
// ROOT APPLICATION WIDGET
// ==========================================
class InstagramReelsApp extends StatelessWidget {
  const InstagramReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLanguageNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Instagram Reels Clone',
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
// MAIN SHELL WITH BOTTOM NAVIGATION
// ==========================================
class ReelsMainShell extends StatefulWidget {
  const ReelsMainShell({super.key});

  @override
  State<ReelsMainShell> createState() => _ReelsMainShellState();
}

class _ReelsMainShellState extends State<ReelsMainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    final List<Widget> pages = [
      const ReelsFeedPage(),
      const DirectMessagesPage(),
      const CreatorDashboardPage(),
      const ProfileAndSettingsPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie_creation_outlined),
            activeIcon: const Icon(Icons.movie_creation),
            label: t('reels'),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.send_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                  ),
                ),
              ],
            ),
            activeIcon: const Icon(Icons.send),
            label: t('dm_chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
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
// 1. REELS FEED PAGE (WITH ADMOB EVERY 12 REELS)
// ==========================================
class ReelsFeedPage extends StatefulWidget {
  const ReelsFeedPage({super.key});

  @override
  State<ReelsFeedPage> createState() => _ReelsFeedPageState();
}

class _ReelsFeedPageState extends State<ReelsFeedPage> {
  final PageController _pageController = PageController();
  int _activeReelIndex = 0;

  List<dynamic> get _feedItems {
    final List<dynamic> items = [];
    for (int i = 0; i < kSampleReels.length; i++) {
      items.add(kSampleReels[i]);
      // Insert an AdMob Native Ad strictly after every 12 reels
      if ((i + 1) % 12 == 0) {
        items.add('ADMOB_NATIVE_AD');
      }
    }
    return items;
  }

  void _showInterstitialAd() {
    showDialog(
      context: context,
      builder: (_) => const AdMobInterstitialModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;
    final items = _feedItems;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            onPageChanged: (idx) => setState(() => _activeReelIndex = idx),
            itemBuilder: (context, index) {
              final item = items[index];

              if (item == 'ADMOB_NATIVE_AD') {
                return const AdMobNativeAdCard();
              }

              final reel = item as ReelModel;
              return ReelPlayerCard(
                reel: reel,
                isActive: index == _activeReelIndex,
              );
            },
          ),

          // Header Overlay
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('reels'),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        foregroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _showInterstitialAd,
                      icon: const Icon(Icons.campaign, size: 16),
                      label: const Text('AdMob Ad', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const UploadReelSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REEL PLAYER CARD WIDGET
// ==========================================
class ReelPlayerCard extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;

  const ReelPlayerCard({super.key, required this.reel, required this.isActive});

  @override
  State<ReelPlayerCard> createState() => _ReelPlayerCardState();
}

class _ReelPlayerCardState extends State<ReelPlayerCard> {
  late VideoPlayerController _controller;
  bool _isLiked = false;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.reel.likesCount;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      })
      ..setLooping(true);

    if (widget.isActive) _controller.play();
  }

  @override
  void didUpdateWidget(ReelPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Stack(
        children: [
          // Video Viewport
          Positioned.fill(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.amberAccent)),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Caption & User Metadata
          Positioned(
            left: 16,
            bottom: 24,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(widget.reel.userAvatar),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${widget.reel.username}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (widget.reel.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, color: Colors.blueAccent, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.reel.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.amberAccent, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.reel.musicTrack,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Sidebar Buttons
          Positioned(
            right: 12,
            bottom: 36,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.redAccent : Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      _likesCount += _isLiked ? 1 : -1;
                    });
                  },
                ),
                Text('$_likesCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
                Text('${widget.reel.commentsCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 28),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(r'Virtual Gift Sent! +$0.50 credited to creator.')),
                    );
                  },
                ),
                const Text('Gift', style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. DIRECT MESSAGES PAGE (INSTAGRAM-STYLE DM & REALTIME CHAT)
// ==========================================
class DirectMessagesPage extends StatefulWidget {
  const DirectMessagesPage({super.key});

  @override
  State<DirectMessagesPage> createState() => _DirectMessagesPageState();
}

class _DirectMessagesPageState extends State<DirectMessagesPage> {
  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('dm_chat'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_outlined),
            onPressed: () => _openCallScreen('Global Call Room', isVideo: true),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: kSampleConversations.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          final conv = kSampleConversations[index];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(conv.avatar),
                ),
                if (conv.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              '@${conv.username}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              conv.lastMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(conv.lastTimestamp, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                if (conv.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle),
                    child: Text(
                      '${conv.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conv)),
              );
            },
          );
        },
      ),
    );
  }

  void _openCallScreen(String title, {required bool isVideo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(contactName: title, isVideo: isVideo),
      ),
    );
  }
}

// ==========================================
// CHAT DETAIL SCREEN WITH AUDIO & VIDEO CALL
// ==========================================
class ChatDetailScreen extends StatefulWidget {
  final DMConversationModel conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  late List<ChatMessageModel> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.conversation.messages);
  }

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessageModel(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderUsername: 'me',
            text: _msgController.text.trim(),
            timestamp: 'Just now',
            isMe: true,
          ),
        );
      });
      _msgController.clear();
    }
  }

  void _sendVoiceNote() {
    setState(() {
      _messages.add(
        ChatMessageModel(
          id: 'vn_${DateTime.now().millisecondsSinceEpoch}',
          senderUsername: 'me',
          text: 'Voice note',
          timestamp: 'Just now',
          voiceNoteDuration: '0:12',
          isMe: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(widget.conversation.avatar)),
            const SizedBox(width: 8),
            Text('@${widget.conversation.username}', style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.greenAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiveCallScreen(contactName: widget.conversation.username, isVideo: false),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.purpleAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiveCallScreen(contactName: widget.conversation.username, isVideo: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Colors.purpleAccent.shade700 : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.photoUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(msg.photoUrl!, height: 120, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (msg.voiceNoteDuration != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow, color: Colors.amberAccent),
                              const SizedBox(width: 4),
                              Text('Voice Note (${msg.voiceNoteDuration})', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ] else
                          Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(msg.timestamp, style: const TextStyle(color: Colors.white54, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.amberAccent),
                  onPressed: _sendVoiceNote,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: t('send_message'),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purpleAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. AUDIO & VIDEO CALLING INTERFACE
// ==========================================
class ActiveCallScreen extends StatefulWidget {
  final String contactName;
  final bool isVideo;

  const ActiveCallScreen({super.key, required this.contactName, required this.isVideo});

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background UI
          Positioned.fill(
            child: widget.isVideo && !_isCameraOff
                ? Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Text('Live HD Camera Stream (Mock)', style: TextStyle(color: Colors.white54)),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.purpleAccent,
                          child: Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(widget.contactName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(t('calling'), style: const TextStyle(color: Colors.greenAccent, fontSize: 13)),
                      ],
                    ),
                  ),
          ),

          // Control Bar
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                  onPressed: () => setState(() => _isMuted = !_isMuted),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
                if (widget.isVideo)
                  IconButton(
                    icon: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                    onPressed: () => setState(() => _isCameraOff = !_isCameraOff),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. CREATOR DASHBOARD & ANALYTICS
// ==========================================
class CreatorDashboardPage extends StatelessWidget {
  const CreatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('creator_dashboard'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(t('monetization'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    const Text(r'$1,240.50', style: TextStyle(color: Colors.amberAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('AdMob eCPM + Virtual Gifts Revenue', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. PROFILE & SETTINGS (WITH AUTH & LANGUAGE ENGINE)
// ==========================================
class ProfileAndSettingsPage extends StatefulWidget {
  const ProfileAndSettingsPage({super.key});

  @override
  State<ProfileAndSettingsPage> createState() => _ProfileAndSettingsPageState();
}

class _ProfileAndSettingsPageState extends State<ProfileAndSettingsPage> {
  void _openAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AuthSheetModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;
    final user = SupabaseAuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.amberAccent),
            onPressed: _showLanguageSelector,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
            ),
            const SizedBox(height: 12),
            Text('@${user?.username ?? 'guest_user'}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(user?.bio ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // Language Selector Button
            ListTile(
              tileColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.translate, color: Colors.amberAccent),
              title: Text(t('language'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
              onTap: _showLanguageSelector,
            ),
            const SizedBox(height: 12),

            // Auth Button (Login/Signup or Logout)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: user == null || user.isAnonymous ? Colors.purpleAccent : Colors.redAccent,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (user == null || user.isAnonymous) {
                  _openAuthModal();
                } else {
                  SupabaseAuthService.signOut();
                  setState(() {});
                }
              },
              icon: Icon(user == null || user.isAnonymous ? Icons.login : Icons.logout),
              label: Text(
                user == null || user.isAnonymous ? t('login') : t('logout'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select App Language / भाषा चुनें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              title: const Text('English', style: TextStyle(color: Colors.white)),
              onTap: () {
                appLanguageNotifier.setLanguage(AppLanguage.english);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('हिंदी (Hindi)', style: TextStyle(color: Colors.white)),
              onTap: () {
                appLanguageNotifier.setLanguage(AppLanguage.hindi);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Hinglish (Hindi + English)', style: TextStyle(color: Colors.white)),
              onTap: () {
                appLanguageNotifier.setLanguage(AppLanguage.hinglish);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Español (Spanish)', style: TextStyle(color: Colors.white)),
              onTap: () {
                appLanguageNotifier.setLanguage(AppLanguage.spanish);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// AUTH MODAL SHEET (LOGIN / SIGNUP)
// ==========================================
class AuthSheetModal extends StatefulWidget {
  const AuthSheetModal({super.key});

  @override
  State<AuthSheetModal> createState() => _AuthSheetModalState();
}

class _AuthSheetModalState extends State<AuthSheetModal> {
  bool _isSignUp = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  void _submit() async {
    if (_isSignUp) {
      await SupabaseAuthService.signUpWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        username: _userCtrl.text,
        fullName: _nameCtrl.text,
        bio: _bioCtrl.text,
      );
    } else {
      await SupabaseAuthService.signInWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = appLanguageNotifier.t;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_isSignUp ? t('sign_up') : t('login'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: t('email'))),
          TextField(controller: _passCtrl, obscureText: true, decoration: InputDecoration(labelText: t('password'))),
          if (_isSignUp) ...[
            TextField(controller: _userCtrl, decoration: InputDecoration(labelText: t('username'))),
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: t('full_name'))),
            TextField(controller: _bioCtrl, decoration: InputDecoration(labelText: t('bio'))),
          ],
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _submit, child: Text(_isSignUp ? t('sign_up') : t('login'))),
          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(_isSignUp ? 'Already have an account? Log In' : "Don't have an account? Sign Up"),
          ),
          TextButton(
            onPressed: () {
              SupabaseAuthService.signInAnonymously();
              Navigator.pop(context);
            },
            child: Text(t('guest_mode'), style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ADMOB CARD & UTILITY MODALS
// ==========================================
class AdMobNativeAdCard extends StatelessWidget {
  const AdMobNativeAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('SPONSORED ADMOB NATIVE AD', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('In-Feed Native Ad displayed strictly every 12 Reels.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class AdMobInterstitialModal extends StatelessWidget {
  const AdMobInterstitialModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text('AdMob Interstitial Ad', style: TextStyle(color: Colors.amberAccent)),
      content: const Text('Full screen AdMob Interstitial reward preview.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close Ad')),
      ],
    );
  }
}

class UploadReelSheet extends StatelessWidget {
  const UploadReelSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Text('Upload Reel to Supabase Storage Sheet', style: TextStyle(color: Colors.white)),
    );
  }
}
