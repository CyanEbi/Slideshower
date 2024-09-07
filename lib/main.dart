import 'package:flutter/material.dart';
import 'package:image_viewer/collection_selector_page.dart';
import 'package:media_kit/media_kit.dart';

//TODO: Rename to SliderShower
//TODO: Keyboard shortcuts
//TODO: Auto-next
//TODO: Prettify collection selector screen
//TODO: Properly define JSON typing if possible
//TODO: Properly handle if _mediaList turns out empty
//TODO: Change app package name
//TODO: Ability to add collections
//TODO: Create a collections file if none exists
//TODO: Ability to edit collections
//TODO: Mark/note/log files that I want to do something about
//TODO: Some images have weird color profiles or something

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
