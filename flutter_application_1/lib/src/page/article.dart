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
        if (context.watch<FetchArticle>().articles.length == 0) {
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
                    height: 150,
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              color: Colors.yellow,
                              width: 100,
                              // height: 50,
                              child: Text('id: ' +
                                  context.watch<FetchArticle>().articles[index]
                                      ['user']['id']),
                            ),
                            Container(
                              color: Colors.green,
                              width: 100,
                              height: 50,
                              child: ListView.builder(
                                itemCount: context
                                    .watch<FetchArticle>()
                                    .articles[index]['tags']
                                    .length,
                                itemBuilder: (context, tagIndex) {
                                  return Text(context
                                          .watch<FetchArticle>()
                                          .articles[index]['tags'][tagIndex]
                                      ['name']);
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.blue,
                          width: 250,
                          height: 50,
                          child: Text(context
                              .watch<FetchArticle>()
                              .articles[index]['title']),
                          alignment: Alignment.center,
                        ),
                        Container(
                          color: Colors.red,
                          width: 100,
                          child: Text(context
                              .watch<FetchArticle>()
                              .articles[index]['created_at']),
                        ),
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
