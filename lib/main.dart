import 'package:flutter/material.dart';
import 'package:image_viewer/collection_selector_page.dart';
import 'package:media_kit/media_kit.dart';

//TODO: Prettify collection selector screen
//TODO: Properly define JSON typing if possible
//TODO: Properly handle if _mediaList turns out empty
//TODO: Figure out why the dataDir folder has "example" in the name
//TODO: Ability to add collections
//TODO: Create a collections file if none exists
//TODO: Ability to edit collections
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
