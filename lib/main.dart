import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase Configuration
const String kSupabaseUrl = 'https://aryqhfwmrgoafveblmyq.supabase.co';
const String kSupabaseAnonKey = 'sb_publishable_JJgo4KjhEZz99eSpllIBwA_b6D-IoOa';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Backend Network Service
  try {
    await Supabase.initialize(
      url: kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase Initialization Note: $e');
  }

  runApp(const InstagramReelsApp());
}

/// Root Application Widget
class InstagramReelsApp extends StatelessWidget {
  const InstagramReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
}

/// Reel Data Model
class ReelModel {
  final String id;
  final String videoUrl;
  final String username;
  final String userAvatar;
  final String caption;
  final String musicTrack;
  int likesCount;
  int commentsCount;
  int sharesCount;
  bool isLiked;
  bool isFollowing;
  List<CommentModel> comments;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.userAvatar,
    required this.caption,
    required this.musicTrack,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isFollowing = false,
    required this.comments,
  });

  factory ReelModel.fromMap(Map<String, dynamic> map) {
    return ReelModel(
      id: map['id']?.toString() ?? '',
      videoUrl: map['video_url'] ?? '',
      username: map['username'] ?? 'creator',
      userAvatar: map['user_avatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      caption: map['caption'] ?? '',
      musicTrack: map['music_track'] ?? 'Original Audio',
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      sharesCount: map['shares_count'] ?? 0,
      isLiked: map['is_liked'] ?? false,
      isFollowing: map['is_following'] ?? false,
      comments: [],
    );
  }
}

class CommentModel {
  final String id;
  final String username;
  final String avatar;
  final String text;
  final String timestamp;
  int likes;

  CommentModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.text,
    required this.timestamp,
    this.likes = 0,
  });
}

/// Sample Fallback Reel Dataset
final List<ReelModel> kSampleReels = [
  ReelModel(
    id: 'reel-1',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-tokyo-city-street-traffic-at-night-41544-large.mp4',
    username: 'alex_tokyo',
    userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    caption: 'Neon lights & midnight drives through Shibuya 🌃✨ #Tokyo #Cyberpunk',
    musicTrack: 'Midnight City Beats • Original Sound',
    likesCount: 142300,
    commentsCount: 2840,
    sharesCount: 12500,
    isLiked: false,
    comments: [
      CommentModel(id: 'c1', username: 'sarah_m', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', text: 'Stunning cinematography! 🌌', timestamp: '2h ago'),
      CommentModel(id: 'c2', username: 'dev_john', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', text: 'Color grading is unmatched!', timestamp: '1h ago'),
    ],
  ),
  ReelModel(
    id: 'reel-2',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-beach-with-clear-blue-water-41551-large.mp4',
    username: 'ocean_escape',
    userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
    caption: 'Crystal clear waters in the Maldives 🌊🏝️ Paradise found!',
    musicTrack: 'Tropical Waves Ambient • Summer Chill',
    likesCount: 89400,
    commentsCount: 1120,
    sharesCount: 6800,
    isLiked: true,
    comments: [
      CommentModel(id: 'c3', username: 'beach_lover', avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', text: 'Adding this to my bucket list now!', timestamp: '3h ago'),
    ],
  ),
  ReelModel(
    id: 'reel-3',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4',
    username: 'nature_walks',
    userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    caption: 'Sunlight filtering through the redwood forest 🌲☀️ Quiet moments in nature.',
    musicTrack: 'Acoustic Guitar Whispers • Relaxing Folk',
    likesCount: 54100,
    commentsCount: 620,
    sharesCount: 3100,
    isLiked: false,
    comments: [],
  ),
];

/// Main Shell with Bottom Navigation Bar
class ReelsMainShell extends StatefulWidget {
  const ReelsMainShell({super.key});

  @override
  State<ReelsMainShell> createState() => _ReelsMainShellState();
}

class _ReelsMainShellState extends State<ReelsMainShell> {
  int _currentBottomTab = 0;
  double _creatorEarnings = 1240.50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentBottomTab,
        children: [
          ReelsFeedScreen(
            onOpenDashboard: () => _showDashboardModal(context),
            onOpenUpload: () => _showUploadModal(context),
            onSendGift: (amount) {
              setState(() => _creatorEarnings += amount);
            },
          ),
          const SearchExploreScreen(),
          ProfileScreen(
            creatorEarnings: _creatorEarnings,
            onOpenDashboard: () => _showDashboardModal(context),
            onOpenUpload: () => _showUploadModal(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomTab,
        onTap: (index) => setState(() => _currentBottomTab = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showDashboardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatorDashboardSheet(earnings: _creatorEarnings),
    );
  }

  void _showUploadModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UploadReelSheet(),
    );
  }
}

/// Core Reels Feed Screen (Module 2)
class ReelsFeedScreen extends StatefulWidget {
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenUpload;
  final Function(double) onSendGift;

  const ReelsFeedScreen({
    super.key,
    required this.onOpenDashboard,
    required this.onOpenUpload,
    required this.onSendGift,
  });

  @override
  State<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends State<ReelsFeedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<ReelModel> _reels = kSampleReels;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchReelsFromSupabase();
  }

  Future<void> _fetchReelsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('reels')
          .select()
          .order('created_at', ascending: false);

      if (response != null && (response as List).isNotEmpty) {
        setState(() {
          _reels = (response as List).map((map) => ReelModel.fromMap(map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Supabase fetch note (using sample reels): $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              // Inject AdMob Native Ad every 5 reels
              if ((index + 1) % 5 == 0) {
                return const AdMobNativeAdCard();
              }
              return ReelVideoCard(
                reel: _reels[index],
                isActive: index == _currentIndex,
                onSendGift: widget.onSendGift,
              );
            },
          ),

          // Header Overlay
          Positioned(
            top: 45,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reels',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.analytics_outlined, color: Colors.emeraldAccent),
                      onPressed: widget.onOpenDashboard,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                      onPressed: widget.onOpenUpload,
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

/// Reel Video Card Component
class ReelVideoCard extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;
  final Function(double) onSendGift;

  const ReelVideoCard({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onSendGift,
  });

  @override
  State<ReelVideoCard> createState() => _ReelVideoCardState();
}

class _ReelVideoCardState extends State<ReelVideoCard> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _discAnimController;
  bool _isInitialized = false;
  bool _showHeartAnim = false;
  Offset _heartAnimPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _videoController.setLooping(true);
        if (widget.isActive) _videoController.play();
      });
  }

  @override
  void didUpdateWidget(covariant ReelVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive && _isInitialized) {
      if (widget.isActive) {
        _videoController.play();
      } else {
        _videoController.pause();
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _discAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    setState(() {
      _showHeartAnim = true;
      _heartAnimPos = details.localPosition;
      if (!widget.reel.isLiked) {
        widget.reel.isLiked = true;
        widget.reel.likesCount++;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showHeartAnim = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleDoubleTap,
      child: Stack(
        fit: StackPane.expand,
        children: [
          // Video Layer
          _isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.roseAccent)),

          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54, Colors.black87],
                stops: [0.5, 0.8, 1.0],
              ),
            ),
          ),

          // Double Tap Heart Pop Up
          if (_showHeartAnim)
            Positioned(
              left: _heartAnimPos.dx - 40,
              top: _heartAnimPos.dy - 40,
              child: const Icon(Icons.favorite, size: 80, color: Colors.rose),
            ),

          // Bottom Left Overlay UI
          Positioned(
            bottom: 24,
            left: 16,
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => widget.reel.isFollowing = !widget.reel.isFollowing);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        side: BorderSide(color: widget.reel.isFollowing ? Colors.grey : Colors.white),
                      ),
                      child: Text(
                        widget.reel.isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(fontSize: 11, color: widget.reel.isFollowing ? Colors.grey : Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.reel.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.music_note, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      widget.reel.musicTrack,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Action Column
          Positioned(
            bottom: 24,
            right: 12,
            child: Column(
              children: [
                // Like Button
                IconButton(
                  icon: Icon(
                    widget.reel.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.reel.isLiked ? Colors.rose : Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.reel.isLiked = !widget.reel.isLiked;
                      widget.reel.likesCount += widget.reel.isLiked ? 1 : -1;
                    });
                  },
                ),
                Text('${widget.reel.likesCount}', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 16),

                // Comment Button
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined, color: Colors.white, size: 28),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.grey[900],
                      builder: (_) => CommentsSheet(reel: widget.reel),
                    );
                  },
                ),
                Text('${widget.reel.commentsCount}', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 16),

                // Virtual Gift Button
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 28),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => VirtualGiftSheet(
                        creatorName: widget.reel.username,
                        onSendGift: widget.onSendGift,
                      ),
                    );
                  },
                ),
                const Text('Gift', style: TextStyle(fontSize: 10, color: Colors.amberAccent)),
                const SizedBox(height: 16),

                // Options / Report Button
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 26),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.grey[900],
                      builder: (_) => ReportSheet(reelId: widget.reel.id),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Spinning Disc
                RotationTransition(
                  turns: _discAnimController,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(widget.reel.userAvatar),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// AdMob Native Ad Card (Module 6)
class AdMobNativeAdCard extends StatelessWidget {
  const AdMobNativeAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[950],
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[600],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('SPONSORED AD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text('FlutterFlow AI Builder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Build full-stack Flutter applications with auto Supabase network integration & AdMob monetization.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Install Studio App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// Virtual Gifting Modal Sheet (Module 8)
class VirtualGiftSheet extends StatelessWidget {
  final String creatorName;
  final Function(double) onSendGift;

  const VirtualGiftSheet({
    super.key,
    required this.creatorName,
    required this.onSendGift,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Send Gift to @$creatorName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGiftItem(context, '🌹 Rose', 10, 0.10),
              _buildGiftItem(context, '💎 Diamond', 50, 0.50),
              _buildGiftItem(context, '🚀 Rocket', 100, 1.00),
              _buildGiftItem(context, '👑 Crown', 500, 5.00),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGiftItem(BuildContext context, String name, int coins, double value) {
    return GestureDetector(
      onTap: () {
        onSendGift(value);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent $name to creator!')),
        );
      },
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text('$coins coins', style: const TextStyle(fontSize: 10, color: Colors.amberAccent)),
        ],
      ),
    );
  }
}

/// Creator Dashboard Sheet (Module 7)
class CreatorDashboardSheet extends StatelessWidget {
  final double earnings;

  const CreatorDashboardSheet({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Creator Earnings & Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.emerald[900]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.emeraldAccent.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Balance', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('\${earnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.emeraldAccent)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payout request submitted to Bank/UPI')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.emeraldAccent),
                  child: const Text('Withdraw', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Upload Reel Modal Sheet (Module 3)
class UploadReelSheet extends StatelessWidget {
  const UploadReelSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Upload Reel to Supabase Storage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Reel Caption',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reel uploaded successfully to Supabase!')),
              );
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Publish Reel'),
          ),
        ],
      ),
    );
  }
}

/// Comments Sheet Component (Module 5)
class CommentsSheet extends StatelessWidget {
  final ReelModel reel;

  const CommentsSheet({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: reel.comments.length,
              itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(reel.comments[i].avatar)),
                title: Text(reel.comments[i].username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                subtitle: Text(reel.comments[i].text, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Report Sheet Component (Module 9)
class ReportSheet extends StatelessWidget {
  final String reelId;

  const ReportSheet({super.key, required this.reelId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Report / DMCA Claim', style: TextStyle(color: Colors.rose, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Copyright Infringement'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
            },
          ),
          ListTile(
            title: const Text('Inappropriate Content'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
            },
          ),
        ],
      ),
    );
  }
}

/// Search & Explore Screen
class SearchExploreScreen extends StatelessWidget {
  const SearchExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Reels')),
      body: const Center(child: Text('Trending Audio & Creators Grid')),
    );
  }
}

/// User Profile Screen (Module 4)
class ProfileScreen extends StatelessWidget {
  final double creatorEarnings;
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenUpload;

  const ProfileScreen({
    super.key,
    required this.creatorEarnings,
    required this.onOpenDashboard,
    required this.onOpenUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('my_creator_profile'),
        actions: [
          IconButton(icon: const Icon(Icons.analytics_outlined), onPressed: onOpenDashboard),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150')),
            const SizedBox(height: 12),
            const Text('Alex Adventures', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Creator Earnings: \${creatorEarnings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.emeraldAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
