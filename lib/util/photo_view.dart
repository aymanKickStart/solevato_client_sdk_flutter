import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui/photo_view_widget.dart';

class PhotoView {
  static show({
    required BuildContext context,
    required int index,
    required List<dynamic> images,
    bool? showControls,
  }) {
    if (images.isNotEmpty) {
      showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.9),
        barrierLabel: '',
        barrierDismissible: true,
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return PhotoViewWidget(
            images: images,
            index: index,
            showControls: showControls ?? true,
          );
        },
      );
    }
  }
}
