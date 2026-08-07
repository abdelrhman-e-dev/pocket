import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket'),
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: const Center(
        child: Text(
          'Pocket Application',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}