import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const VideoPlayerWidget({super.key, required this.videoUrl, this.title});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 80.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 16.h),
                Text(
                  'اضغط للتشغيل',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'خطأ في تحميل الفيديو',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200.h,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_hasError) {
      return Container(
        height: 200.h,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'خطأ في تحميل الفيديو',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return _chewieController != null
        ? AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        )
        : Container(
          height: 200.h,
          color: Colors.black,
          child: Center(
            child: Text(
              'فشل في إنشاء مشغل الفيديو',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const FullScreenVideoPlayer({super.key, required this.videoUrl, this.title});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            widget.title != null
                ? Text(
                  widget.title!,
                  style: const TextStyle(color: Colors.white),
                )
                : null,
      ),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _hasError
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'خطأ في تحميل الفيديو',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                )
                : _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Text(
                  'فشل في إنشاء مشغل الفيديو',
                  style: TextStyle(color: Colors.white),
                ),
      ),
    );
  }
}
