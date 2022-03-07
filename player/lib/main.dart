import 'package:flutter/material.dart';
import 'package:player/video_player_plus/video_player_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'video player plus',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: Scaffold(
            appBar: AppBar(),
            body: Column(
              children: const [
                VideoPlayerPlus.network(
                    "https://apd-e58f9fa4c5a1b495191201f8d19b4722.v.smtcdns.com/vlive.qqvideo.tc.qq.com/AdfcnvRJFCdZsafZfDU8bMsA7a_adfmcLwDnXmrwPo3Y/a3418e5w76q.p201.1.mp4?platform=10901&fmt=shd&level=0&vkey=6EB8FE7AFBAA03E898C217C76661BFE83298A6B2F0CD29C7A67CFD9BBF501FCEBD853047EBF2AB668142E555ACB9619D82423F161667DC3BAC89327E489A09A4A00D81CB8A02A8A09AAAE6B802310C460DDC3AF5EB60A72E0E4D032D7EE3F66F92F855C0042238EEC6BF8A6FA217C7D1DB38A26138567A2F"),
                VideoPlayerPlus.network(
                    "https://apd-5f70613999e3357e772e31ddd10cf629.v.smtcdns.com/vlive.qqvideo.tc.qq.com/AdfcnvRJFCdZsafZfDU8bMsA7a_adfmcLwDnXmrwPo3Y/j3413i1eup6.p201.1.mp4?platform=10901&vkey=4B05FAD8E03A4E45A7DC6122CC0598A1784C0FD198632BD5E319229B22E26E9A4A488FA24ED209C13E522066BFFDC5669B893BB769F308D4E02BA045095082333DFFE600177CEA7F6C117DD9D199611D2F71B5E80BB977AB6008E34A639338D9D0AD5817F88871781F5529B5643F6A872547DC6C6D8218E3&level=0&fmt=shd")

              ],
            ),
          ),
        ));
  }
}
