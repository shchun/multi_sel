import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/game_service.dart';
import '../models/player.dart';
import 'winner_selected_screen.dart';

class TouchWaitingScreen extends StatefulWidget {
  const TouchWaitingScreen({super.key});

  @override
  State<TouchWaitingScreen> createState() => _TouchWaitingScreenState();
}

class _TouchWaitingScreenState extends State<TouchWaitingScreen> {
  final GameService _gameService = GameService();
  final Map<int, String> _touchPoints = {}; // pointerId -> playerId
  Timer? _autoStartTimer;
  int _countdownSeconds = 5;

  @override
  void initState() {
    super.initState();
    _gameService.addListener(_onGameStateChanged);
    _gameService.reset();
  }

  @override
  void dispose() {
    _autoStartTimer?.cancel();
    _gameService.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (_gameService.state == GameState.winner) {
      _autoStartTimer?.cancel();
      // 승자 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WinnerSelectedScreen(),
        ),
      );
    } else {
      _checkAndStartAutoStart();
      setState(() {});
    }
  }

  void _checkAndStartAutoStart() {
    // 최소 인원이 모이면 5초 타이머 시작
    if (_gameService.players.length >= _gameService.minPlayers &&
        _gameService.state == GameState.waiting) {
      if (_autoStartTimer == null || !_autoStartTimer!.isActive) {
        _startAutoStartTimer();
      }
    } else {
      // 최소 인원 미만이면 타이머 취소
      _autoStartTimer?.cancel();
      _countdownSeconds = 5;
    }
  }

  void _startAutoStartTimer() {
    _autoStartTimer?.cancel();
    _countdownSeconds = 5;

    _autoStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _countdownSeconds--;

      if (_countdownSeconds <= 0) {
        timer.cancel();
        if (_gameService.state == GameState.waiting &&
            _gameService.players.length >= _gameService.minPlayers) {
          _gameService.startCountdown();
        }
      } else {
        setState(() {});
      }
    });
  }

  void _handleTouchDown(PointerDownEvent event) {
    if (_gameService.state != GameState.waiting) return;
    if (_gameService.players.length >= _gameService.maxPlayers) return;

    final position = event.localPosition;
    _gameService.addPlayer(position);
    _touchPoints[event.pointer] = _gameService.players.last.id;

    // 햅틱 피드백
    HapticFeedback.mediumImpact();

    // 자동 시작 타이머 체크
    _checkAndStartAutoStart();
  }

  void _handleTouchUp(PointerUpEvent event) {
    final playerId = _touchPoints[event.pointer];
    if (playerId != null) {
      _gameService.removePlayer(playerId);
      _touchPoints.remove(event.pointer);
      // 플레이어 수가 변경되면 타이머 재확인
      _checkAndStartAutoStart();
    }
  }

  void _handleTouchCancel(PointerCancelEvent event) {
    final playerId = _touchPoints[event.pointer];
    if (playerId != null) {
      _gameService.removePlayer(playerId);
      _touchPoints.remove(event.pointer);
      // 플레이어 수가 변경되면 타이머 재확인
      _checkAndStartAutoStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _gameService.players.length >= _gameService.minPlayers;
    final showCountdown = isReady && _autoStartTimer != null && _autoStartTimer!.isActive;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _autoStartTimer?.cancel();
                      _gameService.reset();
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    '${_gameService.players.length} / ${_gameService.maxPlayers} Players',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 48), // Settings 버튼 제거로 인한 공간 확보
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Stack(
                children: [
                  // Animated Background Effects
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.2,
                      child: Stack(
                        children: [
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.25,
                            left: MediaQuery.of(context).size.width * 0.25,
                            child: Container(
                              width: 256,
                              height: 256,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                                child: Container(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: MediaQuery.of(context).size.height * 0.25,
                            right: MediaQuery.of(context).size.width * 0.25,
                            child: Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                                child: Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Touch Area - 실제 터치 감지
                  Listener(
                    onPointerDown: _handleTouchDown,
                    onPointerUp: _handleTouchUp,
                    onPointerCancel: _handleTouchCancel,
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // 실제 터치 포인트들
                          ..._gameService.players.map((player) {
                            return Positioned(
                              left: player.position.dx - 40,
                              top: player.position.dy - 40,
                              child: _AnimatedTouchPoint(
                                player: player,
                              ),
                            );
                          }),
                          // Center Content
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'TOUCH AND HOLD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.1,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white30,
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    isReady
                                        ? (showCountdown
                                            ? 'STARTING IN $_countdownSeconds...'
                                            : 'READY TO START!')
                                        : 'WAITING FOR OTHERS...',
                                    key: ValueKey('$isReady$_countdownSeconds'),
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Meta Text
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    'UP TO ${_gameService.maxPlayers} PLAYERS SUPPORTED',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MetaItem(icon: Icons.touch_app, text: 'Multi-touch Active'),
                      const SizedBox(width: 16),
                      _MetaItem(icon: Icons.vibration, text: 'Haptics On'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTouchPoint extends StatefulWidget {
  final Player player;

  const _AnimatedTouchPoint({required this.player});

  @override
  State<_AnimatedTouchPoint> createState() => _AnimatedTouchPointState();
}

class _AnimatedTouchPointState extends State<_AnimatedTouchPoint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _TouchPoint(
            color: widget.player.color,
            size: 80,
          ),
        );
      },
    );
  }
}

class _TouchPoint extends StatelessWidget {
  final Color color;
  final double size;

  const _TouchPoint({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
        color: color.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
