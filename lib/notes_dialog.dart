import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesDialog extends StatefulWidget {
  final List<File> notes;
  final Function deleteFunction;

  const NotesDialog(
      {super.key, required this.notes, required this.deleteFunction});

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  bool deleteMode = false;

  @override
  Widget build(BuildContext context) {
    List<File> notesList = widget.notes.toList();
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 325,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: widget.notes.length,
                  itemBuilder: (context, index) {
                    File file = notesList[index];
                    final mimeType = lookupMimeType(file.path);
                    return ListTile(
                      title: Text(file.path),
                      leading: IconButton(
                          onPressed: () {
                            if (Platform.isLinux) {
                              showFileInExplorer(file.path);
                            } else {
                              launchUrl(Uri(scheme: 'file', path: file.path));
                            }
                          },
                          icon: mimeType!.startsWith('video/')
                              ? const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.file_open))
                              : Image.file(
                                  file,
                                  width: 32,
                                  height: 32,
                                )),
                      trailing: deleteMode
                          ? IconButton(
                              onPressed: () {
                                widget.deleteFunction(file);
                                widget.notes.remove(file);
                                setState(() {});
                              },
                              icon: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.delete),
                              ))
                          : const SizedBox(
                              width: 48,
                              height: 48,
                            ),
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Return')),
                ),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Stay')),
                ),
                Flexible(
                  flex: 1,
                  child: ListTileTheme(
                    horizontalTitleGap: 0,
                    child: CheckboxListTile(
                        title: const Text('Enable deletion'),
                        value: deleteMode,
                        onChanged: (ticked) {
                          setState(() {
                            if (ticked != null) {
                              deleteMode = ticked;
                            }
                          });
                        }),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

void showFileInExplorer(String path) async {
  if (Platform.isLinux) {
    ProcessResult res =
        await Process.run('xdg-mime', ['query', 'default', 'inode/directory']);
    String explorer = res.stdout.toString().split('.')[0];
    Process.run(explorer, [path]);
  }
}
