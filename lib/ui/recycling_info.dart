import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget getRecyclingInfo(String material) {
  // Mapeo de colores y mensajes por tipo de material
  final Map<String, Map<String, dynamic>> recyclingData = {
    "plastico": {
      "color": const Color.fromARGB(255, 122, 207, 126),
      "icon": "assets/images/verde.webp",
      "message": "Deposita los envases de plastico en el contenedor verde. Asegúrate de vaciarlos y limpiarlos antes de reciclar. "
    },
    "vidrio": {
      "color": const Color.fromARGB(255, 122, 207, 126),
      "icon": "assets/images/verde.webp",
      "message": "Deposita botellas y frascos de vidrio en el contenedor verde.  No incluyas vidrio roto, espejos ni cerámica."
    },
    "carton": {
      "color": const Color.fromARGB(255, 122, 207, 126),
      "icon": "assets/images/verde.webp",
      "message": "Deposita cajas y embalajes de cartón en el contenedor verde. Dóblalos para ahorrar espacio. Evita mezclar cartón sucio o con restos de comida, ya que no se podrá reciclar."
    },
    "papel": {
      "color": const Color.fromARGB(255, 122, 207, 126),
      "icon": "assets/images/verde.webp",
      "message": "Deposita periódicos, revistas y hojas en el contenedor verde. No incluyas papel plastificado o sucio."
    }
  };

  // Depuración: Verificar material recibido
  String cleanedMaterial = material.trim().toLowerCase();
  debugPrint("🔍 Verificando material: '$cleanedMaterial'");

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
          style: GoogleFonts.montserrat(textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        )
      ],
    ),
  );
}