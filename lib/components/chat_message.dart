// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:chat_online/screens/photo_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
    required this.data,
    required this.mine,
    required this.toDelete,
    required this.currentUser,
    required this.cloudinary,
  });

  final Map<String, dynamic>? data;
  final bool mine;
  final DocumentReference toDelete;
  final User? currentUser;
  final Cloudinary? cloudinary;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    final Timestamp timestamp = widget.data!['time'] as Timestamp;
    final DateTime dateTime = timestamp.toDate().toLocal();
    final formatedTime =
        "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, "0")}";

    return Align(
      alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          widget.data!["uid"] == widget.currentUser!.uid ||
                  widget.currentUser!.uid == "0gJySHxjuqeX3bolagnglebVvsz1"
              ? showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Deletar a mensagem",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content:
                          Text("Tem certeza que deseja deletar a mensagem?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Fechar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await widget.toDelete.delete();

                              if (widget.data!["imageUrl"] != null) {
                                final deleted =
                                    await widget.cloudinary!.destroy(
                                  widget.data!['publicId'],
                                  resourceType: CloudinaryResourceType.image,
                                );
                                if (!deleted.isSuccessful) {
                                  throw Exception(
                                      "Erro ao excluir imagem do Cloudinary");
                                }
                              }

                              Navigator.of(context).pop();
                            } catch (e) {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Erro"),
                                  content: Text(
                                      "Ocorreu um erro ao tentar excluir a mensagem ou a mídia: $e"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text('Sim'),
                        ),
                      ],
                    );
                  })
              : null;
        },
        child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.black12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              !widget.mine
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: GestureDetector(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              widget.data!['senderPhotoUrl'] ?? ""),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PhotoScreens(
                                imageData:
                                    widget.data!['senderPhotoUrl'] ?? ""),
                          ));
                        },
                      ),
                    )
                  : Container(),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    crossAxisAlignment: widget.mine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      widget.data!['imageUrl'] != null
                          ? GestureDetector(
                              child: Image.network(
                                widget.data!['imageUrl'],
                                width: 250,
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PhotoScreens(
                                      imageData: widget.data!['imageUrl']),
                                ));
                              },
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 200),
                              child: Text(
                                widget.data!['text'] ?? "",
                                style: TextStyle(fontSize: 23),
                                maxLines: null,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.data!['senderName'] ?? "",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatedTime,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              widget.mine
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              widget.data!['senderPhotoUrl'] ?? ""),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PhotoScreens(
                                imageData:
                                    widget.data!['senderPhotoUrl'] ?? ""),
                          ));
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
