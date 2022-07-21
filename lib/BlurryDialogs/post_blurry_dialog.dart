import 'dart:ui';
import 'package:flutter/material.dart';


class PostsBlurryDialog extends StatelessWidget {

  String title;
  String content;
  VoidCallback imageCallBack, videoCallBack;

  PostsBlurryDialog(this.title, this.content, this.imageCallBack, this.videoCallBack);
  TextStyle textStyle = TextStyle (color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child:

        AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(19.0))),
          title: new Text(title,style: textStyle,),
          content: new Text(content, style: textStyle,),
          actions: <Widget>[
            FlatButton(
              child: new Text("Select"),
              onPressed: () {
                imageCallBack();
              },
            ),
             FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                videoCallBack();
              },
            ),
          ],
        )


    );
  }
}