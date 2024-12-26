import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({
    super.key,
    this.sendMessage,
  });

  final Function({
    String text,
    XFile mediaFile,
  })? sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController textController = TextEditingController();

  bool isComposing = false;
  bool limitText = false;
  int lenText = 0;

  double uploadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black12,
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
                size: 30,
              ),
              onPressed: () {
                final RenderBox button =
                    context.findRenderObject() as RenderBox;
                final Offset buttonPosition = button.localToGlobal(Offset.zero);
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        buttonPosition.dx,
                        buttonPosition.dy + button.size.height,
                        buttonPosition.dx + button.size.width,
                        buttonPosition.dy),
                    items: [
                      PopupMenuItem(
                          value: 'foto_camera',
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_camera,
                                color: Colors.blue,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  "Tirar Foto",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                            ],
                          )),
                      PopupMenuItem(
                          value: 'foto_galeria',
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                color: Colors.blue,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  "Abrir Galeria de Imagens",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                            ],
                          )),
                    ]).then((value) {
                  switch (value) {
                    case "foto_camera":
                      pickImage(ImageSource.camera);
                    case "foto_galeria":
                      pickImage(ImageSource.gallery);
                    default:
                      return;
                  }
                });
              },
            ),
            Expanded(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
                decoration: const InputDecoration.collapsed(
                    hintText: "Digite uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    isComposing = text.isNotEmpty;
                    lenText = text.length;
                    if (lenText >= 201) {
                      limitText = true;
                    } else {
                      limitText = false;
                    }
                  });
                },
                onSubmitted: (text) {
                  widget.sendMessage!(text: text);
                  textController.clear();
                  setState(() {
                    isComposing = false;
                  });
                },
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: isComposing
                          ? () {
                              widget.sendMessage!(text: textController.text);
                              textController.clear();
                              setState(() {
                                isComposing = false;
                                lenText = 0;
                              });
                            }
                          : null,
                      icon: Icon(Icons.send,
                          color: isComposing && limitText == false
                              ? Colors.blue
                              : Colors.grey)),
                  Text("$lenText/200"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? mediaImage = await picker.pickImage(source: source);
    if (mediaImage == null) return;

    widget.sendMessage!(
      mediaFile: mediaImage,
    );
  }
}
