import 'package:flutter/material.dart';

Widget getRecyclingInfo(String material) {
  // Mapeo de colores y mensajes por tipo de material
  final Map<String, Map<String, dynamic>> recyclingData = {
    "plastico": {
      "color": const Color.fromRGBO(251, 192, 45, 1),
      "icon": "assets/images/amarillo.webp",
      "message": "El plástico debe depositarse en el tacho amarillo. Se puede reciclar y reutilizar para reducir contaminación."
    },
    "vidrio": {
      "color": Colors.green.shade700,
      "icon": "assets/images/verde.webp",
      "message": "El vidrio se recicla en el tacho verde. ¡Recuerda enjuagarlo antes de desecharlo!"
    },
    "carton": {
      "color": Colors.brown.shade700,
      "icon": "assets/images/marron.webp",
      "message": "El cartón debe ir en el tacho marrón. ¡Recíclalo seco y limpio para mejor reutilización!"
    },
    "papel": {
      "color": Colors.blue.shade700,
      "icon": "assets/images/azul.webp",
      "message": "El papel debe ir en el tacho azul. Evita desecharlo mojado para facilitar su reciclaje."
    }
  };

  // Depuración: Verificar material recibido
  String cleanedMaterial = material.trim().toLowerCase();
  debugPrint("🔍 Verificando material: '$cleanedMaterial'");

  // Verificar si el material existe en el diccionario
  if (!recyclingData.containsKey(cleanedMaterial)) {
    debugPrint("⚠️ No hay datos de reciclaje para: '$cleanedMaterial'");
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        "⚠️ Material no reconocido: $cleanedMaterial",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, color: Colors.red),
      ),
    );
  }


  // Obtener datos según el material
  final data = recyclingData[material.trim().toLowerCase()]!;
  
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: data["color"],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono del tacho de reciclaje
        Image.asset(
          data["icon"],
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 10),

        // Texto de detección
        Text(
          "♻️ ${material[0].toUpperCase()}${material.substring(1)} Detectado ♻️",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),

        // Mensaje de reciclaje
        Text(
          data["message"],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}