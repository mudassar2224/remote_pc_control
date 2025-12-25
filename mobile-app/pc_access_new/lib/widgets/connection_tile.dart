import 'package:flutter/material.dart';
import '../models/remote_connection.dart';

class ConnectionTile extends StatelessWidget {
  final RemoteConnection connection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConnectionTile({
    super.key,
    required this.connection,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(connection.name),
      subtitle: Text('${connection.ip}:${connection.port}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
