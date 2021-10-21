import 'package:cartoon/log.dart';
import 'package:dio/dio.dart';

import 'cartoon_image.dart';
import 'cartoon_parse.dart';

class Api {
  static final String _TAG = "API_TAG";
  static final parentUrl = "http://www.krmanhua.com";

  /*Map<String, dynamic> map = Map();
  map["Host"] = 'www.krmanhua.com';
  map["Referer"] = 'http://www.krmanhua.com/search/?keyword=%E5%B1%B1';
  map["User-Agent"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36';
 */

  static final Api _instance = Api._();
  Dio? _dio;

  String _nowPagePath = 'http://www.krmanhua.com';

  Api._();

  factory Api() {
    return _instance;
  }

  static void init() {
    //_instance = Api._();
  }

  Dio dio() {
    if (null == _dio) {
      _dio = Dio();
    }
    return _dio!;
  }

  void updateNowHref(String href) {
    this._nowPagePath = Uri.encodeFull(href);
  }

  String nowHref() {
    return _nowPagePath;
  }

  int nowPage = 0;
  late List<ImageBean> catalogueList;

  void recycleNowList() {
    nowPage = 0;
    catalogueList.clear();
  }

  Map<String, dynamic> headers({String? referer}) {
    var map = Map<String, dynamic>();
    map['Referer'] = referer ?? Api().nowHref();
    map["Host"] = 'www.krmanhua.com';
    map["User-Agent"] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36';
    return map;
  }

  Future<Resource<String>> getUrl(String path, [Map<String, dynamic>? headers]) async {
    Dio dioGet = dio();
    var options = Options(headers: headers);
    path.log(_TAG);
    try {
      Response<String?> response = await dioGet.get(path, options: options);
      String? result = response.data;
      response.headers.forEach((name, values) {
        "name=$name : $values".log(_TAG);
      });
      if (null == result || result.isEmpty) {
        return "empty data".empty();
      } else {
        return result.success();
      }
    } catch (e) {
      print(e);
      return e.toString().fail();
    }
  }

  Future<Resource<ImageListBean>> search(String searchName) async {
    var path = Api.parentUrl + "/search/?keyword=$searchName";
    updateNowHref(path);
    var value = await Api().getUrl(path);
    if (value.isNotEmpty()) {
      try {
        var listBean = CartoonUtil.parseImageList(path, value.t!);
        return listBean.success();
      } catch (e) {
        print(e);
        return Resource(message: e.toString(), code: Resource.FAIL_CODE);
      }
    } else if (value.isSuccess()) {
      return Resource(message: 'no data', code: Resource.EMPTY_CODE);
    } else {
      return Resource(message: value.message, code: Resource.FAIL_CODE);
    }
  }

  Future<Resource<ImageListBean>> nextPage(dynamic href) async {
    String endPath;
    if (!href.toString().startsWith("/")) {
      endPath = "/" + href.toString();
    } else
      endPath = href.toString();
    print("href=$endPath");
    var path = Api.parentUrl + endPath;
    Map<String, dynamic> map = Map();
    map["Referer"] = _nowPagePath;
    var value = await Api().getUrl(path, map);
    if (value.isNotEmpty()) {
      try {
        var listBean = CartoonUtil.parseImageList(_nowPagePath, value.t!);
        return listBean.success();
      } catch (e) {
        print(e);
        return Resource(message: e.toString(), code: Resource.FAIL_CODE);
      }
    } else if (value.isSuccess()) {
      return Resource(message: 'no data', code: Resource.EMPTY_CODE);
    } else {
      return Resource(message: value.message, code: Resource.FAIL_CODE);
    }
  }
}

class Resource<T> {
  static final String EMPTY = "empty";
  static final SUCCESS_CODE = 200;
  static final FAIL_CODE = 404;

  ///成功，但返回空
  static final EMPTY_CODE = 204;
  String message = EMPTY;
  int code = -1;
  T? t;

  Resource({T? t, String? message, int code = -1}) {
    this.code = code;
    this.t = t;
    this.message = message ?? EMPTY;
  }

  bool isSuccess() => code != FAIL_CODE;

  bool isEmpty() => null == t && code == EMPTY_CODE;

  bool isNotEmpty() => t != null && isSuccess();
}

extension Result<T> on T? {
  Resource<T> success([String? message]) {
    return Resource(t: this!, message: message ?? "success", code: Resource.SUCCESS_CODE);
  }

  T check(String explain) {
    if (null == this) {
      throw StateError("$explain is null");
    }
    if (this is List && (this as List).isEmpty) {
      throw StateError('$explain list is empty');
    }
    return this!;
  }

  log([String? tag]) {
    Log.e(this?.toString() ?? "null", tag: tag);
  }
}

extension Result1<T> on String? {
  Resource<String> fail() {
    return Resource(message: this ?? "fail", code: Resource.FAIL_CODE);
  }

  Resource<String> empty() {
    return Resource(message: this, code: Resource.EMPTY_CODE);
  }

  log([String? tag]) {
    Log.e(this ?? "null", tag: tag);
  }
}

extension ToString<T> on List<T> {
  log([String? tag]) {
    var stringBuffer = StringBuffer();
    this.forEach((value) {
      stringBuffer.write(value);
      stringBuffer.write(",");
    });
    String s = stringBuffer.toString();
    s.substring(0, s.length - 1).log(tag);
  }
}
