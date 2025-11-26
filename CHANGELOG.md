<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Registro de Cambios](#registro-de-cambios)
  - [[No publicado]](#no-publicado)
  - [[3.0.1] - 2025-11-26](#301---2025-11-26)
  - [[3.0.0] - 2025-11-20](#300---2025-11-20)
  - [[2.1.0] - 2025-11-19](#210---2025-11-19)
    - [El commit 5f8ec51910074d28212491b23568d03b25815ce5 introduce la](#el-commit-5f8ec51910074d28212491b23568d03b25815ce5-introduce-la)
  - [[2.0.5] - 2025-11-18](#205---2025-11-18)
  - [[2.0.4] - 2025-09-29](#204---2025-09-29)
  - [[2.0.3] - 2025-09-29](#203---2025-09-29)
  - [[2.0.2] - 2025-09-24](#202---2025-09-24)
  - [[2.0.1] - 2025-09-08](#201---2025-09-08)
  - [[2.0.0] - 2025-08-30](#200---2025-08-30)
  - [[1.0.2] - 2025-05-26](#102---2025-05-26)
  - [[1.0.1] - 2025-04-29](#101---2025-04-29)
  - [[1.0.0] - 2025-04-22](#100---2025-04-22)
  - [[0.2.9] - 2025-04-19](#029---2025-04-19)
  - [[0.2.8] - 2025-04-17](#028---2025-04-17)
  - [[0.2.7] - 2025-04-11](#027---2025-04-11)
  - [[0.2.6] - 2025-04-09](#026---2025-04-09)
  - [[0.2.5] - 2025-04-07](#025---2025-04-07)
  - [[0.2.4] - 2025-04-05](#024---2025-04-05)
  - [[0.2.3] - 2025-04-05\n\nUpdate Github Actions, dart and version-bump\n](#023---2025-04-05%5Cn%5Cnupdate-github-actions-dart-and-version-bump%5Cn)
  - [[0.2.2] - 2025-04-05](#022---2025-04-05)
  - [[0.2.1] - 2025-04-02](#021---2025-04-02)
  - [[0.2.0] - 2025-03-28](#020---2025-03-28)
    - [Agregado](#agregado)
  - [[0.1.0] - 2025-03-xx](#010---2025-03-xx)
    - [Agregado](#agregado-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Registro de Cambios

Todos los cambios notables en este proyecto se documentarán en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [No publicado]

## [3.0.1] - 2025-11-26

feat: enhance notification service with timezone configuration and Android channels, and add dedicated tests for TeamPage and UserListPage.

## [3.0.0] - 2025-11-20

feat: Add Product and SaleOrder models with Firestore serialization and unit tests.

## [2.1.0] - 2025-11-19

feat: Agregar lógica de recurrencia en el modelo de evento y crear selector de recurrencia (#153)

### El commit 5f8ec51910074d28212491b23568d03b25815ce5 introduce la
interfaz de usuario para crear eventos recurrentes.


Nuevo Widget de Recurrencia (lib/widgets/recurrence_rule.dart):
* Se ha creado un nuevo archivo que contiene el widget
RecurrenceSelector.
* Este componente permite al usuario:
Activar si el evento es recurrente ("Esdeveniment recurrent?").
Elegir la frecuencia (Diaria, Semanal, Mensual, Anual).
Definir el intervalo (ej. cada 2 semanas).
Seleccionar una fecha de finalización opcional.

* Integración en el Formulario (lib/widgets/event_form_modal.dart):
* Se ha añadido el RecurrenceSelector dentro del formulario de creación
de eventos (EventFormModal).
* Se han realizado ajustes visuales menores:
Reducción de espacios (SizedBox) para compactar el formulario.
Cambio de estilo en el botón "Canviar" (ahora usa color cyan).
* Cambios en Dependencias (pubspec.lock):
Hay pequeños cambios automáticos en las versiones de meta y test_api,
probablemente fruto de ejecutar flutter pub get.

En resumen, este commit conecta la lógica de recurrencia que vimos en el
modelo con la interfaz visual, permitiendo a los usuarios configurar
repeticiones al crear un evento.

## [2.0.5] - 2025-11-18

test: Remove `EventFormModal` assertions and use dynamic dates in dashboard tests, and add 2.0.4 changelog entry.

## [2.0.4] - 2025-09-29

feat: Corregir la referencia del mensaje de commit en la actualización del cuerpo de la PR

## [2.0.3] - 2025-09-29

COMMIT_MSG_ENV

## [2.0.2] - 2025-09-24

feat: Agregar soporte para notificaciones locales y mejorar la gestión de eventos

## [2.0.1] - 2025-09-08

feat: Actualizar CHANGELOG y eliminar comentarios de cobertura en varios archivos

## [2.0.0] - 2025-08-30

feat: Agregar gestión de eventos con reglas de Firestore, modelo de evento y páginas relacionadas

## [1.0.2] - 2025-05-26

feat: Agregar reglas de etiquetado para archivos Dart en el labeler

## [1.0.1] - 2025-04-29

feat: Actualizar la licencia a GNU GENERAL PUBLIC LICENSE en varios archivos y agregar versión 1.0.0 al changelog

## [1.0.0] - 2025-04-22

feat: Agregar página de listado de usuarios y soporte para mostrar usuarios en Firestore

## [0.2.9] - 2025-04-19

feat: Add image_picker and firebase_storage dependencies

feat: Implement Firebase Storage rules for user profile images

test: Update dashboard_page_test to include profile navigation and mock user provider

test: Refactor firebase_auth_test to include copyright and license comments

test: Enhance hcc_app_bar_test with copyright and license comments

test: Improve login_page_test with copyright and license comments

test: Refactor profile_page_test to include mock user provider and network image mocking

test: Update registration_page_test with copyright and license comments

test: Add copyright and license comments to user_model_test

fix: Register file_selector_windows and firebase_storage plugins in Windows

fix: Update generated_plugins.cmake to include new plugins

## [0.2.8] - 2025-04-17

Agregar comentarios de cobertura para las funciones de restablecimiento de contraseña y registro en los widgets de inicio de sesión y registro.

## [0.2.7] - 2025-04-11

Actualizar etiquetas de navegación en DashboardPage y refactorizar ProfilePage para inicializar FirebaseAuth y FirebaseFirestore. Agregar pruebas para DashboardPage.

## [0.2.6] - 2025-04-09

Add profile test and update profile page widget

## [0.2.5] - 2025-04-07

Add FUNDING.yml for supported funding platforms and enhance version bump workflow with PR creation

## [0.2.4] - 2025-04-05

Ajustar correctamente formato CHANGELOG.md

## [0.2.3] - 2025-04-05\n\nUpdate Github Actions, dart and version-bump\n

## [0.2.2] - 2025-04-05

## [0.2.1] - 2025-04-02

## [0.2.0] - 2025-03-28

### Agregado
- Sistema de CI/CD con GitHub Actions
- Etiquetado automático de Pull Requests

## [0.1.0] - 2025-03-xx

### Agregado
- Configuración inicial del proyecto Flutter
- Integración con Firebase (Auth, Firestore)
- Pantalla de inicio
- Funcionalidad de registro de usuarios
- Funcionalidad de inicio de sesión
- Modelo de usuario básico
