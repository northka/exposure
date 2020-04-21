import 'dart:math' show max;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import './render_exposure_detector.dart';

class ExposureDetector extends SingleChildRenderObjectWidget {
  const ExposureDetector({
      @required Key key,
      @required Widget child,
      this.onExposure,
    })  : assert(key != null),
          assert(child != null),
          super(key: key, child: child);
  /// 回调触发曝光函数
  final ExposureCallback onExposure;

  
  @override
  RenderExposureDetector createRenderObject(BuildContext context) {
    return RenderExposureDetector(
      key: key,
      onExposure: onExposure,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderExposureDetector renderObject) {
    assert(renderObject.key == key);
    renderObject.onExposure = onExposure;
  }

}

typedef ExposureCallback = void Function(VisibilityInfo info);

@immutable
class VisibilityInfo {
  /// Constructor.
  ///
  const VisibilityInfo({@required this.key, Size size, Rect visibleBounds})
      : assert(key != null),
        size = size ?? Size.zero,
        visibleBounds = visibleBounds ?? Rect.zero;

  factory VisibilityInfo.fromRects({
    @required Key key,
    @required Rect widgetBounds,
    @required Rect clipRect,
  }) {
    assert(widgetBounds != null);
    assert(clipRect != null);

    // 计算展示面积交集
    final Rect visibleBounds = widgetBounds.overlaps(clipRect)
        ? widgetBounds.intersect(clipRect).shift(-widgetBounds.topLeft)
        : Rect.zero;

    return VisibilityInfo(
        key: key, size: widgetBounds.size, visibleBounds: visibleBounds);
  }

  ///
  /// widget的key
  final Key key;

  /// widget的展示大小
  final Size size;

  final Rect visibleBounds;

  /// 获取展示面积百分比
  double get visibleFraction {
    final double visibleArea = _area(visibleBounds.size);
    final double maxVisibleArea = _area(size);

    if (_floatNear(maxVisibleArea, 0)) {
      return 0;
    }

    double visibleFraction = visibleArea / maxVisibleArea;

    if (_floatNear(visibleFraction, 0)) {
      visibleFraction = 0;
    } else if (_floatNear(visibleFraction, 1)) {
      visibleFraction = 1;
    }

    assert(visibleFraction >= 0);
    assert(visibleFraction <= 1);
    return visibleFraction;
  }

  bool matchesVisibility(VisibilityInfo info) {
    assert(info != null);
    return size == info.size && visibleBounds == info.visibleBounds;
  }
}

const _kDefaultTolerance = 0.01;

double _area(Size size) {
  assert(size != null);
  assert(size.width >= 0);
  assert(size.height >= 0);
  return size.width * size.height;
}

/// 两个的数值是否十分接近
bool _floatNear(double f1, double f2) {
  final double absDiff = (f1 - f2).abs();
  return absDiff <= _kDefaultTolerance ||
      (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
}

