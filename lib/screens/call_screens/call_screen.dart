import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/models/call.dart';
import 'package:teams_clone/resources/call_methods.dart';
import 'package:teams_clone/extras/user_provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import '../../extras/agora_configs.dart';

class CallScreen extends StatefulWidget {
  final Call call;
  CallScreen({@required this.call});
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallMethods _callMethods = CallMethods();
  UserProvider userProvider;
  StreamSubscription callStreamSubscription;
  final List<int> _users = [];
  bool _isMuted = false;
  RtcEngine _engine;
  var _role;

  @override
  void initState() {
    _role =
        widget.call.hasDialed ? ClientRole.Broadcaster : ClientRole.Audience;
    /*SchedulerBinding.instance.addPersistentFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      callStreamSubscription = _callMethods
          .callStream(userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        switch (ds.data()) {
          case null:
            Navigator.pop(context);
            break;
          default:
            break;
        }
      });
    });*/
    initializeAgora();
    super.initState();
    final views = _getRenderViews();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        print(
            '>>>>>>>>>>>>>>>>>>> APP_ID missing, please provide your APP_ID in settings.dart');
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>> Agora Engine is not starting');
      });
      return;
    }
  
     
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);

    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token,"teamstest", null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(_role);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>> onError: $code');
    }, joinChannelSuccess: (channel, uid, _) {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>> onJoinChannel: $channel, uid: $uid');
    }, leaveChannel: (stats) {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>> onLeaveChannel: $stats');
      _users.clear();
    }, userJoined: (uid, _) {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>> userJoined: $uid');
      _users.add(uid);
    }, userOffline: (uid, _) {
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>>  userOffline: $uid');
      _callMethods.endCall(call: widget.call);
      _users.remove(uid);
    }, firstRemoteVideoFrame: (uid, width, height, _) {
      print('>>>>>>>>>>>>>>>>>>>>>>  firstRemoteVideo: $uid ${width}x $height');
    }));
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (_role == ClientRole.Broadcaster) list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  Widget _videoView(view) => Expanded(child: Container(child: view));

  Widget _expandedVideoRow(List<Widget> views) {
    List<Widget> wrappedViews = views.map((view) => _videoView(view)).toList();
    return Expanded(child: Row(children: wrappedViews));
  }

  Widget _viewRows() {
    final List<Widget> views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }


  Widget _toolbar() {
    if (_role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
              _engine.muteLocalAudioStream(_isMuted);
            },
            child: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? Colors.white : Colors.blueAccent,
              size: 20,
            ),
            shape: CircleBorder(),
            elevation: 2,
            fillColor: _isMuted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.call_end, color: Colors.white, size: 35),
            shape: CircleBorder(),
            elevation: 2,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15),
          ),
          RawMaterialButton(
            onPressed: () => _engine.switchCamera(),
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20,
            ),
            shape: CircleBorder(),
            elevation: 2,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
