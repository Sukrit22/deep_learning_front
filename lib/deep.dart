//import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<int>? _selectedFile;
  Uint8List? _bytesData;
  String _backendURL = 'http://deep-api.celab.network';
  Map<String, dynamic> predict = {};
  //bool _emergencyMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _urlFieldController = TextEditingController();

  void display() {}

  void setUrl() {
    //! set as emergency mode
    //get url from text field
    //final tempUrl = '';

    setState(
      () {
        _backendURL = _urlFieldController.text == ''
            ? "http://deep-api.celab.network"
            : _urlFieldController.text;
        print(_backendURL);
      },
    );
  }

  startWebFilePicker() async {
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
          //print(_bytesData);
        });
      });
      reader.readAsDataUrl(file);
    });
  }

  Future<void> uploadImage() async {
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
        setState(() async {
          predict = json.decode(await response.stream.bytesToString());
          print(predict);
        });
      } else {
        print('File upload failed.');
        //show error
      }
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
      key: _scaffoldKey,
      appBar: AppBar(
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
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onSubmitted: _backendURL == ''
                    ? null
                    : (String value) {
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
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _selectImage(),
                const SizedBox(
                  height: 10,
                ),
                _bytesData != null
                    ? Image.memory(_bytesData!,
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.5)
                    : Container(),
                _sendToBackend(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultFresh() {
    return Stack(
      children: [
        Text(
          "😆",
          style: _emojiStyle(),
        ),
        Text(
          "Fresh",
          style: _resultSize(color: Colors.red),
        )
      ],
    );
  }

  Widget _resultNotFresh() {
    return Stack(
      children: [
        Text(
          "😢",
          style: _emojiStyle(),
        ),
        Text(
          "NotFresh",
          style: _resultSize(color: Colors.lime),
        )
      ],
    );
  }

  Widget _resultSpoiled() {
    return Stack(
      children: [
        Text(
          "🤢",
          style: _emojiStyle(),
        ),
        Text(
          "Spoiled",
          style: _resultSize(color: Colors.lightGreen),
        )
      ],
    );
  }

  TextStyle _emojiStyle() {
    return TextStyle(fontSize: 50.0);
  }

  TextStyle _resultSize({
    required Color color,
  }) {
    return TextStyle(
      fontSize: 30.0,
      color: color,
    );
  }

  MaterialButton _sendToBackend() {
    return MaterialButton(
      color: Colors.orange,
      elevation: 8.0,
      highlightElevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      textColor: Colors.white,
      onPressed: () {
        uploadImage();
      },
      child: const Text('send to backend'),
    );
  }

  MaterialButton _selectImage() {
    return MaterialButton(
      color: Colors.orange,
      elevation: 8.0,
      highlightElevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      textColor: Colors.white,
      onPressed: () {
        startWebFilePicker();
      },
      child: const Text('select image'),
    );
  }
}
