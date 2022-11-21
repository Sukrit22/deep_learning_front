//import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<int>? _selectedFile;
  Uint8List? _bytesData;
  String _backendURL = '';
  Map<String, dynamic> predict = {};

  final _urlFieldController = TextEditingController();

  setUrl() {
    //get url from text field
    //final tempUrl = '';

    setState(
      () {
        _backendURL = _urlFieldController.text;
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
          print(_bytesData);
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  _backendURL != '' ? 'The Url is :' : 'please enter your URL',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _backendURL != '' ? '"  $_backendURL  "' : '',
                  style: const TextStyle(color: Colors.purple),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                MaterialButton(
                  color: Colors.orange,
                  elevation: 8.0,
                  highlightElevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  textColor: Colors.white,
                  onPressed: () {
                    startWebFilePicker();
                  },
                  child: const Text('select image'),
                ),
                const SizedBox(
                  height: 10,
                ),
                _bytesData != null
                    ? Image.memory(_bytesData!, width: 200, height: 200)
                    : Container(),
                //Expanded(child: Container()),
                const Divider(
                  color: Colors.teal,
                ),
                const SizedBox(height: 20),
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
                      hintText: 'your.server.domain or ip address (:port)/path',
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
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  color: Colors.orange,
                  elevation: 8.0,
                  highlightElevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  textColor: Colors.white,
                  onPressed: _backendURL == ''
                      ? null
                      : () {
                          uploadImage();
                        },
                  child: const Text('send to backend'),
                ),
                Row(
                  children: [Expanded(child: Container())],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
