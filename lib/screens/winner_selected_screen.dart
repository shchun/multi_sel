import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/game_service.dart';
import '../models/player.dart';
import 'touch_waiting_screen.dart';

class WinnerSelectedScreen extends StatefulWidget {
  const WinnerSelectedScreen({super.key});

  @override
  State<WinnerSelectedScreen> createState() => _WinnerSelectedScreenState();
}

class _WinnerSelectedScreenState extends State<WinnerSelectedScreen> {
  final GameService _gameService = GameService();
  Player? _winner;

  @override
  void initState() {
    super.initState();
    _winner = _gameService.winner;
    _gameService.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _gameService.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) {
      // build 중에 setState가 호출되지 않도록 postFrameCallback 사용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _winner = _gameService.winner;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_winner == null) {
      // 승자가 없으면 홈으로 돌아가기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _gameService.reset();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const TouchWaitingScreen(),
            ),
            (route) => false,
          );
        }
      });
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // 승자 표시 영역 크기
    const double displayWidth = 250.0;
    const double displayHeight = 250.0;
    
    // 화면 경계 내에서 위치 계산
    // winner.position은 터치 대기 화면의 SafeArea 내부 좌표이므로
    // 승자 화면의 SafeArea 내부 좌표로 변환
    double left;
    double top;
    
    // winner.position이 유효한지 확인
    if (_winner!.position.dx.isFinite && _winner!.position.dy.isFinite &&
        _winner!.position.dx > 0 && _winner!.position.dy > 0) {
      // 터치 대기 화면의 SafeArea 내부 좌표를 그대로 사용
      // (두 화면 모두 SafeArea를 사용하므로 동일한 좌표계)
      left = _winner!.position.dx - displayWidth / 2;
      top = _winner!.position.dy - displayHeight / 2;
    } else {
      // 유효하지 않으면 화면 중앙에 표시
      left = (screenSize.width - displayWidth) / 2;
      top = (screenSize.height - displayHeight) / 2 - 50;
    }
    
    // 좌우 경계 체크
    if (left < 16) {
      left = 16;
    } else if (left + displayWidth > screenSize.width - 16) {
      left = screenSize.width - displayWidth - 16;
    }
    
    // 상하 경계 체크 (SafeArea는 Stack 내부에서 처리되므로 원래 좌표 사용)
    // 단, 버튼 공간만 확보
    const double minTop = 60.0; // 상단 여백
    final double maxTop = screenSize.height - displayHeight - 120.0; // 하단 버튼 공간 확보
    
    if (top < minTop) {
      top = minTop;
    } else if (top > maxTop) {
      top = maxTop;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Winner 표시 - 터치 위치에 (경계 조정됨)
            Positioned(
              left: left,
              top: top,
              child: _WinnerDisplay(winner: _winner!),
            ),
            // Top App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        // 리스너 제거 후 reset 호출
                        _gameService.removeListener(_onGameStateChanged);
                        _gameService.reset();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TouchWaitingScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Button - 확실히 하단에 배치
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + safeAreaBottom,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 리스너 제거 후 reset 호출
                      _gameService.removeListener(_onGameStateChanged);
                      _gameService.reset();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TouchWaitingScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: AppTheme.primary.withOpacity(0.3),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text(
                          'Play Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WinnerDisplay extends StatefulWidget {
  final Player winner;

  const _WinnerDisplay({required this.winner});

  @override
  State<_WinnerDisplay> createState() => _WinnerDisplayState();
}

class _WinnerDisplayState extends State<_WinnerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    return SizedBox(
      width: 250,
      height: 250,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Glow effect
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.winner.color.withOpacity(_glowAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Crown
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.workspace_premium,
                    color: AppTheme.gold,
                    size: 48,
                    shadows: [
                      Shadow(
                        color: AppTheme.gold.withOpacity(0.8),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                // Winner Circle
                Positioned(
                  top: 60,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.winner.color,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.winner.color.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
