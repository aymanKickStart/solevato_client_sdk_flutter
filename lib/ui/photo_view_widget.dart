import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class PhotoViewWidget extends StatefulWidget {
  final List<dynamic> images;
  final int index;
  final bool? showControls;

  /// [images] are the images will be shown
  /// [index] is the position of the initial image to show firstly
  const PhotoViewWidget({
    required this.images,
    required this.index,
    required this.showControls,
  });

  @override
  State<PhotoViewWidget> createState() => _PhotoViewWidgetState();
}

class _PhotoViewWidgetState extends State<PhotoViewWidget> {
  PageController? pageController = PageController();
  ValueNotifier<int>? currentPageNotifier;

  @override
  void initState() {
    super.initState();
    currentPageNotifier = ValueNotifier<int>(widget.index);
    pageController = PageController(
      initialPage: widget.index,
      viewportFraction: 1,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView.builder(
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    padEnds: false,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return PinchZoom(
                        maxScale: 2.5,
                        onZoomStart: () {
                          debugPrint('Start zooming');
                        },
                        onZoomEnd: () {
                          debugPrint('Stop zooming');
                        },
                        zoomEnabled: false,
                        child: Image.network(
                          widget.images.elementAt(index)['data_url'] ?? '',
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                    onPageChanged: (int index) {
                      currentPageNotifier!.value = index;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                if ((widget.showControls ?? true) == true &&
                    widget.images.length > 1) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (currentPageNotifier!.value <
                                    widget.images.length &&
                                currentPageNotifier!.value != 0) {
                              currentPageNotifier!.value--;
                              moveImage();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.only(end: 1.3),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: currentPageNotifier!,
                          builder: (context, value, child) {
                            return Text(
                              '${currentPageNotifier!.value + 1}/${widget.images.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        InkWell(
                          onTap: () {
                            if (currentPageNotifier!.value + 1 <
                                widget.images.length) {
                              currentPageNotifier!.value++;
                              moveImage();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.only(start: 1.3),
                              child: Center(
                                child: Icon(Icons.arrow_forward_ios_rounded),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  moveImage() {
    pageController!.animateToPage(
      currentPageNotifier!.value,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
