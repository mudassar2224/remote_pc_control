class RemoteConnection {
  final String name;
  final String ip;
  final int port; // <-- add port here

  RemoteConnection({
    required this.name,
    required this.ip,
    this.port = 8765,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'ip': ip,
        'port': port,
      };

  factory RemoteConnection.fromJson(Map<String, dynamic> json) => RemoteConnection(
        name: json['name'],
        ip: json['ip'],
        port: json['port'] ?? 8765,
      );
}
