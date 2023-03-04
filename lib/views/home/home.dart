import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/views/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromRGBO(99, 99, 99, 100),
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  AlertDialog alert = AlertDialog(
                      title: const Text("確認"),
                      content: const Text("ログアウトします。よろしいですか？"),
                      actions: <Widget>[
                        // ボタン領域
                        ElevatedButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          child: const Text("OK"),
                          onPressed: () async {
                            final preferences =
                                await SharedPreferences.getInstance();
                            preferences.clear(); // セッション情報の削除

                            if (!mounted) return;
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const Login(title: "ログイン")));
                          },
                        ),
                      ]);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                }),
          ),
          Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                "assets/images/logo_white.png",
                fit: BoxFit.contain,
              )),
        ],
      ),
      body: SingleChildScrollView(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30.0),
                ),
              ))),
    );
  }
}
