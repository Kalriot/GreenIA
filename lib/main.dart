import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'ui/camera.dart';
import 'ui/gallery.dart';
import 'ui/history_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  runApp(const BottomNavigationBarApp());
}

class BottomNavigationBarApp extends StatelessWidget {
  const BottomNavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  late CameraDescription cameraDescription;
  int _selectedIndex = 0;
  List<Widget>? _widgetOptions;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPages();
    });
  }

  initPages() async {
    _widgetOptions = [
      const GalleryScreen(),
      if (cameraIsAvailable)
        CameraScreen(camera: (await availableCameras()).first),
      const HistoryScreen(),
    ];
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Image.asset(
                'assets/images/basurin.png',
                height: 50,
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            Text(
              "GreenIA",
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor:
            const Color.fromARGB(255, 10, 225, 100).withOpacity(0.9),
      ),
      body: _widgetOptions != null
          ? _widgetOptions![_selectedIndex]
          : const Center(child: CircularProgressIndicator()), // Carga inicial
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Live Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // 📌 Historial con su ícono
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
