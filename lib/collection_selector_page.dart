import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:slideshower/slideshower_model.dart';
import 'package:slideshower/slideshower_page.dart';
import 'package:provider/provider.dart';

class CollectionSelectorPage extends StatefulWidget {
  const CollectionSelectorPage({super.key});

  @override
  State<CollectionSelectorPage> createState() => _CollectionSelectorPageState();
}

class _CollectionSelectorPageState extends State<CollectionSelectorPage> {
  late String dataPath;
  List<dynamic> collections = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  void fetchCollections() async {
    final dataDir = await getApplicationSupportDirectory();
    dataPath = '${dataDir.path}/slideshowercollections.json';
    File file = File(dataPath);
    final contents = await file.readAsString();
    setState(() {
      collections = json.decode(contents) as List<dynamic>;
    });
  }

  void startSlideshower(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => ChangeNotifierProvider(
                  create: (context) =>
                      SlideshowerModel(collections[selectedIndex]),
                  child: const SlideshowerPage(),
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
                    selectedTileColor: Colors.cyan,
                    tileColor: const Color.fromARGB(255, 228, 228, 228),
                    leading: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        print('New'); //TODO: Add functionality
                      },
                    ),
                    selected: index == selectedIndex,
                    onTap: () {
                      print('New'); //TODO: Add functionality
                    },
                  );
                }
                return ListTile(
                  title: Text(collections[index]['name']),
                  selectedTileColor: Colors.cyan,
                  tileColor: const Color.fromARGB(255, 228, 228, 228),
                  leading: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        selectedIndex = index;
                      });
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
              startSlideshower(context);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    ));
  }
}
