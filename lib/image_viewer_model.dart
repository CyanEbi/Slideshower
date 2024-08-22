import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_viewer/node.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mime/mime.dart';
import 'package:collection/collection.dart';

class ImageViewerModel extends ChangeNotifier {
  List<FileSystemEntity> _mediaList =
      []; // All files and folders defined by selected collection
  bool get hasMedia => _mediaList.isNotEmpty;

  late Node _current; // Double-linked list serving as a "history" of files
  File get current => _current.value;

  final _random = Random();

  late final player = Player();
  late final controller = VideoController(player);

  ImageViewerModel(collection) {
    populateMediaList(collection);
    player.setPlaylistMode(PlaylistMode.single);
  }

  void populateMediaList(collection) async {
    List<FileSystemEntity> mediaList = [];
    //TODO: Properly handle if _mediaList turns out empty
    for (final dir in collection['directories']) {
      final temp =
          await getFSEntities(Directory(dir['path']), dir['searchDepth']);
      mediaList.addAll(temp);
    }
    _mediaList = mediaList;

    if (_mediaList.isNotEmpty) {
      FileSystemEntity first = _mediaList[_random.nextInt(_mediaList.length)];
      if (first is File) {
        _current = Node(first);
      } else if (first is Directory) {
        _current = await createSequence(first);
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

  Future<List<FileSystemEntity>> getFSEntities(
      Directory dir, int depthLeft) async {
    List<FileSystemEntity> entitiesHere = await dir.list().toList();

    if (depthLeft == 0) {
      return filterFSEntities(entitiesHere);
    }

    List<FileSystemEntity> entitiesBelow = [];
    for (final e in entitiesHere) {
      if (e is Directory) {
        entitiesBelow.addAll(await getFSEntities(e, depthLeft - 1));
      }
    }
    return entitiesBelow;
  }

  List<FileSystemEntity> filterFSEntities(List<FileSystemEntity> entities) {
    return entities.where((e) => (isMedia(e)) | (e is Directory)).toList();
  }

  void next() async {
    if (player.state.playing) {
      player.stop();
    }

    if (_current.next == null) {
      FileSystemEntity next = _mediaList[_random.nextInt(_mediaList.length)];
      if (next is File) {
        _current.next = Node(next, _current);
      } else if (next is Directory) {
        Node sequenceHead = await createSequence(next);
        sequenceHead.prev = _current;
        _current.next = sequenceHead;
      }
    }

    Node? next = _current.next;
    if (next != null) {
      _current = next;
      notifyListeners();
    }
  }

  Future<Node> createSequence(Directory dir) async {
    List<FileSystemEntity> entitiesHere = await dir.list().toList();
    entitiesHere.sort(
        (a, b) => compareNatural(a.path.toLowerCase(), b.path.toLowerCase()));
    List<FileSystemEntity> mediaHere = filterMedia(entitiesHere);
    Node sequenceHead = Node(mediaHere[0] as File);
    Node tempCurrent = sequenceHead;
    Node tempNext;
    for (final m in mediaHere.sublist(1)) {
      tempNext = Node(m as File, tempCurrent);
      tempCurrent.next = tempNext;
      tempCurrent = tempNext;
    }

    return sequenceHead;
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

  void disposePlayer() async {
    await player.dispose();
  }
}
