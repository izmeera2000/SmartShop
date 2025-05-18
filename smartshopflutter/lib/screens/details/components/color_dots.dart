import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartshopflutter/components/save_details.dart';
import 'package:smartshopflutter/screens/chat/chat_screen.dart';

import '../../../components/rounded_icon_btn.dart';
import '../../../constants.dart';
import '../../../models/Product.dart';

class ColorDots extends StatefulWidget {
  const ColorDots({
    Key? key,
    required this.product,
    required this.quantity,
    required this.incrementQuantity,
    required this.decrementQuantity,
  }) : super(key: key);

  final Product product;
  final int quantity;
  final VoidCallback incrementQuantity;
  final VoidCallback decrementQuantity;

  @override
  State<ColorDots> createState() => _ColorDotsState();
}

class _ColorDotsState extends State<ColorDots> {
  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  Future<void> _startChat() async {
    String? currentUserId = await getUserID();
    String sellerId = widget.product.userId;

    if (currentUserId == null || currentUserId == sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot chat with yourself.")),
      );
      return;
    }

    String chatId = _getChatId(currentUserId, sellerId);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatRef.get();

    // Check if the chat already exists and if the current user is a participant
    if (!chatSnapshot.exists) {
      // Create a new chat document if it doesn't exist
      await chatRef.set({
        'participants': [currentUserId, sellerId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': null,
      });
    }

    Navigator.pushNamed(
      context,
      ChatScreen.routeName,
      arguments: {
        'chatId': chatId,
        'otherUserId': sellerId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
              ),
              onPressed: _startChat,
              child: const Text("Chat with Seller"),
            ),
          ),
          const Spacer(),
          RoundedIconBtn(
            icon: Icons.remove,
            press: widget.decrementQuantity,
          ),
          const SizedBox(width: 20),
          Text(
            '${widget.quantity}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          RoundedIconBtn(
            icon: Icons.add,
            showShadow: true,
            press: widget.incrementQuantity,
          ),
        ],
      ),
    );
  }
}

class ColorDot extends StatelessWidget {
  const ColorDot({
    Key? key,
    required this.color,
    this.isSelected = false,
  }) : super(key: key);

  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.all(8),
      height: 20,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border:
            Border.all(color: isSelected ? kPrimaryColor : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
