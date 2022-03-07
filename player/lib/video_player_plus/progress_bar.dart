import 'dart:ui';
import 'format.dart' as format;
import 'package:flutter/material.dart';

typedef ValueChanged<T> = void Function(T value);
typedef Callback = void Function();

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar(
      this.currentSecond, this.videoTotalSecond, this.isPlaying,
      {Key? key,
        this.onChange,
        this.onChangeEnd,
        this.onTabDown,
        this.onPlay,
        this.onFullScreen,
        this.progressBackgroundColor,
        this.progressColor,
        this.progressBarColor,
        this.iconColor = Colors.white,
        this.isFullScreen=false})
      : super(key: key);

  //当前秒数
  final double currentSecond;
  //是否全屏
  final bool isFullScreen;
  //是否正在播放
  final bool isPlaying;
  //视频总秒数
  final double videoTotalSecond;
  //进度条背景颜色
  final Color? progressBackgroundColor;
  //暂停播放全屏颜色
  final Color iconColor;
  //进度条颜色
  final Color? progressColor;
  //进度条拖动按钮颜色
  final Color? progressBarColor;
  //拖动进度条时触发事件
  final ValueChanged<double>? onChange;
  //拖动进度条结束触发事件
  final ValueChanged<double>? onChangeEnd;
  //单击进度条结束触发事件
  final ValueChanged<double>? onTabDown;
  //点击播放或者暂停时触发参数bool 表示当前是否在播放
  final ValueChanged<bool>? onPlay;
  //参数表示当前是否全屏
  final ValueChanged<bool>? onFullScreen;

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  final GlobalKey _progressBarFocusKey = GlobalKey();
  final GlobalKey _progressBarKey = GlobalKey();
  double? _progressBarWidth; //进度条宽度
  double? _progressBarStartPosition; //进度条起始位置绝对坐标
  double currentProgressPosition = 0;//初始为0
  static const double barWidth = 4;//进度条拖动按钮默认宽度4
  static const double backgroundHeight = 26.0;//进度条背景默认26高度
  static const double iconSize = 10; //默认播放全屏暂停按钮大小

//当前是否全屏
   bool isFullScreen=false;

  @override
  Widget build(BuildContext context) {

    //判断当前是否全屏
    bool checkIsFullScreen(){
      return MediaQuery.of(context).size.width>MediaQuery.of(context).size.height;
    }

    //获取进度条起始位置绝对坐标
    double _getProgressBarStartPosition() {
      if (_progressBarStartPosition != null) {
        return _progressBarStartPosition!;
      }
      if (_progressBarKey.currentContext != null) {
        final RenderBox box =
        (_progressBarKey.currentContext!.findRenderObject() as RenderBox);
        _progressBarStartPosition = box.localToGlobal(Offset.zero).dx;
        return _progressBarStartPosition!;
      } else {
        return 0;
      }
    }

    //获取进度条宽度
    double _getProgressBarWidth() {
      if (_progressBarWidth != null) {
        return _progressBarWidth!;
      }
      if (_progressBarKey.currentContext != null) {
        final RenderBox box =
        (_progressBarKey.currentContext!.findRenderObject() as RenderBox);
        _progressBarWidth = box.size.width;
        return _progressBarWidth!;
      } else {
        return 0;
      }
    }

    //拖动进度条时的百分比=拖动时x轴的绝对坐标-进度条的起始位置x轴坐标/进度条的总长度
    double calculationCurrentProgress(double x) {
      currentProgressPosition =
          (x - _getProgressBarStartPosition()) / _getProgressBarWidth();
      if (currentProgressPosition > 1) {
        currentProgressPosition = 1;
      }
      if (currentProgressPosition < 0) {
        currentProgressPosition = 0;
      }
      return currentProgressPosition;
    }

    IconButton buildFullScreen() {
      return IconButton(
        icon: Icon(
          Icons.fullscreen,
          size: iconSize,
          color: widget.iconColor,
        ),
        onPressed: () {
          if (widget.onFullScreen != null) {
            widget.onFullScreen!(isFullScreen);
          }
        },
      );
    }

    Padding buildTotalDuration() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 2, 0),
        child: Text(
          format.formatDuration(widget.videoTotalSecond.toInt()),
          style: TextStyle(
              fontSize: 10,
              color: widget.progressBackgroundColor ??
                  const Color.fromRGBO(200, 167, 153, 1)),
        ),
      );
    }

    double getBarLeftPosition() {
      if (widget.currentSecond == widget.videoTotalSecond) {
        return _getProgressBarWidth() - barWidth;
      }
      return _getProgressBarWidth() *
          (widget.currentSecond / widget.videoTotalSecond);
    }

    Stack buildProgressBar() {
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: GestureDetector(
              key: _progressBarKey,
              onTapDown: (TapDownDetails details) {
                // print(details.globalPosition);
                double position = calculationCurrentProgress(details.globalPosition.dx);
                // print("点击的位置占比：$position");
                if (widget.onTabDown != null) {
                  widget.onTabDown!(position * widget.videoTotalSecond);
                }
              },
              child: Container(
                // width: 200,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.progressBackgroundColor ??
                      const Color.fromRGBO(200, 167, 153, 1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Positioned(
            left: getBarLeftPosition(),
            child: GestureDetector(
              child: Container(
                key: _progressBarFocusKey,
                width: barWidth,
                height: 13,
                decoration: BoxDecoration(
                  // color: Color.fromRGBO(200, 167, 153, 1),
                  // boxShadow:[],TODO 进度条光标待添加阴影效果！
                  color: widget.iconColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onHorizontalDragUpdate: (e) {
                double position = calculationCurrentProgress(e.globalPosition.dx);
                if (widget.onChange != null) {
                  widget.onChange!(position * widget.videoTotalSecond);
                }
              },
              onHorizontalDragEnd: (e) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(
                      currentProgressPosition * widget.videoTotalSecond);
                }
                // print(e.primaryVelocity);
              },
            ),
          ),
        ],
      );
    }

    Padding buildCurrentDuration() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          format.formatDuration(widget.currentSecond.toInt()),
          style: TextStyle(
              fontSize: 10,
              color: widget.progressBackgroundColor ??
                  const Color.fromRGBO(200, 167, 153, 1)),
        ),
      );
    }

    IconButton buildPlayIcon() {
      return IconButton(
        icon: Icon(
          widget.isPlaying ? Icons.pause : Icons.play_arrow,
          size: iconSize,
          color: widget.iconColor,
        ),
        onPressed: () {
          if (widget.onPlay != null) {
            widget.onPlay!(widget.isPlaying);
          }
        },
      );
    }

    GestureDetector buildBackground(double width) {
      return GestureDetector(

        onHorizontalDragUpdate: (e) {
          double position = calculationCurrentProgress(e.globalPosition.dx);
          if (widget.onChange != null) {
            widget.onChange!(position * widget.videoTotalSecond);
          }
        },
        onTapDown: (TapDownDetails details) {
          // print(details.globalPosition);
          double position = calculationCurrentProgress(details.globalPosition.dx);
          // print("点击的位置占比：$position");
          if (widget.onTabDown != null) {
            widget.onTabDown!(position * widget.videoTotalSecond);
          }
        },
        onHorizontalDragEnd: (e) {
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd!(
                currentProgressPosition * widget.videoTotalSecond);
          }},

        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: ClipRect(
            //背景过滤器
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  width: width - 20,
                  height: backgroundHeight,
                  // decoration: BoxDecoration(color: Colors.grey.shade200),
                  decoration: BoxDecoration(
                      color: widget.progressBackgroundColor ?? Colors.black54),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: backgroundHeight,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildBackground(MediaQuery.of(context).size.width),
          //高斯模糊，毛玻璃效果背景
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(flex: 1, child: buildPlayIcon()), //播放按钮
              Expanded(flex: 2, child: buildCurrentDuration()), //当前播放进度
              Expanded(flex: checkIsFullScreen()?18:10, child: buildProgressBar()), //进度条
              Expanded(flex: 2, child: buildTotalDuration()), //总时长
              Expanded(flex: 1, child: buildFullScreen()), //全屏播放
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}
