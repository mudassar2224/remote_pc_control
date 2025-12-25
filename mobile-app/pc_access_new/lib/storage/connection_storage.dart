import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/remote_connection.dart';

class ConnectionStorage {
  static const _key = 'connections';

  static Future<void> saveConnections(List<RemoteConnection> connections) async {
    final prefs = await SharedPreferences.getInstance();
    final list = connections.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<List<RemoteConnection>> loadConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => RemoteConnection.fromJson(jsonDecode(e))).toList();
  }
}
