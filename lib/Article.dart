import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

class ArticlePage extends StatefulWidget {
  String url;
  ArticlePage({Key? key, required this.url}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         
        titleSpacing: 0,
        title: Text(
          "Home",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
