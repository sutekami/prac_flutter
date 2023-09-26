import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ArticleNotifier extends ChangeNotifier {
  String tekitou = 'tekitou';
  var articles = [];
  List<String> articleIds = [];
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

  void controllArticleIds(String id) {
    print(id);
    // notifyListeners();
  }
}

class Article extends StatelessWidget {
  const Article({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticleNotifier(),
      builder: (context, child) {
        // 初期化実行 もしgetした記事の数が一つもないときのみ起動
        if (context.watch<ArticleNotifier>().articles.isEmpty) {
          context.read<ArticleNotifier>().get_Articles();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('記事一覧'),
          ),
          body: ListView.builder(
              itemCount: context.watch<ArticleNotifier>().articles.length,
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
                            ArticleUserId(index: index),
                            ArticleTag(index: index),
                            ArticleFavoriteButton(index: index),
                          ],
                        ),
                        ArticleTitle(index: index),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ArticleCreatedDate(index: index),
                            ArticleId(index: index),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<ArticleNotifier>().get_Articles(),
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

class ArticleUserId extends StatelessWidget {
  int index;
  ArticleUserId({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      width: 100,
      // height: 50,
      child: Text(
          'id: ${context.watch<ArticleNotifier>().articles[index]['user']['id']}'),
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
        itemCount:
            context.watch<ArticleNotifier>().articles[index]['tags'].length,
        itemBuilder: (context, tagIndex) {
          return Text(context.watch<ArticleNotifier>().articles[index]['tags']
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
                body: Provider.of<ArticleNotifier>(context, listen: false)
                    .articles[index]['body']));
      },
      child: Container(
        color: Colors.blue,
        width: 250,
        height: 100,
        alignment: Alignment.center,
        child: Text(context.watch<ArticleNotifier>().articles[index]['title']),
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
      child:
          Text(context.watch<ArticleNotifier>().articles[index]['created_at']),
    );
  }
}

class ArticleId extends StatelessWidget {
  int index;
  ArticleId({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      color: Colors.purple,
      child: Text(context.watch<ArticleNotifier>().articles[index]['id']),
    );
  }
}

class ArticleFavoriteButton extends StatelessWidget {
  int index;
  ArticleFavoriteButton({required this.index});

  bool isTrue = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<ArticleNotifier>().controllArticleIds(
            Provider.of<ArticleNotifier>(context, listen: false).articles[index]
                ['id']);
      },
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        fixedSize: const Size(50, 25),
        foregroundColor:
            isTrue ? Color.fromARGB(255, 224, 96, 139) : Colors.white,
        backgroundColor: Color.fromARGB(255, 100, 179, 245),
      ),
      child: const Icon(Icons.favorite),
    );
  }
}
