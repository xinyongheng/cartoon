import 'package:cartoon/cartoon_image.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'service.dart';

final int SEARCH_TYPE = 1;

class CartoonUtil {
  ///图片 ID
  static final String SEARCH_TAG_ID = "list_img";

  ///页数 class值
  static final String PAGE_TAG_CLASS = 'pagination';

  static final List<ImageBean> menuList = [
    ImageBean("/update/", "", "最近更新", '2021-10-11', ''),
    ImageBean("/comic_list/shaonian/", "", "热血少年", '2021-10-11', ''),
    ImageBean("/comic_list/shaonv/", "", "少女漫画", '2021-10-11', ''),
    ImageBean("/comic_list/kehuanmohuan/", "", "科幻魔幻", '2021-10-11', ''),
    ImageBean("/comic_list/dushi/", "", "都市校园", '2021-10-11', ''),
    ImageBean("/comic_list/gaoxiao/", "", "搞笑漫画", '2021-10-11', ''),
    ImageBean("/comic_list/shenghuolianai/", "", "生活恋爱", '2021-10-11', ''),
    ImageBean("/comic_list/xuanyi/", "", "悬疑恐怖", '2021-10-11', '')
  ];

  static List<ImageBean> parseImage(String htmlString) {
    dom.Element? body = parser.parse(htmlString).body;
    body.check('body');
    var id = SEARCH_TAG_ID;
    dom.Element? ul = body!.querySelector('#$id');
    ul.check("ul");
    List<dom.Element> lis = ul!.getElementsByTagName('li');
    lis.check('cartoon');
    List<ImageBean> imageList = <ImageBean>[];
    lis.forEach((li) {
      imageList.add(ImageBean(
          loadOne(li.getElementsByTagName('a'))?.attributes['href'],
          loadOne(li.getElementsByTagName('img'))?.attributes['src'],
          loadOne(li.getElementsByTagName('p'))?.text,
          loadOne(li.getElementsByTagName('em '))?.text,
          loadOne(li.getElementsByTagName('span'))?.text));
    });
    return imageList;
  }

  static dom.Element? loadOne(List<dom.Element>? list) {
    if (null == list || list.isEmpty) return null;
    return list[0];
  }

  static ImageListBean parseImageList(String href, String htmlString) {
    dom.Element? body = parser.parse(htmlString).body;
    body.check('body');
    var id = SEARCH_TAG_ID;
    dom.Element? ul = body!.querySelector('#$id');
    ul.check("ul");
    List<dom.Element> lis = ul!.getElementsByTagName('li');
    lis.check('cartoon');
    List<ImageBean> imageList = <ImageBean>[];
    ImageListBean listBean = ImageListBean(imageList, PageBean(nowHref: href));
    lis.forEach((li) {
      imageList.add(ImageBean(
          loadOne(li.getElementsByTagName('a'))?.attributes['href'],
          loadOne(li.getElementsByTagName('img'))?.attributes['src'],
          loadOne(li.getElementsByTagName('p'))?.text,
          loadOne(li.getElementsByTagName('em '))?.text,
          loadOne(li.getElementsByTagName('span'))?.text));
    });
    listBean.pageBean!.loadMaxPage(loadOne(body.getElementsByClassName(PAGE_TAG_CLASS)));
    return listBean;
  }

  static List<ImageBean> parseChild(String htmlString) {
    var body = parser.parse(htmlString).body;
    body.check('body');
    var ul = loadOne(body!.getElementsByClassName('jslist01'));
    ul.check('child');
    var lis = ul!.getElementsByTagName('li');
    lis.check('child list');
    List<ImageBean> list = [];
    lis.forEach((element) {
      var a = loadOne(element.getElementsByTagName('a'));
      a?.attributes['title'].log();
      list.add(ImageBean(a?.attributes['href'], null, a?.attributes['title'], null, null));
    });
    return list;
  }

  static List<String> parseChildHref(String htmlString) {
    var body = parser.parse(htmlString).body.check('body');
    var imageElement = body.getElementsByTagName('script').firstWhere((element) => element.text.contains('z_yurl'));
    var text = imageElement.text;
    text.log();
    var textArray = text.split(';');
    String? head;
    List<String>? imageChildUrl;
    textArray.forEach((element) {
      if (element.isNotEmpty) {
        if (element.contains('z_yurl')) {
          head = _parseImageUrlHead(element);
        } else if (element.contains('z_img')) {
          imageChildUrl = _parseImageUrlEnd(element);
        }
      }
    });
    head.check("图片子元素链接头");
    for (var i = 0; i < imageChildUrl.check('图片子元素').length; i++) {
      imageChildUrl![i] = head! + "/" + imageChildUrl![i];
    }
    return imageChildUrl!;
  }

  static String _parseImageUrlHead(String s) {
    int start = s.indexOf('http');
    int end = s.lastIndexOf("/'");
    if (start < 0 || end < 0 || start > end) {
      s.log();
      throw StateError('图片网址头解析错误-$s');
    }
    return s.substring(start, end);
  }

  static List<String> _parseImageUrlEnd(String content) {
    var s = content.replaceAll('"', '');
    int start = s.indexOf('[');
    int end = s.lastIndexOf("]");
    if (start < 0 || end < 0 || start > end) {
      s.log();
      throw StateError('图片网址数组解析错误-$s');
    }
    return s.substring(start + 1, end).split(',');
  }

  static Map<String, List<ImageBean>> parseHomeData(String htmlString) {
    var body = parser.parse(htmlString).body.check('body').check('body is null');
    var tabcon01_1 = body.querySelector('#tabcon01_1').check('tabcon01_1 最新连载 暂无');
    var tabcon01_2 = body.querySelector('#tabcon01_2').check('tabcon01_2 最新完结 暂无');
    var tabcon01_3 = body.querySelector('#tabcon01_3').check('tabcon01_3 推荐连载 暂无');
    var tabcon01_4 = body.querySelector('#tabcon01_4').check('tabcon01_4 推荐完结 暂无');
    Map<String, List<ImageBean>> map = Map();
    map['最新连载']=_loadHomeTypeData(tabcon01_1,'最新连载 list is null');
    map['最新完结']=_loadHomeTypeData(tabcon01_2,'最新完结 list is null');
    map['推荐连载']=_loadHomeTypeData(tabcon01_3,'推荐连载 list is null');
    map['推荐完结']=_loadHomeTypeData(tabcon01_4,'推荐完结 list is null');
    return map;
  }

  static List<ImageBean> _loadHomeTypeData(dom.Element element,[String explain="a list is null"]){
    var aList = element.getElementsByTagName('a').check(explain);
    var list = <ImageBean>[];
    aList.forEach((a) {
      var href = a.attributes['href'];
      var imagePath = a.getElementsByTagName('img')[0].attributes['src'];
      var progress = loadOne(a.getElementsByTagName('span'))?.text;
      var title = a.getElementsByTagName('p')[0].text;
      list.add(ImageBean(href, imagePath, title, '2020-10-11', progress));
    });
    return list;
  }
}

extension MaxPage on PageBean {
  PageBean loadMaxPage(dom.Element? pagination) {
    if (null != pagination) {
      var pageLinks = pagination.getElementsByClassName('page-link');
      if (pageLinks.isNotEmpty) {
        pageLinks.forEach((element) {
          if (element.localName == "a") {
            int num = 0;
            try {
              num = int.parse(element.text.trim());
            } catch (e) {
              //print(e);
            }
            if (num > 0) {
              this.maxPage += 1;
              "${element.attributes['href']} text=${element.text}".log();
            }
          }
        });
      }
    }
    return this;
  }
}
