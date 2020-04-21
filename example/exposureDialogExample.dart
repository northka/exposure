import 'package:exposure/exposure.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ExposureDialogExample extends StatefulWidget {
  @override
  _ExposureDialogState createState() => _ExposureDialogState();
}

class _ExposureDialogState extends State<ExposureDialogExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'dialog exposure',
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
          alignment: Alignment.center,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OutlineButton.icon(
                icon: Icon(Icons.add),
                label: Text("open alert dialog"),
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return ExposureDetector(key: Key('AlertDialog'),child: AlertDialog(
                        title: Text("alert"),
                        content: Text("are you sure?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("cancel"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          FlatButton(
                            child: Text("delete"),
                            onPressed: () {
                              // 执行删除操作
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      ),onExposure: (visibilityInfo) {
                        Toast.show('alert dialog exposure', context);
                      },)
                      ;
                    },
                  );
                },
              ),
              OutlineButton.icon(
                icon: Icon(Icons.check_box_outline_blank),
                label: Text("open option dialog"),
                onPressed: () {
                  showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                      var child = Column(
                        children: <Widget>[
                          ListTile(title: Text("select")),
                          Expanded(
                              child: ListView.builder(
                            itemCount: 30,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text("$index"),
                                onTap: () => Navigator.of(context).pop(index),
                              );
                            },
                          )),
                        ],
                      );
                      //使用AlertDialog会报错
                      //return AlertDialog(content: child);
                      return ExposureDetector(child: Dialog(child: child), key: Key('optional_dialog'),onExposure: (visibilityInfo) {
                        Toast.show('option dialog exposure', context);
                      },);
                    },
                  );
                },
              )
            ],
          ),
          decoration: BoxDecoration(color: Colors.lightGreen)),
    );
  }
}
