import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './article.dart';

class Favorite extends StatelessWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticleNotifier(),
      builder: (context, child) {
        return Center(
          child: Text(context.watch<ArticleNotifier>().tekitou),
        );
      },
    );
  }
}
