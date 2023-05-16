# 実機インストール手順
- `flutter clean` (任意)
- `flutter build ios --dart-define-from-file=dart_defines/prod.json` (インストールしたい環境に応じて読み込むjsonを変更する)
- `flutter devices` (インストールしたい端末のid等を確認)
- `flutter install -d ${id}`
