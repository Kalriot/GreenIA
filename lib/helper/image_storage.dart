import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_analysis.dart';

class ImageStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getLocalFile() async {
    final path = await _localPath;
    return File('$path/analyzed_images.json');
  }

  // Guardar imagen en caché y registrar análisis
  static Future<void> saveImage(File imageFile, String classification, double probability) async {
    final path = await _localPath;
    final savedImage = File('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageFile.copy(savedImage.path);

    List<ImageAnalysis> history = await getAnalyzedImages();
    history.add(ImageAnalysis(
      imagePath: savedImage.path,
      classification: classification,
      probability: probability,
      timestamp: DateTime.now(),
    ));

    final file = await _getLocalFile();
    file.writeAsString(ImageAnalysis.encode(history));

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("analyzed_images", ImageAnalysis.encode(history));
  }

  // Obtener imágenes guardadas
  static Future<List<ImageAnalysis>> getAnalyzedImages() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      return ImageAnalysis.decode(contents);
    } else {
      return [];
    }
  }

  // Eliminar imagen del historial y del almacenamiento
  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }

    List<ImageAnalysis> history = await getAnalyzedImages();
    history.removeWhere((image) => image.imagePath == imagePath);

    final storageFile = await _getLocalFile();
    storageFile.writeAsString(ImageAnalysis.encode(history));

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("analyzed_images", ImageAnalysis.encode(history));
  }
}
