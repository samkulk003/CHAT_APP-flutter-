import 'package:flutter/material.dart';

class SplachScreen extends StatelessWidget {
  const SplachScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter chat'),
      ),
      body: const Center(
        child: Text('loading'),
      ),
    );
  }
}
