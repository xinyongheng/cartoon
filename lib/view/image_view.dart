import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cartoon/cartoon_image.dart';
import 'package:cartoon/cartoon_parse.dart';
import 'package:cartoon/config.dart';
import 'package:cartoon/db/db_cartoon.dart';
import 'package:cartoon/db/db_config.dart';
import 'package:cartoon/db/db_provider.dart';
import 'package:cartoon/service.dart';
import 'package:cartoon/view/image_child_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../toast.dart';

class ImageArrayViewList extends StatefulWidget {
  const ImageArrayViewList({Key? key, required this.title, required this.href}) : super(key: key);
  final title;
  final href;

  @override
  _ImageArrayViewListState createState() => _ImageArrayViewListState();
}

class _ImageArrayViewListState extends State<ImageArrayViewList> {
  PageBean? _pageBean;
  List<ImageBean>? _list;
  String _hint = "加载中。。。";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Config.appBar(
        context,
        widget.title,
        true,
        [
          TextButton(
            onPressed: null == _pageBean || _pageBean!.isLastPage() ? null : () {},
            child: Text(
              null == _pageBean || _pageBean!.isLastPage() ? "没有了" : "下一页",
              style: TextStyle(color: null == _pageBean || _pageBean!.isLastPage() ? Colors.grey : Config.titleColor),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Text(null == _pageBean ? "0/0" : "${_pageBean!.nowPage}/${_pageBean!.maxPage}"),
        backgroundColor: Config.themeColor,
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: _list == null ? _buildAnimatedTextKit() : _buildGridView(),
    );
  }

  GridView _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //列数，即一行有几个子元素
        mainAxisSpacing: 2, //主轴方向上的空隙间距
        crossAxisSpacing: 2, //次轴方向上的空隙间距
        childAspectRatio: 167.0 / 275, //子元素的宽高比例
      ),
      itemBuilder: _itemBuilder,
      itemCount: _list?.length ?? 0,
    );
  }

  AnimatedTextKit _buildAnimatedTextKit() {
    return AnimatedTextKit(
      animatedTexts: [
        RotateAnimatedText(
          _hint,
          textStyle: TextStyle(
            fontSize: Config.titleSize,
            fontWeight: Config.medium,
          ),
        )
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    var bean = _list![index];
    return ListItemChildWidget(imageBean: bean);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestData(widget.href, true);
  }

  void _requestData(String href, [bool initTag = false]) {
    var path = Api.parentUrl + href;
    Api().getUrl(path, Api().headers()).then((value) {
      if (value.isNotEmpty()) {
        var bean = CartoonUtil.parseImageList(path, value.t!);
        if (initTag || null == _list) {
          _list = bean.list;
        } else {
          _list!.addAll(bean.list);
        }
        _pageBean = bean.pageBean;
        _updateUi();
      } else if (value.isSuccess()) {
        _pageBean?.nowPage += 1;
        _updateUi();
        toast('无数据');
      } else {
        toast('访问失败');
      }
    });
  }

  void _updateUi() => setState(() {});
}

class ImageViewList extends StatefulWidget {
  final String filter;
  final int type;

  const ImageViewList({Key? key, required this.type, required this.filter}) : super(key: key);

  @override
  _ImageViewListState createState() => _ImageViewListState();
}

class _ImageViewListState extends State<ImageViewList> {
  List<ImageBean>? _list;
  String hint = "加载中。。。";

  @override
  void initState() {
    super.initState();
    switch (widget.type) {
      case 1:
        Api().search(widget.filter).then((value) {
          if (value.isNotEmpty()) {
            _list = value.t!.list;
            //preLoadNext(value.t!.pageBean!);
            setState(() {});
          } else if (value.isSuccess()) {
            hint = "暂无结果";
            setState(() {});
          } else {
            hint = "访问失败-${value.message}";
            setState(() {});
          }
        });
        break;
    }
  }

  void preLoadNext(PageBean pageBean) {
    if (pageBean.isLastPage()) {
      setState(() {});
      return;
    }
    loadNextPage(pageBean);
  }

  loadNextPage(PageBean pageBean) {
    if (pageBean.isLastPage()) return '加载第二页'.log("Image_view");
    Api().nextPage(pageBean.nowPage + 1).then((value) {
      if (value.isNotEmpty()) {
        _list!.addAll(value.t!.list);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Config.appBar(context, widget.filter, true),
      body: null == _list
          ? AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  hint,
                  textStyle: TextStyle(
                    fontSize: Config.mediumSize,
                    fontWeight: Config.medium,
                  ),
                  textAlign: TextAlign.center,
                  speed: Duration(milliseconds: 200),
                ),
              ],
              totalRepeatCount: 3,
              pause: const Duration(milliseconds: 500),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            )
          : Container(
              child: ListView.builder(
                itemBuilder: itemView,
                itemCount: _list!.length,
              ),
            ),
    );
  }

  Widget itemView(context, index) {
    ImageBean bean = _list![index];
    return InkWell(
      onTap: () => itemClick(context, bean),
      child: Column(
        children: [
          Image.network(bean.imagePath!),
          Text(
            bean.progress ?? "暂无",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Color.fromARGB(25, 0, 0, 0),
              fontSize: Config.normalSize,
              fontWeight: Config.normal,
            ),
          ),
          Text(bean.titleName!, style: TextStyle(color: Colors.black, fontSize: Config.mediumSize)),
          Text(bean.date!, style: TextStyle(color: Colors.grey, fontSize: Config.normalSize)),
        ],
      ),
    );
  }

  void itemClick(BuildContext context, ImageBean bean) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageCatalogueView(href: bean.href!, title: bean.titleName!);
    }));
  }
}

///目录列表
class ImageCatalogueView extends StatefulWidget {
  final String href;
  final String title;

  const ImageCatalogueView({Key? key, required this.href, required this.title}) : super(key: key);

  @override
  _ImageCatalogueViewState createState() => _ImageCatalogueViewState();
}

class _ImageCatalogueViewState extends State<ImageCatalogueView> {
  List<ImageBean>? _list;
  String msg = '---正在访问中。。。';
  ReadInfoDb? _readInfoDb;

  @override
  void initState() {
    super.initState();
    var url = Api.parentUrl + widget.href;
    requestData(url, widget.title).then((value) {
      if (value.isNotEmpty()) {
        ///访问成功
        try {
          //1000+100+28 873.5
          _list = CartoonUtil.parseChild(value.t!);
          Api().catalogueList = _list!;
          msg = '访问成功';
        } catch (e) {
          print(e);
          msg = '访问失败' + e.toString();
        }
      } else {
        ///失败
        msg = '访问失败';
      }
      setState(() {});
    });
  }

  Future<Resource<String>> requestData(String url, String title) async {
    _readInfoDb = await ReadInfoDbProvider.load(title);
    return Api().getUrl(url, Api().headers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Config.appBar(context, widget.title),
      body: _list?.isNotEmpty == true
          ? Container(
              child: ListView.builder(
                itemBuilder: _itemChild,
                itemCount: _list?.length ?? 0,
              ),
            )
          : Center(
              child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  msg,
                  colors: [Colors.black, Colors.red, Colors.blueAccent],
                  textStyle: TextStyle(fontSize: Config.mediumSize, fontWeight: Config.medium),
                  textAlign: TextAlign.center,
                )
              ],
              totalRepeatCount: 3,
            )),
    );
  }

  Widget _itemChild(BuildContext context, int index) {
    //"size = ${_list?.length ?? -1}, index=$index".log("_itemChild");
    var bean = _list![index];
    bool lastClickTag = bean.titleName == _readInfoDb?.progress;
    var child = TextButton(
        onPressed: () {
          Api().nowPage = index;
          //更新数据库记录
          _updateRecordDb(bean, widget.title);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ImageChildListView(
                href: bean.href!,
                title: bean.titleName!,
                parentTitle: widget.title,
                referer: Api.parentUrl + widget.href);
          })).then((value) async {
            //返回值
            if (null != value) {
              var lastPageProgress = value.toString();
              "$lastPageProgress-${_readInfoDb?.progress}".log();
              if (lastPageProgress != _readInfoDb?.progress) {
                _readInfoDb!.progress = lastPageProgress;
                setState(() {});
                _readInfoDb = await ReadInfoDbProvider.load(widget.title);
                "${_readInfoDb!.progress}-${DateTime.fromMillisecondsSinceEpoch(_readInfoDb!.timeMilli).toString()}"
                    .log();
              }
            }
          });
        },
        child: Text(_list == null || _list!.isEmpty ? "空-$index" : _list![index].titleName!));
    return lastClickTag
        ? Tooltip(
            message: from(_readInfoDb!.timeMilli),
            child: DecoratedBox(
              decoration: BoxDecoration(
                //color: Colors.yellow,
                border: Border.all(color: Config.themeColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: child,
            ),
          )
        : child;
  }

  void _updateRecordDb(ImageBean bean, String title) async {
    var data = ReadInfoDb.make(title, bean.href!, bean.titleName!);
    await data.insertOrReplace(DbManage.instance);
    _readInfoDb = data;
    setState(() {});
  }

  String from(int milli) {
    var date = DateTime.fromMillisecondsSinceEpoch(milli);
    return "${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute}:${date.second}";
  }
}

///图片列表 子元素
class ImageChildListView extends StatefulWidget {
  final String href;
  final String title;
  final String parentTitle;
  final String referer;

  const ImageChildListView(
      {Key? key, required this.href, required this.title, required this.parentTitle, required this.referer})
      : super(key: key);

  @override
  _ImageChildListViewState createState() => _ImageChildListViewState();
}

class _ImageChildListViewState extends State<ImageChildListView> {
  List<String>? _list;
  String msg = '正在访问中。。。';
  final _scroll = ScrollController();
  String _finalTitle = "";
  String _nowHref = "";

  @override
  void initState() {
    super.initState();
    "initState".log("IMAGE-TAG");
    _loadContent(widget.href, false);
    _scroll.addListener(() async {
      //_scroll.position.pixels.log("TAG-pixels");
      //_scroll.position.viewportDimension.log("TAG-viewport");
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent) {
        //滑到底部
        "滑到底部".log();
        var bean = await ReadInfoDbProvider.load(widget.parentTitle);
        if (bean == null) {
          bean = ReadInfoDb.make(widget.parentTitle, _nowHref, _nowHref);
        } else {
          if (bean.progress == _finalTitle) return;
        }
        bean.progress = _finalTitle;
        var id = await bean.insertOrReplace(DbManage.instance);
        "插入成功 id=$id ${bean.progress}".log();
      }
    });
  }

  void _loadContent(String href, bool next) {
    var url = Api.parentUrl + href;
    this._nowHref = href;
    //this._finalTitle = widget.title;
    var heads = Api().headers(referer: widget.referer);
    Api().getUrl(url, heads).then((value) {
      if (value.isNotEmpty()) {
        ///访问成功
        msg = '访问成功';
        var listNow = CartoonUtil.parseChildHref(value.t!);
        if (next) {
          Api().nowPage += 1;
        }
        if (null != _list && _list!.length < 100) {
          _list!.addAll(listNow);
          _finalTitle = Api().catalogueList[Api().nowPage].titleName!;
        } else {
          _list = listNow;
          Api().catalogueList.length.toString().log();
          _finalTitle = Api().catalogueList[Api().nowPage].titleName!;
        }
        "${Api().nowPage}".log("IMAGE");
      } else {
        ///失败
        msg = '访问失败';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scroll.dispose();
    //Api().recycleNowList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final click = _hasNext() ? () => _nextClick() : null;
    final buttonChild = Text(
      _hasNext() ? '下一页' : '没有了',
      style: TextStyle(color: _color()),
    );
    return Scaffold(
      appBar: Config.appBar(
          context,
          _finalTitle.isEmpty ? widget.title : _finalTitle,
          true,
          [
            TextButton(
              onPressed: click,
              child: buttonChild,
            ),
          ],
          popPage),
      body: WillPopScope(
        onWillPop: onWilPop,
        child: Container(
          child: Center(
            child: _list?.isNotEmpty == true
                ? ListView.builder(
                    itemBuilder: _itemChild,
                    controller: _scroll,
                    itemCount: _list?.length ?? 0,
                  )
                : Text(msg),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '下一页',
        onPressed: click,
        child: buttonChild,
      ),
    );
  }

  Future<bool> onWilPop() async {
    popPage();
    return Future.value(false);
  }

  void popPage() {
    Navigator.pop(context, _finalTitle);
  }

  _nextClick() {
    _loadContent(Api().catalogueList[Api().nowPage + 1].href!, true);
  }

  bool _hasNext() {
    return Api().nowPage < Api().catalogueList.length - 1;
  }

  Color _color() {
    return Api().nowPage != Api().catalogueList.length - 1 ? Colors.white : Colors.grey;
  }

  Widget _itemChild(BuildContext context, int index) {
    var href = _list![index];
    return Image.network(
      href,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (null == loadingProgress) return child;
        return Container(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "第 ${index + 1} 张，加载中。。。",
                  style: TextStyle(
                    color: Config.themeColor,
                    fontSize: Config.normalSize,
                    fontWeight: Config.normal,
                  ),
                ),
              ),
              Container(
                //color: Colors.white12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFF7F00),
                      Color(0xFFFFFF00),
                      Color(0xFF00FF00),
                      Color(0xFF00FFFF),
                      Color(0xFF0000FF),
                      Color(0xFF8B00FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                height: 240.h,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Container(color: Colors.grey, child: Center(child: Text("加载失败-$exception")));
      },
    );
  }
}
