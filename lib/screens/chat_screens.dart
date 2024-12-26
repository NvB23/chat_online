// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_online/components/chat_message.dart';
import 'package:chat_online/components/text_composer.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreens extends StatefulWidget {
  const ChatScreens({super.key});

  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  User? currentUser;
  bool isLoading = false;
  Cloudinary? configCloudinary;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
      });
    });
  }

  // Instancia e começa o processo de login:
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> getUser() async {
    if (currentUser != null) return currentUser;

    try {
      // Abre a interface de login do Google, retorna a conta selecionada pelo usuário ou null se for cancelado:
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      // Obtem informações da conta selecionada (Para mudar de contas):
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      // Cria credenciais:
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Usa as crendiciais criadas para autentificar o usuário:
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Variável com as informações do usuário ou null se der errado:
      final User? user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void sendMessage({
    String? text,
    XFile? mediaFile,
  }) async {
    final User? user = await getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Não foi possível fazer o login. Tente novamente"),
        backgroundColor: Colors.blue,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now(),
    };

    if (mediaFile != null) {
      File file = File(mediaFile.path);

      setState(() {
        isLoading = true;
      });

      // UploadTask task = FirebaseStorage.instance
      //     .ref()
      //     .child(DateTime.now().microsecondsSinceEpoch.toString())
      //     .putFile(file);

      // TaskSnapshot taskSnapshot = await task;
      // String url = await taskSnapshot.ref.getDownloadURL();

      // data["imgUrl"] = url;
      final publicId = DateTime.now().millisecondsSinceEpoch.toString();

      final cloudinary = Cloudinary.signedConfig(
          apiKey: "222786371534496",
          apiSecret: "5WCx9pbMa1EslNHLh6mzaARj2t4",
          cloudName: "dwwao07ae");

      configCloudinary = cloudinary;

      final responseImage = await cloudinary.upload(
        file: file.path,
        resourceType: CloudinaryResourceType.image,
        fileName: user.uid + DateTime.now().millisecondsSinceEpoch.toString(),
        publicId: publicId,
      );

      final responseVideo = await cloudinary.upload(
        file: file.path,
        resourceType: CloudinaryResourceType.video,
        fileName: DateTime.now().millisecondsSinceEpoch.toString(),
        publicId: publicId,
      );

      print("CHEGOU!!!!!!!!!!!!");

      if (!file.path.endsWith('.mp4') && !file.path.endsWith('.mov')) {
        print("O ARQUIVO É $file.path");
        print("Formato não suportado");
      }

      if (responseImage.isSuccessful) {
        data["imageUrl"] = responseImage.secureUrl;
        data["publicId"] = publicId;
        setState(() {
          isLoading = false;
        });
      } else if (responseVideo.isSuccessful) {
        data["videoUrl"] = responseVideo.secureUrl;
        data["publicId"] = publicId;
        setState(() {
          isLoading = false;
        });
      }
    }

    if (text != null) {
      data["text"] = text;
    }

    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          currentUser != null
              ? "Olá, ${currentUser!.displayName}!"
              : "Olá, Usuário!",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          currentUser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Você saiu com sucesso!"),
                      backgroundColor: Colors.blue,
                    ));
                  },
                  icon: Icon(Icons.exit_to_app))
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("messages")
                      .orderBy("time")
                      .snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      default:
                        List<DocumentSnapshot> documents =
                            snapshot.data!.docs.reversed.toList();

                        return ListView.builder(
                            itemCount: documents.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final documentData = documents[index].data()
                                  as Map<String, dynamic>?;

                              final mine = documentData != null &&
                                  documentData['uid'] == currentUser?.uid;

                              return ChatMessage(
                                data: documentData,
                                mine: mine,
                                toDelete: documents[index].reference,
                                currentUser: currentUser,
                                cloudinary: configCloudinary,
                              );
                            });
                    }
                  })),
          isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(sendMessage: sendMessage),
        ],
      ),
    );
  }
}
