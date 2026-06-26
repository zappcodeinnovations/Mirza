import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../controllers/auth_controller.dart';
import 'auth/login_view.dart';
import 'main_navigation_shell.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late VideoPlayerController _videoController;
  Timer? _completionTimer;

  bool _isVideoReady = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _videoController =
        VideoPlayerController.asset('assets/video/mirzaa_video.mp4')
          ..setLooping(false)
          ..setVolume(0.0)
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {
              _isVideoReady = true;
            });
            _videoController.play();
            _videoController.addListener(_handleVideoProgress);
            _completionTimer = Timer(
              _videoController.value.duration +
                  const Duration(milliseconds: 250),
              _checkSession,
            );
          });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _videoController.dispose();

    super.dispose();
  }

  Future<void> _checkSession() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (!mounted) return;

    final authController = Provider.of<AuthController>(context, listen: false);

    final bool isLoggedIn = await authController.checkAuthStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  void _handleVideoProgress() {
    if (!_videoController.value.isInitialized || _hasNavigated) {
      return;
    }

    final position = _videoController.value.position;
    final duration = _videoController.value.duration;

    if (duration.inMilliseconds > 0 &&
        position >= duration - const Duration(milliseconds: 120) &&
        !_videoController.value.isPlaying) {
      _checkSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF30432A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isVideoReady && _videoController.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF30432A), Color(0xFF5D7751)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.42),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.42),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mirza Internationals',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Loading your workspace…',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
