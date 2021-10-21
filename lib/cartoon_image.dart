class ImageBean {
  String? href;
  String? imagePath;
  String? titleName;
  String? date;
  String? progress;

  ImageBean(
      this.href, this.imagePath, this.titleName, this.date, this.progress);

  @override
  String toString() {
    return 'ImageBean{href: $href, imagePath: $imagePath, titleName: $titleName, date: $date, progress: $progress}';
  }
}

class PageBean {
  int nowPage = 1;
  int maxPage = 1;

  ///当前链接
  String nowHref = '';

  PageBean({required String nowHref, int maxPage = 1}) {
    this.nowHref=nowHref;
    this.maxPage = maxPage;
  }

  ///是否是最后一页
  bool isLastPage() {
    return nowPage == maxPage;
  }
}

class ImageListBean {
  final List<ImageBean> list;
  final PageBean? pageBean;

  const ImageListBean(this.list, this.pageBean);
}
