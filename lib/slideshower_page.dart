import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slideshower/slideshower_model.dart';
import 'package:slideshower/notes_dialog.dart';
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

  SnackBar getSnackBar(double windowWidth) {
    double hozMargin = windowWidth / 2 - 100;
    return SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(hozMargin, 0, hozMargin, 75),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        content: const Align(
            alignment: Alignment.center, child: Text('Note added')));
  }

  void returnToCollections(BuildContext context, SlideshowerModel model) async {
    List<File> notedMedia = model.notedMedia;
    Function deleteFunction = model.deleteMedia;
    if (notedMedia.isEmpty) {
      if (context.mounted) {
        model.disposePlayer();
        Navigator.pop(context);
      }
    } else {
      bool? res = await showDialog(
          context: context,
          builder: (BuildContext context) =>
              NotesDialog(notes: notedMedia, deleteFunction: deleteFunction));
      if (res != null) {
        if (res && context.mounted) {
          model.disposePlayer();
          Navigator.pop(context);
        }
      }
    }
  }

  final ShortcutActivator exit =
      const SingleActivator(LogicalKeyboardKey.escape);
  final ShortcutActivator back =
      const SingleActivator(LogicalKeyboardKey.arrowLeft);
  final ShortcutActivator note = const SingleActivator(LogicalKeyboardKey.keyN);
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
            returnToCollections(context, model);
          },
          back: () => model.back(),
          note: () {
            model.noteMedia();
            ScaffoldMessenger.of(context)
                .showSnackBar(getSnackBar(MediaQuery.of(context).size.width));
          },
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
                              returnToCollections(context, model);
                            },
                            child: const Text('Return')),
                        ElevatedButton(
                          onPressed: model.back,
                          child: const Text('Back'),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              model.noteMedia();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  getSnackBar(
                                      MediaQuery.of(context).size.width));
                            },
                            child: const Text('Note')),
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
