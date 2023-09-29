import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleNotifier extends ChangeNotifier {
  String tekitou = 'tekitou';
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

  void addfavoriteArticle(article) async {
    String key = article['id'];
    String value = jsonEncode(article);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    notifyListeners();
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
                            ArticleUserId(
                              index: index,
                              articleUserId: context
                                  .watch<ArticleNotifier>()
                                  .articles[index]['user']['id'],
                            ),
                            ArticleTag(
                              index: index,
                              articleTags: context
                                  .watch<ArticleNotifier>()
                                  .articles[index]['tags'],
                            ),
                            ArticleFavoriteButton(
                              index: index,
                              id: context
                                  .watch<ArticleNotifier>()
                                  .articles[index]['id'],
                            ),
                          ],
                        ),
                        ArticleTitle(
                          index: index,
                          articleTitle: context
                              .watch<ArticleNotifier>()
                              .articles[index]['title'],
                          articleBody: context
                              .watch<ArticleNotifier>()
                              .articles[index]['body'],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ArticleCreatedDate(
                              index: index,
                              articleCreateDate: context
                                  .watch<ArticleNotifier>()
                                  .articles[index]['created_at'],
                            ),
                            ArticleId(
                              index: index,
                              articleId: context
                                  .watch<ArticleNotifier>()
                                  .articles[index]['id'],
                            ),
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
  String articleUserId;
  ArticleUserId({required this.index, required this.articleUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      width: 100,
      // height: 50,
      child: Text('id: ${articleUserId}'),
    );
  }
}

class ArticleTag extends StatelessWidget {
  int index;
  List articleTags;
  ArticleTag({required this.index, required this.articleTags});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      width: 100,
      height: 50,
      child: ListView.builder(
        itemCount: articleTags.length,
        itemBuilder: (context, tagIndex) {
          return Text(articleTags[tagIndex]['name']);
        },
      ),
    );
  }
}

class ArticleTitle extends StatelessWidget {
  int index;
  String articleTitle;
  String articleBody;
  ArticleTitle(
      {required this.index,
      required this.articleTitle,
      required this.articleBody});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/article_body',
            arguments: ArticleBodyArguments(body: articleBody));
      },
      child: Container(
        color: Colors.blue,
        width: 250,
        height: 100,
        alignment: Alignment.center,
        child: Text(articleTitle),
      ),
    );
  }
}

class ArticleCreatedDate extends StatelessWidget {
  int index;
  String articleCreateDate;
  ArticleCreatedDate({required this.index, required this.articleCreateDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: 100,
      child: Text(articleCreateDate),
    );
  }
}

class ArticleId extends StatelessWidget {
  int index;
  String articleId;
  ArticleId({required this.index, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      color: Colors.purple,
      child: Text(articleId),
    );
  }
}

class ArticleFavoriteButton extends StatefulWidget {
  int index;
  String id;
  ArticleFavoriteButton({required this.index, required this.id});

  @override
  _ArticleFavoriteButtonState createState() => _ArticleFavoriteButtonState();
}

class _ArticleFavoriteButtonState extends State<ArticleFavoriteButton> {
  bool isFavoriteArticle = false;

  void fetchLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().contains(widget.id)) {
      setState(() {
        isFavoriteArticle = true;
      });
    } else {
      setState(() {
        isFavoriteArticle = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<ArticleNotifier>().addfavoriteArticle(
            Provider.of<ArticleNotifier>(context, listen: false)
                .articles[widget.index]);
        fetchLocalStorage();
      },
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        fixedSize: const Size(50, 25),
        foregroundColor: isFavoriteArticle
            ? Color.fromARGB(255, 224, 96, 139)
            : Colors.white,
        backgroundColor: Color.fromARGB(255, 100, 179, 245),
      ),
      child: const Icon(Icons.favorite),
    );
  }
}
