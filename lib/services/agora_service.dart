import 'package:flutter/foundation.dart';

import 'package:video_call/consts/agora.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? engine;   // 아고라 엔진을 저장할 변수
  int? uid;   // 내 ID
  int? otherUid;   // 상대방 ID
  bool isAudioMuted = false;   // 내 마이크 음소거 상태 (Default : 켜짐)
  bool isVideoMuted = false;   // 내 카메라 끄기 상태 (Default : 켜짐)
  bool isRemoteVideoMuted = false;   // 상대방 카메라 끄기 상태 (Default : 켜짐)

  final VoidCallback onStateChanged;   // 상태 변경을 UI에 알리기 위한 콜백 (setState 역할)

  AgoraService({required this.onStateChanged});

  // 권한 관련 작업 모두 실행
  Future<bool> init() async {
    final resp = await [Permission.camera, Permission.microphone].request();

    if (resp[Permission.camera] != PermissionStatus.granted || resp[Permission.microphone] != PermissionStatus.granted) {
      throw 'You do not have camera or microphone permission.';
    }

    // 엔진이 정의되지 않았다면 새로 정의
    if (engine == null) {
      engine = createAgoraRtcEngine();

      // 아고라 엔진 초기화
      await engine!.initialize(
        // 초기화할 때 사용할 설정을 제공
        const RtcEngineContext(
          appId: APP_ID,   // 미리 저장해 둔 APP ID 입력
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,   // 라이브 동영상 송출에 최적화
        ),
      );

      engine!.registerEventHandler(
        RtcEngineEventHandler(
          // 채널 접속에 성공했을 경우
          // elapsed : 실행 후 콜백이 실행되기까지 걸린 시간
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('You have entered the channel. ID : ${connection.localUid}');
            uid = connection.localUid;

            onStateChanged();
          },
          // 채널에서 퇴장했을 경우
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint('Leave the channel.');
            uid = null;

            onStateChanged();
          },
          // 다른 사용자가 접속했을 경우
          // remoteUid : 상대방 고유 ID
          // elapsed : 내가 채널을 들어왔을 때부터 상대가 들어올 때까지 걸린 시간
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('The other person has entered the channel. ID : $remoteUid');
            otherUid = remoteUid;

            isRemoteVideoMuted = false;   // 새 상대 입장 시 초기화

            onStateChanged();
          },
          // 다른 사용자가 채널에서 퇴장했을 경우
          // reason : 방에서 나가게 된 이유 (직접 퇴장 또는 네트워크 끊김 등)
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('The other person left the channel. ID : $remoteUid');
            otherUid = null;

            isRemoteVideoMuted = false;   // 상대 퇴장 시 초기화

            onStateChanged();
          },
          // 상대방이 비디오 송출을 끄거나 켰을 때 호출
          onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
            debugPrint('Remote user ($remoteUid) video muted : $muted');

            if (remoteUid == otherUid) {
              isRemoteVideoMuted = muted;

              onStateChanged();
            }
          },
          // 에러가 발생했을 경우 (토큰 만료, 잘못된 App ID, 네트워크 문제 등)
          onError: (ErrorCodeType err, String msg) {
            debugPrint('Agora Error [$err] : $msg');
          },
        ),
      );

      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);   // 엔진으로 영상을 송출하겠다고 설정
      await engine!.enableVideo();   // 비디오 기능을 활성화
      await engine!.enableAudio();   // 오디오 기능을 활성화
      await engine!.startPreview();   // 카메라를 이용해 동영상을 화면에 실행

      // 채널에 입장
      await engine!.joinChannel(
        token: TEMP_TOKEN,
        channelId: CHANNEL_NAME,
        uid: 0,
        options: const ChannelMediaOptions(),   // 영상과 관련된 여러 가지 설정 가능
      );
    }

    return true;
  }

  // 내 마이크 음소거 및 해제 토글
  Future<void> toggleAudio() async {
    if (engine != null) {
      isAudioMuted = !isAudioMuted;

      await engine!.muteLocalAudioStream(isAudioMuted);
      debugPrint('Local audio muted: $isAudioMuted');

      onStateChanged();
    }
  }

  // 내 카메라 끄기 및 켜기 토글
  Future<void> toggleVideo() async {
    if (engine != null) {
      isVideoMuted = !isVideoMuted;

      await engine!.muteLocalVideoStream(isVideoMuted);
      debugPrint('Local video muted: $isVideoMuted');

      onStateChanged();   // 아이콘 모양과 내 화면 UI 갱신
    }
  }

  // 전면 및 후면 카메라 전환
  Future<void> switchCamera() async {
    if (engine != null) {
      await engine!.switchCamera();
      debugPrint('Camera switched.');
    }
  }

  Future<void> dispose() async {
    if (engine != null) {
      await engine!.leaveChannel();
      await engine!.release();   // 리소스 해제

      engine = null;
    }
  }
}