import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './article.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  var articles = [];

  void getFavoriteArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var favoriteArticles = [];
    for (var key in prefs.getKeys()) {
      var data = jsonDecode(prefs.getString(key) ?? '');
      favoriteArticles.add(data);
    }

    favoriteArticles = List.from(favoriteArticles.reversed);

    setState(() {
      articles = favoriteArticles;
    });
  }

  @override
  void initState() {
    super.initState();
    getFavoriteArticles();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticleNotifier(),
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('お気に入り一覧'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                getFavoriteArticles();
              },
              child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0)),
                        width: 300,
                        height: 200,
                        margin: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ArticleUserId(
                                    index: index,
                                    articleUserId: articles[index]['user']
                                        ['id']),
                                ArticleTag(
                                    index: index,
                                    articleTags: articles[index]['tags'])
                              ],
                            ),
                            ArticleTitle(
                                index: index,
                                articleTitle: articles[index]['title'],
                                articleBody: articles[index]['body']),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ArticleCreatedDate(
                                    index: index,
                                    articleCreateDate: articles[index]
                                        ['created_at']),
                                ArticleId(
                                    index: index,
                                    articleId: articles[index]['id'])
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ));
      },
    );
  }
}
