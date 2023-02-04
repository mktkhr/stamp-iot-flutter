import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/proxy.dart';
import 'package:frontend/views/login/login.dart';
import 'package:system_proxy/system_proxy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // システムのproxy設定を取得する.
  Map<String, String>? proxy = await SystemProxy.getProxySettings();
  // HttpOverridesの派生クラスをHttpOverrides.globalに指定する.
  HttpOverrides.global = ProxyHttpOverrides(
    proxy?['host'],
    proxy?['port'],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Login(
        title: 'ログイン',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromRGBO(99, 99, 99, 100),
      ),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
