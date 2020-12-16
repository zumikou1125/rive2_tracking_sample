import 'dart:math';
import 'dart:ui';

import 'package:rive/rive.dart';

class EyeController extends RiveAnimationController<RuntimeArtboard> {
  // 中心点
  // Scalingアニメーションの制御に使用する
  final centerPoint = 0.5;

  // アートボード
  RuntimeArtboard _artBoard;

  // アニメーション
  LinearAnimationInstance _idle;
  LinearAnimationInstance _vertical;
  LinearAnimationInstance _horizontal;
  LinearAnimationInstance _scaling;

  // Idleアニメーションを除いた各アニメーションの再生終了時間(s)
  double _verticalEndTime;
  double _horizontalEndTime;
  double _scalingEndTime;

  // Idleアニメーションを除いた各アニメーションの再生時間の中央値(s)
  // ドラッグ終了時に使用する
  double _verticalMedianTime;
  double _horizontalMedianTime;
  double _scalingMedianTime;

  // ドラッグ位置の割合
  Offset percentage;

  @override
  bool init(RuntimeArtboard core) {
    // アートボードをセット
    _artBoard = core;

    // 各アニメーションをセット
    // "animationByName(String name)" でアニメーションの名前を指定する
    _idle = core.animationByName('Idle');
    _vertical = core.animationByName('Vertical');
    _horizontal = core.animationByName('Horizontal');
    _scaling = core.animationByName('Scaling');

    // Verticalアニメーションの初期処理
    //
    // 再生終了時間を計算
    _verticalEndTime = _vertical.animation.duration / _vertical.animation.fps;
    // 再生時間の中央値を計算
    _verticalMedianTime = _verticalEndTime / 2;

    // Horizontalアニメーションの初期処理
    //
    // 再生終了時間を計算
    _horizontalEndTime =
        _horizontal.animation.duration / _horizontal.animation.fps;
    // 再生時間の中央値を計算
    _horizontalMedianTime = _horizontalEndTime / 2;

    // Scalingアニメーションの初期処理
    //
    // 再生終了時間を計算
    _scalingEndTime = _scaling.animation.duration / _scaling.animation.fps;
    // 再生時間の中央値を計算
    _scalingMedianTime = _scalingEndTime / 2;

    // isActive にtrueをセットして、アニメーションの再生を開始する
    isActive = true;
    return _idle != null;
  }

  @override
  void apply(RuntimeArtboard core, double elapsedSeconds) {
    // Idleアニメーション
    _idle.animation.apply(_idle.time, coreContext: core);
    _idle.advance(elapsedSeconds);

    if (percentage != null) {
      // ドラッグ操作中

      // Verticalアニメーション
      _vertical.animation.apply(
        _verticalEndTime * percentage.dy,
        coreContext: core,
      );

      // Horizontalアニメーション
      _horizontal.animation.apply(
        _horizontalEndTime * percentage.dx,
        coreContext: core,
      );

      // Scalingアニメーション
      //
      // 以下の二点間の距離を求める
      // - 画面中心(0.5, 0.5)
      // - 現在のドラッグ位置(percentage.dx, percentage.dy)
      final distanceFromCenter = sqrt(
        pow(percentage.dx - centerPoint, 2) +
            pow(percentage.dy - centerPoint, 2),
      );
      _scaling.animation.apply(
        _scalingEndTime * distanceFromCenter,
        coreContext: core,
      );
    }
  }

  // Idleアニメーションを除いた各アニメーションのリセット
  // ドラッグ終了時に呼び出す
  void reset() {
    // ドラッグ位置の割合を初期化
    percentage = null;

    // Idleアニメーションを除いた各アニメーションを再生時間の中央値を反映
    _vertical.animation.apply(_verticalMedianTime, coreContext: _artBoard);
    _horizontal.animation.apply(_horizontalMedianTime, coreContext: _artBoard);
    _scaling.animation.apply(_scalingMedianTime, coreContext: _artBoard);
  }
}
