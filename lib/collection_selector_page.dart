import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_viewer/image_viewer_model.dart';
import 'package:image_viewer/image_viewer_page.dart';
import 'package:provider/provider.dart';

class CollectionSelectorPage extends StatefulWidget {
  const CollectionSelectorPage({super.key});

  @override
  State<CollectionSelectorPage> createState() => _CollectionSelectorPageState();
}

class _CollectionSelectorPageState extends State<CollectionSelectorPage> {
  int searchDepth = 2;
  String? path;

  void selectFolder() async {
    String? newPath = await FilePicker.platform.getDirectoryPath();
    setState(() {
      path = newPath;
    });
  }

  void startImageViewer(BuildContext context) {
    String? selectedPath = path;
    if (selectedPath != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => ChangeNotifierProvider(
                    create: (context) =>
                        ImageViewerModel(Directory(selectedPath), searchDepth),
                    child: const ImageViewerPage(),
                  ))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownButton<int>(
            items: const [
              DropdownMenuItem<int>(value: 0, child: Text('0')),
              DropdownMenuItem<int>(value: 1, child: Text('1')),
              DropdownMenuItem<int>(value: 2, child: Text('2')),
            ],
            onChanged: (int? value) {
              setState(() {
                searchDepth = value!;
              });
            },
            value: searchDepth,
          ),
          ElevatedButton(
            onPressed: selectFolder,
            child: const Text('Select folder'),
          ),
          ElevatedButton(
            onPressed: path == null
                ? null
                : () {
                    startImageViewer(context);
                  },
            child: const Text('Start'),
          )
        ],
      ),
    ));
  }
}
