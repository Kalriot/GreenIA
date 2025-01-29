import 'dart:io';
import 'package:flutter/material.dart';
import '../helper/image_storage.dart';
import '../helper/image_analysis.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ImageAnalysis> images = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyzedImages();
  }

  Future<void> _loadAnalyzedImages() async {
    images = await ImageStorage.getAnalyzedImages();
    images.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Ordena de más reciente a más antiguo
    setState(() {});
  }

  Future<void> _deleteImage(int index) async {
    await ImageStorage.deleteImage(images[index].imagePath);
    setState(() {
      images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: images.isEmpty
          ? const Center(
              child: Text(
                "No hay imágenes analizadas.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(images[index].imagePath),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              images[index].classification,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Probabilidad: ${(images[index].probability * 100).toStringAsFixed(2)}%",
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            Text(
                              "Fecha: ${images[index].timestamp.toLocal()}",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteImage(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
