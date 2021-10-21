import 'package:cartoon/cartoon_image.dart';
import 'package:cartoon/cartoon_parse.dart';
import 'package:html/parser.dart';

import 'service.dart';

void main() {
  Api.init();
  var date = DateTime.now();
  print(date.toIso8601String());
  print(date.toString());
  print('${date.year}-${date.month}-${date.day}:${date.hour}:${date.minute}:${date.second}');
  print(date.millisecond);
  print(date.millisecondsSinceEpoch);
  date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
  print(date.toIso8601String());
  print(date.toString());
  print('${date.year}-${date.month}-${date.day}:${date.hour}:${date.minute}:${date.second}');
  print(date.millisecond);
  print(date.millisecondsSinceEpoch);
  // final String TAG = "TEST_TAG";
  // Map<String, dynamic> map = Map();
  // map["Host"] = 'www.krmanhua.com';
  // map["Referer"] = 'http://www.krmanhua.com/manhua/congqianyouzuolingjianshan';
  // map["User-Agent"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36';
  // Api().getUrl(Api.parentUrl + "/manhua/congqianyouzuolingjianshan/391691.html").then((value) {
  //   if (value.isNotEmpty()) {
  //     //value.t.log();
  //     CartoonUtil.parseChildHref(value.t!).forEach((element) {
  //       element.log();
  //     });
  //   } else {
  //     value.message.log(TAG);
  //   }
  // });
  //homeData();
}

void homeData(){
  Api().getUrl(Api.parentUrl+"/",Api().headers()).then((value) {
    if(value.isNotEmpty()){
      CartoonUtil.parseHomeData(value.t!).forEach((key, value) {
        "$key".log("TEST");
      });
    }else{
      value.message.log();
    }
  });
}
