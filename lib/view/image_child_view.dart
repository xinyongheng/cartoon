import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cartoon_image.dart';
import '../config.dart';
import 'image_view.dart';

class ListItemChildWidget extends StatelessWidget {
  const ListItemChildWidget({Key? key, required this.imageBean, this.onTap}) : super(key: key);
  final imageBean;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _childRowWidget(imageBean, context);
  }

  Widget _childRowWidget(ImageBean bean, BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ImageCatalogueView(href: bean.href!, title: bean.titleName!);
            }));
          },
      child: Tooltip(
        message: bean.titleName ?? "啥也没有...",
        child: Column(
          children: [
            Center(
              child: Container(
                width: 170.w,
                //167.0 / 275
                height: 226.w,
                // decoration: ShapeDecoration(
                //   shape: Border.all(
                //         color: Colors.red,
                //         width: 1.0,
                //       ) +
                //       Border.all(
                //         color: Colors.green,
                //         width: 1.0,
                //       ) +
                //       Border.all(
                //         color: Colors.blue,
                //         width: 1.0,
                //       ),
                // ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: Colors.red,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    bean.imagePath!,
                    color: Colors.grey,
                    colorBlendMode: BlendMode.dstIn,
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (null == loadingProgress) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(color: Colors.grey, child: Center(child: Text("加载失败-$exception")));
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 2),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color.fromARGB(25, 0, 0, 0),
                borderRadius: BorderRadius.circular(2.0),
                border: Border.all(color: Colors.yellow),
              ),
              child: Text(
                bean.progress ?? "暂无",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  // backgroundColor: Color.fromARGB(25, 0, 0, 0),
                  fontSize: Config.normalSize,
                  fontWeight: Config.normal,
                ),
              ),
            ),
            Text(
              bean.titleName!,
              style: TextStyle(color: Colors.black, fontSize: Config.mediumSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(bean.date!, style: TextStyle(color: Colors.grey, fontSize: Config.normalSize)),
          ],
        ),
      ),
    );
  }
}
