
String formatDuration(int sec) {
  if (sec < 0) {
    return "00:00";
  } else if (sec < 60) {
    return "00:$sec";
  } else if (sec >= 60 && sec < 3600) {
    var minute = sec ~/ 60; //分钟
    var se = sec % 60; //秒

    String str;
    if (minute < 10) {
      str = "0$minute:";
    } else {
      str = "$minute:";
    }
    if (se < 10) {
      str = str + "0$se";
    } else {
      str = str + "$se";
    }
    return str;
  } else {
    var hour = sec ~/ 3600; //小时
    var subSec = sec % 3600; //秒
    var minute = subSec ~/ 60; //分钟
    var finalSec = subSec % 60; //秒

    String str;
    str = "$hour:";

    if (minute < 10) {
      str = str + "0$minute:";
    } else {
      str = str + "$minute:";
    }
    if (finalSec < 10) {
      str = str + "0$finalSec";
    } else {
      str = str + "$finalSec";
    }
    return str;
  }
}