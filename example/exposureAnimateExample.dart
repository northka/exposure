import 'package:exposure/exposure.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ExposureAnimateExample extends StatefulWidget {
  @override
  _ExposureAnimateState createState() => _ExposureAnimateState();
}

class _ExposureAnimateState extends State<ExposureAnimateExample>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<num> animation;
  int bulletIndex = 0;

  @override
  void initState() {
    super.initState();
    initAnimationCtrls();
  }

  void initAnimationCtrls() {
    controller = AnimationController(
        duration: Duration(milliseconds: 7000), vsync: this);
    animation = Tween(begin: -150, end: 750.0).animate(controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          bulletIndex += 1;
          controller.reset();
          controller.forward();
        });
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '动画曝光',
            style: TextStyle(
                fontSize: 17,
                color: Color(0xFF03081A),
                fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          elevation: 15,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 20,
            ),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: Container(
            child: Stack(
              fit: StackFit.passthrough,
              overflow: Overflow.visible,
              children: <Widget>[
                AnimatedBulletScreenItem(
                  child: ExposureDetector(
                      key: Key('exposure_animate_$bulletIndex'),
                      child: BulletScreenItem(
                        index: bulletIndex,
                      ),
                      onExposure: (visibilityInfo) {
                        Toast.show('第$bulletIndex 条弹幕曝光', context);
                      }),
                  animation: animation,
                )
              ],
            ),
            height: 300,
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                border: Border(
                    bottom: BorderSide(color: Colors.white, width: 10)))));
  }
}

class BulletScreenItem extends StatelessWidget {
  final int index;
  BulletScreenItem({this.index});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Container(
        height: 20,
        decoration: BoxDecoration(
            color: Color.fromRGBO(0x03, 0x08, 0x1A, 0.6),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/gameIcon.png',
                    width: 16,
                    height: 16,
                  )),
            ),
            Text(
              '第$index 条弹幕返利',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
            Image.asset(
              'assets/images/coin.png',
              width: 21,
              height: 21,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBulletScreenItem extends AnimatedWidget {
  final Widget child;
  final double top;
  AnimatedBulletScreenItem({
    Key key,
    Animation<num> animation,
    this.child,
    this.top = 0,
  }) : super(key: key, listenable: animation);
  @override
  Widget build(BuildContext context) {
    final Animation<num> animation = listenable as Animation<num>;
    return Positioned(
      right: animation.value.toDouble(),
      top: 50.0,
      child: child,
    );
  }
}
