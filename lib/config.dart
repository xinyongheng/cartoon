import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class Config {
  static double width = 360;
  static double height = 640;

  static Color themeColor = Color(0xff00adfd);
  static final Color titleColor = Colors.white;

  static MaterialColor primarySwatch = Colors.blue;
  static FontWeight normal = FontWeight.normal; //w400
  static FontWeight bold = FontWeight.bold; //w700
  static FontWeight medium = FontWeight.w500;

  static final double titleSize = 22.sp;
  static final double mediumSize = 19.sp;
  static final double normalSize = 15.sp;

  /// 当前设备宽度 dp
  static double get screenWidth => ScreenUtil().screenWidth;

  ///当前设备高度 dp
  static double get screenHeight => ScreenUtil().screenHeight;

  static AppBar appBar<T extends Object?>(BuildContext context, String text,
      [bool showBack = true, List<Widget>? actions, VoidCallback? onPressed]) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack ? _buttonBack(context, onPressed) : null,
      actions: actions,
      title: appBarText(text),
      centerTitle: true,
    );
  }

  static Text appBarText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: titleColor,
        fontSize: 22.sp,
        fontWeight: medium,
      ),
    );
  }

  static Text titleText(String data,
      {bool inherit = true,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle}) {
    return Text(
      data,
      style:
          TextStyle(inherit: inherit, color: color, fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle),
    );
  }

  static _buttonBack(BuildContext context, [VoidCallback? onPress]) {
    return IconButton(
      onPressed: onPress ?? () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back, color: Config.titleColor),
    );
  }
}
