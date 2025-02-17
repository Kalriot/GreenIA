import 'dart:io';
import 'dart:isolate'; // Para usar ReceivePort, SendPort y los isolates
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../helper/image_classification_helper.dart';
import '../helper/image_storage.dart';
import '../helper/isolate_inference.dart';
import 'DetectionPainter.dart';

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
  List<Map<String, dynamic>>? classification;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    imageClassificationHelper = ImageClassificationHelper();
    _initializeHelper();

  }

  Future<void> _initializeHelper() async {
    await imageClassificationHelper!.initHelper();
    setState(() {});
  }
  // Procesar imagen desde la cámara
  Future<void> processCameraFrame(CameraImage cameraImage) async {
    classification = await imageClassificationHelper?.inferenceCameraFrame(cameraImage);
    setState(() {});  // Actualizar la UI con los resultados
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
      //Leer la imagen desde el archivo
      final imageData = File(imagePath!).readAsBytesSync();
      image = img.decodeImage(imageData);
      setState(() {}); //Actualizar el estado

      // Obtener clasificación con el modelo
      classification = await imageClassificationHelper?.inferenceImage(image!);
      setState(() {}); //Actualizar el estado
      // Guardar la imagen analizada en caché
      //Verificamos que hay detecciones
      /*if (classification != null && classification!.isNotEmpty) {
        // Obtener la primera detección
        Map<String, dynamic> bestDetection = classification!.first;
        //Extraer la primera clave y el valor del mapa
        String bestClass = bestDetection.keys.first;
        double bestProbability = bestDetection.values.first;
        //Guardar la imagen con la mejor deteccion
        await ImageStorage.saveImage(File(imagePath!), bestClass, bestProbability);
      }*/

      setState(() {}); //Se actualiza
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
          // Botones para tomar o elegir una foto
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    cleanResult();
                    final result = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );
                    imagePath = result?.path;
                    setState(() {});
                    processImage();
                  },
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text("Take a Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
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
                  icon: const Icon(Icons.image, size: 24),
                  label: const Text("Pick from Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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

          // Mostrar imagen y resultados
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mostrar imagen seleccionada
                  if (imagePath != null)
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: 640, // Ancho fijo de 640 píxeles
                      height: 640, // Alto fijo de 640 píxeles
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            //Imagen
                            Image.file(
                            File(imagePath!),
                            width: 640,
                            height: 640,
                            fit: BoxFit.cover,
                            ),
                            //Si hay detecciones,dibujarlas
                            if((classification ?? []).isNotEmpty)
                              CustomPaint(
                                size: const Size(640, 640), //Tamano de la imagen
                                painter: DetectionPainter(classification!),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // Espaciado antes de mostrar los resultados
                  if (classification != null && classification!.isNotEmpty)
                    const SizedBox(height: 20),

                  // Mostrar clasificación de la imagen
                  if (classification != null && classification!.isNotEmpty)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: classification != null && classification!.isNotEmpty
                            ? classification!.map((map) {
                          // Extraer label y probabilist de cada mapa
                          final label = map["label"];
                          final probabilist = map["probabilist"];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  label.toString(), // Mostrar el label
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${(probabilist * 100).toStringAsFixed(2)}%", // Mostrar el probabilist como porcentaje
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                            : [], // Si no hay datos, retornar una lista vacía
                      ),
                    ),

                  // Mensaje si no hay imagen seleccionada
                  if (classification == null)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No image selected. Pick or take a photo to classify.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
