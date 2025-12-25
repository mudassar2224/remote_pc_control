import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum MouseMode { directTouch, pointer }

class RemoteDesktopPage extends StatefulWidget {
  final String ip;
  final int port;

  const RemoteDesktopPage({
    super.key,
    required this.ip,
    this.port = 8765,
  });

  @override
  State<RemoteDesktopPage> createState() => _RemoteDesktopPageState();
}

class _RemoteDesktopPageState extends State<RemoteDesktopPage> {
  WebSocketChannel? _channel;
  Uint8List? _lastFrame;
  TransformationController _transformationController = TransformationController();
  MouseMode _mouseMode = MouseMode.directTouch;
  bool _showKeyboard = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    final uri = Uri.parse('ws://${widget.ip}:${widget.port}');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen((data) {
      if (data is List<int>) {
        setState(() {
          _lastFrame = Uint8List.fromList(data);
        });
      }
    }, onError: (error) {
      debugPrint('WebSocket error: $error');
    }, onDone: () {
      debugPrint('WebSocket closed');
    });
  }

  void _sendMouseClick(Offset pos, Size size) {
    if (_channel == null) return;

    final nx = pos.dx / size.width;
    final ny = pos.dy / size.height;

    final msgMove = jsonEncode({
      "type": "mouse_move",
      "x": nx,
      "y": ny,
    });

    final msgClick = jsonEncode({
      "type": "mouse_click",
    });

    if (_mouseMode == MouseMode.directTouch) {
      _channel!.sink.add(msgMove);
      _channel!.sink.add(msgClick);
    } else {
      // In pointer mode, maybe drag/other gestures can be implemented
      _channel!.sink.add(msgMove);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final size = MediaQuery.of(context).size;

          return Stack(
            children: [
              GestureDetector(
                onTapDown: (details) => _sendMouseClick(details.localPosition, size),
                child: Container(
                  color: Colors.black,
                  child: _lastFrame != null
                      ? InteractiveViewer(
                          transformationController: _transformationController,
                          panEnabled: true,
                          scaleEnabled: true,
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: Image.memory(
                            _lastFrame!,
                            gaplessPlayback: true,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
              // Connection bar
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(
                          _showKeyboard ? Icons.keyboard_hide : Icons.keyboard,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _showKeyboard = !_showKeyboard);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _mouseMode == MouseMode.directTouch
                              ? Icons.touch_app
                              : Icons.mouse,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _mouseMode = _mouseMode == MouseMode.directTouch
                                ? MouseMode.pointer
                                : MouseMode.directTouch;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                        onPressed: _resetZoom,
                      ),
                    ],
                  ),
                ),
              ),
              // Optional keyboard overlay
              if (_showKeyboard)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 250,
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                        fillColor: Colors.white70,
                        filled: true,
                      ),
                      onSubmitted: (text) {
                        if (_channel != null) {
                          _channel!.sink.add(jsonEncode({"type": "keyboard_input", "text": text}));
                        }
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _transformationController.dispose();
    super.dispose();
  }
}
