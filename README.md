# Multi Sel

여러 명이 동시에 화면을 터치하면, 조건 충족 시 한 명을 랜덤으로 선택하는 Flutter 앱입니다.

## 핵심 기능

- 다중 터치로 플레이어 참가(최대 10명)
- 최소 2명 이상일 때 자동 시작 타이머(5초)
- 시작 시 활성 플레이어 중 랜덤 승자 1명 선택
- 승자 위치 기반 결과 화면 표시 및 다시 시작

## 실제 화면 흐름

1. 홈 화면(`Start Game`)
2. 터치 대기 화면 (`TouchWaitingScreen`)
3. 자동 시작 후 승자 선택 (`GameService`)
4. 승자 발표 화면 (`WinnerSelectedScreen`)

참고: `CountdownInProgressScreen`은 현재 메인 플레이 흐름보다 디버그/보조 성격으로 포함되어 있습니다.

## 프로젝트 구조

```text
lib/
  main.dart
  models/player.dart
  services/game_service.dart
  theme/app_theme.dart
  screens/
    touch_waiting_screen.dart
    countdown_in_progress_screen.dart
    winner_selected_screen.dart
```

## 실행 방법

```bash
flutter pub get
flutter run
```

## 개발 환경

- Flutter SDK 3.10.8+
- Dart SDK

