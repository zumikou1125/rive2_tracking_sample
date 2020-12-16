import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:rive2_tracking_sample/eye_controller.dart';

class TrackingSample extends StatefulWidget {
  const TrackingSample({Key key}) : super(key: key);

  @override
  _TrackingSampleState createState() => _TrackingSampleState();
}

class _TrackingSampleState extends State<TrackingSample> {
  // GlobalKeyを用意
  final _globalKey = GlobalKey();

  // ドラッグ位置取得用Widgetのサイズ
  Size _widgetSize;
  // 読み込んだRiveファイル内のArtboard
  Artboard _artBoard;
  // ドラッグ位置トラッキング用のカスタムコントローラー
  EyeController _controller;

  // Widgetサイズのセット
  void _setWidgetSize() {
    // WidgetsBinding.instance.addPostFrameCallback に指定した処理は、
    // build完了後に実行されます
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // サイズ取得対象WidgetのGlobalKeyのContextからSizeを取得
      _widgetSize = _globalKey.currentContext.size;
    });
  }

  // ドラッグ位置の割合を計算する
  Offset _calcPercentage(Offset dragPosition, Size widgetSize) {
    // x軸の割合
    final x = dragPosition.dx / widgetSize.width;
    // y軸の割合
    final y = dragPosition.dy / widgetSize.height;

    return Offset(x, y);
  }

  // Riveファイルを読み込む
  void _loadRiveFile() async {
    final bytes = await rootBundle.load('assets/eye.riv');
    final file = RiveFile();

    if (file.import(bytes)) {
      // ファイルの読み込みに成功
      setState(
        () {
          // Riveファイル内のアートボードを取得
          //
          // アートボードがひとつのみの場合は "mainArtboard" から、
          // 複数存在する場合は "artboardByName(String name)" を使用して名前指定で取得します
          _artBoard = file.mainArtboard;

          // アニメーションコントローラーを追加
          // 同時にメンバ変数 _controller へセット
          _artBoard.addController(
            _controller = EyeController(),
          );
        },
      );
    }
  }

  // アニメーション位置の更新
  void _updateLineOfSight(Offset percentage) {
    if (_controller == null) {
      return;
    }

    // コントローラー内部で保持しているドラッグ位置の割合を更新する
    _controller.percentage = percentage;
  }

  @override
  void initState() {
    super.initState();

    // Widgetサイズをセット
    _setWidgetSize();

    // Riveファイルを読み込む
    _loadRiveFile();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // アニメーション表示用Widget
        Center(
          child: SizedBox(
            height: 160,
            width: 160,
            // Riveアニメーション
            child: _artBoard != null
                ? Rive(
                    artboard: _artBoard,
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                  )
                : Container(),
          ),
        ),
        // ドラッグ位置取得用Widget
        GestureDetector(
          onPanDown: (detail) {
            // ドラッグ位置の割合計算
            final percentage = _calcPercentage(
              detail.localPosition,
              _widgetSize,
            );

            // ドラッグ位置を元にアニメーションを更新する
            _updateLineOfSight(percentage);

            print('onPanDown: $percentage');
          },
          onPanUpdate: (detail) {
            // ドラッグ位置の割合計算
            final percentage = _calcPercentage(
              detail.localPosition,
              _widgetSize,
            );

            // ドラッグ位置を元にアニメーションを更新する
            _updateLineOfSight(percentage);

            print('onPanUpdate: $percentage');
          },
          onPanEnd: (detail) {
            // Idle以外のアニメーションを初期化
            _controller.reset();

            print('onPanEnd');
          },
          child: Container(
            key: _globalKey,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
