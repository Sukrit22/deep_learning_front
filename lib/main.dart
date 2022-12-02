import 'package:deep_learning_front/deep.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        // textTheme: const TextTheme(
        //   headline1: TextStyle(color: Colors.deepPurpleAccent),
        //   headline2: TextStyle(color: Colors.deepPurpleAccent),
        //   bodyText2: TextStyle(color: Colors.deepPurpleAccent),
        //   subtitle1: TextStyle(color: Colors.pinkAccent),
        // ),
      ),
      title: 'Deep Learning',
      home: const MyHomePage(title: 'Group : หมูยังสดไหมนะ 🥩🐷'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ImageUploadScreen(title: widget.title ?? "");
  }
}
