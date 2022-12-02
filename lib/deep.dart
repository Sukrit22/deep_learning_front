import 'dart:html' as html;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({this.title = "", super.key});

  final String title;

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<int>? _selectedFile;
  Uint8List? _bytesData;
  String _backendURL = 'http://deep-api.celab.network';
  Map<String, dynamic> predict = const {
    "model_1_xception": {
      "Class": 0,
      "Confidence": 0.7419300079345703,
      "data": {
        "class_0_confidence_score": 0.7419300079345703,
        "class_1_confidence_score": 0.25799131393432617,
        "class_2_confidence_score": 7.875412120483816e-05
      }
    },
    "model_2_vgg16": {
      "Class": 1,
      "Confidence": 0.7941277623176575,
      "data": {
        "class_0_confidence_score": 0.1787939816713333,
        "class_1_confidence_score": 0.7941277623176575,
        "class_2_confidence_score": 0.027078306302428246
      }
    },
    "model_3_cnn": {
      "Class": 0,
      "Confidence": 1.0,
      "data": {
        "class_0_confidence_score": 1.0,
        "class_1_confidence_score": 4.668444555544938e-28,
        "class_2_confidence_score": 1.908612557167092e-17
      }
    }
  };
  bool _posted = false;
  bool _isLoadingResult = false;
  bool _isDebugMode = false;
  int _debugPageNum = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final MyCheckBox debugMode = const MyCheckBox();

  final _urlFieldController = TextEditingController();

  void setUrl() {
    setState(
      () {
        _backendURL = _urlFieldController.text == ''
            ? "http://deep-api.celab.network"
            : _urlFieldController.text;
        print(_backendURL);
      },
    );
  }

  void _startWebFilePicker() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      final file = files![0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        setState(() {
          _bytesData = const Base64Decoder()
              .convert(reader.result.toString().split(",").last);
          _selectedFile = _bytesData;
          _posted = false;
          //print(_bytesData);
        });
      });
      reader.readAsDataUrl(file);
    });
  }

  Future<void> _uploadImage() async {
    _posted = false;
    setState(() {
      _isLoadingResult = true;
    });
    var url = Uri.parse(_backendURL);
    var request = http.MultipartRequest("POST", url);
    request.files.add(
      http.MultipartFile.fromBytes('file', _selectedFile!,
          contentType: MediaType('image', 'jpg'), filename: "yo"),
    );

    request.send().then((response) async {
      if (response.statusCode == 200) {
        print('File upload successfully.');
        //show json
        final data = json.decode(await response.stream.bytesToString());
        setState(() {
          _isLoadingResult = false;
          predict = data;
          print(predict);
          _posted = true;
        });
      } else {
        print('File upload failed.');
        //show error
      }
    });
  }

  void _viewResult() {
    setState(() {
      _bytesData = null;
    });
  }

  @override
  void dispose() {
    _urlFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showFAB(),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: "maintenance mode",
            icon: const Icon(Icons.engineering),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
          ),
          const SizedBox(width: 15),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _menuBuilder(),
        ),
      ),
      endDrawer: Drawer(
        //backgroundColor: Color(Colors.teal.value),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: GradientText(
                'Maintenance Mode',
                style: const TextStyle(
                  fontSize: 40.0,
                ),
                colors: const <Color>[
                  Colors.yellow,
                  Colors.black,
                  Colors.yellow,
                  Colors.black,
                  Colors.yellow,
                ],
              ),
            ),
            const Text("Backend URL"),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onSubmitted: (String value) {
                  setUrl();
                },
                controller: _urlFieldController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.link_rounded),
                  //icon: Icon(Icons.main),
                  hintText: "http://deep-api.celab.network",
                  labelText: 'Url',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
              ),
            ),
            MaterialButton(
              color: Colors.orange,
              elevation: 8.0,
              highlightElevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textColor: Colors.white,
              onPressed: () {
                setUrl();
              },
              child: const Text('set url'),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: _isDebugMode,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDebugMode = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 10.0),
                  const Text("Debug Mode")
                ],
              ),
            ),
            MaterialButton(
              color: Colors.orange,
              elevation: 8.0,
              highlightElevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textColor: Colors.white,
              onPressed: () {
                print(predict);
              },
              child: const Text('print predict {}'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(child: _pageBuilder()),
        ),
      ),
    );
  }

  Widget _result(String emoji, String freshness, Color color) {
    return Column(
      children: [
        Text(
          //"😆😢🤢",
          emoji,
          style: const TextStyle(fontSize: 50.0),
        ),
        Text(
          //"FreshNotFreshSpoiled",
          freshness,
          style: TextStyle(
            fontSize: 30.0,
            //"redgreenlightGreen",
            color: color,
          ),
        ),
      ],
    );
  }

  // MaterialButton _sendToBackend() {
  //   return MaterialButton(
  //     color: Colors.orange,
  //     elevation: 8.0,
  //     highlightElevation: 2.0,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //     textColor: Colors.white,
  //     onPressed: () {
  //       _uploadImage();
  //     },
  //     child: const Text('send to backend'),
  //   );
  // }

  // MaterialButton _selectImage() {
  //   return MaterialButton(
  //     color: Colors.orange,
  //     elevation: 8.0,
  //     highlightElevation: 2.0,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //     textColor: Colors.white,
  //     onPressed: () {
  //       _startWebFilePicker();
  //     },
  //     child: const Text('select image'),
  //   );
  // }

  Widget _showFAB() {
    if (_bytesData == null) {
      //ยังไม่เลือกรูป
      // 1 fab
      return _showImagePickFAB("pick an image");
    } else if (!_posted) {
      //เลือกรูปแล้ว แสดงปุ่มเลือกรูปใหม่ และ ปุ่มsubmit รูป
      // 2 fab
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _showImagePickFAB("pick another image instead"),
          const SizedBox(
            width: 15.0,
          ),
          _showUploadImageFAB(),
        ],
      );
    } else if (_posted) {
      //submit แล้ว แสดงปุ่ม view result
      // 1 fab
      return _showViewResult();
    }
    return const Text("Error ไม่แสดง FAB");
  }

  FloatingActionButton _showImagePickFAB(String tooltip) {
    return FloatingActionButton(
      tooltip: tooltip,
      onPressed: () => _startWebFilePicker(),
      child: const Icon(Icons.image_rounded),
    );
  }

  FloatingActionButton _showUploadImageFAB() {
    return FloatingActionButton(
      tooltip: "let's guess your result",
      onPressed: () => _uploadImage(),
      child: const Icon(Icons.upload),
    );
  }

  FloatingActionButton _showViewResult() {
    return FloatingActionButton(
      tooltip: "see your result",
      onPressed: () => _viewResult(),
      child: const Icon(Icons.preview),
    );
  }

  //? Done
  Widget _blankPage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25, //250.0,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 30.0,
          fontFamily: 'Agne',
        ),
        child: AnimatedTextKit(
          repeatForever: true,
          pause: const Duration(milliseconds: 2000),
          animatedTexts: [
            TypewriterAnimatedText(
              "เริ่มต้นกันเถอะ",
              speed: const Duration(milliseconds: 100),
            ),
            TypewriterAnimatedText(
              "Let's get started",
              speed: const Duration(milliseconds: 100),
            ),
            TypewriterAnimatedText(
              "시작하자",
              speed: const Duration(milliseconds: 100),
            ),
            TypewriterAnimatedText(
              "始めましょう",
              speed: const Duration(milliseconds: 100),
            ),
            TypewriterAnimatedText(
              "Давайте начнем",
              speed: const Duration(milliseconds: 100),
            ),
            TypewriterAnimatedText(
              "Empecemos",
              speed: const Duration(milliseconds: 100),
            ),
            TypewriterAnimatedText("هيا بنا نبدأ",
                speed: const Duration(milliseconds: 100),
                textAlign: TextAlign.end),
            // TypewriterAnimatedText("Let's guess your first image",
            //     speed: const Duration(milliseconds: 70), cursor: '|'),
            // TypewriterAnimatedText('See if you can still eat them',
            //     speed: const Duration(milliseconds: 70), cursor: ''),
            // TypewriterAnimatedText("< If it's spoiled, you'll know right away!",
            //     cursor: "/>"),
          ],
          onTap: () {
            print("Tap Event");
          },
        ),
      ),
    );
  }

  //? Done
  Widget _imagePage() {
    return _bytesData != null
        ? Image.memory(_bytesData!,
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5)
        : const Placeholder();
  }

  Widget _loadingPage() {
    return const SizedBox(
      height: 200.0,
      width: 200.0,
      child: LoadingIndicator(
        colors: [
          Colors.blue,
          Colors.green,
          Colors.yellow,
        ],
        indicatorType: Indicator.pacman,
      ),
    );
  }

  Widget _resultReadyPage() {
    return SizedBox(
      width: 700.0,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 70.0,
        ),
        child: AnimatedTextKit(
          pause: const Duration(milliseconds: 500),
          repeatForever: true,
          animatedTexts: [
            ScaleAnimatedText('Your Result Is Ready',
                textAlign: TextAlign.center),
          ],
          onTap: null,
        ),
      ),
    );
  }

  String _classDetermination(int classNumber) {
    switch (classNumber) {
      case 0:
        return "สด";
      case 1:
        return "ไม่สด";
      case 2:
        return "เน่า";
      default:
        return "error : class out of range";
    }
  }

  int _toPercent(double confindenceScore) {
    return (confindenceScore * 100).round();
  }

  Widget _resultClass1Formatter() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
          child: Column(
        children: [
          Text(
            "Xception : ${_classDetermination(predict["model_1_xception"]!["Class"])}",
            style: TextStyle(fontSize: 25.0),
          ),
          Text(
              "สด   : ${_toPercent(predict["model_1_xception"]!["data"]!["class_0_confidence_score"])} %"),
          Text(
              "ไม่สด : ${_toPercent(predict["model_1_xception"]!["data"]!["class_1_confidence_score"])} %"),
          Text(
              "เน่า   : ${_toPercent(predict["model_1_xception"]!["data"]!["class_2_confidence_score"])} %"),
        ],
      )),
    );
  }

  Widget _resultClass2Formatter() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
          child: Column(
        children: [
          Text(
            "VGG-16 : ${_classDetermination(predict["model_2_vgg16"]!["Class"])}",
            style: TextStyle(fontSize: 25.0),
          ),
          Text(
              "สด   : ${_toPercent(predict["model_2_vgg16"]!["data"]!["class_0_confidence_score"])} %"),
          Text(
              "ไม่สด : ${_toPercent(predict["model_2_vgg16"]!["data"]!["class_1_confidence_score"])} %"),
          Text(
              "เน่า   : ${_toPercent(predict["model_2_vgg16"]!["data"]!["class_2_confidence_score"])} %"),
        ],
      )),
    );
  }

  Widget _resultClass3Formatter() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
          child: Column(
        children: [
          Text(
            "CNN : ${_classDetermination(predict["model_3_cnn"]!["Class"])}",
            style: TextStyle(fontSize: 25.0),
          ),
          Text(
              "สด   : ${_toPercent(predict["model_3_cnn"]!["data"]!["class_0_confidence_score"])} %"),
          Text(
              "ไม่สด : ${_toPercent(predict["model_3_cnn"]!["data"]!["class_1_confidence_score"])} %"),
          Text(
              "เน่า   : ${_toPercent(predict["model_3_cnn"]!["data"]!["class_2_confidence_score"])} %"),
        ],
      )),
    );
  }

  Map<String, dynamic> _finalResultDeterminer() {
    if ((predict["model_1_xception"]!["Class"] !=
            predict["model_2_vgg16"]!["Class"]) &&
        (predict["model_1_xception"]!["Class"] !=
            predict["model_3_cnn"]!["Class"]) &&
        (predict["model_2_vgg16"]!["Class"] !=
            predict["model_3_cnn"]!["Class"])) {
      return {
        "emoji": "😕",
        "freshness": "Can't be determined",
        "color": Colors.blue,
      }; // 3 = cant be determined
    }
    int freshness = 3;
    if (predict["model_1_xception"]!["Class"] ==
        predict["model_2_vgg16"]!["Class"]) {
      freshness = predict["model_1_xception"]!["Class"];
    }
    if (predict["model_1_xception"]!["Class"] ==
        predict["model_3_cnn"]!["Class"]) {
      freshness = predict["model_1_xception"]!["Class"];
    }
    if (predict["model_3_cnn"]!["Class"] ==
        predict["model_2_vgg16"]!["Class"]) {
      freshness = predict["model_3_cnn"]!["Class"];
    }

    if (freshness == 0) {
      return {"emoji": "😆", "freshness": "Fresh", "color": Colors.red};
    }
    if (freshness == 1) {
      return {"emoji": "😢", "freshness": "Not Fresh", "color": Colors.lime};
    }
    if (freshness == 2) {
      return {"emoji": "🤢", "freshness": "Spolied", "color": Colors.green};
    }
    return {
      "emoji": "😕",
      "freshness": "Can't be determined",
      "color": Colors.blue
    };
  }

  Widget _resultPage() {
    Map<String, dynamic> myResult = _finalResultDeterminer();
    return Column(
      children: [
        Center(
            child: Column(
          children: [
            const Text("Your Meat is", style: TextStyle(fontSize: 50)),
            _result(myResult['emoji'], myResult['freshness'], myResult['color'])
          ],
        )),
        const SizedBox(
          height: 30.0,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.deepPurpleAccent,
                ),
                child: _resultClass1Formatter(),
              ),
            ),
            const VerticalDivider(
              width: 20,
              thickness: 1,
              indent: 20,
              endIndent: 0,
              color: Colors.grey,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.deepOrangeAccent,
                ),
                child: _resultClass2Formatter(),
              ),
            ),
            const VerticalDivider(
              width: 20,
              thickness: 1,
              indent: 20,
              endIndent: 0,
              color: Colors.grey,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.lightGreen,
                ),
                child: _resultClass3Formatter(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pageBuilder() {
//if else if else if else
    if (_isDebugMode == true) {
      switch (_debugPageNum) {
        case 0:
          return _blankPage();
        case 1:
          return _imagePage();
        case 2:
          return _loadingPage();
        case 3:
          return _resultReadyPage();
        case 4:
          return _resultPage();
        case 5:
          return Container();
        default:
          return const Text("error : debug mode => default");
      }
    } else {
      if (_isLoadingResult) {
        return _loadingPage();
      }
      if (_bytesData == null && !_posted) {
        return _blankPage();
      } else if (_bytesData != null && !_posted) {
        return _imagePage();
      } else if (_bytesData != null && _posted) {
        return _resultReadyPage();
      } else if (_bytesData == null && _posted) {
        return _resultPage();
      }
      return const Text("error :none debug default");
    }
  }

  List<Widget> _menuBuilder() {
    if (!_isDebugMode) {
      return [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
          ),
          child: Text(
            'Guest User',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        const Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Modes"),
        ),
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('Upload your image'),
          onTap: () {},
        ),
      ];
    } else {
      return [
        ListTile(
          leading: const Icon(Icons.looks_one),
          title: const Text('start page before upload'),
          onTap: () {
            setState(() {
              _debugPageNum = 0;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.looks_two),
          title: const Text('image uploaded'),
          onTap: () {
            setState(() {
              _debugPageNum = 1;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.looks_3),
          title: const Text('loading'),
          onTap: () {
            setState(() {
              _debugPageNum = 2;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.looks_4),
          title: const Text('after loading'),
          onTap: () {
            setState(() {
              _debugPageNum = 3;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.looks_5),
          title: const Text("result page"),
          onTap: () {
            setState(() {
              _debugPageNum = 4;
            });
          },
        ),
      ];
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.orange;
    }
    return Colors.blueGrey;
  }
}
