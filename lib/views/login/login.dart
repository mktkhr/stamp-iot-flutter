import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:frontend/views/register/register.dart';
import 'package:frontend/views/home/home.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  bool _isObscure = true;

  final _formkey = GlobalKey<FormState>();
  final emailInputFieldController = TextEditingController();
  final passwordInputFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromRGBO(99, 99, 99, 100),
        actions: [
          Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                "assets/images/logo_white.png",
                fit: BoxFit.contain,
              ))
        ],
      ),
      body: SingleChildScrollView(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Container(
                              height: 50,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo_blue.png',
                                  fit: BoxFit.contain,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            validator: (value) {
                              String mailAddressRegExp =
                                  r"^[a-zA-Z0-9_+-]+(.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$";
                              RegExp regExp = RegExp(mailAddressRegExp);
                              if (value == null || value.isEmpty) {
                                return 'ユーザー名が入力されていません';
                              } else if (!regExp.hasMatch(value)) {
                                return 'メールアドレスが正しく入力されていません';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'メールアドレス',
                            ),
                            controller: emailInputFieldController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            validator: (value) {
                              // ログイン画面ではセキュリティ上，パスワードの正規表現チェックを行わない
                              if (value == null || value.isEmpty) {
                                return 'パスワードが入力されていません';
                              }
                              return null;
                            },
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                                labelText: 'パスワード',
                                suffixIcon: IconButton(
                                    icon: Icon(_isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    })),
                            controller: passwordInputFieldController,
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                              onPressed: () async {
                                if (!_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('入力値に誤りがあります')),
                                  );
                                } else {
                                  Map<String, String> header = {
                                    'content-type': 'application/json'
                                  };
                                  try {
                                    final response = await http.post(
                                        Uri.parse(
                                            'http://localhost:8082/ems/account/login'),
                                        headers: header,
                                        body: json.encode({
                                          "email":
                                              emailInputFieldController.text,
                                          "password":
                                              passwordInputFieldController.text
                                        }));

                                    String statusCode =
                                        response.statusCode.toString();

                                    if (!mounted) {
                                      // contextがない場合はreturn
                                      return;
                                    }
                                    if (statusCode == "200") {
                                      // ems_session=xxx の xxx の部分(UUID)を取得
                                      final sessionId = response
                                          .headers['set-cookie']
                                          .toString()
                                          .substring(12, 48);

                                      // log('session ID: $sessionId');

                                      final preferences =
                                          await SharedPreferences.getInstance();
                                      preferences.setString(
                                          "ems_session", sessionId);

                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(title: "ホーム")));
                                    } else if (statusCode == "400" ||
                                        statusCode == "401") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('アカウント情報に誤りがあります。')),
                                      );
                                    } else if (statusCode == "500") {
                                      // #8 catchで拾えているかの確認が取れるまで，重複するが拾えるようにする
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                '問題が発生しました。時間をおいて再度お試しください。')),
                                      );
                                    }
                                  } catch (exception) {
                                    log("Error: ${exception.toString()}");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '問題が発生しました。時間をおいて再度お試しください。')),
                                    );
                                  }
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromRGBO(
                                          153, 153, 153, 100))),
                              child: const Text('ログイン')),
                        ),
                        Center(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Register(title: "新規登録")));
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromRGBO(46, 109, 186, 80))),
                              child: const Text('新規登録はこちら')),
                        ),
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }
}
