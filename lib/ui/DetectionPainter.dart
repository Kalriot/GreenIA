import 'package:flutter/material.dart';

class DetectionPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;

  DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var detection in detections) {
      final box = detection['box'];

      // Validar que las coordenadas existan y sean numéricas
      if (box == null || box.length != 4 || box.any((coord) => coord == null || coord is! num)) {
        continue;  // Ignorar detecciones inválidas
      }
      // Desglosar las coordenadas del centro y las dimensiones
      final cx = box[0]; // Centro X
      final cy = box[1]; // Centro Y
      final w = box[2];  // Ancho
      final h = box[3];  // Alto

      // Normalizar las coordenadas al tamaño del canvas
      final double x = ((cx - w / 2) * size.width).clamp(0.0, size.width);
      final double y = ((cy - h / 2) * size.height).clamp(0.0, size.height);
      final double width = (w * size.width).clamp(0.0, size.width - x);
      final double height = (h * size.height).clamp(0.0, size.height - y);

      // Dibujar la caja delimitadora
      final rect = Rect.fromLTWH(x, y, width, height);
      canvas.drawRect(rect, paint);

      // Preparar el texto (etiqueta y confianza)
      final textSpan = TextSpan(
        text: '${detection['label'] ?? 'Unknown'} ${(detection['confidence'] != null ? (detection['confidence'] * 100).toStringAsFixed(2) : '0.00')}%',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          backgroundColor: Colors.white,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Posicionar el texto dentro de los límites de la imagen
      final double offsetX = (x).clamp(0.0, size.width - textPainter.width);
      final double offsetY = (y - textPainter.height).clamp(0.0, size.height - textPainter.height);

      textPainter.paint(canvas, Offset(offsetX, offsetY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}