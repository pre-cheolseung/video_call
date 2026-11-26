import 'package:flutter/material.dart';

import 'package:video_call/consts/agora.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// 내 화면 (좌측 상단 작은 화면)
class LocalVideoView extends StatelessWidget {
  final RtcEngine engine;
  final int? uid;

  const LocalVideoView({
    super.key,

    required this.engine,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    if (uid != null) {
      // 동영상을 화면에 보여주는 위젯
      return AgoraVideoView(
        // 동영상 정보를 AgoraVideoView 위젯을 통해 보여주는 것이 가능
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: const VideoCanvas(uid: 0),   // 내 영상을 보여주기 위해 0 입력
        ),
      );
    }

    // 내가 아직 채널에 접속하지 않았다면 로딩 화면
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDB3FF)),   // 색상 지정
      ),
    );
  }
}

// 상대방 화면 (전체 메인 화면)
class RemoteVideoView extends StatelessWidget {
  final RtcEngine engine;
  final int? otherUid;

  const RemoteVideoView({
    super.key,

    required this.engine,
    required this.otherUid,
  });

  @override
  Widget build(BuildContext context) {
    if (otherUid != null) {
      // 동영상을 화면에 보여주는 위젯
      return AgoraVideoView(
        // 상대방 동영상 정보를 AgoraVideoView 위젯을 통해 보여주는 것이 가능
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: otherUid),   // 상대방 영상을 보여주기 위해 otherUid 입력
          connection: const RtcConnection(channelId: CHANNEL_NAME),
        ),
      );
    }

    // 상대가 아직 채널에 접속하지 않았다면 대기 메시지
    return const Center(
      child: Text(
        'Please wait until another user joins.',
        textAlign: TextAlign.center,
      ),
    );
  }
}