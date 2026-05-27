import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/data/repositories/reels_repository.dart';
import '../../../../core/data/repositories/provinces_repository.dart';
import '../../../../core/widgets/app_dropdown.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  bool _loading = true;
  List<dynamic> _reels = [];
  List<dynamic> _provinces = [];
  String? _selectedProvinceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final pRepo = ref.read(provincesRepositoryProvider);
      final prov = await pRepo.findAll();
      _provinces = (prov is List) ? prov : [];
      await _loadReels();
    } catch (e) {
      debugPrint('Error loading initial data: \$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadReels() async {
    setState(() => _loading = true);
    try {
      final rRepo = ref.read(reelsRepositoryProvider);
      final query = _selectedProvinceId != null
          ? {'provinceId': _selectedProvinceId}
          : null;
      final res = await rRepo.findAll(query: query);
      _reels = (res is List) ? res : [];
    } catch (e) {
      debugPrint('Error loading reels: \$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openTheater(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TheaterScreen(
          reels: _reels,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Reels'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor.withAlpha(50))),
            ),
            child: Row(
              children: [
                Icon(Icons.map_rounded, color: theme.colorScheme.primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppDropdown<String?>(
                    isExpanded: true,
                    value: _selectedProvinceId,
                    hint: 'Todas las provincias',
                    items: [
                      const AppDropdownItem<String?>(
                        value: null,
                        label: 'Todas las provincias',
                      ),
                      ..._provinces.map((p) {
                        return AppDropdownItem<String?>(
                          value: p['id'].toString(),
                          label: p['name'] ?? 'Provincia',
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedProvinceId = val);
                      _loadReels();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _reels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off_rounded,
                                size: 64.r, color: Colors.grey),
                            SizedBox(height: 16.h),
                            Text('No se encontraron reels.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16.sp)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(4.r),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.w,
                          mainAxisSpacing: 4.h,
                          childAspectRatio: 9 / 16,
                        ),
                        itemCount: _reels.length,
                        itemBuilder: (context, index) {
                          // Attempt to use thumbnail if available, otherwise just placeholder
                          // Since thumbnail_url might not be in reel, use placeholder
                          return GestureDetector(
                            onTap: () => _openTheater(index),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: Colors.grey.withAlpha(50),
                                  child: Icon(Icons.play_circle_fill_rounded,
                                      color: Colors.white.withAlpha(150),
                                      size: 40.r),
                                ),
                                Positioned(
                                  bottom: 8.h,
                                  left: 8.w,
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_arrow_rounded,
                                          color: Colors.white, size: 14.r),
                                      Text('\${_reels[index]["views_count"] ?? 0}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TheaterScreen extends ConsumerStatefulWidget {
  final List<dynamic> reels;
  final int initialIndex;

  const _TheaterScreen({required this.reels, required this.initialIndex});

  @override
  ConsumerState<_TheaterScreen> createState() => _TheaterScreenState();
}

class _TheaterScreenState extends ConsumerState<_TheaterScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Set<String> _viewedIds = {};
  final Set<String> _likedIds = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _onPageChanged(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    final reel = widget.reels[index];
    final id = reel['id'].toString();
    if (!_viewedIds.contains(id)) {
      _viewedIds.add(id);
      _incrementStats(id, 'views');
    }
  }

  Future<void> _incrementStats(String id, String type) async {
    try {
      final repo = ref.read(reelsRepositoryProvider);
      await repo.updateStats(id, {type: 1});
    } catch (e) {
      debugPrint('Error updating \$type for reel \$id: \$e');
    }
  }

  void _toggleLike(String id, int currentLikes) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
        _incrementStats(id, 'likes');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: widget.reels.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final reel = widget.reels[index];
              return _ReelVideoPlayer(
                reel: reel,
                isLiked: _likedIds.contains(reel['id'].toString()),
                onLike: () => _toggleLike(
                    reel['id'].toString(), reel['likes'] ?? 0),
                isActive: index == _currentIndex,
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ReelVideoPlayer extends StatefulWidget {
  final dynamic reel;
  final bool isLiked;
  final VoidCallback onLike;
  final bool isActive;

  const _ReelVideoPlayer({
    required this.reel,
    required this.isLiked,
    required this.onLike,
    required this.isActive,
  });

  @override
  State<_ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<_ReelVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant _ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (_controller == null) {
        _initVideo();
      } else {
        _controller!.play();
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
      _controller?.seekTo(Duration.zero);
    }
  }

  Future<void> _initVideo() async {
    final url = widget.reel['video_url'];
    if (url == null || url.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted && widget.isActive) {
        setState(() => _initialized = true);
        _controller!.play();
      }
    } catch (e) {
      debugPrint('Video error: \$e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.reel['title'] ?? 'Sin título';
    final desc = widget.reel['description'] ?? '';
    final profData = widget.reel['Professional']?['Profile'] ?? {};
    final profName = profData['display_name'] ?? 'Profesional';
    final profAvatar = profData['avatar_url'];
    final likes = (widget.reel['likes'] ?? 0) + (widget.isLiked ? 1 : 0);
    final views = widget.reel['views_count'] ?? 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_initialized && _controller != null)
          GestureDetector(
            onTap: () {
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
              setState(() {});
            },
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        
        // Gradient overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withAlpha(150),
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Pause icon overlay
        if (_initialized && _controller != null && !_controller!.value.isPlaying)
          Center(
            child: Icon(Icons.play_arrow_rounded,
                size: 80.r, color: Colors.white.withAlpha(150)),
          ),

        // Info
        Positioned(
          left: 16.w,
          bottom: 30.h,
          right: 80.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: profAvatar != null
                        ? NetworkImage(profAvatar)
                        : const NetworkImage('https://ui-avatars.com/api/?name=P'),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '@$profName',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (title.isNotEmpty)
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600)),
              if (desc.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(desc,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),

        // Actions
        Positioned(
          right: 16.w,
          bottom: 40.h,
          child: Column(
            children: [
              _ActionBtn(
                icon: widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: widget.isLiked ? Colors.redAccent : Colors.white,
                label: '$likes',
                onTap: widget.onLike,
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                icon: Icons.play_arrow_rounded,
                color: Colors.white,
                label: '$views',
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                icon: Icons.share_rounded,
                color: Colors.white,
                label: 'Compartir',
                onTap: () {
                  // TODO: Share logic
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 36.r),
          onPressed: onTap,
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
