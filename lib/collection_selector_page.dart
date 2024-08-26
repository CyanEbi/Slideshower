import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
  List<dynamic> collections = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  void fetchCollections() async {
    print(await getApplicationSupportDirectory());
    final dataDir = await getApplicationSupportDirectory();
    File file = File('${dataDir.path}/imageviewercollections.json');
    final contents = await file.readAsString();
    setState(() {
      collections = json.decode(contents) as List<dynamic>;
    });
  }

  void startImageViewer(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => ChangeNotifierProvider(
                  create: (context) =>
                      ImageViewerModel(collections[selectedIndex]),
                  child: const ImageViewerPage(),
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: collections.length + 1,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                if (index == collections.length) {
                  return ListTile(
                    title: const Text("New collection"),
                    tileColor: const Color.fromARGB(255, 228, 228, 228),
                    leading: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        print('New'); //TODO: Add functionality
                      },
                    ),
                  );
                }
                return ListTile(
                  title: Text(collections[index]['name']),
                  selectedTileColor: Colors.cyan,
                  tileColor: const Color.fromARGB(255, 228, 228, 228),
                  leading: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      print('Edit'); //TODO: Add functionality
                    },
                  ),
                  selected: index == selectedIndex,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              startImageViewer(context);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    ));
  }
}
