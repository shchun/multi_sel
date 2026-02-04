import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

class GameService extends ChangeNotifier {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  List<Player> _players = [];
  GameState _state = GameState.waiting;
  int _countdown = 3;
  Timer? _countdownTimer;
  Timer? _progressTimer;
  double _progress = 0.0;
  Player? _winner;
  final int maxPlayers = 10;
  final int minPlayers = 2;
  final Duration countdownDuration = const Duration(seconds: 3);
  final Duration selectionDuration = const Duration(seconds: 3);

  List<Player> get players => _players;
  GameState get state => _state;
  int get countdown => _countdown;
  double get progress => _progress;
  Player? get winner => _winner;
  int get activePlayerCount => _players.where((p) => p.isActive).length;

  final List<Color> _playerColors = [
    AppTheme.cyan,
    AppTheme.pink,
    AppTheme.lime,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.amber,
  ];

  void addPlayer(Offset position) {
    if (_state != GameState.waiting) return;
    if (_players.length >= maxPlayers) return;

    final player = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: position,
      color: _playerColors[_players.length % _playerColors.length],
      joinTime: DateTime.now(),
    );

    _players.add(player);
    notifyListeners();
  }

  void removePlayer(String playerId) {
    if (_state == GameState.countdown || _state == GameState.selecting) {
      // 카운트다운 중이거나 선택 중에는 플레이어를 비활성화만 함
      final index = _players.indexWhere((p) => p.id == playerId);
      if (index != -1) {
        _players[index].isActive = false;
        notifyListeners();
      }
    } else {
      _players.removeWhere((p) => p.id == playerId);
      notifyListeners();
    }
  }

  void startCountdown() {
    if (_players.length < minPlayers) return;
    if (_state != GameState.waiting) return;

    // 카운트다운 없이 바로 승자 선택
    _selectWinner();
  }

  void _selectWinner() {
    final activePlayers = _players.where((p) => p.isActive).toList();
    if (activePlayers.isEmpty) {
      _reset();
      return;
    }

    // 랜덤으로 승자 선택
    final random = Random();
    _winner = activePlayers[random.nextInt(activePlayers.length)];
    _state = GameState.winner;
    
    // 상태 변경을 확실히 알리기 위해 즉시 notify
    notifyListeners();
    
    // 혹시 모를 경우를 대비해 추가로 한 번 더 notify
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_state == GameState.winner) {
        notifyListeners();
      }
    });
  }

  void reset() {
    _reset();
  }

  void _reset() {
    _countdownTimer?.cancel();
    _progressTimer?.cancel();
    _players.clear();
    _state = GameState.waiting;
    _countdown = 3;
    _progress = 0.0;
    _winner = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }
}

enum GameState {
  waiting,
  countdown,
  selecting,
  winner,
}
