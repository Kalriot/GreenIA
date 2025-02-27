import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigationBarExample()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CB050),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/basurin.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              "PCIV PROJECT",
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("Investigadores:", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("- Jean Lavaud", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                  Text("- Fabrizio Mantari", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                  Text("- Jesus Suyco", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                  Text("- Nick Salcedo", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                  Text("- Edu Sanchez", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 20),
                  Text("Asesor Principal:", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("- Dr. Ciro Rodriguez", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
