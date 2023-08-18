import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/views/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class MeasuredData extends StatefulWidget {
  const MeasuredData(
      {Key? key, required this.title, required this.microControllerUuid})
      : super(key: key);

  final String title;
  final String microControllerUuid;

  @override
  State<MeasuredData> createState() => _MeasuredData();
}

class _MeasuredData extends State<MeasuredData> {
  late Future<MeasuredDataState>? microControllerList;
  bool showSdiChart = true;
  String targetSdiVariable = sdi12Variables.first;
  String targetEnvironmentVariable = environmentVariables.first;

  // response を state に追加
  Future<MeasuredDataState> getMeasuredData() async {
    MeasuredDataState response =
        await fetchMeasuredData(widget.microControllerUuid);
    return response;
  }

  setCharVariety(String value) {
    if (value == "SDI-12データ") {
      showSdiChart = true;
    } else {
      showSdiChart = false;
    }
  }

  setSdiVariable(String value) {
    targetSdiVariable = value;
  }

  setEnvironmentVariable(String value) {
    targetEnvironmentVariable = value;
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
        body: Container(
          padding:
              const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 40),
          child: Column(children: [
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(15),
                  height: 600,
                  width: double.infinity,
                  child: FutureBuilder<MeasuredDataState?>(
                      future: getMeasuredData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done) {
                          return LineChart(mainData(
                              snapshot.data,
                              showSdiChart,
                              showSdiChart
                                  ? targetSdiVariable
                                  : targetEnvironmentVariable));
                        } else {
                          return Text(snapshot.error.toString());
                        }
                      })),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text("表示する種類"),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(80, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton(
                        underline: Container(),
                        items: chartVariety
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: showSdiChart ? "SDI-12データ" : "環境データ",
                        onChanged: (String? value) {
                          setState(() {
                            setCharVariety(value!);
                          });
                        },
                      ),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("表示する項目"),
                    const Padding(padding: EdgeInsets.all(10)),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(80, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton(
                        underline: Container(),
                        items: generateListForDropDownMenu(showSdiChart),
                        value: showSdiChart
                            ? targetSdiVariable
                            : targetEnvironmentVariable,
                        onChanged: (String? value) {
                          setState(() {
                            if (showSdiChart) {
                              setSdiVariable(value!);
                            } else {
                              setEnvironmentVariable(value!);
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ]),
        ));
  }
}

/// ドロップダウンリスト用選択肢
const List<String> chartVariety = <String>["SDI-12データ", "環境データ"];

/// ドロップダウンリスト用選択肢
const List<String> sdi12Variables = <String>[
  '体積含水率',
  'バルク比誘電率',
  '地温',
  'バルク電気伝導度',
  '土壌間隙水電気伝導度',
  '重力加速度(X)',
  '重力加速度(Y)',
  '重力加速度(Z)'
];

/// ドロップダウンリスト用選択肢
const List<String> environmentVariables = <String>[
  '大気圧',
  '気温',
  '相対湿度',
  '二酸化炭素濃度',
  '揮発性有機化合物',
  'アナログ値'
];

/// ドロップダウンリストの値を基に，グラフ表示用データを生成する
List<DropdownMenuItem<String>> generateListForDropDownMenu(bool showSdiChart) {
  if (showSdiChart) {
    return sdi12Variables.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  } else {
    return environmentVariables.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }
}

Future<MeasuredDataState> fetchMeasuredData(String microControllerUuid) async {
  final preferences = await SharedPreferences.getInstance();
  final sessionId = preferences.getString("ems_session");
  Map<String, String> header = {
    'content-type': 'application/json',
    'Cookie': 'ems_session=$sessionId'
  };

  const String apiUrl = String.fromEnvironment("url");

  final response = await http.get(
      Uri.parse(
          '$apiUrl/ems/measured-data?microControllerUuid=$microControllerUuid'),
      headers: header);

  final body = json.decode(response.body);

  List<Sdi12DataState> sdi12Data = body["sdi12Data"]
      .map<Sdi12DataState>((dynamic item) => Sdi12DataState.fromJson(item))
      .toList();

  List<EnvironmentalDataState> environmentalData = body["environmentalData"]
      .map<EnvironmentalDataState>(
          (dynamic item) => EnvironmentalDataState.fromJson(item))
      .toList();

  List<VoltageDataState> voltageData = body["voltageData"]
      .map<VoltageDataState>((dynamic item) => VoltageDataState.fromJson(item))
      .toList();

  final measuredDataState = MeasuredDataState(
      sdi12Data: sdi12Data,
      environmentalData: environmentalData,
      voltageData: voltageData);

  return Future.value(measuredDataState);
}

LineChartData mainData(MeasuredDataState? measuredDataState, bool sdiChart,
    String selectedVariable) {
  return LineChartData(
      // タッチ操作時の設定
      lineTouchData: const LineTouchData(
        handleBuiltInTouches: true, // タッチ時のアクションの有無
        getTouchedSpotIndicator: defaultTouchedIndicators, // インジケーターの設定
        // ツールチップの設定
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: defaultLineTooltipItem, // 表示文字設定
          tooltipBgColor: Colors.white, // 背景の色
          tooltipRoundedRadius: 2.0, // 角丸
        ),
      ),

      // 背景のグリッド線の設定
      gridData: FlGridData(
        show: true, // 背景のグリッド線の有無
        drawVerticalLine: true, // 水平方向のグリッド線の有無
        //horizontalInterval: 1.0, // 背景グリッドの横線間隔
        //verticalInterval: 1.0, // 背景グリッドの縦線間隔
        // 背景グリッドの横線設定
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(80, 0, 0, 0),
            strokeWidth: 1.0, // 線の太さ
          );
        },
        // 背景グリッドの縦線設定
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(80, 0, 0, 0),
            strokeWidth: 1.0, // 線の太さ
          );
        },
      ),

      // グラフのタイトル設定
      titlesData: FlTitlesData(
        show: true, // タイトルの有無
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        // 下側のタイトル設定
        bottomTitles: const AxisTitles(
          // タイトル名
          axisNameWidget: Text(
            "DOY",
            style: TextStyle(
              color: Color(0xff68737d),
            ),
          ),
          axisNameSize: 20.0, //タイトルの表示エリアの幅
          // サイドタイトルの設定
          sideTitles: SideTitles(
            showTitles: true, // サイドタイトルの有無
            interval: 1.0, // サイドタイトルの表示間隔
            reservedSize: 50.0, // サイドタイトルの表示エリアの幅
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            selectedVariable,
            style: const TextStyle(
              color: Color(0xff68737d),
            ),
          ),
          axisNameSize: 20.0, //タイトルの表示エリアの幅
          sideTitles: const SideTitles(
            showTitles: true, // サイドタイトルの表示・非表示
            interval: 1.0, // サイドタイトルの表示間隔
            reservedSize: 50.0, // サイドタイトルの表示エリアの幅
            //getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),

      // グラフの外枠線
      borderData: FlBorderData(
        show: true, // 外枠線の有無
        border: Border.all(
          color: const Color(0xff37434d),
        ),
      ),
      lineBarsData:
          generateChartDate(measuredDataState!, sdiChart, selectedVariable));
}

/// グラフ全体のデータを生成する処理
List<LineChartBarData> generateChartDate(
    MeasuredDataState state, bool showSdiChart, String selectedVariable) {
  if (showSdiChart) {
    if (state.sdi12Data != null && state.sdi12Data!.isNotEmpty) {
      return state.sdi12Data!.map<LineChartBarData>((Sdi12DataState state) {
        return LineChartBarData(
          // 表示する座標のリスト
          spots: state.dataList
              .map((Sdi12Data sdi12data) =>
                  generateSdiData(sdi12data, selectedVariable))
              .toList(),
          // チャート線を曲線にするか折れ線にするか
          isCurved: false,
          barWidth: 1.0, // チャート線幅
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true, // 座標にドット表示の有無
            // ドットの詳細設定
            getDotPainter: (spot, percent, barData, index) =>
                // ドットの詳細設定
                FlDotCirclePainter(
              radius: 2.0,
              color: Colors.blue,
              strokeWidth: 2.0,
              strokeColor: Colors.blue,
            ),
          ),
          // チャート線下部に色を付ける場合の設定
          belowBarData: BarAreaData(
            show: false,
          ),
        );
      }).toList();
    } else {
      return [LineChartBarData()];
    }
  } else {
    if (state.environmentalData != null &&
        state.environmentalData!.isNotEmpty) {
      return [
        LineChartBarData(
          // 表示する座標のリスト
          spots: state.environmentalData!
              .map<FlSpot>((EnvironmentalDataState state) =>
                  generateEnvironmentData(state, selectedVariable))
              .toList(),
          // チャート線を曲線にするか折れ線にするか
          isCurved: false,
          barWidth: 1.0, // チャート線幅
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true, // 座標にドット表示の有無
            // ドットの詳細設定
            getDotPainter: (spot, percent, barData, index) =>
                // ドットの詳細設定
                FlDotCirclePainter(
              radius: 2.0,
              color: Colors.blue,
              strokeWidth: 2.0,
              strokeColor: Colors.blue,
            ),
          ),
          // チャート線下部に色を付ける場合の設定
          belowBarData: BarAreaData(
            show: false,
          ),
        )
      ];
    } else {
      return [LineChartBarData()];
    }
  }
}

/// SDI-12データのグラフのポイントを生成する処理
FlSpot generateSdiData(Sdi12Data sdiData, String targetSdiVariable) {
  switch (targetSdiVariable) {
    case "体積含水率":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse(
              (sdiData.vwc != "" && sdiData.vwc != null ? sdiData.vwc! : "0")));
    case "バルク比誘電率":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse(
              (sdiData.brp != "" && sdiData.brp != null ? sdiData.brp! : "0")));
    case "地温":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse((sdiData.soilTemp != "" && sdiData.soilTemp != null
              ? sdiData.soilTemp!
              : "0")));
    case "バルク電気電動度":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse((sdiData.sbec != "" && sdiData.sbec != null
              ? sdiData.sbec!
              : "0")));
    case "土壌感間隙水電気伝導度":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse((sdiData.spwec != "" && sdiData.spwec != null
              ? sdiData.spwec!
              : "0")));
    case "重力加速度(X)":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse(
              (sdiData.gax != "" && sdiData.gax != null ? sdiData.gax! : "0")));
    case "重力加速度(Y)":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse(
              (sdiData.gay != "" && sdiData.gay != null ? sdiData.gay! : "0")));
    case "重力加速度(Z)":
      return FlSpot(
          double.parse(sdiData.dayOfYear ?? "0"),
          double.parse(
              (sdiData.gaz != "" && sdiData.gaz != null ? sdiData.gaz! : "0")));
    default:
      return const FlSpot(0, 0);
  }
}

/// 環境データのグラフのポイントを生成する処理
FlSpot generateEnvironmentData(
    EnvironmentalDataState state, String targetEnvironmentVariable) {
  switch (targetEnvironmentVariable) {
    case "大気圧":
      return FlSpot(
          double.parse(state.dayOfYear ?? "0"),
          double.parse((state.airPress != "" && state.airPress != null
              ? state.airPress!
              : "0")));
    case "気温":
      return FlSpot(
          double.parse(state.dayOfYear ?? "0"),
          double.parse(
              (state.temp != "" && state.temp != null ? state.temp! : "0")));
    case "相対湿度":
      return FlSpot(
          double.parse(state.dayOfYear ?? "0"),
          double.parse(
              (state.humi != "" && state.humi != null ? state.humi! : "0")));
    case "二酸化炭素濃度":
      return FlSpot(
          double.parse(state.dayOfYear ?? "0"),
          double.parse((state.co2Concent != "" && state.co2Concent != null
              ? state.co2Concent!
              : "0")));
    case "揮発性有機化合物":
      return FlSpot(
          double.parse(state.dayOfYear ?? "0"),
          double.parse(
              (state.tvoc != "" && state.tvoc != null ? state.tvoc! : "0")));
    case "アナログ値(X)":
      return FlSpot(
          double.parse(state.dayOfYear ?? "0"),
          double.parse((state.analogValue != "" && state.analogValue != null
              ? state.analogValue!
              : "0")));
    default:
      return const FlSpot(0, 0);
  }
}

/// SDI-12のデータクラス
class Sdi12Data {
  num measuredDataMasterId;
  String? dayOfYear;
  String? vwc;
  String? soilTemp;
  String? brp;
  String? sbec;
  String? spwec;
  String? gax;
  String? gay;
  String? gaz;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Sdi12Data.fromJson(Map<String, dynamic> json)
      : measuredDataMasterId = json["measuredDataMasterId"],
        dayOfYear = json["dayOfYear"],
        vwc = json["vwc"],
        soilTemp = json["soilTemp"],
        brp = json["brp"],
        sbec = json["sbec"],
        spwec = json["spwec"],
        gax = json["gax"],
        gay = json["gay"],
        gaz = json["gaz"],
        createdAt = json["createdAt"],
        updatedAt = json["updatedAt"],
        deletedAt = json["deletedAt"];
}

/// アドレス毎のSDI-12データを保持するクラス
class Sdi12DataState {
  String sdiAddress;
  List<Sdi12Data> dataList;

  Sdi12DataState.fromJson(Map<String, dynamic> json)
      : sdiAddress = json["sdiAddress"],
        dataList = json["dataList"]
            .map<Sdi12Data>((dynamic item) => Sdi12Data.fromJson(item))
            .toList();
}

/// 電圧データクラス
class VoltageDataState {
  num measuredDataMasterId;
  String? dayOfYear;
  String? voltage;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  VoltageDataState.fromJson(Map<String, dynamic> json)
      : measuredDataMasterId = json["measuredDataMasterId"],
        dayOfYear = json["dayOfYear"],
        voltage = json["voltage"],
        createdAt = json["createdAt"],
        updatedAt = json["updatedAt"],
        deletedAt = json["deletedAt"];
}

/// 環境データクラス
class EnvironmentalDataState {
  num measuredDataMasterId;
  String? dayOfYear;
  String? airPress;
  String? temp;
  String? humi;
  String? co2Concent;
  String? tvoc;
  String? analogValue;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  EnvironmentalDataState.fromJson(Map<String, dynamic> json)
      : measuredDataMasterId = json["measuredDataMasterId"],
        dayOfYear = json["dayOfYear"],
        airPress = json["airPress"],
        temp = json["temp"],
        humi = json["humi"],
        co2Concent = json["co2Concent"],
        tvoc = json["tvoc"],
        analogValue = json["analogValue"],
        createdAt = json["createdAt"],
        updatedAt = json["updatedAt"],
        deletedAt = json["deletedAt"];
}

/// 測定データクラス
class MeasuredDataState {
  List<Sdi12DataState>? sdi12Data;
  List<EnvironmentalDataState>? environmentalData;
  List<VoltageDataState>? voltageData;
  MeasuredDataState(
      {required this.sdi12Data,
      required this.environmentalData,
      required this.voltageData});

  MeasuredDataState.fromJson(Map<String, dynamic> json)
      : sdi12Data = json["sdi12Data"],
        environmentalData = json["environmentalData"],
        voltageData = json["voltageData"];
}
