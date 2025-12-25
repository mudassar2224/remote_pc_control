import 'package:flutter/material.dart';
import '../models/remote_connection.dart';
import '../storage/connection_storage.dart';
import '../widgets/connection_tile.dart';
import 'remote_desktop_page.dart';

class ConnectionCenterPage extends StatefulWidget {
  const ConnectionCenterPage({super.key});

  @override
  State<ConnectionCenterPage> createState() => _ConnectionCenterPageState();
}

class _ConnectionCenterPageState extends State<ConnectionCenterPage> {
  List<RemoteConnection> connections = [];

  @override
  void initState() {
    super.initState();
    loadConnections();
  }

  Future<void> loadConnections() async {
    final list = await ConnectionStorage.loadConnections();
    setState(() => connections = list);
  }

  Future<void> addConnection() async {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '8765');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: ipController, decoration: const InputDecoration(labelText: 'IP')),
            TextField(controller: portController, decoration: const InputDecoration(labelText: 'Port')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final conn = RemoteConnection(
                name: nameController.text.trim(),
                ip: ipController.text.trim(),
                port: int.tryParse(portController.text) ?? 8765,
              );
              setState(() => connections.add(conn));
              ConnectionStorage.saveConnections(connections);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteConnection(int index) {
    setState(() {
      connections.removeAt(index);
      ConnectionStorage.saveConnections(connections);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Connections')),
      body: ListView.builder(
        itemCount: connections.length,
        itemBuilder: (ctx, i) {
          final conn = connections[i];
          return ConnectionTile(
            connection: conn,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RemoteDesktopPage(ip: conn.ip, port: conn.port)),
              );
            },
            onDelete: () => deleteConnection(i),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addConnection,
        child: const Icon(Icons.add),
      ),
    );
  }
}
