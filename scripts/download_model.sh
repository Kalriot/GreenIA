# Download model
curl https://storage.googleapis.com/download.tensorflow.org/models/tflite/task_library/image_classification/android/mobilenet_v1_1.0_224_quantized_1_metadata_1.tflite \
    -o assets/models/best-fp16.tflite

# Unzip model to get labels and vocab
unzip -o assets/models/best-fp16.tflite \
    -d assets/models/