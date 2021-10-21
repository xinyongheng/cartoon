class Log {

  static bool LOG_TAG = true;

  static void e(String msg, {String? tag}) {
    if (LOG_TAG) {
      tag ??= "TAG";
      print('$tag ==> $msg');
    }
  }
}
