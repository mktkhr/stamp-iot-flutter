import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/views/login/login.dart';

import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  final _formKey = GlobalKey<FormState>();
  final emailInputFieldController = TextEditingController();
  final passwordInputFieldController = TextEditingController();
  final passwordConfirmInputFieldController = TextEditingController();

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
          child: Center(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      String mailAddressRegExp =
                          r"^[a-zA-Z0-9_+-]+(.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$";
                      RegExp regExp = RegExp(mailAddressRegExp);
                      if (value == null || value.isEmpty) {
                        return 'メールアドレスが入力されていません';
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      String passwordRegExp =
                          r"^(?=.*[A-Z])[a-zA-Z0-9.?/-]{8,24}$";
                      RegExp regExp = RegExp(passwordRegExp);
                      if (value == null || value.isEmpty) {
                        return 'パスワードが入力されていません';
                      } else if (!regExp.hasMatch(value)) {
                        return "1文字以上の大文字を含む,8~24文字のパスワードを入力して下さい";
                      } else if (value !=
                          passwordConfirmInputFieldController.text) {
                        return 'パスワードと確認用パスワードが一致しません';
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      String passwordRegExp =
                          r"^(?=.*[A-Z])[a-zA-Z0-9.?/-]{8,24}$";
                      RegExp regExp = RegExp(passwordRegExp);
                      if (value == null || value.isEmpty) {
                        return '確認用パスワードが入力されていません';
                      } else if (!regExp.hasMatch(value)) {
                        return "1文字以上の大文字を含む,8~24文字のパスワードを入力して下さい";
                      } else if (value != passwordInputFieldController.text) {
                        return 'パスワードと確認用パスワードが一致しません';
                      }
                      return null;
                    },
                    obscureText: _isConfirmObscure,
                    decoration: InputDecoration(
                        labelText: '確認用パスワード',
                        suffixIcon: IconButton(
                            icon: Icon(_isConfirmObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isConfirmObscure = !_isConfirmObscure;
                              });
                            })),
                    controller: passwordConfirmInputFieldController,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('入力値に誤りがあります')),
                          );
                        } else {
                          Map<String, String> header = {
                            'content-type': 'application/json'
                          };
                          const String apiUrl = String.fromEnvironment("url");
                          try {
                            final response = await http.post(
                                Uri.parse('$apiUrl/ems/account/register'),
                                headers: header,
                                body: json.encode({
                                  "email": emailInputFieldController.text,
                                  "password": passwordInputFieldController.text
                                }));

                            String statusCode = response.statusCode.toString();
                            log(statusCode);
                            if (!mounted) {
                              // contextがない場合はreturn
                              return;
                            }
                            if (statusCode == "200") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('登録に成功しました。再度ログインしてください。')),
                              );
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Login(title: "ログイン")));
                            } else if (statusCode == "400") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('アカウント情報に誤りがあります。')),
                              );
                            } else if (statusCode == "403") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'メールアドレスは既に使用されています。別のメールアドレスでお試しください。')),
                              );
                            } else if (statusCode == "500") {
                              // #8 catchで拾えているかの確認が取れるまで，重複するが拾えるようにする
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('問題が発生しました。時間をおいて再度お試しください。')),
                              );
                            }
                          } catch (exception) {
                            log("Error: ${exception.toString()}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('問題が発生しました。時間をおいて再度お試しください。')),
                            );
                          }
                          //     .then((value) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //         content: Text('登録に成功しました。再度ログインしてください。')),
                          //   );
                          //   Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) =>
                          //               const Login(title: "ログイン")));
                          // });
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(153, 153, 153, 100))),
                      child: const Text('登録')),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const Login(title: "ログイン")));
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(46, 109, 186, 80))),
                      child: const Text('ログインはこちら')),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
