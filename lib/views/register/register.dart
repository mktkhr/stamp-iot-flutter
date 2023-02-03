import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool _isObscure = true;

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromRGBO(99, 99, 99, 100),
        actions: [
          Container(
              padding: EdgeInsets.all(10),
              child: Image.asset(
                "assets/images/logo_white.png",
                fit: BoxFit.contain,
              ))
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formkey,
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
                      if (value == null || value.isEmpty) {
                        return 'ユーザー名が入力されていません';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
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
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '確認用パスワードが入力されていません';
                      }
                      return null;
                    },
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                        labelText: '確認用パスワード',
                        suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            })),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Data')),
                          );
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(46, 109, 186, 80))),
                      child: const Text('登録')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
