import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toast {
  static show(String message, BuildContext context) {
    if(kIsWeb){
      SnackBar(content: Text(message),);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, maxLines: 1,)
          ,)
      );
    }
    else{
      Fluttertoast.showToast(
        msg: message,
      );
    }

  }
}