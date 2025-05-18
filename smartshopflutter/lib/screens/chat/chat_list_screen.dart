import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  static String routeName = "/chats";

  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chatDoc = snapshot.data!.docs[index];
              var data = chatDoc.data() as Map<String, dynamic>;

              // Find the other participant's data
              String chatId = chatDoc.id;
              String? lastMessage = data['lastMessage'] ?? '';
              Timestamp? time = data['lastMessageTime'];
              List participants = data['participants'];
              String otherUserId = participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  String name = userData['firstName'] ?? 'User';
                  String imageUrl = userData['profileImage'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/Profile Image.png') as ImageProvider,
                    ),
                    title: Text(name),
                    subtitle: Text(lastMessage!),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat', // Define this in your routes
                        arguments: {
                          'chatId': chatId,
                          'otherUserId': otherUserId,
                          'otherUserName': name,
                          'otherUserImage': imageUrl,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
