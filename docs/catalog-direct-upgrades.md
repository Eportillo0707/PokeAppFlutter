# Actualización directa del catálogo

El catálogo incluido en la app tiene versión `2026.11.05`. Los paquetes
firmados futuros usan esa versión como `baseCatalogVersion` mínima. Cada
paquete contiene el SQLite completo y los medios que difieren del catálogo
incluido. El generador rechaza otra base para evitar publicar una actualización
que deje sin ruta a quienes no hayan instalado versiones intermedias.

La app acepta el paquete más reciente cuando la versión instalada es igual o
posterior a la base mínima y anterior a la versión publicada. Antes de activar
el SQLite valida integridad, esquema y todos los medios necesarios; puede
recuperar la versión anterior si la nueva falla al iniciar.

La prueba automatizada cubre instalación desde el catálogo incluido, salto
desde una versión intermedia y un medio nuevo. Para validar el recorrido en
Play Store se necesita un AAB construido con este cambio y un Release posterior
al catálogo instalado por los testers, firmado con base `2026.11.05`.
