import 'package:flutter/material.dart';

class Article extends StatelessWidget {
  const Article({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事一覧'),
      ),
      body: const Center(
        child: Text(
          '記事一覧',
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
