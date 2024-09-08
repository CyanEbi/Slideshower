import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slideshower/slideshower_model.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class SlideshowerPage extends StatelessWidget {
  const SlideshowerPage({super.key});

  Widget getMediaWidget(File current, SlideshowerModel model) {
    final mimeType = lookupMimeType(current.path);
    if (mimeType!.startsWith('video/')) {
      model.player.open(Media(current.path));
      return Video(
        controller: model.controller,
      );
    } else {
      return (Image.file(current, fit: BoxFit.contain));
    }
  }

  final ShortcutActivator exit =
      const SingleActivator(LogicalKeyboardKey.escape);
  final ShortcutActivator back =
      const SingleActivator(LogicalKeyboardKey.arrowLeft);
  final ShortcutActivator next =
      const SingleActivator(LogicalKeyboardKey.arrowRight);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<SlideshowerModel>(builder: (context, model, child) {
      // --- Create a Widget containing the current media ---
      Widget mediaWidget = model.hasMedia
          ? getMediaWidget(model.current, model)
          : const Center(child: Text('Loading'));
      return CallbackShortcuts(
        // --- Assign shortcuts ---
        bindings: {
          exit: () {
            model.disposePlayer();
            Navigator.pop(context);
          },
          back: () => model.back(),
          next: () => model.next(),
        },
        // --- Create the Slideshower page ---
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              // --- Media Widget ---
              Expanded(
                child: mediaWidget,
              ),
              // --- Footer ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Filename ---
                    model.hasMedia ? Text(model.current.path) : const Text(''),
                    // --- Navigation buttons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              model.disposePlayer();
                              Navigator.pop(context);
                            },
                            child: const Text('Return')),
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
                ),
              )
            ],
          ),
        ),
      );
    }));
  }
}
