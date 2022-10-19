//FLUTTER NATIVE
import 'package:flutter/material.dart';

//MODELS
import 'package:zune/src/models/tflite/recognition.dart';
import 'package:zune/src/models/tflite/stats.dart';

//SCREENS
import 'package:zune/src/screens/scanner_view/box_widget.dart';
import 'package:zune/src/screens/scanner_view/camera_view_singleton.dart';
import 'camera_view.dart';

//WIDGETS
import 'package:zune/src/widgets/text/custom_text.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class ScannerView extends StatefulWidget {
  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  /// Results to draw bounding boxes
  List<Recognition> results = [];

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // Camera View
          CameraView(resultsCallback, statsCallback),

          // Bounding boxes
          boundingBoxes(results),

          // Heading
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: CustomText(
                'Object Detection Flutter',
                textAlign: TextAlign.left,
                color: Colors.deepOrangeAccent.withOpacity(0.6),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (_, ScrollController scrollController) => Container(
                width: double.maxFinite,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BORDER_RADIUS_BOTTOM_SHEET),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up, size: 48, color: Colors.orange),
                        (stats != null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: stats == null
                                    ? Container()
                                    : Column(
                                        children: [
                                          StatsRow('Inference time:', '${stats!.inferenceTime} ms'),
                                          StatsRow('Total prediction time:', '${stats!.totalElapsedTime} ms'),
                                          StatsRow('Pre-processing time:', '${stats!.preProcessingTime} ms'),
                                          StatsRow('Frame', '${CameraViewSingleton.inputImageSize.width} X ${CameraViewSingleton.inputImageSize?.height}'),
                                        ],
                                      ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    if (mounted) {
      setState(() {
        this.results = results;
      });
    }
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    if (mounted) {
      setState(() {
        this.stats = stats;
      });
    }
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [CustomText(left), CustomText(right)],
      ),
    );
  }
}