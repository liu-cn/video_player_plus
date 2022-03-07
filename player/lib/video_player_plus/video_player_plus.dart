import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'format.dart';
import 'full_screen.dart';
import 'progress_bar.dart';

enum VideoType {
  network,
  file,
  asset,
}

//根据条件判断是否显示该组件
Widget ifShowWidget<T>(T, bool isShow) {
  if (isShow) {
    return T;
  } else {
    return const SizedBox();
  }
}

class VideoPlayerPlus extends StatefulWidget {
  const VideoPlayerPlus(
      {Key? key,
      required this.videoType,
      required this.videoPath,
      this.authPlay = true,
      this.looping = false,
      this.onLoading,
      this.title,
      this.seekToSecond,
      this.height,
      this.width})
      : super(key: key);

  //视频类型 本地 /网络
  final VideoType videoType;

  //视频高度，如果确定视频的高度，并填写此参数后，视频加载中时会根据视频尺寸的大小来渲染加载中的组件，不会等到视频加载好才渲染，此体验更好
  final double? height;

  //视频宽度，如果确定视频的高度，并填写此参数后，视频加载中时会根据视频尺寸的大小来渲染加载中的组件，不会等到视频加载好才渲染，此体验更好
  final double? width;

  //加载好视频后跳转到第几秒开始播放?
  final int? seekToSecond;

  //视频标题
  final String? title;

  //循环播放
  final bool looping;

  //视频地址
  final String videoPath;

  //自动播放？
  final bool authPlay;

  //加载中时候显示的组件，自定义
  final Widget? onLoading;

  const VideoPlayerPlus.network(this.videoPath,
      {Key? key,
      this.videoType = VideoType.network,
      this.authPlay = false,
      this.looping = false,
      this.onLoading,
      this.title,
      this.seekToSecond,
      this.height,
      this.width})
      : super(key: key);

  const VideoPlayerPlus.file(this.videoPath,
      {Key? key,
      this.videoType = VideoType.file,
      this.authPlay = false,
      this.looping = false,
      this.onLoading,
      this.title,
      this.seekToSecond,
      this.height,
      this.width})
      : super(key: key);

  const VideoPlayerPlus.asset(this.videoPath,
      {Key? key,
      this.videoType = VideoType.asset,
      this.authPlay = false,
      this.looping = false,
      this.onLoading,
      this.title,
      this.seekToSecond,
      this.height,
      this.width})
      : super(key: key);

  @override
  _VideoPlayerPlusState createState() => _VideoPlayerPlusState();
}

class _VideoPlayerPlusState extends State<VideoPlayerPlus> {
  late final VideoPlayerController _videoCtl;

  //手机竖屏状态下高度
  double phoneHeight = 0;

  //手机竖屏状态下宽度
  double phoneWidth = 0;

  //水平滑动快进快退时候的起始位置
  late double verticalMoveStart;

  //水平滑动快进快退时候的终止位置
  late double verticalMoveEnd;

  //当前是否处于滑动进度条状态，
  bool isSlide = false;

  //水平滑动时候，预跳转的位置，秒
  late int willSkipToSec = 0;

  //水平滑动时候，改变(快进快退)的秒数
  late int changeSubSec = 0;

  //是否展示快进快退信息
  bool isShowChangeEcho = false;

  //当前播放进度
  late double progress;

  //当前播放速度
  late double speed;

  //屏幕宽度
  late double screenWidth;

  //是否显示导航栏
  bool isShowNav = true;

  //当前进度条的位置
  double _currentSliderValue = 0;

  //视频总秒数，初始为1，后面视频加载好后会赋值
  int videoTotalSecond = 1;

  //当前是否全屏
  bool currentIsFullScreen = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  //同步播放中的进度条
  void syncVideoProgress() {
    //进度条处于滑动状态时
    // 不让刷新进度条的位置，此时进度条的位置随着拖动时间来改变位置
    if (!isSlide) {
      _currentSliderValue = _videoCtl.value.position.inSeconds.toDouble();
      setState(() {});
    }
  }

  void videoListener() {
    setState(() {
      syncVideoProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    if (_videoCtl.value.isInitialized) {
      return Column(
        children: [
          AspectRatio(
              aspectRatio: _videoCtl.value.aspectRatio,
              child: GestureDetector(
                //双击暂停或播放
                onDoubleTap: () {
                  _videoCtl.value.isPlaying
                      ? _videoCtl.pause()
                      : _videoCtl.play();
                },
                //单击显示四周导航栏
                onTap: () {
                  setState(() {
                    isShowNav = !isShowNav;
                  });
                },

                child: Stack(children: [
                  SizedBox(
                      // width: 300,
                      height: 9999,
                      child: VideoPlayer(_videoCtl)),
                  ifShowWidget(
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
                      isShowNav),
                ]),
              )),
        ],
      );
    } else {
      if (widget.height != null) {
        if (widget.onLoading != null) {
          return Container(
            color: Colors.amber,
            width: widget.width,
            height: widget.height!,
            child: widget.onLoading!,
          );
        } else {
          return Container(
            color: Colors.black,
            width: widget.width ?? 400,
            height: widget.height!,
            child: const Text("加载中！"),
          );
        }
      }
      return const Text("加载中！！！！！！！！！！");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoCtl.dispose();
    _videoCtl.removeListener(videoListener);
  }

  //取消全屏播放
  void cancelFullScreen() {
    currentIsFullScreen = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    setState(() {});
  }

  //全屏播放
  void fullScreen() {
    currentIsFullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    setState(() {});
  }

  //导航栏视频播放器下方导航栏
  Row buildBottomNavBar() {
    return Row(
      children: [
        Expanded(
          flex: 15,
          child: buildBottomProgressBar(_currentSliderValue, videoTotalSecond),
        ),
      ],
    );
  }

  Widget buildBottomProgressBar(double position, int totalSecond) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: VideoProgressBar(
        _currentSliderValue,
        totalSecond.toDouble(),
        _videoCtl.value.isPlaying,
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

          _videoCtl.seekTo(Duration(seconds: position.toInt()));
        },
        onTabDown: (position) {
          _videoCtl.seekTo(Duration(seconds: position.toInt()));
        },
        onFullScreen: (isFullScreen) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FullScreen(
              _videoCtl,
              title: widget.title ?? "",
            );
          }));
        },
        onPlay: (bool isPlaying) {
          setState(() {
            if (isPlaying) {
              _videoCtl.pause();
            } else {
              _videoCtl.play();
            }
          });
        },
      ),
    );
  }

  String getVideoProgressNum() {
    var totalStr = formatDuration(_videoCtl.value.duration.inSeconds);
    var currentStr = formatDuration(_videoCtl.value.position.inSeconds);
    return "$currentStr/$totalStr";
  }

  //获取格式化后当前播放的时间
  String get currentVideoProgressSeconds {
    return formatDuration(_videoCtl.value.position.inSeconds);
  }

  //获取格式化后当前播放的时间
  String get totalVideoProgressSeconds {
    return formatDuration(_videoCtl.value.duration.inSeconds);
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

  // TODO 初始化视频类型
  void init() {
    switch (widget.videoType) {
      case VideoType.network:
        _videoCtl = VideoPlayerController.network(widget.videoPath)
          ..initialize().then((_) {
            // 确保在初始化视频后显示第一帧，直至在按下播放按钮。
            if (widget.authPlay) {
              _videoCtl.play();
            }
            _videoCtl.setLooping(widget.looping);
            videoTotalSecond = _videoCtl.value.duration.inSeconds;
            if (widget.seekToSecond != null) {
              if (widget.seekToSecond! <= videoTotalSecond) {
                _videoCtl.seekTo(Duration(seconds: widget.seekToSecond!));
              }
            }

            setState(() {});
          });
        break;
      case VideoType.file:
        _videoCtl = VideoPlayerController.file(File(widget.videoPath))
          ..initialize().then((_) {
            if (widget.authPlay) {
              _videoCtl.play();
            }
            _videoCtl.setLooping(widget.looping);
            videoTotalSecond = _videoCtl.value.duration.inSeconds;
            //确保跳转的秒数小于等于视频的总秒数，如果大于则不跳转
            if (widget.seekToSecond != null) {
              if (widget.seekToSecond! <= videoTotalSecond) {
                _videoCtl.seekTo(Duration(seconds: widget.seekToSecond!));
              }
            }
            // 确保在初始化视频后显示第一帧，直至在按下播放按钮。
            setState(() {});
          });
        break;
      case VideoType.asset:
        _videoCtl = VideoPlayerController.asset(widget.videoPath)
          ..initialize().then((_) {
            if (widget.authPlay) {
              _videoCtl.play();
            }
            _videoCtl.setLooping(widget.looping);
            videoTotalSecond = _videoCtl.value.duration.inSeconds;
            //确保跳转的秒数小于等于视频的总秒数，如果大于则不跳转
            if (widget.seekToSecond != null) {
              if (widget.seekToSecond! <= videoTotalSecond) {
                _videoCtl.seekTo(Duration(seconds: widget.seekToSecond!));
              }
            }
            // 确保在初始化视频后显示第一帧，直至在按下播放按钮。
            setState(() {});
          });
        break;
    }
    //执行监听，只要有内容就会刷新
    _videoCtl.addListener(videoListener);
  }
}
