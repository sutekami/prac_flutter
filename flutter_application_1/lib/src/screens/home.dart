import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _articleList = [];
  int _page = 1;
  int _per_page = 20;

  Future<List<dynamic>> fetchData() async {
    String url =
        "https://qiita.com/api/v2/items?page=${_page}&per_page=${_per_page}";
    String token = "859a79cf51d8018db9e9ab9a3b69ea224530ef9f";

    var res = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    return jsonDecode(res.body);
  }

  void _reload() async {
    _page++;
    List<dynamic> tekitou = await fetchData();
    setState(() {
      _articleList.addAll(tekitou);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事一覧'),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _articleList.addAll(snapshot.data!);

            return ListView.builder(
              itemCount: _articleList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_articleList[index]['title']),
                  onTap: () {
                    _reload();
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text('ロード中...'),
            );
          }
        },
      ),
    );
  }
}
