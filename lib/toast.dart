import 'package:cartoon/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toast(String msg, [Toast? toastLength, ToastGravity? gravity]) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength ?? Toast.LENGTH_SHORT,
    gravity: gravity ?? ToastGravity.CENTER,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: Config.mediumSize,
  );
}
