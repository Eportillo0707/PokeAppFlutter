# PokeAPP Flutter

Migracion Flutter de `Eportillo0707/PokeAPP`, orientada a Android y iOS.

## Funcionalidad portada

- Listado paginado de Pokemon usando PokeAPI.
- Busqueda por nombre.
- Filtro por tipo.
- Pantalla de favoritos persistidos localmente.
- Detalle con imagen oficial, tipos, estadisticas, descripcion, habilidades, cadena evolutiva y mega evoluciones.
- Tema oscuro con paleta cercana a la app Kotlin/Jetpack Compose original.

## Ejecutar

Este entorno no tiene Flutter instalado. En una maquina con Flutter:

```bash
flutter pub get
flutter create . --platforms=android,ios
flutter run
```

`flutter create . --platforms=android,ios` genera las carpetas nativas Android/iOS alrededor del codigo Dart ya migrado.
