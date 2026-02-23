import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('Chats', style: kHeadTitleB),
        backgroundColor: kWhite,
      ),
      body: Center(
        child: Text('Dummy Chat Page', style: kLargeTitleM),
      ),
    );
  }
}
