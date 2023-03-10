import 'dart:convert';
import 'dart:developer';
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
              padding: EdgeInsets.all(10),
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
                                return '?????????????????????????????????????????????';
                              } else if (!regExp.hasMatch(value)) {
                                return '????????????????????????????????????????????????????????????';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: '?????????????????????',
                            ),
                            controller: emailInputFieldController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            validator: (value) {
                              // ?????????????????????????????????????????????????????????????????????????????????????????????????????????
                              if (value == null || value.isEmpty) {
                                return '?????????????????????????????????????????????';
                              }
                              return null;
                            },
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                                labelText: '???????????????',
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
                                        content: Text('?????????????????????????????????')),
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
                                    log(statusCode);
                                    if (!mounted) {
                                      // context??????????????????return
                                      return;
                                    }
                                    if (statusCode == "200") {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(title: "?????????")));
                                    } else if (statusCode == "400" ||
                                        statusCode == "401") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('????????????????????????????????????????????????')),
                                      );
                                    } else if (statusCode == "500") {
                                      // #8 catch??????????????????????????????????????????????????????????????????????????????????????????
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                '??????????????????????????????????????????????????????????????????????????????')),
                                      );
                                    }
                                  } catch (exception) {
                                    log("Error: ${exception.toString()}");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '??????????????????????????????????????????????????????????????????????????????')),
                                    );
                                  }
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromRGBO(
                                          153, 153, 153, 100))),
                              child: const Text('????????????')),
                        ),
                        Center(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Register(title: "????????????")));
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromRGBO(46, 109, 186, 80))),
                              child: const Text('????????????????????????')),
                        ),
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }
}
