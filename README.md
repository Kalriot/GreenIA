# Aplicación basada en Machine Learning para la identificación de residuos sólidos

Este proyecto esta desarrollado en **Flutter** y utiliza **TensorFlow Lite** para la clasificación de imágenes. Permite procesar tanto **imágenes estáticas** como **análisis en tiempo real desde la cámara** e incorpora una **funcionalidad de historial** para revisar imágenes analizadas previamente.

## 📌 Características

- **Clasificación de imágenes**: Permite seleccionar una imagen desde la galería o capturar una nueva para su análisis.
- **Clasificación en tiempo real**: Detecta y categoriza residuos directamente desde la cámara del dispositivo.
- **Historial de análisis**: Guarda automáticamente las imágenes procesadas junto con sus resultados de clasificación.
- **Eliminación de historial**: Permite borrar imágenes analizadas previamente cuando ya no sean necesarias.
- **Clasificación de residuos**: Identifica y categoriza residuos en cartón, vidrio, papel y plástico.

## 🔗 Dataset

El modelo fue entrenado con 1,975 imágenes categorizadas en plástico, papel, vidrio y cartón.

- **📦Cartón**: 496 imágenes
- **🥃Vidrio**: 500 imágenes
- **📄Papel**: 500 imágenes
- **🛍️Plastico**: 479 imágenes

El dataset se encuentra disponible en la plataforma Roboflow. Puede descargarse en el siguiente enlace: [Acceder al dataset](https://universe.roboflow.com/testing-ml-solid-waste/fourth-project-o8hdx/dataset/2)

## 🛠️Modelo

El modelo fue entrenado utilizando EfficientNetV2 para maximizar tanto la eficiencia como el rendimiento. Para el proceso de entrenamiento, se tomó como referencia un [notebook de Kaggle](https://www.kaggle.com/code/annafabris/efficientnet-v2-image-classification-93-accuracy#Introduction),  el cual implementa la arquitectura previamente mencionada.

El entrenamiento se realizó en el entorno Kaggle CPU, y el código del proceso está disponible en el siguiente enlace: [Acceder al entrenamiento](https://www.kaggle.com/code/jeanlavaud/effnet-v2-solid-waste-dataset)

## 🚀 Guía de Instalación

1. **Instalar Flutter**
  
Si aún no tienes Flutter instalado, sigue estos pasos:

- Descarga e instala Flutter desde su [sitio web oficial](https://flutter.dev/).
- Asegúrate de agregar Flutter al PATH de tu sistema.
- Para verificar la instalación, ejecuta:

```bash
flutter doctor
```

2. **Descargar el proyecto**

Clona el repositorio del proyecto con:

```
git clone https://github.com/Kalriot/TensorTrashProject.git
cd <nombre_del_proyecto>
```

1. **Instalar dependencias:**
Ejecuta el siguiente comando para descargar las dependencias necesarias:

```bash
flutter pub get
```

2. **Ejecuta la aplicación**:
Inicia la app en un dispositivo o emulador con:

```bash
flutter run
```

## 🔥 ¿Cómo funciona?

La aplicación permite identificar residuos sólidos mediante dos modos de clasificación: **análisis de imágenes estáticas** y **clasificación en tiempo real desde la cámara**. Además, incluye un **historial** donde se almacenan los análisis previos para su consulta posterior.

### 📷 Modo Galeria

1. El usuario puede **seleccionar una imagen desde la galería o capturar una nueva** con la cámara.
2. La imagen es procesada por el modelo **EfficientNetV2** para clasificar el residuo.
3. Se muestra el resultado de la clasificación junto con un **porcentaje de confianza.**
4. Los residuos son categorizados en una de las siguientes clases:
   - 🟤 **Cartón**
   - 🟢 **Vidrio**
   - 📄 **Papel**
   - ⚪ **Plástico**

### 🎥 Modo Análisis en Tiempo Real

1. Activa la cámara del móvil para analizar objetos en vivo.
2. Se actualiza dinámicamente con la categoría detectada entre **Cartón, Vidrio, Papel o Plástico**.
3. Este modo permite una clasificación más rápida y sin necesidad de capturar imágenes manualmente.

### 📜 Historial

1. Todas las imágenes analizadas en Galeria se guardan automáticamente en un historial.
2. Cada entrada incluye:
   - Nombre del residuo clasificado
   - Porcentaje de confianza del modelo
   - Fecha y hora del análisis

### 💭 Colaboradores

- Lavaud Guevara, Jean Alessandro
- Mantari Flores, Fabrizio Armando
- Salcedo Alfaro, Nick Emanuel
- Sanchez Gotea, Edu Joseph
- Suyco Rivera, Jesus Pedro

### Docente Investigador Responsable

-  Rodriguez Rodriguez, Ciro
