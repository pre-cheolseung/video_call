# Video Call

Apps that can make video calls.

- Flutter 3.47.7
- Dart 3.13.5

## Preparation

- Camera Plugin
- Permission management in Flutter
- Camera and microphone native permissions settings.

## Key Components

- WebRTC API
- Agora API
- Permission management
- BoxShadow
- Navigator

## Additional Components

- IconButton toggle
- AnimatedAlign
- ClipRRect
- AbsorbPointer

## Plugin

- agora_rtc_engine: ^6.6.4
- permission_handler: ^13.0.2

## Features

- One-on-one video call using a real phone
- Select the desired room
- Microphone can be muted
    - Check whether the other person's microphone is muted
- Camera can be turned off
    - Can check whether the other person's camera is turned off
- Front and rear cameras are interchangeable
- Ability to switch between PIP and full-screen mode
- PIP screen can be moved to any of the four corners
- End of video call

## 기능

- 실제 휴대폰을 이용해서 1:1 영상 통화
- 원하는 방 선택
- 마이크 음소거 가능
    - 상대방 마이크 음소거 여부 확인
- 카메라 끄기 가능
    - 상대방 카메라 꺼짐 여부 확인 가능
- 전면 및 후면 카메라 전환 가능
- PIP 화면 및 전체 화면 전환 가능
- PIP 화면 네 모서리로 이동 가능
- 화상 통화 종료