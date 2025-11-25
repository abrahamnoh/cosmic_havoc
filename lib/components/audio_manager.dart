import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager extends Component{
  bool musicEnabled = true;
  bool soundsEnabled = true;  

  @override
  FutureOr<void> onLoad() {
    FlameAudio.bgm.initialize();
    return super.onLoad();
  }

  void playMusic(){
    if (musicEnabled){
      FlameAudio.bgm.play('music.ogg');
    }
  }
}