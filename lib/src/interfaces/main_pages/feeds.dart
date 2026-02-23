import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('Feeds', style: kHeadTitleB),
        backgroundColor: kWhite,
      ),
      body: Center(
        child: Text('Dummy Feed Page', style: kLargeTitleM),
      ),
    );
  }
}
