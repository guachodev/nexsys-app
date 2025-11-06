# nexsys_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Dev

1. Copiar el .env.template y renombrarlo a .env
2. Cambiar las variables de entorno (The MovieDB)
3. Cambios en la entidad, hay que ejecutar el comando

```
flutter pub run build_runner build
```

# Prod

Para cambiar el nombre de la aplicación:

```
flutter pub run change_app_package_name:main com.fernandoherrera.cinemapedia-test
```

Para cambiar el ícono de la aplicación

```
flutter pub run flutter_launcher_icons
```

Para cambair el splash screen

```
dart run flutter_native_splash:create --path=splash.yaml
```

Android AAB

```
flutter build appbundle
```
