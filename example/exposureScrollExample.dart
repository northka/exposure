import 'package:exposure/exposure.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ExposureScrollExample extends StatefulWidget {
  @override
  _ExposureScrollState createState() => _ExposureScrollState();
}

class _ExposureScrollState extends State<ExposureScrollExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '滚动曝光',
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
      body: CustomScrollView(slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return ExposureDetector(
            key: Key('column_scroll_$index'),
            child: Container(
              alignment: Alignment.center,
              height: 250,
              child: Text(
                index.toString(),
                style: TextStyle(fontSize: 24),
              ),
              decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  border: Border(
                      bottom: BorderSide(color: Colors.white, width: 10))),
            ),
            onExposure: (visibilityInfo) {
              Toast.show('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}',
                  context);
            },
          );
        }, childCount: 10)),
      ]),
    );
  }
}
