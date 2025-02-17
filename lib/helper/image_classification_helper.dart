/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'isolate_inference.dart';

class ImageClassificationHelper {

  static const modelPath = 'assets/models/UltimoModelitoYolo.tflite';
  static const labelsPath = 'assets/models/labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  // Carga el modelo
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    //Segun el sistema operativo como que optimiza
    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    // Use GPU Delegate
    // doesn't work on emulator
    // if (Platform.isAndroid) {
    //   options.addDelegate(GpuDelegateV2());
    // }

    // Use Metal Delegate
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get tensor input shape [1, 640, 640, 3]
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;

    log('Interpreter loaded successfully');
  }

  // Cargar las etiquetas
  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    // Se carga dentro de "labels" que fue definido al inicio como una lista de String
    labels = labelTxt.split('\n');
  }

  // Funcion que inicializa el modelo, espera que todo se cargue.
  Future<void> initHelper() async {
    _loadLabels();
    _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  //Envia imagen al modelo para realizar la inferencia.
  Future<List<Map<String, dynamic>>> _inference(InferenceModel inferenceModel) async {
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort.send(inferenceModel..responsePort = responsePort.sendPort);

    // Obtener resultado
    var results = await responsePort.first;

    if (results is List && results.isNotEmpty && results.first is Map<String, dynamic>) {
      // Aquí, results es una lista de mapas, cada mapa contiene datos de la detección
      return results.map((detection) {
        // Verificamos que las claves necesarias existan
        if (detection.containsKey("label") && detection.containsKey("confidence") &&
            detection.containsKey("box") && detection.containsKey("probabilist")) {
          return {
            "label": detection["label"],
            "confidence": detection["confidence"],
            "box": detection["box"],
            "probabilist": detection["probabilist"]
          };
        } else {
          throw Exception("El mapa de detección no tiene las claves esperadas: $detection");
        }
      }).toList();
    } else {
      throw Exception("El resultado no tiene el formato esperado o está vacío");
    }
  }


  // Esto es para capturar una imagen en tiempo real
  Future<List<Map<String, dynamic>>> inferenceCameraFrame(
      CameraImage cameraImage) async {
    var isolateModel = InferenceModel(cameraImage, null, interpreter.address,
        labels, inputTensor.shape, outputTensor.shape);
    return _inference(isolateModel);
  }

  // Para capturar una imagen fija
  Future<List<Map<String, dynamic>>> inferenceImage(Image image) async {
    var isolateModel = InferenceModel(null, image, interpreter.address, labels,
        inputTensor.shape, outputTensor.shape);
    return _inference(isolateModel);
  }

  Future<void> close() async {
    isolateInference.close();
  }
}
