import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const ReelsFeedScreen(),
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
  final List<String> comments;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.userAvatar,
    required this.caption,
    required this.musicTrack,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.isLiked = false,
    required this.comments,
  });
}

/// Main Feed Screen with Vertical Scroll PageView
class ReelsFeedScreen extends StatefulWidget {
  const ReelsFeedScreen({super.key});

  @override
  State<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends State<ReelsFeedScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  // Sample Online MP4 Video URLs for Testing
  final List<ReelModel> _reels = [
    ReelModel(
      id: 'reel_1',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      username: 'alex_adventures',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      caption: 'Chasing sunsets and endless mountain horizons 🌄✨ Which trail should I explore next?',
      musicTrack: 'alex_adventures • Original Audio - Golden Hour Echoes',
      likesCount: 142800,
      commentsCount: 2340,
      sharesCount: 8900,
      isLiked: false,
      comments: [
        'This view is absolutely breathtaking! 😍',
        'The colors in this reel are insane. What camera did you use?',
        'Adding this to my travel bucket list immediately! 🏔️',
      ],
    ),
    ReelModel(
      id: 'reel_2',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      username: 'cyber_creator',
      userAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      caption: 'Testing high-speed cinematic motion capture 🎥 Smooth framerate & vivid contrast!',
      musicTrack: 'cyber_creator • Cyberpunk Beats - Synthetic Pulse',
      likesCount: 89500,
      commentsCount: 1120,
      sharesCount: 4320,
      isLiked: true,
      comments: [
        'The smooth motion is crazy good 🔥',
        'Great lighting contrast! Keep it up 🙌',
      ],
    ),
    ReelModel(
      id: 'reel_3',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      username: 'urban_vibes',
      userAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      caption: 'Weekend energy hitting different ⚡️ Tag a friend who needs motivation today! #reels',
      musicTrack: 'urban_vibes • Electric Chillout - Midnight Groove',
      likesCount: 210400,
      commentsCount: 4500,
      sharesCount: 15200,
      isLiked: false,
      comments: [
        'This energy is contagious 💯💯',
        'Best reel I\'ve seen all day!',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
          // 1. Vertical Scrolling PageView for Reels
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ReelPlayerItem(
                reel: _reels[index],
                isCurrentPage: index == _currentIndex,
              );
            },
          ),

          // 2. Top Header Overlay (Camera & Reels Title)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
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
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera feature tapped')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual Reel Item Widget with Video Auto-Play & Loop Mode
class ReelPlayerItem extends StatefulWidget {
  final ReelModel reel;
  final bool isCurrentPage;

  const ReelPlayerItem({
    super.key,
    required this.reel,
    required this.isCurrentPage,
  });

  @override
  State<ReelPlayerItem> createState() => _ReelPlayerItemState();
}

class _ReelPlayerItemState extends State<ReelPlayerItem> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _discAnimController;
  
  bool _isInitialized = false;
  bool _isPlaying = true;
  bool _showPlayPauseIcon = false;
  bool _showBigHeart = false;
  Offset _heartPos = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Spinning Music Vinyl Disc Controller
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Initialize Video Player from Network URL
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _videoController.setLooping(true); // Loop mode enabled
          if (widget.isCurrentPage) {
            _videoController.play();
          }
        }
      }).catchError((error) {
        debugPrint('Video Player Initialization Error: $error');
      });
  }

  @override
  void didUpdateWidget(covariant ReelPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isCurrentPage) {
        _videoController.play();
        _discAnimController.repeat();
        setState(() => _isPlaying = true);
      } else {
        _videoController.pause();
        _discAnimController.stop();
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _discAnimController.dispose();
    super.dispose();
  }

  // Toggle Video Play / Pause
  void _togglePlayPause() {
    if (!_isInitialized) return;
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _discAnimController.stop();
        _isPlaying = false;
      } else {
        _videoController.play();
        _discAnimController.repeat();
        _isPlaying = true;
      }
      _showPlayPauseIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showPlayPauseIcon = false;
        });
      }
    });
  }

  // Double Tap to Like with Animated Heart
  void _handleDoubleTap(TapDownDetails details) {
    setState(() {
      _heartPos = details.localPosition;
      _showBigHeart = true;
      if (!widget.reel.isLiked) {
        widget.reel.isLiked = true;
        widget.reel.likesCount++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showBigHeart = false;
        });
      }
    });
  }

  // Format Large Counts (e.g., 142800 -> 142.8K)
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  // Open Comments Bottom Sheet
  void _openCommentsSheet() {
    final TextEditingController commentTextController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comments (${widget.reel.comments.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(color: Colors.grey),
                    // Comments List
                    Expanded(
                      child: widget.reel.comments.isEmpty
                          ? const Center(
                              child: Text('No comments yet. Be the first!'),
                            )
                          : ListView.builder(
                              itemCount: widget.reel.comments.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.pinkAccent,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text(
                                    'user_$index',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  subtitle: Text(widget.reel.comments[index]),
                                  trailing: const Icon(Icons.favorite_border, size: 16),
                                );
                              },
                            ),
                    ),
                    // Comment Input Box
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentTextController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: () {
                            if (commentTextController.text.trim().isNotEmpty) {
                              setState(() {
                                widget.reel.comments.add(commentTextController.text.trim());
                                widget.reel.commentsCount++;
                              });
                              setSheetState(() {});
                              commentTextController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Open Share Dialog
  void _openShareModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Text(
                'Share Reel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _shareActionItem(Icons.link, 'Copy Link', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reel link copied to clipboard!')),
                    );
                  }),
                  _shareActionItem(Icons.send, 'Direct Message', () {
                    Navigator.pop(context);
                  }),
                  _shareActionItem(Icons.download, 'Save Video', () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shareActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[800],
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTapDown: _handleDoubleTap,
      child: Stack(
        fit: StackFrame.expand,
        children: [
          // 1. Video Player Container
          _isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

          // 2. Play / Pause Overlay Icon Indicator
          if (_showPlayPauseIcon)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showPlayPauseIcon ? 1.0 : 0.0,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: Icon(
                    _isPlaying ? Icons.play_arrow : Icons.pause,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // 3. Double-Tap Animated Heart Overlay
          if (_showBigHeart)
            Positioned(
              left: _heartPos.dx - 40,
              top: _heartPos.dy - 40,
              child: const Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 80,
              ),
            ),

          // 4. Overlay UI - Bottom Gradient for readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 5. Bottom Left Overlay: Username, Reel Caption, Music Track Name
          Positioned(
            left: 16,
            bottom: 24,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username & Follow Button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.reel.userAvatar),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '@${widget.reel.username}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Reel Caption
                Text(
                  widget.reel.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Music Track Name with Ticker Icon
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.reel.musicTrack,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 6. Right Side Action Bar: Like, Comment, Share, Vinyl Disc
          Positioned(
            right: 12,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like Button & Counter
                _actionButton(
                  icon: widget.reel.isLiked ? Icons.favorite : Icons.favorite_border,
                  iconColor: widget.reel.isLiked ? Colors.redAccent : Colors.white,
                  label: _formatCount(widget.reel.likesCount),
                  onTap: () {
                    setState(() {
                      widget.reel.isLiked = !widget.reel.isLiked;
                      if (widget.reel.isLiked) {
                        widget.reel.likesCount++;
                      } else {
                        widget.reel.likesCount--;
                      }
                    });
                  },
                ),
                const SizedBox(height: 18),

                // Comment Button & Counter
                _actionButton(
                  icon: Icons.mode_comment_outlined,
                  iconColor: Colors.white,
                  label: _formatCount(widget.reel.commentsCount),
                  onTap: _openCommentsSheet,
                ),
                const SizedBox(height: 18),

                // Share Button & Counter
                _actionButton(
                  icon: Icons.send_outlined,
                  iconColor: Colors.white,
                  label: _formatCount(widget.reel.sharesCount),
                  onTap: _openShareModal,
                ),
                const SizedBox(height: 18),

                // More Options Button
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 26),
                  onPressed: () {},
                ),
                const SizedBox(height: 12),

                // Spinning Vinyl Music Disk
                RotationTransition(
                  turns: _discAnimController,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Colors.grey, Colors.black],
                      ),
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 6,
                        backgroundImage: NetworkImage(widget.reel.userAvatar),
                      ),
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

  // Reusable Overlay Action Button Widget
  Widget _actionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
