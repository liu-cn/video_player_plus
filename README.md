#### flutter的视频播放器

1. 支持网络视频，本地视频和项目视频三种视频类型。

2. 支持全屏播放

3. 支持视频尺寸自适配手机屏幕

4. 支持倍速播放（包括自定义倍速）

5. 支持显示视频进度 ，进度条拖拽点击跳转视频位置

6. 支持循环播放

7. 支持视频加载好自动跳转指定秒数播放

8. 支持控制视频音量

9. 支持锁定屏幕

10. 支持设置视频标题

11. 支持自定义进度条颜色（高斯模糊，毛玻璃效果的进度条）



#### 使用方法
把目前没有上架到pub，所以想用可以把 player/lib/video_player_plus/ 目录下的四个文件复制到你的项目里就可以了，当然还要下载一下官方的video_player
用法很极简，一行代码就可以搞定

```dart
VideoPlayerPlus.network("网络视频的地址"),
VideoPlayerPlus.asset("项目视频地址"),
VideoPlayerPlus.file("本地视频地址"),
```





#### 使用效果

##### 竖屏效果

<img src="http://cdn.motianli.com/cdn/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202022-03-07%20at%2014.29.00.png" style="zoom:50%;" />

##### 全屏效果

<img src="http://cdn.motianli.com/cdn/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202022-03-07%20at%2014.29.09.png" style="zoom:50%;" />



##### 倍速效果

![](http://cdn.motianli.com/cdn/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202022-03-07%20at%2014.29.13.png )



##### 控制音量

![](http://cdn.motianli.com/cdn/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202022-03-07%20at%2014.29.24.png)



##### 锁定屏幕

![](http://cdn.motianli.com/cdn/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202022-03-07%20at%2014.29.48.png)



##### 多个视频播放

![](http://cdn.motianli.com/cdn/Simulator%20Screen%20Shot%20-%20iPhone%2012%20Pro%20-%202022-03-07%20at%2014.35.47.png)
