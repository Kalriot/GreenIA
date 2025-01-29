# Usa la imagen oficial de Flutter
FROM  ghcr.io/cirruslabs/flutter:3.27.3



# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia todos los archivos del proyecto al contenedor
COPY ../../tflite_flutter ./tflite_flutter

# Ejecuta el comando de instalación de dependencias
RUN flutter pub get

# Construye la aplicación para la plataforma deseada (por ejemplo, Android)
RUN flutter build apk --release

# Copia el APK generado a una carpeta de salida en el contenedor
CMD ["sh", "-c", "cp build/app/outputs/flutter-apk/app-release.apk /output && ls /output"]
