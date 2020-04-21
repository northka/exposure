import 'dart:async' show Timer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import './exposure_detector.dart';
import './exposure_detector_controller.dart';


Iterable<Layer> _getLayerChain(Layer start) {
  final List<Layer> layerChain = <Layer>[];
  for (Layer layer = start; layer != null; layer = layer.parent) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}


Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {
  assert(layerChain != null);

  final Matrix4 transform = Matrix4.identity();
  if (layerChain.isNotEmpty) {
    Layer parent = layerChain.first;
    for (final Layer child in layerChain.skip(1)) {
      (parent as ContainerLayer).applyTransform(child, transform);
      parent = child;
    }
  }
  return transform;
}


Rect _localRectToGlobal(Layer layer, Rect localRect) {
  final Iterable<Layer> layerChain = _getLayerChain(layer);

  assert(layerChain.isNotEmpty);
  assert(layerChain.first is TransformLayer);
  final Matrix4 transform = _accumulateTransforms(layerChain.skip(1));
  return MatrixUtils.transformRect(transform, localRect);
}

class ExposureTimeLayer {
  final int time;
  ExposureDetectorLayer layer;
  ExposureTimeLayer(this.time, this.layer);
}

class ExposureDetectorLayer extends ContainerLayer {
  ExposureDetectorLayer(
      {
      @required this.key,
      @required this.widgetSize,
      @required this.paintOffset,
      this.onExposureChanged
      })
      : assert(key != null),
        assert(paintOffset != null),
        assert(widgetSize != null),
        assert(onExposureChanged != null),
        _layerOffset = Offset.zero;
    static Timer _timer;

    static final _updated = <Key, ExposureDetectorLayer>{};

    final Key key;

    final Size widgetSize;

    Offset _layerOffset;

    final Offset paintOffset;

    final ExposureCallback onExposureChanged;

    static List<Key> toRemove = [];

    static final _exposureTime = <Key, ExposureTimeLayer>{};


    bool filter = false;
    static void setScheduleUpdate() {
      final bool isFirstUpdate = _updated.isEmpty;

      final updateInterval = ExposureDetectorController.instance.updateInterval;
      if (updateInterval == Duration.zero) {
        if (isFirstUpdate) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            _processCallbacks();
          });
        }
      } else if (_timer == null) {
        _timer = Timer(updateInterval, _handleTimer);
      } else {
        assert(_timer.isActive);
      }
    }

    void _scheduleUpdate() {
      final bool isFirstUpdate = _updated.isEmpty;
      _updated[key] = this;

      final updateInterval = ExposureDetectorController.instance.updateInterval;
      if (updateInterval == Duration.zero) {
        if (isFirstUpdate) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            _processCallbacks();
          });
        }
      } else if (_timer == null) {
        _timer = Timer(updateInterval, _handleTimer);
      } else {
        assert(_timer.isActive);
      }
    }

    static void _handleTimer() {
      _timer = null;
      _exposureTime.forEach((key, exposureLayer) {
        if (_updated[key] == null) {
          _updated[key] = exposureLayer.layer;
        }
      });
      /// 确保在两次绘制中计算完
      SchedulerBinding.instance
          .scheduleTask<void>(_processCallbacks, Priority.touch);
    }

  /// 计算组件的矩形
  Rect _computeWidgetBounds() {
    final Rect r = _localRectToGlobal(this, Offset.zero & widgetSize);
    return r.shift(paintOffset + _layerOffset);
  }

  /// 计算两个两个矩形相交
  Rect _computeClipRect() {
    assert(RendererBinding.instance?.renderView != null);
    Rect clipRect = Offset.zero & RendererBinding.instance.renderView.size;

    ContainerLayer parentLayer = parent;
    while (parentLayer != null) {
      Rect curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath.getBounds();
      }

      if (curClipRect != null) {
        curClipRect = _localRectToGlobal(parentLayer, curClipRect);
        clipRect = clipRect.intersect(curClipRect);
      }

      parentLayer = parentLayer.parent;
    }

    return clipRect;
  }

  /// instances.
  static void _processCallbacks() {
    int nowTime = new DateTime.now().millisecondsSinceEpoch;
    List<Key> toReserveList = [];

    for (final ExposureDetectorLayer layer in _updated.values) {
      if (!layer.attached) {
        continue;
      }

      final widgetBounds = layer._computeWidgetBounds();

      final info = VisibilityInfo.fromRects(
          key: layer.key,
          widgetBounds: widgetBounds,
          clipRect: layer._computeClipRect());
      if (info.visibleFraction >= 0.5 ) {
        if (_exposureTime[layer.key] != null && _exposureTime[layer.key].time > 0) {
          if (nowTime - _exposureTime[layer.key].time > ExposureDetectorController.instance.exposureTime) {
            layer.onExposureChanged(info);
            toRemove.add(layer.key);
          } else {
            setScheduleUpdate();
            toReserveList.add(layer.key);
            _exposureTime[layer.key].layer = layer;

          }
        } else {
          _exposureTime[layer.key] = ExposureTimeLayer(nowTime, layer);

          toReserveList.add(layer.key);
          setScheduleUpdate();
        }
      }

      _exposureTime.removeWhere((key, _) => !toReserveList.contains(key));
    
    }

    toRemove.forEach((key) {
      ExposureDetectorController.instance.forget(key);
    });
    toRemove.clear();
    _updated.clear();
  }

  static void forget(Key key) {
    if (_updated[key] != null) {
      _updated[key].filter = true;
      _updated.remove(key);
    }
    
    if (_updated.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// See [Layer.addToScene].
  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    if (!filter) {
      _layerOffset = layerOffset;
      _scheduleUpdate();
    }
    super.addToScene(builder, layerOffset);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
    super.attach(owner);
    if (!filter) { 
      _scheduleUpdate();
    }
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    if (!filter) { 
      _scheduleUpdate();
    }
  }
}