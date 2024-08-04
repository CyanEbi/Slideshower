import 'package:flutter/material.dart';
import 'package:image_viewer/collection_selector_page.dart';
import 'package:media_kit/media_kit.dart';

//TODO: Collection selector screen
//TODO: Saving collections and search depth for individual folders
//TODO: Prevent multiple file selectors being open
//TODO: Support sequential files
//TODO: Mark/note/log files that I want to do something about

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const ImageViewerApp());
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
