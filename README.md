# Multi Sel

다중 터치 기반 랜덤 선택 게임 앱입니다. 여러 명이 동시에 화면을 터치하고 유지하면, 그 중 한 명이 랜덤으로 선택되는 게임입니다.

## 📱 프로젝트 개요

Multi Sel은 Stitches 디자인 도구로 제작된 시안을 기반으로 개발된 Flutter 앱입니다. 여러 명의 플레이어가 동시에 화면을 터치하고 유지하면, 그 중 한 명이 승자로 선택되는 간단하고 재미있는 게임입니다.

## ✨ 주요 기능

### 1. 다중 터치 지원
- 최대 10명의 플레이어가 동시에 참여 가능
- 각 플레이어는 고유한 색상으로 표시
- 실시간 터치 포인트 시각화

### 2. 자동 게임 시작
- 최소 2명 이상 모이면 자동으로 5초 카운트다운 시작
- "STARTING IN X..." 메시지로 시작 시간 표시
- 수동 시작 버튼 없이 자동 진행

### 3. 즉시 승자 선택
- 카운트다운 없이 바로 승자 선택
- 랜덤 알고리즘으로 공정한 선택
- 승자의 터치 위치에 결과 표시

### 4. 승자 화면
- 승자가 터치한 위치에 크라운과 원형 표시
- 부드러운 애니메이션 효과
- 간결하고 깔끔한 UI

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점 및 홈 화면
├── theme/
│   └── app_theme.dart                # 앱 테마 및 색상 정의
├── models/
│   └── player.dart                   # 플레이어 데이터 모델
├── services/
│   └── game_service.dart             # 게임 상태 관리 서비스
└── screens/
    ├── touch_waiting_screen.dart     # 터치 대기 화면
    ├── countdown_in_progress_screen.dart  # 카운트다운 화면 (현재 미사용)
    └── winner_selected_screen.dart   # 승자 발표 화면

assets/
└── screens/                          # Stitches 디자인 시안
    ├── touch_waiting_screen/
    ├── countdown_in_progress/
    └── winner_selected_screen/
```

## 🛠️ 기술 스택

- **Framework**: Flutter 3.10.8+
- **Language**: Dart
- **State Management**: ChangeNotifier (GameService)
- **UI Framework**: Material Design
- **Platform Support**: Android, iOS, Web, Windows, Linux, macOS

## 📋 사전 요구사항

- Flutter SDK 3.10.8 이상
- Dart SDK
- Android Studio / VS Code (선택사항)
- Android/iOS 디바이스 또는 에뮬레이터

## 🚀 실행 방법

### 1. 프로젝트 클론 및 의존성 설치

```bash
# 프로젝트 디렉토리로 이동
cd multi_sel

# Flutter 의존성 설치
flutter pub get
```

### 2. 디바이스 연결 확인

```bash
# 연결된 디바이스 확인
flutter devices
```

### 3. 앱 실행

```bash
# 디버그 모드로 실행
flutter run

# 특정 디바이스에서 실행
flutter run -d <device-id>

# 릴리즈 모드로 실행 (Android)
flutter run --release
```

### 4. 빌드

```bash
# Android APK 빌드
flutter build apk

# Android App Bundle 빌드
flutter build appbundle

# iOS 빌드 (macOS만 가능)
flutter build ios
```

## 🎮 사용 방법

### 게임 플레이

1. **앱 실행**: 앱을 실행하면 홈 화면이 표시됩니다.
2. **게임 시작**: "Start Game" 버튼을 누르거나 자동으로 터치 대기 화면으로 이동합니다.
3. **플레이어 참가**: 
   - 화면을 터치하여 플레이어로 참가
   - 최대 10명까지 참가 가능
   - 각 플레이어는 고유한 색상으로 표시
4. **자동 시작**: 
   - 최소 2명 이상 모이면 5초 후 자동으로 게임 시작
   - "STARTING IN 5..." 메시지가 표시됨
5. **승자 선택**: 
   - 게임이 시작되면 즉시 승자가 선택됨
   - 승자가 터치한 위치에 크라운과 원형 표시
6. **다시 하기**: 
   - "Play Again" 버튼을 눌러 새로운 게임 시작

### 게임 규칙

- **최소 인원**: 2명
- **최대 인원**: 10명
- **터치 유지**: 게임 중 손을 떼면 탈락
- **승자 선택**: 랜덤 알고리즘으로 선택

## 🎨 디자인

이 프로젝트는 Stitches 디자인 도구로 제작된 시안을 기반으로 개발되었습니다.

- **주요 색상**:
  - Primary: `#256af4` (파란색)
  - Background Dark: `#101622` (어두운 배경)
  - Background Light: `#f5f6f8` (밝은 배경)
  - Text Secondary: `#90a4cb` (보조 텍스트)

- **폰트**: Spline Sans (현재 시스템 폰트 사용)

## 📝 주요 클래스 설명

### GameService
게임의 전체 상태를 관리하는 싱글톤 서비스입니다.
- 플레이어 추가/제거
- 게임 상태 관리 (waiting, selecting, winner)
- 승자 선택 알고리즘

### Player
플레이어 정보를 담는 모델 클래스입니다.
- 고유 ID
- 터치 위치 (Offset)
- 색상
- 활성 상태

### TouchWaitingScreen
플레이어들이 터치하여 참가하는 화면입니다.
- 다중 터치 감지
- 자동 시작 타이머
- 플레이어 수 표시

### WinnerSelectedScreen
승자가 발표되는 화면입니다.
- 승자 위치에 결과 표시
- 애니메이션 효과
- Play Again 기능

## 🔧 개발 환경 설정

### VS Code 설정

1. Flutter 확장 설치
2. Dart 확장 설치
3. 프로젝트 열기
4. `F5` 키로 디버그 실행

### Android Studio 설정

1. Flutter 플러그인 설치
2. 프로젝트 열기
3. Run 버튼 클릭 또는 `Shift+F10`

## 🐛 문제 해결

### 디바이스 연결 문제

```bash
# ADB 서버 재시작
adb kill-server
adb start-server

# 연결된 디바이스 확인
adb devices
```

### 빌드 오류

```bash
# Flutter 클린
flutter clean

# 의존성 재설치
flutter pub get

# 다시 빌드
flutter run
```

### Hot Reload가 작동하지 않을 때

- `r` 키: Hot Reload
- `R` 키: Hot Restart
- `q` 키: 종료

## 📄 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 👥 기여

프로젝트 개선을 위한 제안이나 버그 리포트는 이슈로 등록해주세요.

## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 생성해주세요.

---

**Made with ❤️ using Flutter**
