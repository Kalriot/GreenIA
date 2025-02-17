import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../helper/image_classification_helper.dart';
import '../helper/image_storage.dart';
import 'package:camera/camera.dart';
import '../ui/recycling_info.dart'; // Importamos la nueva función para mostrar info de reciclaje

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = false;

  @override
  void initState() {
    super.initState();
    imageClassificationHelper = ImageClassificationHelper();
    _initializeHelper();
    _checkCameraAvailability();
  }

  Future<void> _initializeHelper() async {
    await imageClassificationHelper!.initHelper();
    setState(() {});
  }

  Future<void> _checkCameraAvailability() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          cameraIsAvailable = true;
        });
      }
    } catch (e) {
      debugPrint("Error checking camera availability: $e");
      setState(() {
        cameraIsAvailable = false;
      });
    }
  }

  // Método para limpiar resultados previos
  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  // Procesar la imagen seleccionada
  Future<void> processImage() async {
    if (imagePath != null) {
      try {
        final imageData = File(imagePath!).readAsBytesSync();
        image = img.decodeImage(imageData);
        setState(() {});

        // Obtener clasificación con el modelo
        classification = await imageClassificationHelper?.inferenceImage(image!);


        if (classification != null && classification!.isNotEmpty) {
          // Ordenar para encontrar la categoría con la mayor probabilidad
          var sortedEntries = classification!.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Obtener la categoría con mayor probabilidad y limpiarla
          String detectedCategory = sortedEntries.first.key.toLowerCase().trim();
          double probability = sortedEntries.first.value;

          // Guardar la imagen analizada en caché
          await ImageStorage.saveImage(File(imagePath!), detectedCategory, probability);

          // Llamar a la función para mostrar información de reciclaje
          setState(() {
            classification = {detectedCategory: probability}; // Guardar solo la mejor categoría
          });
        }
      } catch (e) {
        debugPrint("❌ Error processing image: $e");
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    imageClassificationHelper?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: cameraIsAvailable
                      ? () async {
                          cleanResult();
                          try {
                            final result = await imagePicker.pickImage(
                              source: ImageSource.camera,
                            );
                            imagePath = result?.path;
                            setState(() {});
                            processImage();
                          } catch (e) {
                            debugPrint("Error accessing camera: $e");
                          }
                        }
                      : null,
                  icon: const Icon(Icons.camera_alt, size: 24, color: Color.fromARGB(255, 220, 216, 216),),
                  label: const Text("Tomar Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 48, 185, 11),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: () async {
                    cleanResult();
                    final result = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    imagePath = result?.path;
                    setState(() {});
                    processImage();
                  },
                  icon: const Icon(Icons.image, size: 24,color: Color.fromARGB(255, 220, 216, 216),),
                  label: const Text("Seleccionar Imagen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 111, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imagePath != null)
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration( 
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).toInt()),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(imagePath!),
                            width: 300, height: 300, fit: BoxFit.contain),
                      ),
                    ),
                  if (classification != null && classification!.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          "${classification!.entries.first.key.toUpperCase()} - ${(classification!.entries.first.value * 100).toStringAsFixed(2)}%",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        getRecyclingInfo(classification!.entries.first.key.toLowerCase()),
                        
                      ],
                    ),
                  if (classification == null)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No se ha seleccionado ninguna imagen. Toma o elige una para clasificar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}