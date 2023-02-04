import 'dart:io';

class ProxyHttpOverrides extends HttpOverrides {
  final String? _port;
  final String? _host;
  ProxyHttpOverrides(this._host, this._port);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // host情報が設定されていればhostとportを指定、そうでなければ DIRECT を設定.
    return super.createHttpClient(context)
      // set proxy
      ..findProxy = (uri) {
        return _port != null ? "PROXY $_host:$_port;" : 'DIRECT';
      };
  }
}
