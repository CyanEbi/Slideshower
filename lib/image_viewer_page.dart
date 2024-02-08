import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_viewer/image_viewer_model.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

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
      Widget mediaWidget = model.hasMedia
          ? getMediaWidget(model.current, model)
          : const Center(child: Text('Loading'));
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
