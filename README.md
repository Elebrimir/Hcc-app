<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [🏑 HCC App - Hoquei Club Cocentaina](#-hcc-app---hoquei-club-cocentaina)
  - [📱 Descripción](#-descripci%C3%B3n)
  - [✨ Características Principales](#-caracter%C3%ADsticas-principales)
    - [� Gestión de Usuarios](#%EF%BF%BD-gesti%C3%B3n-de-usuarios)
    - [📅 Calendario y Eventos](#-calendario-y-eventos)
    - [🏆 Gestión Deportiva](#-gesti%C3%B3n-deportiva)
  - [🛠️ Tecnologías y Librerías](#-tecnolog%C3%ADas-y-librer%C3%ADas)
  - [🚀 Instalación y Configuración](#-instalaci%C3%B3n-y-configuraci%C3%B3n)
  - [📁 Estructura del Proyecto](#-estructura-del-proyecto)
  - [🧪 Tests](#%F0%9F%A7%AA-tests)
  - [🤝 Contribución](#-contribuci%C3%B3n)
  - [📄 Licencia](#-licencia)
  - [📬 Contacto](#-contacto)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 🏑 HCC App - Hoquei Club Cocentaina

![Logo](assets/images/logo_club.png)

[![Dart CI](https://github.com/Elebrimir/Hcc-app/actions/workflows/dart.yml/badge.svg)](https://github.com/Elebrimir/Hcc-app/actions/workflows/dart.yml)
[![Labeler](https://github.com/Elebrimir/Hcc-app/actions/workflows/label.yml/badge.svg)](https://github.com/Elebrimir/Hcc-app/actions/workflows/label.yml)
[![codecov](https://codecov.io/gh/Elebrimir/Hcc-app/graph/badge.svg?token=ZR5T8B8ZUI)](https://codecov.io/gh/Elebrimir/Hcc-app)
![GitHub milestone details](https://img.shields.io/github/milestones/progress-percent/elebrimir/hcc-app/1)


## 📱 Descripción

Aplicación oficial del **Hoquei Club Cocentaina**, diseñada para centralizar y facilitar la gestión integral del club. La aplicación sirve como punto de encuentro para jugadores, entrenadores, directivos y aficionados, permitiendo una comunicación fluida y una gestión eficiente de las actividades deportivas.

## ✨ Características Principales

### � Gestión de Usuarios
- **Autenticación Segura**: Registro e inicio de sesión mediante correo electrónico y contraseña (Firebase Auth).
- **Perfiles Personalizados**: Edición de datos personales y fotos de perfil.
- **Roles de Usuario**: Funcionalidades adaptadas según el rol (Jugador, Entrenador, Directivo, Administrador).
- **Listado de Usuarios**: Visualización y gestión de los miembros del club (para administradores).

### 📅 Calendario y Eventos
- **Agenda Interactiva**: Calendario visual para consultar entrenamientos, partidos y eventos sociales.
- **Gestión de Eventos**: Creación y edición de eventos con detalles como fecha, hora y ubicación.
- **Notificaciones**: Recordatorios locales para próximos eventos importantes.

### 🏆 Gestión Deportiva
- **Equipos**: Información detallada sobre las diferentes categorías y plantillas del club.
- **Dashboard**: Panel de control con resumen de actividad y accesos rápidos (especialmente útil para gestión).
- **Estadísticas**: Seguimiento de rendimiento y resultados (en desarrollo).

## 🛠️ Tecnologías y Librerías

El proyecto está construido con **Flutter** y utiliza un conjunto robusto de tecnologías:

- **Core**:
  - [Flutter](https://flutter.dev/) (SDK ^3.7.2)
  - [Dart](https://dart.dev/)

- **Backend & Servicios (Firebase)**:
  - `firebase_auth`: Autenticación de usuarios.
  - `cloud_firestore`: Base de datos NoSQL en tiempo real.
  - `firebase_storage`: Almacenamiento de archivos multimedia (fotos de perfil, etc.).

- **Gestión de Estado**:
  - `provider`: Inyección de dependencias y gestión de estado eficiente.

- **UI & Utilidades**:
  - `table_calendar`: Componente avanzado para la visualización del calendario.
  - `image_picker`: Selección de imágenes desde galería o cámara.
  - `flutter_local_notifications`: Sistema de notificaciones locales.
  - `intl`: Internacionalización y formateo de fechas.

- **Testing**:
  - `flutter_test`, `mockito`, `fake_cloud_firestore`, `firebase_auth_mocks` para pruebas unitarias y de integración robustas.

## 🚀 Instalación y Configuración

Sigue estos pasos para ejecutar el proyecto en tu entorno local:

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/Elebrimir/Hcc-app.git
   cd hcc_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configuración de Firebase**
   - Asegúrate de tener el archivo `firebase_options.dart` configurado correctamente para tu entorno (Android/iOS/Web).
   - Si no lo tienes, necesitarás configurar un proyecto en Firebase Console y usar `flutterfire configure`.

4. **Generación de código (opcional)**
   Si realizas cambios que requieran generación de código (mocks, etc.):
   ```bash
   flutter pub run build_runner build
   ```

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

La estructura del código fuente en `lib/` está organizada por funcionalidad:

```
lib/
├── auth/               # Lógica de autenticación
├── models/             # Modelos de datos (User, Team, Event)
│   ├── event_model.dart
│   ├── team_model.dart
│   └── user_model.dart
├── pages/              # Pantallas de la aplicación
│   ├── calendar_page.dart
│   ├── dashboard_page.dart
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── profile_page.dart
│   ├── team_page.dart
│   └── user_list_page.dart
├── providers/          # State Management (Providers)
├── services/           # Servicios externos y lógica de negocio
├── widgets/            # Componentes UI reutilizables
│   ├── event_form_modal.dart
│   ├── hcc_app_bar.dart
│   ├── user_display_item.dart
│   └── ...
├── firebase_options.dart
└── main.dart           # Punto de entrada
```

## 🧪 Tests

El proyecto cuenta con una suite de pruebas para asegurar la calidad del código.

Para ejecutar los tests:
```bash
flutter test
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas!

1. Haz un fork del proyecto.
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`).
3. Haz commit de tus cambios (`git commit -m 'Añade nueva funcionalidad'`).
4. Haz push a la rama (`git push origin feature/nueva-funcionalidad`).
5. Abre un Pull Request.

## 📄 Licencia

Este proyecto está bajo la licencia [GNU](LICENSE).

## 📬 Contacto

**Hoquei Club Cocentaina**
- Email: [presidenciah.c.cocentaina@gmail.com](mailto:presidenciah.c.cocentaina@gmail.com)
- Instagram: [@hoqueiclubcocentaina](https://instagram.com/hoqueiclubcocentaina)

Repositorio: [https://github.com/Elebrimir/Hcc-app](https://github.com/Elebrimir/Hcc-app)
