import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// class Article extends StatefulWidget {
//   const Article({Key? key}) : super(key: key);

//   @override
//   _ArticleState createState() => _ArticleState();
// }

// class _ArticleState extends State<Article> {
//   var _articles = [];
//   int _page_index = 1;

//   Future<dynamic> _get_Articles() async {
//     String url =
//         'https://qiita.com/api/v2/authenticated_user/items?page=${_page_index}&per_page=20';
//     var uri = Uri.parse(url);
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer a51da60bd906fade8e1dffbd02676a89425c2c6e',
//     };
//     var res = await http.get(uri, headers: headers);
//     return res;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _get_Articles();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('記事一覧'),
//       ),
//       body: FutureBuilder(
//         future: _get_Articles(),
//         builder: (BuildContext context, snapshot) {
//           if (snapshot.hasData) {
//             if (snapshot.data.statusCode == 200) {
//               return ListView.builder(
//                   itemCount: _articles.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return ListTile(
//                       title: Text(
//                         _articles[index]['title'],
//                       ),
//                     );
//                   });
//             } else {
//               return const Center(
//                 child: Text('読み込みエラー'),
//               );
//             }
//           } else {
//             return const Center(
//               child: Text('読み込み中'),
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // _page_index++;
//         },
//         child: const Icon(Icons.book),
//       ),
//     );
//   }
// }

// class Article extends StatelessWidget {
//   const Article({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => Counter(),
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           TextWidgetA(),
//           TextWidgetB(),
//           TextWidgetC(),
//           ButtonWidgetA(),
//           ButtonWidgetB(),
//           ButtonWidgetC(),
//         ],
//       ),
//     );
//   }
// }

class FetchArticle extends ChangeNotifier {
  var articles = ['Apple', 'Banana', 'WaterMelon'];

  void addArticleToArticles() {
    articles.add('SOMETHING');
    notifyListeners();
  }
}

class Article extends StatelessWidget {
  const Article({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FetchArticle(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('記事一覧'),
          ),
          body: ListView.builder(
              itemCount: context.watch<FetchArticle>().articles.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Text(context.watch<FetchArticle>().articles[index]),
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                context.read<FetchArticle>().addArticleToArticles(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
