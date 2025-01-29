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

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(entryPoint, _receivePort.sendPort,
        debugName: _debugName);
    _sendPort = await _receivePort.first;
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

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

      // Resize image to match model input shape
      image_lib.Image imageInput = image_lib.copyResize(
        img,
        width: isolateModel.inputShape[1],
        height: isolateModel.inputShape[2],
      );

      if (Platform.isAndroid && isolateModel.isCameraFrame()) {
        imageInput = image_lib.copyRotate(imageInput, angle: 90);
      }

      // Detect if model expects float32 or int8 input
      bool isFloatModel = isolateModel.inputShape.contains(3) &&
          (isolateModel.inputShape[0] == 1);

      final imageMatrix = List.generate(
        imageInput.height,
        (y) => List.generate(
          imageInput.width,
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
      final output = [List<double>.filled(isolateModel.outputShape[1], 0)];

      // Run inference
      Interpreter interpreter =
          Interpreter.fromAddress(isolateModel.interpreterAddress);
      interpreter.run(input, output);

      // Print raw output for debugging
      print("Raw Model Output: $output");

      final List<double> result = List<double>.from(output.first);
      int maxIndex = result.indexOf(result.reduce((a, b) => a > b ? a : b));
      double confidence = result[maxIndex];


      // Send classification result
      var classification = <String, double>{
        isolateModel.labels[maxIndex]: confidence
      };

      isolateModel.responsePort.send(classification);
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
