import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_incall_manager.dart';

enum MediaType {
  AUDIO,
  VIDEO
}

enum ForceSpeakerType {
  DEFAULT,
  FORCE_ON,
  FORCE_OFF
}

class IncallManager {
  MethodChannel _channel = Incall.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;

  IncallManager() {
    initEvent();
  }

  //init event process
  initEvent() {
    _eventSubscription = _eventChannelFor()
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  //Start InCallManager
  Future<void> start({bool auto = true, MediaType media = MediaType.AUDIO, String ringback}) async {
    await _channel.invokeMethod('start',
        <String, dynamic>{'media': media == MediaType.AUDIO ? 'audio' : 'video', 'auto': auto, 'ringback': ringback});
  }

  //Stop InCallManager
  Future<void> stop({String busytone}) async {
    await _channel
        .invokeMethod('stop', <String, dynamic>{'busytone': busytone});
  }

  Future<void> setKeepScreenOn(bool enable) async {
    await _channel
        .invokeMethod('setKeepScreenOn', <String, dynamic>{'enable': enable});
  }

  Future<void> setSpeakerphoneOn(bool enable) async {
    await _channel
        .invokeMethod('setSpeakerphoneOn', <String, dynamic>{'enable': enable});
  }

  /*
   * flag: Int
   * 0: use default action
   * 1: force speaker on
   * -1: force speaker off
   */
  Future<void> setForceSpeakerphoneOn({ForceSpeakerType flag = ForceSpeakerType.DEFAULT}) async {
    await _channel.invokeMethod(
        'setForceSpeakerphoneOn', <String, dynamic>{'flag': flag == ForceSpeakerType.DEFAULT ? 0 : (flag == ForceSpeakerType.FORCE_ON ? 1 : -1)});
  }

  Future<void> setMicrophoneMute(enable) async {
    await _channel
        .invokeMethod('setMicrophoneMute', <String, dynamic>{'enable': enable});
  }

  Future<void> turnScreenOff() async {
    await _channel.invokeMethod('turnScreenOff');
  }

  Future<void> turnScreenOn() async {
    await _channel.invokeMethod('turnScreenOn');
  }

  /*
  *get audio path
  */
  Future<void> getAudioUriJS(audioType, fileType) async {
    final Map<String, String> response = await _channel.invokeMethod(
        'getAudioUriJS',
        <String, dynamic>{'audioType': audioType, 'fileType': fileType});
    String uri = response['uri'];
    // print('getAudioUriJS:uri:$uri'); TODO: logging?
  }

  /*
  ios_category:'ios value playback or default
  seconds:android only
  */
  Future<void> startRingtone(ringtoneUriType, ios_category, seconds) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _channel.invokeMethod('startRingtone', <String, dynamic>{
          'ringtoneUriType': ringtoneUriType,
          'ios_category': ios_category
        });
      } else {
        await _channel.invokeMethod('startRingtone', <String, dynamic>{
          'ringtoneUriType': ringtoneUriType,
          'seconds': seconds
        });
      }
    } on PlatformException catch (e) {
      throw 'Unable to startRingtone: ${e.message}';
    }
  }

  Future<void> stopRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } on PlatformException catch (e) {
      throw 'Unable to stopRingtone: ${e.message}';
    }
  }

  Future<void> startRingback() async {
    try {
      await _channel.invokeMethod('startRingback');
    } on PlatformException catch (e) {
      throw 'Unable to startRingback: ${e.message}';
    }
  }

  Future<void> stopRingback() async {
    try {
      await _channel.invokeMethod('stopRingback');
    } on PlatformException catch (e) {
      throw 'Unable to stopRingback: ${e.message}';
    }
  }

  /*check record permission*/
  Future<String> checkRecordPermission() async {
    String re = "unknow";

    String response = await _channel.invokeMethod('checkRecordPermission');
    re = response;
//    print("incall_manager.dart:checkRecordPermission:" + response); TODO: logging
    return re;
  }

  /*request record permission*/
  Future<String> requestRecordPermission() async {
    String re = "unknow";
    String response = await _channel.invokeMethod('requestRecordPermission');
    re = response;
    return re;
  }

  /*check camera permission*/
  Future<String> checkCameraPermission() async {
    String re = "unknow";

    String response = await _channel.invokeMethod('checkCameraPermission');
    re = response;
    return re;
  }

  /*request camera permission*/
  Future<String> requestCameraPermission() async {
    String re = "unknow";

    String response = await _channel.invokeMethod('requestCameraPermission');
    re = response;

    return re;
  }

  EventChannel _eventChannelFor() {
    return new EventChannel('cloudwebrtc.com/incall.manager.event');
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;

    switch (map['event']) {
      case 'demoEvent':
        String id = map['id'];
        String value = map['value'];
//        print("demo event data:$id $value");
        break;
      case 'WiredHeadset': //wire headset is plugged
        bool isPlugged = map['isPlugged'];
        bool hasMic = map['hasMic'];
        String deviceName = map['deviceName'];
//        print(
//            "WiredHeadset:isPlugged:$isPlugged hasMic:$hasMic deviceName:$deviceName");
        break;
      case 'NoisyAudio': //noisy audio
        String status = map['status'];
//        print("NoisyAudio:status:$status");
        break;
      case 'MediaButton':
        String eventText = map['eventText'];
        int eventCode = map['eventCode'];
        break;
      case 'Proximity':
        bool isNear = map['isNear'];
        break;
      case 'onAudioFocusChange':
        String eventText = map['eventText'];
        int eventCode = map['eventCode'];
        break;
      case 'onAudioDeviceChanged':
        String availableAudioDeviceList = map['availableAudioDeviceList'];
        String selectedAudioDevice = map['selectedAudioDevice'];
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}
