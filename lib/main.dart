import 'package:cartoon/cartoon_image.dart';
import 'package:cartoon/cartoon_parse.dart';
import 'package:cartoon/db/db_config.dart';
import 'package:cartoon/service.dart';
import 'package:cartoon/view/image_child_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config.dart';
import 'view/image_view.dart';

void main() {
  Api.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360.0, 640.0),
      builder: () => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: '漫画'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _filterController = TextEditingController();
  Future<Widget>? _homeFuture11;
  @override
  void initState() {
    _homeFuture11 = _homeFuture();
    super.initState();
    DbManage.instance.init().then((value) => null);
    "initState".log("TAG-Perform");
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    "build".log("TAG-Perform");
    final body = _buildSingleChildScrollView();
    final drawer = _buildDrawer();
    final appBar = AppBar(
      leading: _buildBuilder(),
      title: Config.appBarText(widget.title),
      centerTitle: true,
    );
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
    );
  }

  SingleChildScrollView _buildSingleChildScrollView() {
    "_buildSingleChildScrollView".log("TAG-Perform");
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _searchWidget(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFutureBuilder(),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    "_buildDrawer".log("TAG-Perform");
    return Drawer(
      elevation: 16,
      semanticLabel: '分类',
      child: Stack(
        children: [
          Image.asset(
            'images/head_bg.jpg',
            fit: BoxFit.fill,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1, top: 1),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: _drawerItemChild,
              itemCount: CartoonUtil.menuList.length + 1,
            ),
          )
        ],
      ),
    );
  }

  Builder _buildBuilder() {
    return Builder(builder: (context) {
      return IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => _showMenu(context),
        tooltip: '分类菜单',
      );
    });
  }

  FutureBuilder<Widget> _buildFutureBuilder() {
    "_buildFutureBuilder".log("TAG-Perform");
    return FutureBuilder(
      future: _homeFuture11,
      builder: (BuildContext context, AsyncSnapshot<Widget> builder) {
        switch (builder.connectionState) {
          case ConnectionState.none:
            return Text('开始加载');
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(child: new CircularProgressIndicator());
          default:
            return builder.hasError ? Text('访问失败') : builder.requireData;
        }
      },
    );
  }

  List<Widget> _bodyList(Map<String, List<ImageBean>> map) {
    List<Widget> list = [];
    map.forEach((key, value) {
      list.add(_typeChild(key, value));
    });
    return list;
  }

  Widget _searchWidget() {
    return TextField(
      autofocus: false,
      controller: _filterController,
      decoration: InputDecoration(labelText: null, hintText: '请输入搜索内容', prefixIcon: Icon(Icons.search)),
      onSubmitted: _child,
      onEditingComplete: () => 'onEditingComplete'.log(),
    );
  }

  Widget _drawerItemChild(context, index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Image.asset(
          'images/logo.png',
          fit: BoxFit.fill,
          alignment: Alignment.center,
        ),
      );
    }
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, top: 8, bottom: 8),
        child: Text(
          CartoonUtil.menuList[index - 1].titleName!,
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: Config.mediumSize,
            fontWeight: Config.medium,
          ),
        ),
      ),
      onTap: () => _drawerItemClick(CartoonUtil.menuList[index - 1]),
    );
  }

  void _drawerItemClick(ImageBean bean) {
    _popMenu();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageArrayViewList(href: bean.href!, title: bean.titleName!);
    }));
  }

  void _popMenu() {
    Navigator.of(context).pop();
  }

  void _showMenu(context) {
    Scaffold.of(context).openDrawer();
    //Scaffold.of(context).isDrawerOpen();
  }

  void _child(String? filter) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Center(
                    child: ImageViewList(
                  type: 1,
                  filter: filter?.isNotEmpty == true ? filter! : '山', //从前有座灵剑
                ))));
  }

  //01 23 45 67
  Widget _typeChild(String title, List<ImageBean> list) {
    var length = list.length;
    var size = length / 2.toDouble();
    var sizeInt = size.toInt();
    int finalSize = (size - sizeInt > 0) ? (sizeInt + 1) : sizeInt;
    List<Widget> listWidget = [];
    listWidget.add(SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Config.themeColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              title + ":",
              style: TextStyle(
                fontWeight: Config.medium,
                fontSize: Config.mediumSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ));
    for (var i = 0; i < finalSize; i++) {
      var index = i * 2;
      if (index + 1 < length) {
        listWidget.add(_rowWidget(list[index], list[index + 1]));
      } else {
        listWidget.add(_childRowWidget(list[index]));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listWidget,
    );
  }

  Widget _rowWidget(ImageBean bean1, ImageBean bean2) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(flex: 1, child: _childRowWidget(bean1)),
        SizedBox(width: 4, height: 10),
        Expanded(flex: 1, child: _childRowWidget(bean2)),
      ],
    );
  }

  Widget _childRowWidget(ImageBean bean) {
    return ListItemChildWidget(
        imageBean: bean,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ImageCatalogueView(href: bean.href!, title: bean.titleName!);
          }));
        });
  }

  Future<Widget>? _homeFuture() async {
    "perform _homeFuture".log("TAG-Perform");
    var value = await Api().getUrl(Api.parentUrl + "/", Api().headers());
    if (value.isNotEmpty()) {
      try {
        var map = CartoonUtil.parseHomeData(value.t!);
        return Column(
          children: _bodyList(map),
        );
      } catch (e) {
        print(e);
        return _errorWidget();
      }
    } else {
      value.message.log();
      return _errorWidget();
    }
  }

  Widget _errorWidget() {
    return Text('访问失败');
  }
}
