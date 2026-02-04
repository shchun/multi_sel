import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/game_service.dart';
import '../models/player.dart';
import 'winner_selected_screen.dart';

class CountdownInProgressScreen extends StatefulWidget {
  const CountdownInProgressScreen({super.key});

  @override
  State<CountdownInProgressScreen> createState() => _CountdownInProgressScreenState();
}

class _CountdownInProgressScreenState extends State<CountdownInProgressScreen> {
  final GameService _gameService = GameService();
  final Map<int, String> _touchPoints = {}; // pointerId -> playerId

  @override
  void initState() {
    super.initState();
    _gameService.addListener(_onGameStateChanged);
    // 카운트다운이 시작되지 않았다면 시작
    if (_gameService.state == GameState.waiting) {
      _gameService.startCountdown();
    }
  }

  @override
  void dispose() {
    _gameService.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (_gameService.state == GameState.winner) {
      // 승자 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WinnerSelectedScreen(),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleTouchDown(PointerDownEvent event) {
    if (_gameService.state != GameState.countdown &&
        _gameService.state != GameState.selecting) return;

    final position = event.localPosition;
    // 이미 존재하는 플레이어인지 확인
    final existingPlayer = _gameService.players.firstWhere(
      (p) => (p.position - position).distance < 50,
      orElse: () => Player(
        id: '',
        position: Offset.zero,
        color: Colors.transparent,
        joinTime: DateTime.now(),
      ),
    );

    if (existingPlayer.id.isEmpty) {
      // 새 플레이어 추가
      _gameService.addPlayer(position);
      _touchPoints[event.pointer] = _gameService.players.last.id;
    } else {
      _touchPoints[event.pointer] = existingPlayer.id;
    }
  }

  void _handleTouchUp(PointerUpEvent event) {
    final playerId = _touchPoints[event.pointer];
    if (playerId != null) {
      _gameService.removePlayer(playerId);
      _touchPoints.remove(event.pointer);
    }
  }

  void _handleTouchCancel(PointerCancelEvent event) {
    final playerId = _touchPoints[event.pointer];
    if (playerId != null) {
      _gameService.removePlayer(playerId);
      _touchPoints.remove(event.pointer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // SVG Energy Lines (simulated with CustomPaint)
          CustomPaint(
            size: Size.infinite,
            painter: _EnergyLinesPainter(
              players: _gameService.players.where((p) => p.isActive).toList(),
            ),
          ),
          // Touch Points
          ..._buildTouchPoints(),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () {
                          _gameService.reset();
                          Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Center Countdown
                Expanded(
                  child: Listener(
                    onPointerDown: _handleTouchDown,
                    onPointerUp: _handleTouchUp,
                    onPointerCancel: _handleTouchCancel,
                    behavior: HitTestBehavior.translucent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _gameService.state == GameState.countdown
                                  ? '${_gameService.countdown}'
                                  : '${_gameService.activePlayerCount}',
                              key: ValueKey(_gameService.countdown),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 180,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.primary,
                                    blurRadius: 20,
                                  ),
                                  Shadow(
                                    color: AppTheme.primary,
                                    blurRadius: 40,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _gameService.state == GameState.countdown
                                ? "DON'T LET GO!"
                                : 'SELECTING...',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _gameService.state == GameState.countdown
                                ? 'Readying selection...'
                                : 'Selecting winner...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 6,
                          color: const Color(0xFF314368),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _gameService.state == GameState.countdown
                                ? (3 - _gameService.countdown) / 3
                                : _gameService.progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar Group
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _gameService.players
                        .where((p) => p.isActive)
                        .take(6)
                        .map((player) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.backgroundDark,
                              width: 2,
                            ),
                            color: player.color.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: player.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTouchPoints() {
    final activePlayers = _gameService.players.where((p) => p.isActive).toList();
    return activePlayers.map((player) {
      return _TouchPoint(
        player: player,
        left: player.position.dx / MediaQuery.of(context).size.width,
        top: player.position.dy / MediaQuery.of(context).size.height,
        size: 64,
      );
    }).toList();
  }
}

class _TouchPoint extends StatelessWidget {
  final Player player;
  final double left;
  final double top;
  final double size;

  const _TouchPoint({
    required this.player,
    required this.left,
    required this.top,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * left - size / 2,
      top: MediaQuery.of(context).size.height * top - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: player.color, width: 2),
          color: player.color.withOpacity(0.4),
          boxShadow: [
            BoxShadow(
              color: player.color.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnergyLinesPainter extends CustomPainter {
  final List<Player> players;

  _EnergyLinesPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.3)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    for (final player in players) {
      final playerX = player.position.dx;
      final playerY = player.position.dy;

      canvas.drawLine(
        Offset(playerX, playerY),
        Offset(centerX, centerY),
        glowPaint,
      );
      canvas.drawLine(
        Offset(playerX, playerY),
        Offset(centerX, centerY),
        paint..color = player.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _EnergyLinesPainter ||
        oldDelegate.players.length != players.length;
  }
}
