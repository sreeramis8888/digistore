import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../advanced_network_image.dart';
import '../../../data/constants/color_constants.dart';

class VideoBannerPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isActivePage;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final bool showControls;

  const VideoBannerPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.isActivePage,
    this.autoplay = true,
    this.loop = true,
    this.muted = true,
    this.showControls = true,
  });

  @override
  State<VideoBannerPlayer> createState() => _VideoBannerPlayerState();
}

class _VideoBannerPlayerState extends State<VideoBannerPlayer> with AutomaticKeepAliveClientMixin<VideoBannerPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  late bool _isMuted;
  bool _showPlayPauseOverlay = false;
  IconData _overlayIcon = Icons.play_arrow;

  bool _isVisible = false;
  bool _isManuallyPaused = false;
  
  bool _isUsingCachedFile = false;
  Timer? _cacheTimer;
  StreamSubscription? _downloadSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.muted;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(widget.videoUrl);
      
      if (!mounted) return;

      if (fileInfo != null) {
        _isUsingCachedFile = true;
        _controller = VideoPlayerController.file(fileInfo.file);
      } else {
        _isUsingCachedFile = false;
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      }

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      _controller!.setLooping(widget.loop);
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      _handlePlaybackState();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _handlePlaybackState() {
    if (_controller == null || !_isInitialized) return;

    final shouldPlay = widget.isActivePage && _isVisible && widget.autoplay && !_isManuallyPaused;
    if (shouldPlay) {
      if (!_controller!.value.isPlaying) {
        _controller!.play();
      }
      _triggerCacheTimerIfNeeded();
    } else {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      }
      _cancelCacheAndDownload();
    }
  }

  void _triggerCacheTimerIfNeeded() {
    if (_isUsingCachedFile || _cacheTimer != null || _downloadSubscription != null) return;

    _cacheTimer = Timer(const Duration(seconds: 3), () {
      _startBackgroundDownload();
    });
  }

  void _startBackgroundDownload() {
    if (_downloadSubscription != null) return;

    _downloadSubscription = DefaultCacheManager().getFileStream(widget.videoUrl).listen(
      (fileResponse) {
        if (fileResponse is FileInfo) {
          _isUsingCachedFile = true;
          _cancelCacheAndDownload();
        }
      },
      onError: (e) {
        _cancelCacheAndDownload();
      },
      cancelOnError: true,
    );
  }

  void _cancelCacheAndDownload() {
    _cacheTimer?.cancel();
    _cacheTimer = null;
    _downloadSubscription?.cancel();
    _downloadSubscription = null;
  }

  @override
  void didUpdateWidget(VideoBannerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActivePage != oldWidget.isActivePage) {
      if (!widget.isActivePage) {
        _isManuallyPaused = false;
      }
      _handlePlaybackState();
    }
  }

  @override
  void dispose() {
    _cancelCacheAndDownload();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;
    
    final isPlaying = _controller!.value.isPlaying;
    
    if (isPlaying) {
      await _controller!.pause();
      if (!mounted) return;
      _isManuallyPaused = true;
      setState(() {
        _overlayIcon = Icons.pause;
        _showPlayPauseOverlay = true;
      });
    } else {
      await _controller!.play();
      if (!mounted) return;
      _isManuallyPaused = false;
      setState(() {
        _overlayIcon = Icons.play_arrow;
        _showPlayPauseOverlay = true;
      });
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showPlayPauseOverlay = false;
        });
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    if (!mounted) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_hasError) {
      return _buildThumbnail();
    }

    return VisibilityDetector(
      key: Key('video_visibility_${widget.videoUrl}'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        final isVisible = info.visibleFraction > 0.5;
        if (isVisible != _isVisible) {
          setState(() {
            _isVisible = isVisible;
          });
          _handlePlaybackState();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnail(),
            if (_isInitialized && _controller != null)
              AnimatedOpacity(
                opacity: _isInitialized ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              ),
            if (_showPlayPauseOverlay)
              Center(
                child: AnimatedOpacity(
                  opacity: _showPlayPauseOverlay ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _overlayIcon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            if (!_isInitialized && !_hasError)
              const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
            if (_isInitialized && widget.showControls)
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            if (_isInitialized && _controller != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller!,
                  builder: (context, value, child) {
                    final duration = value.duration.inMilliseconds;
                    final position = value.position.inMilliseconds;
                    double progress = 0.0;
                    if (duration > 0) {
                      progress = position / duration;
                    }
                    return Container(
                      height: 3,
                      width: double.infinity,
                      color: Colors.black12,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          color: kPrimaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return AdvancedNetworkImage(
      imageUrl: widget.thumbnailUrl ?? '',
      borderRadius: BorderRadius.circular(16),
      fit: BoxFit.cover,
    );
  }
}
