import 'package:flutter/material.dart';

import 'package:video_call/consts/agora.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  // State<CamScreen> createState() => _CamScreenState();
  State<CamScreen> createState() {
    return _CamScreenState();
  }
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine;   // 아고라 엔진을 저장할 변수
  int? uid;   // 내 ID
  int? otherUid;   // 상대방 ID

  // 권한 관련 작업 모두 실행
  Future<bool> init() async {
    final resp = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = resp[Permission.camera];
    final microphonePermission = resp[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted || microphonePermission != PermissionStatus.granted) {
      throw 'You do not have camera or microphone permission.';
    }

    // 엔진이 정의되지 않았다면 새로 정의
    if (engine == null) {
    engine = createAgoraRtcEngine();

    // 아고라 엔진 초기화
    await engine!.initialize(
      // 초기화할 때 사용할 설정을 제공
      RtcEngineContext(
        appId: APP_ID,   // 미리 저장해 둔 APP ID 입력
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,   // 라이브 동영상 송출에 최적화
      ),
    );

    engine!.registerEventHandler(
      // 아고라 엔진에서 받을 수 있는 이벤트 값들을 등록
      RtcEngineEventHandler(
        // 채널 접속에 성공했을 경우
        // elapsed : 실행 후 콜백이 실행되기까지 걸린 시간
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('You have entered the channel. ID : ${connection.localUid}');

          // 상태 변경 시 setState() 함수 실행
          // 값 변경 시 build() 함수 재실행
          // Clean -> setState() -> Dirty -> build() -> Clean
          setState(() {
            this.uid = connection.localUid;
          });
        },
        // 채널에서 퇴장했을 경우
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print('Leave the channel.');

          // 상태 변경 시 setState() 함수 실행
          // 값 변경 시 build() 함수 재실행
          // Clean -> setState() -> Dirty -> build() -> Clean
          setState(() {
            uid = null;
          });
        },
        // 다른 사용자가 접속했을 경우
        // remoteUid : 상대방 고유 ID
        // elapsed : 내가 채널을 들어왔을 때부터 상대가 들어올 때까지 걸린 시간
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('The other person has entered the channel. ID : $remoteUid');

          // 상태 변경 시 setState() 함수 실행
          // 값 변경 시 build() 함수 재실행
          // Clean -> setState() -> Dirty -> build() -> Clean
          setState(() {
            otherUid = remoteUid;
          });
        },
        // 다른 사용자가 채널에서 퇴장했을 경우
        // reason : 방에서 나가게 된 이유 (직접 퇴장 또는 네트워크 끊김 등)
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print('The other person left the channel. ID : $uid');

          // 상태 변경 시 setState() 함수 실행
          // 값 변경 시 build() 함수 재실행
          // Clean -> setState() -> Dirty -> build() -> Clean
          setState(() {
            otherUid = null;
          });
        },
      ),
    );

    await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);   // 엔진으로 영상을 송출하겠다고 설정
    await engine!.enableAudio();   // 동영상 기능을 활성화
    await engine!.startPreview();   // 카메라를 이용해 동영상을 화면에 실행
    // 채널에 입장
    await engine!.joinChannel(
      token: TEMP_TOKEN,
      channelId: CHANNEL_NAME,
      uid: 0,
      options: ChannelMediaOptions(),   // 영상과 관련된 여러 가지 설정 가능
    );
  }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE'),
      ),
      // Future 값을 기반으로 위젯 렌더링
      body: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Future 실행 후 에러가 있을 경우 bool 값으로 반환
          // true면 에러, false면 에러가 없는 상태
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          // Future 실행 후 아직 데이터가 없을 경우 반환받은 데이터가 있는지 확인 (로딩 중)
          // snapshot.data를 실행하면 반환된 데이터값 확인 가능
          if (!snapshot.hasData) {
            return Center(
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDB3FF)),   // 색상 지정
              ),
            );
          }

          // 나머지 상황에 권한 있음을 표시
          return Center(
            child: const Text('You have full authority!'),
          );
        }
      ),
    );
  }
}