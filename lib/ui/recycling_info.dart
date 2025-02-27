import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget getRecyclingInfo(String material) {
  // Mapeo de colores y mensajes por tipo de material
  final Map<String, Map<String, dynamic>> recyclingData = {
    "plastico": {
      "color": const Color.fromRGBO(251, 192, 45, 1),
      "icon": "assets/images/amarillo.webp",
      "message": "Deposita el plástico en el contenedor amarillo. Reciclar y reutilizar este material ayuda a disminuir la contaminación y a prevenir "
    },
    "vidrio": {
      "color": Colors.green.shade700,
      "icon": "assets/images/verde.webp",
      "message": "Deposita el vidrio en el contenedor verde.  "
    },
    "carton": {
      "color": Colors.brown.shade700,
      "icon": "assets/images/marron.webp",
      "message": "Deposita el cartón en el contenedor marrón. ¡Recíclalo seco y limpio para mejor reutilización!"
    },
    "papel": {
      "color": Colors.blue.shade700,
      "icon": "assets/images/azul.webp",
      "message": "Deposita el papel en el contenedor azul. Evita desecharlo mojado para facilitar su reciclaje."
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

        Image.asset(
          data["icon"],
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 10),

        Text(
          "♻️ ${material[0].toUpperCase()}${material.substring(1)} Detectado ♻️",
          style: GoogleFonts.montserrat(textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),),
        ),
        const SizedBox(height: 10),

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