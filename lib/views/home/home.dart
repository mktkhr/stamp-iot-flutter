import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/views/login/login.dart';
import 'package:frontend/views/measuredData/measured_data.dart';
import 'package:frontend/views/microControllerDetail/micro_controller_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  late Future<List<MicroController>>? microControllerList;

  // response を state に追加
  Future<List<MicroController>> getMicroController() async {
    List<MicroController> microControllerList = [];
    List<MicroController> response = await fetchMicroController();
    for (var i = 0; i < response.length; i++) {
      microControllerList.add(response[i]);
    }
    return microControllerList;
  }

  @override
  void initState() {
    super.initState();
  }

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
          padding: const EdgeInsets.all(5),
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder<List<MicroController>?>(
                  future: getMicroController(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData &&
                        snapshot.data!.isNotEmpty &&
                        snapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, index) {
                          return ListTile(
                            leading: const Icon(Icons.person),
                            trailing: IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed: () => onClickSetting(
                                    context, snapshot.data![index].uuid)),
                            title: Text(snapshot.data![index].name ?? "名称未設定"),
                            subtitle: Text(snapshot.data![index].macAddress),
                            onTap: () {
                              String uuid = snapshot.data![index].uuid;
                              if (uuid.isEmpty) return;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MeasuredData(
                                            title: "測定結果",
                                            microControllerUuid: uuid,
                                          )));
                            },
                          );
                        },
                      );
                    } else if (snapshot.data!.isEmpty &&
                        snapshot.connectionState == ConnectionState.done) {
                      // マイコンがない場合
                      return const Column(children: [
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text("端末が登録されていません。"),
                          ),
                        ),
                      ]);
                    } else {
                      log(snapshot.error.toString());
                      return const Column(children: [
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text("予期せぬエラーが発生しました。"),
                          ),
                        ),
                      ]);
                    }
                  }))),
    );
  }
}

class MicroController {
  num id;
  String uuid;
  String? name;
  String macAddress;
  String interval;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  MicroController(
      {required this.id,
      required this.uuid,
      this.name,
      required this.macAddress,
      required this.interval,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});
}

Future<List<MicroController>> fetchMicroController() async {
  final preferences = await SharedPreferences.getInstance();
  final sessionId = preferences.getString("ems_session");
  Map<String, String> header = {
    'content-type': 'application/json',
    'Cookie': 'ems_session=$sessionId'
  };

  const String apiUrl = String.fromEnvironment("url");

  final response = await http
      .get(Uri.parse('$apiUrl/ems/micro-controller/info'), headers: header);

  List<MicroController> list = [];
  final responseList = json.decode(utf8.decode(response.bodyBytes)) as List;
  for (var element in responseList) {
    late num id;
    late String uuid;
    String? name;
    late String macAddress;
    late String interval;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? deletedAt;

    element.forEach((key, value) {
      switch (key) {
        case 'id':
          id = value;
          break;
        case 'uuid':
          uuid = value;
          break;
        case 'name':
          if (value != "" && value != null) {
            name = value;
          } else {
            name = "名称未設定";
          }
          break;
        case 'macAddress':
          macAddress = value;
          break;
        case 'interval':
          interval = value;
          break;
        case 'createdAt':
          if (value != "" && value != null) {
            try {
              createdAt = DateFormat('yyyy-MM-ddThh:mm:ss').parse(value);
            } catch (e) {
              log("ParseError:${e.toString()}");
            }
          }
          break;
        case 'updatedAt':
          if (value != "" && value != null) {
            try {
              updatedAt = DateFormat('yyyy-MM-ddThh:mm:ss').parse(value);
            } catch (e) {
              log("ParseError:${e.toString()}");
            }
          }
          break;
        case 'deletedAt':
          if (value != "" && value != null) {
            try {
              deletedAt = DateFormat('yyyy-MM-ddThh:mm:ss').parse(value);
            } catch (e) {
              log("ParseError:${e.toString()}");
            }
          }
          break;
        default:
      }
    });

    MicroController microController = MicroController(
        id: id,
        uuid: uuid,
        name: name,
        macAddress: macAddress,
        interval: interval,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt);
    list.add(microController);
  }

  return Future.value(list);
}

/// 設定ボタン押下時の処理
void onClickSetting(BuildContext context, String uuid) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MicroControllerDetail(
                title: "端末情報",
                microControllerUuid: uuid,
              )));
}
