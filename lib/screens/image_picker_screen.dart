import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File _storedImage;
  final picker = ImagePicker();

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
  File imageFile = await  ImagePicker.pickImage(
      source: ImageSource.gallery, imageQuality: 50, maxHeight: 300,maxWidth: 300

  );

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
      }
    );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 120,
        ),
        Container(
          height: 300,
          width: 300,
          
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
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
            
            icon: Icon(Icons.camera, color: Theme.of(context).primaryColor,),
            label: Text('Take picture', style: TextStyle(color: Theme.of(context).primaryColor),))
      ],
    );
  }
}
