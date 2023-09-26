import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FetchArticle extends ChangeNotifier {
  var articles = [];
  int _page_index = 0;

  Future<void> get_Articles() async {
    _page_index++;
    String url =
        'https://qiita.com/api/v2/items?page=${_page_index}&per_page=20';
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer a51da60bd906fade8e1dffbd02676a89425c2c6e',
    };
    var res = await http.get(uri, headers: headers);
    articles.addAll(jsonDecode(res.body));
    notifyListeners();
  }
}

class Article extends StatelessWidget {
  const Article({Key? key}) : super(key: key);

  String returnStringFrom(List tags) {
    print(tags);
    return 'Ruby';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FetchArticle(),
      builder: (context, child) {
        // 初期化実行 もしgetした記事の数が一つもないときのみ起動
        if (context.watch<FetchArticle>().articles.isEmpty) {
          context.read<FetchArticle>().get_Articles();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('記事一覧'),
          ),
          body: ListView.builder(
              itemCount: context.watch<FetchArticle>().articles.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0)),
                    width: 300,
                    height: 200,
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ArticleId(index: index),
                            ArticleTag(index: index),
                          ],
                        ),
                        ArticleTitle(index: index),
                        ArticleCreatedDate(index: index),
                      ],
                    ),
                  ),
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<FetchArticle>().get_Articles(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class ArticleBodyArguments {
  final String body;

  ArticleBodyArguments({required this.body});
}

class ArticleBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ArticleBodyArguments;

    return Scaffold(
        appBar: AppBar(
          title: const Text('記事本文'),
        ),
        body: Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(args.body),
        )));
  }
}

class ArticleId extends StatelessWidget {
  int index;
  ArticleId({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      width: 100,
      // height: 50,
      child: Text(
          'id: ${context.watch<FetchArticle>().articles[index]['user']['id']}'),
    );
  }
}

class ArticleTag extends StatelessWidget {
  int index;
  ArticleTag({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      width: 100,
      height: 50,
      child: ListView.builder(
        itemCount: context.watch<FetchArticle>().articles[index]['tags'].length,
        itemBuilder: (context, tagIndex) {
          return Text(context.watch<FetchArticle>().articles[index]['tags']
              [tagIndex]['name']);
        },
      ),
    );
  }
}

class ArticleTitle extends StatelessWidget {
  int index;
  ArticleTitle({required this.index});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/article_body',
            arguments: ArticleBodyArguments(
                body: Provider.of<FetchArticle>(context, listen: false)
                    .articles[index]['body']));
      },
      child: Container(
        color: Colors.blue,
        width: 250,
        height: 100,
        alignment: Alignment.center,
        child: Text(context.watch<FetchArticle>().articles[index]['title']),
      ),
    );
  }
}

class ArticleCreatedDate extends StatelessWidget {
  int index;
  ArticleCreatedDate({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: 100,
      child: Text(context.watch<FetchArticle>().articles[index]['created_at']),
    );
  }
}
