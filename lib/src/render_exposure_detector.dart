import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import './exposure_detector.dart';
import './exposure_detector_controller.dart';
import './exposure_detector_layer.dart';

class RenderExposureDetector extends RenderProxyBox {
  /// Constructor.
  RenderExposureDetector(
      {RenderBox child, @required this.key, ExposureCallback onExposure})
      : assert(key != null),
        _onExposure = onExposure,
        super(child);
  final Key key;
  ExposureCallback _onExposure;

  /// See [RenderObject.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => (_onExposure != null);

  /// See [VisibilityDetector.onVisibilityChanged].
  ExposureCallback get onExposure => _onExposure;

  set onExposure(ExposureCallback value) {
    _onExposure = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (_onExposure == null ||
        ExposureDetectorController.instance.filterKeysContains(key)) {
      // 不在需要创建ExposureDetectorLayer
      ExposureDetectorLayer.forget(key);
      super.paint(context, offset);
      return;
    }
    var visibilityDetectorLayer = ExposureDetectorLayer(
      key: key,
      widgetSize: semanticBounds.size,
      paintOffset: offset,
      onExposureChanged: _onExposure,
    );
    final layer = visibilityDetectorLayer;
    context.pushLayer(layer, super.paint, offset);
  }
}
