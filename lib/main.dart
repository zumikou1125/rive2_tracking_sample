import 'package:flutter/material.dart';
import 'package:rive2_tracking_sample/tracking_sample.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rive2 Tracking Sample',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0D2336),
        scaffoldBackgroundColor: Color(0xFF12314A),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rive2 Tracking Sample'),
      ),
      body: SafeArea(
        child: const TrackingSample(),
      ),
    );
  }
}
