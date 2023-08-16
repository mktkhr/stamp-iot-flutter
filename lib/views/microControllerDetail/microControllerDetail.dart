import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/views/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MicroControllerDetail extends StatefulWidget {
  const MicroControllerDetail(
      {Key? key, required this.title, required this.microControllerUuid})
      : super(key: key);

  final String title;
  final String microControllerUuid;

  @override
  State<MicroControllerDetail> createState() => _MicroControllerDetail();
}

class _MicroControllerDetail extends State<MicroControllerDetail> {
  late MicroController? microController;
  MicroController? microControllerForEdit;

  // response を state に追加
  Future<MicroController> getMicroControllerDetail() async {
    MicroController response =
        await fetchMicroControllerDetail(widget.microControllerUuid);
    microController = response;

    return response;
  }

  final formKey = GlobalKey<FormState>();
  var nameInputFieldController = TextEditingController();
  var sdiAddressInputFieldController = TextEditingController();
  bool isEditMode = false;

  void changeEditMode() {
    setState(() {
      nameInputFieldController.text = microController!.name;
      sdiAddressInputFieldController.text = microController!.sdi12Address;
      microControllerForEdit = microController;
      isEditMode = !isEditMode;
    });
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
          child: FutureBuilder<MicroController>(
              future: getMicroControllerDetail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  String name = snapshot.data!.name;
                  String macAddress = snapshot.data!.macAddress;
                  String interval = snapshot.data!.interval;
                  String sdi12Address = snapshot.data!.sdi12Address;
                  final dateTimeFormatter = DateFormat("yyyy/MM/dd");
                  DateTime createdAt = DateTime.parse(snapshot.data!.createdAt);
                  String createdAtString = dateTimeFormatter.format(createdAt);
                  DateTime updatedAt = DateTime.parse(snapshot.data!.updatedAt);
                  String updatedAtString = dateTimeFormatter.format(updatedAt);
                  if (isEditMode) {
                    return Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => changeEditMode(),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey),
                                    child: const Text('キャンセル'),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      log(nameInputFieldController.text);
                                      log(sdiAddressInputFieldController.text);
                                      log(microControllerForEdit!.interval
                                          .toString());
                                      if (!formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('入力値に誤りがあります')),
                                        );
                                      } else {
                                        final preferences =
                                            await SharedPreferences
                                                .getInstance();
                                        final sessionId = preferences
                                            .getString("ems_session");
                                        Map<String, String> header = {
                                          'content-type': 'application/json',
                                          'Cookie': 'ems_session=$sessionId'
                                        };

                                        const String apiUrl =
                                            String.fromEnvironment("url");

                                        try {
                                          final response = await http.patch(
                                              Uri.parse(
                                                  '$apiUrl/ems/micro-controller/detail'),
                                              headers: header,
                                              body: json.encode({
                                                "microControllerUuid":
                                                    widget.microControllerUuid,
                                                "name": nameInputFieldController
                                                    .text,
                                                "interval":
                                                    microControllerForEdit!
                                                        .interval
                                                        .toString(),
                                                "sdi12Address":
                                                    sdiAddressInputFieldController
                                                        .text
                                              }));

                                          String statusCode =
                                              response.statusCode.toString();

                                          if (!mounted) {
                                            // contextがない場合はreturn
                                            return;
                                          }
                                          if (statusCode == "200") {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.blue,
                                                content: Text('更新に成功しました。'),
                                              ),
                                            );
                                            setState(() {
                                              isEditMode = false;
                                            });
                                          } else if (statusCode == "400" ||
                                              statusCode == "401") {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('入力内容に誤りがあります。')),
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    '問題が発生しました。時間をおいて再度お試しください。')),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('保存'),
                                  ),
                                ]),
                            const Divider(
                              thickness: 1.0,
                              color: Colors.grey,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: const Icon(
                                        Icons.image,
                                        size: 50,
                                      )),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.only(left: 10)),
                                        // initialValue: name,
                                        controller: nameInputFieldController,
                                      ),
                                      Text(
                                        'MACアドレス:$macAddress',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    ],
                                  ))
                                ]),
                            Container(padding: const EdgeInsets.all(5)),
                            Table(
                              border: TableBorder.all(),
                              columnWidths: const <int, TableColumnWidth>{
                                0: FixedColumnWidth(150),
                                1: FlexColumnWidth(),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(children: [
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text("測定間隔"),
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: DropdownButton(
                                          isExpanded: true,
                                          underline: Container(),
                                          items: generateListForDropDownMenu(),
                                          value:
                                              microControllerForEdit!.interval,
                                          onChanged: (String? value) {
                                            setState(() {
                                              microControllerForEdit!.interval =
                                                  value!;
                                            });
                                          },
                                        ),
                                      )),
                                ]),
                                TableRow(children: [
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text("測定アドレス"),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.only(left: 10)),
                                      // initialValue: sdi12Address,
                                      validator: (value) {
                                        String sdiAddressRegExp =
                                            r"^(([0-9A-Za-z]{1},)*[0-9A-za-z]{1})|([0-9A-za-z]{1})$";
                                        RegExp regExp =
                                            RegExp(sdiAddressRegExp);
                                        if (value != null &&
                                            value.isNotEmpty &&
                                            !regExp.hasMatch(value)) {
                                          return 'SDI-12アドレスが正しく入力されていません';
                                        }
                                        return null;
                                      },
                                      controller:
                                          sdiAddressInputFieldController,
                                    ),
                                  ),
                                ]),
                                TableRow(children: [
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text("登録日"),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      createdAtString,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ]),
                                TableRow(children: [
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text("最終更新日"),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      updatedAtString,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ])
                              ],
                            )
                          ],
                        ));
                  } else {
                    return Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => changeEditMode(),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Text('編集'),
                              ),
                            ]),
                        const Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                  )),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name != "" ? name : "名称未設定",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'MACアドレス:$macAddress',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                ],
                              ))
                            ]),
                        Container(padding: const EdgeInsets.all(5)),
                        Table(
                          border: TableBorder.all(),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(150),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text("測定間隔"),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '$interval分',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text("測定アドレス"),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  sdi12Address,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text("登録日"),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  createdAtString,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text("最終更新日"),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  updatedAtString,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ])
                          ],
                        )
                      ],
                    );
                  }
                } else {
                  log(snapshot.error.toString());
                  return const Text("データの取得に失敗しました。");
                }
              })),
    );
  }
}

class MicroController {
  num id;
  String uuid;
  String name;
  String macAddress;
  String interval;
  String sdi12Address;
  String createdAt;
  String updatedAt;
  String? deletedAt;

  MicroController(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.macAddress,
      required this.interval,
      required this.sdi12Address,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});

  MicroController.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json["name"],
        macAddress = json["macAddress"],
        interval = json["interval"],
        sdi12Address = json["sdi12Address"],
        createdAt = json["createdAt"],
        updatedAt = json["updatedAt"],
        deletedAt = json["deletedAt"];
}

Future<MicroController> fetchMicroControllerDetail(
    String microControllerUuid) async {
  final preferences = await SharedPreferences.getInstance();
  final sessionId = preferences.getString("ems_session");
  Map<String, String> header = {
    'content-type': 'application/json',
    'Cookie': 'ems_session=$sessionId'
  };

  const String apiUrl = String.fromEnvironment("url");

  final response = await http.get(
      Uri.parse(
          '$apiUrl/ems/micro-controller/detail?microControllerUuid=$microControllerUuid'),
      headers: header);

  final body = json.decode(utf8.decode(response.bodyBytes));
  MicroController microController = MicroController.fromJson(body);

  return Future.value(microController);
}

const intervalList = ["1", "5", "10", "15", "20", "30", "60"];

/// ドロップダウンリストの値を生成する
List<DropdownMenuItem<String>> generateListForDropDownMenu() {
  return intervalList.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text('$value分'),
    );
  }).toList();
}
