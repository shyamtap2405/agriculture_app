import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        accentColor: Colors.amber,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _storedImage;
  final picker = ImagePicker();
  String predict;

  Future imageFromCamera() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (imageFile != null) {
        _storedImage = File(imageFile.path);
      } else {
        print('No image selected.');
      }
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  }

  Future imageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 300,
        maxWidth: 300);

    setState(() {
      if (imageFile != null) {
        _storedImage = File(imageFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        imageFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  var _isLoading = false;

  Future _submitData() async {
    setState(() {
      _isLoading = true;
    });
    String url = " ";
    final response =
        await http.post(url, headers: {"content/type": "application/json"});
    final extractedData = jsonDecode(response.body);
    setState(() {
      _isLoading = false;
      predict = extractedData['prediction'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agriculture'),
      ),
      body:  _isLoading == true ? Container(child: Center(child: CircularProgressIndicator(),),)
      : Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 120,
                  ),
                  Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: _storedImage != null
                        ? SingleChildScrollView(
                            child: Image.file(
                              _storedImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Center(
                            child: Text(
                              'No image taken',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FlatButton.icon(
                      onPressed: () {
                        _showPicker(context);
                      },
                      icon: Icon(
                        Icons.camera,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        'Take picture',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ))
                ],
              ),
              SizedBox(
                height: 2,
              ),
              predict != null
                  ? Container(
                      child: Column(
                      children: [
                        Container(
                            child: Text(
                          "Disease Predicted:",
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        )),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Text(predict,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ))
                  : Container(),
              RaisedButton(
                onPressed: () async {
                  await _submitData();
                },
                child: Text(
                  'check for disease',
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
