import 'package:flutter/material.dart';
import 'social/social_hub_screen.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The main Social tab now simply shows the Social Hub
    return const SocialHubScreen();
  }

}
