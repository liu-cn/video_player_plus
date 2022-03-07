import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'format.dart';

enum DrawerType { speed, episode, setting }

//根据条件判断是否显示该组件
Widget ifShowWidget<T>(T, bool isShow) {
  if (isShow) {
    return T;
  } else {
    return const SizedBox();
  }
}

List<Widget> ifShowWidgets<Widget>(List<Widget> list, bool isShow) {
  if (isShow) {
    return list;
  } else {
    return [];
  }
}

class FullScreen extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final List<double> speed;
  final String title;

  const FullScreen(this.videoPlayerController,
      {Key? key,
      this.speed = const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5],
      this.title = ""})
      : super(key: key);

  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  bool isSlide = false;
  double _currentSliderValue = 0;

  //当前音量
  // late double? currentVolume;

  //将要设置的音量
  late double whileSetVolume;

  //屏幕右侧上下滑动起始位置
  late double volumeMoveStart;

  //正在滑动设置音量
  late bool isMoveVolume = false;

  //屏幕锁定中
  bool screenLocking = false;
  bool isShowNav = false;

  //屏幕高度
  late double screenHeight;

  //屏幕宽度
  late double screenWidth;

  @override
  void initState() {
    // widget.videoPlayerController.setVolume(volume)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _currentSliderValue =
        widget.videoPlayerController.value.position.inSeconds.toDouble();

    //执行监听，只要有内容就会刷新
    widget.videoPlayerController.addListener(videoListener);

    setState(() {});
    super.initState();
  }

  //同步播放中的进度条
  void syncVideoProgress() {
    //进度条处于滑动状态时不让刷新进度条的位置，此时进度条的位置随着拖动时间来改变位置
    if (!isSlide) {
      _currentSliderValue =
          widget.videoPlayerController.value.position.inSeconds.toDouble();
      setState(() {});
    }
  }

  void setSpeed(double speed) {
    widget.videoPlayerController.setPlaybackSpeed(speed);
  }

  //点击时要打开的抽屉控件，动态替换
  late Drawer? drawer = const Drawer();

  //视频播放时监听处理事件
  void videoListener() {
    setState(() {
      syncVideoProgress();
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.removeListener(videoListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  //控制按钮
  List<Positioned> buildNavBar() {
    var lock = Positioned(
      left: 10,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          IconButton(
            onPressed: () {
              screenLocking = !screenLocking;
              setState(() {});
            },
            icon: Icon(screenLocking ? Icons.lock : Icons.lock_open),
            color: Colors.white,
          ),
        ],
      ),
    );
    if (isShowNav && !screenLocking) {
      return [
        Positioned(
          left: 70,
          top: 20,
          child: Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              IconButton(
                onPressed: () {
                  cancelFullScreen();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              IconButton(
                onPressed: () {
                  screenLocking = !screenLocking;
                  setState(() {});
                },
                icon: Icon(screenLocking ? Icons.lock : Icons.lock_open),
                color: Colors.white,
              ),
            ],
          ),
        ),
        lock,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              buildBottomNavBar(),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 0,
          top: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    setNextOpenDrawer(DrawerType.speed);
                    // Scaffold.of(context).openDrawer();
                    Scaffold.of(context).openEndDrawer();
                    setState(() {});
                    // setSpeed(0.5);
                    // 打开设置倍速抽屉
                  },
                  icon: const Icon(Icons.speed),
                  color: Colors.white,
                );
              }),
            ],
          ),
        ),
      ];
    } else if (isShowNav && screenLocking) {
      return [lock];
    } else {
      return [];
    }
  }

  //取消全屏播放
  void cancelFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    setState(() {});
  }

  //点击按键时随机变换抽屉
  Drawer setNextOpenDrawer(DrawerType type) {
    late Drawer thisDrawer;
    switch (type) {
      case DrawerType.speed:
        thisDrawer = buildSpeedDrawer();
        break;
      case DrawerType.episode:
        break;
      case DrawerType.setting:
        break;
    }
    drawer = thisDrawer;

    return thisDrawer;
  }

  Drawer buildSpeedDrawer() {
    List<TextButton> list = [];

    for (double sp in widget.speed) {
      list.add(TextButton(
        onPressed: () {
          setSpeed(sp);
        },
        child: Text("$sp倍速"),
      ));
    }
    return Drawer(
      child: ListView(
        children: [...list],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: drawer!,
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: drawer!,
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(

        //单击显示四周导航栏
        onTap: () {
          setState(() {
            isShowNav = !isShowNav;
          });
        },
        //双击暂停或播放
        onDoubleTap: () {
          widget.videoPlayerController.value.isPlaying
              ? widget.videoPlayerController.pause()
              : widget.videoPlayerController.play();
        },
        onVerticalDragStart: (v) {
          if (!screenLocking) {
            //右侧滑动
            if (v.globalPosition.dx >= screenWidth / 2) {
              volumeMoveStart = v.globalPosition.dy;
              isMoveVolume = true;
            }
          }
        },
        onVerticalDragUpdate: (v) {
          if (!screenLocking) {
            //右侧滑动
            if (v.globalPosition.dx >= screenWidth / 2) {
              double move = volumeMoveStart - v.globalPosition.dy;
              var than = move / screenHeight;
              widget.videoPlayerController.setVolume(
                  widget.videoPlayerController.value.volume + than / 10);
            }
          }
        },
        onVerticalDragEnd: (v) {
          if (!screenLocking) {
            isMoveVolume = false;
            setState(() {});
          }
        },

        child: Stack(alignment: AlignmentDirectional.center, children: [
          AspectRatio(
            aspectRatio: widget.videoPlayerController.value.aspectRatio,
            child: VideoPlayer(widget.videoPlayerController),
          ),
          ifShowWidget(
              buildVolumeProgressBar(widget.videoPlayerController.value.volume),
              isMoveVolume && !screenLocking),
          //点击时显示的控制组件
          ...buildNavBar(),
          Row(
            children: const [],
          )
        ]),
      ),
    );
  }

//导航栏视频播放器下方导航栏
  Row buildBottomNavBar() {
    return Row(
      children: [
        // 进度条组件
        Expanded(
          flex: 15,
          child: buildBottomProgressBar(_currentSliderValue.toDouble(),
              widget.videoPlayerController.value.duration.inSeconds),
        ),

      ],
    );
  }

//获取格式化后当前播放的时间
  String get currentVideoProgressSeconds {
    return formatDuration(
        widget.videoPlayerController.value.position.inSeconds);
  }
  Widget buildBottomProgressBar(double position, int totalSecond) {
    return Padding(
      padding:  const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: VideoProgressBar(
        _currentSliderValue,
        totalSecond.toDouble(),
        widget.videoPlayerController.value.isPlaying,
        onChange: (position) {
          if (!isSlide) {
            setState(() {
              isSlide = true;
              _currentSliderValue = position;
            });
          } else {
            setState(() {
              _currentSliderValue = position;
            });
          }
        },
        onChangeEnd: (position) {
          if (isSlide) {
            setState(() {
              isSlide = false;
            });
          }

          widget.videoPlayerController.seekTo(Duration(seconds: position.toInt()));
        },
        onTabDown: (position) {
          widget.videoPlayerController.seekTo(Duration(seconds: position.toInt()));
        },
        onFullScreen: (isFullScreen) {
          cancelFullScreen();
          Navigator.pop(context);
        },
        onPlay: (bool isPlaying) {
          setState(() {
            if (isPlaying) {
              widget.videoPlayerController.pause();
            } else {
              widget.videoPlayerController.play();
            }
          });
        },
      ),
    );
  }

//获取格式化后当前播放的时间
  String get totalVideoProgressSeconds {
    return formatDuration(
        widget.videoPlayerController.value.duration.inSeconds);
  }

  int getVideoProgressSecondsFlex(String string) {
    if (string.length == 4) {
      return 2;
    } else if (string.length == 5) {
      return 3;
    } else {
      return 4;
    }
  }

  //右侧滑动加减音量时显示该控件
  Widget buildVolumeProgressBar(double progress) {
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        height: screenHeight / 2,
        //单独一个Column在滑动时候会颤动，外面套个SizedBox固定住就可以了
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              progress > 0 ? Icons.volume_down : Icons.volume_off,
              color: Colors.white,
            ),
            Stack(alignment: Alignment.bottomCenter, children: [
              Container(
                width: 30,
                height: 100,
                color: Colors.black,
              ),
              Container(
                width: 30,
                height: 100 * progress,
                color: Colors.white,
              )
            ]),
          ],
        ),
      ),
    );
  }
}
