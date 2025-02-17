import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image_classification_mobilenet/image_utils.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  // Funcion para inicializar
  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(entryPoint, _receivePort.sendPort,
        debugName: _debugName);
    _sendPort = await _receivePort.first;
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  //Aqui se ejecuta la inferencia
  static void entryPoint(SendPort sendPort) async {

    final port = ReceivePort();
    sendPort.send(port.sendPort); //Enviar sendport al hilo principal

    await for (final InferenceModel isolateModel in port) {
      image_lib.Image? img;
      if (isolateModel.isCameraFrame()) {
        img = ImageUtils.convertCameraImage(isolateModel.cameraImage!);
      } else {
        img = isolateModel.image;
      }

      if (img == null) {
        isolateModel.responsePort.send({});
        continue;
      }

      // Redimencionar la imagen al formato esperado por el modelo
      image_lib.Image imageInput = image_lib.copyResize(
        img,
        width: 640,
        height: 640,
      );

      //Eto' es porque en los Android's la imagen se vuelve chueca
      if (Platform.isAndroid && isolateModel.isCameraFrame()) {
        imageInput = image_lib.copyRotate(imageInput, angle: 90);
      }

      // Detect if model expects float32 or int8 input
      bool isFloatModel = isolateModel.inputShape.contains(3) &&
          (isolateModel.inputShape[0] == 1);

      // Convierte a tensor
      final imageMatrix = List.generate(
        imageInput.height,
        (y) => List.generate(
          640,
          (x) {
            final pixel = imageInput.getPixel(x, y);
            if (isFloatModel) {
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0]; // Normalized
            } else {
              return [pixel.r, pixel.g, pixel.b]; // Integer (0-255)
            }
          },
        ),
      );

      // Set tensor input
      final input = [imageMatrix];

      final output = List.generate(1, (_) => List.filled(25200 * 23, 0.0)).reshape([1, 25200, 23]);

      // Correr Inferencia
      Interpreter interpreter = Interpreter.fromAddress(isolateModel.interpreterAddress);
      interpreter.run(input, output);

      List<Map<String, dynamic>> detections = [];
      for (var i = 0; i < 25200; i++) {
        double confidence = output[0][i][4]; // Confianza de la detección
        if (confidence > 0.01
        ) { // Filtrar detecciones relevantes
          List<double> classScores = output[0][i].sublist(5); //Toma valor del indice 5 pa'lante
          //Toma el indice del valor mas alto.
          int bestClassIdx = classScores.indexWhere((e) => e == classScores.reduce((a, b) => a > b ? a : b));
          //Toma el valor mas grande dentro del array
          double maxValue = classScores.reduce((a, b) => a > b ? a : b);

          // Extraer coordenadas de la caja
          double cx = output[0][i][0];
          double cy = output[0][i][1];
          double w = output[0][i][2];
          double h = output[0][i][3];

          detections.add({
            "label": isolateModel.labels[bestClassIdx],
            "confidence": confidence,
            "box": [ cx, cy,  w,  h],
            "probabilist": maxValue
          });
        }
      }
      // Print raw output for debugging
      print("Raw Model Output: $output");


      if (detections.isNotEmpty) {
        // Ordena la lista, haciendo una comparacion de a dos
        detections.sort((a, b) => b["confidence"].compareTo(a["confidence"]));
        //Obtienes la primera deteccion con mayor confianza
        var bestDetection = detections.first;
        //Envias al hilo principal una lista de mapas
        isolateModel.responsePort.send(detections.map((detection) => {
          "label": detection["label"],
          "confidence": detection["confidence"],
          "box": detection["box"],
          "probabilist": detection["probabilist"]
        }).toList());
      } else {
        isolateModel.responsePort.send({});
      }

    }
  }
}

class InferenceModel {
  CameraImage? cameraImage;
  image_lib.Image? image;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(this.cameraImage, this.image, this.interpreterAddress,
      this.labels, this.inputShape, this.outputShape);

  // Check if input is from camera or image
  bool isCameraFrame() {
    return cameraImage != null;
  }
}
