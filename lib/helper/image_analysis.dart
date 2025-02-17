import 'dart:convert';

class ImageAnalysis {
  String imagePath;
  String classification;
  double probability;
  DateTime timestamp;

  ImageAnalysis({
    required this.imagePath,
    required this.classification,
    required this.probability,
    required this.timestamp,
  });

  // Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() => {
        "imagePath": imagePath,
        "classification": classification,
        "probability": probability,
        "timestamp": timestamp.toIso8601String(),
      };

  // Convertir de JSON
  factory ImageAnalysis.fromJson(Map<String, dynamic> json) => ImageAnalysis(
        imagePath: json["imagePath"],
        classification: json["classification"],
        probability: json["probability"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  // Convertir lista de objetos a JSON
  static String encode(List<ImageAnalysis> images) =>
      json.encode(images.map((e) => e.toJson()).toList());

  // Convertir JSON a lista de objetos
  static List<ImageAnalysis> decode(String images) =>
      (json.decode(images) as List<dynamic>)
          .map((item) => ImageAnalysis.fromJson(item))
          .toList();
}
