import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

//TODO: Separate into multiple dart files
//TODO: Collection selector screen
//TODO: Saving collections and search depth for individual folders
//TODO: Prevent multiple file selectors being open
//TODO: Scale images
//TODO: Support sequential files
//TODO: Mark/note/log files that I want to do something about

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const ImageViewerApp());
}

class Node {
  File value;
  Node? prev;
  Node? next;

  Node(this.value, [this.prev, this.next]);
}

class ImageViewerModel extends ChangeNotifier {
  List<FileSystemEntity> _mediaList =
      []; // All files and folders defined by selected collection

  late Node _current; // Double-linked list serving as a "history" of files
  File get current => _current.value;

  final _random = Random();

  late final player = Player();
  late final controller = VideoController(player);

  ImageViewerModel(Directory dir, int searchDepth) {
    populateMediaList(dir, searchDepth);
    player.setPlaylistMode(PlaylistMode.single);
  }

  void populateMediaList(Directory dir, int searchDepth) async {
    //TODO: Properly handle if _mediaList turns out empty
    _mediaList = await getMedia(dir, searchDepth);

    if (_mediaList.isNotEmpty) {
      FileSystemEntity first = _mediaList[_random.nextInt(_mediaList.length)];
      if (first is File) {
        _current = Node(first);
      }
      notifyListeners();
    }
  }

  List<FileSystemEntity> filterMedia(List<FileSystemEntity> entities) {
    return entities.where((entity) => isMedia(entity)).toList();
  }

  bool isMedia(FileSystemEntity entity) {
    if (entity is File) {
      final mimeType = lookupMimeType(entity.path);

      if (mimeType != null) {
        return mimeType.startsWith('image/') || mimeType.startsWith('video/');
      }
    }
    return false;
  }

  Future<List<FileSystemEntity>> getMedia(Directory dir, int depthLeft) async {
    List<FileSystemEntity> entitiesHere = await dir.list().toList();

    if (depthLeft == 0) {
      return filterMedia(entitiesHere);
    }

    List<FileSystemEntity> entitiesBelow = [];
    for (final e in entitiesHere) {
      if (e is Directory) {
        entitiesBelow.addAll(await getMedia(e, depthLeft - 1));
      }
    }
    return entitiesBelow;
  }

  void next() {
    if (player.state.playing) {
      player.stop();
    }

    if (_current.next == null) {
      FileSystemEntity next = _mediaList[_random.nextInt(_mediaList.length)];
      if (next is File) {
        _current.next = Node(next, _current);
      }
    }

    Node? next = _current.next;
    if (next != null) {
      _current = next;
      notifyListeners();
    }
  }

  void back() {
    if (player.state.playing) {
      player.stop();
    }

    if (_current.prev != null) {
      _current = _current.prev!;
    }

    notifyListeners();
  }
}

class ImageViewerApp extends StatelessWidget {
  const ImageViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CollectionSelectorPage(),
    );
  }
}

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

class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key});

  Widget getMediaWidget(File current, ImageViewerModel model) {
    final mimeType = lookupMimeType(current.path);
    if (mimeType!.startsWith('video/')) {
      model.player.open(Media(current.path));
      return Video(
        controller: model.controller,
      );
    } else {
      return (Image.file(current));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<ImageViewerModel>(builder: (context, model, child) {
      Widget mediaWidget = model._mediaList.isEmpty
          ? const Center(child: Text('Loading'))
          : getMediaWidget(model.current, model);
      return Column(
        children: [
          Expanded(child: mediaWidget),
          Row(
            children: [
              ElevatedButton(
                onPressed: model.back,
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: model.next,
                child: const Text('Next'),
              )
            ],
          )
        ],
      );
    }));
  }
}
