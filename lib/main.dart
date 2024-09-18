import 'package:flutter/material.dart';
import 'package:slideshower/collection_selector_page.dart';
import 'package:media_kit/media_kit.dart';

//TODO: Auto-next
//TODO: Prettify collection selector screen
//TODO: Properly define JSON typing if possible
//TODO: Properly handle if _mediaList turns out empty
//TODO: Properly handle if _mediaList becomes empty due to deleting files
//TODO: Change app package name
//TODO: Ability to add collections
//TODO: Create a collections file if none exists
//TODO: Ability to edit collections
//TODO: Some images have weird color profiles or something
//TODO: Handle if media is deleted by third party while slideshower is on

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const SlideshowerApp());
}

class SlideshowerApp extends StatelessWidget {
  const SlideshowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slideshower',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CollectionSelectorPage(),
    );
  }
}
