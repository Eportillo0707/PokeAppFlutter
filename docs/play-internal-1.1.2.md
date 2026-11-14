# Prueba interna: versiones saltadas del catálogo

El AAB `build/play-internal-1.1.2-11/PokeApp-internal-1.1.2-11.aab`
corresponde a `com.emerson.pokeapp`, versión `1.1.2 (11)`, SHA-256
`E73401CEE73E1A87D9C278195CFDA8EFBA1BFDFB9A8A9E164394F1DBF0DCE4A9`.
Se compila con la URL fija del Release
`catalog-play-internal-2026.11.14.1` en `Eportillo0707/PokeAppCatalog`.
El Release está publicado con 189 assets verificados y admite como base
`2026.11.05`. No cambia el Release `latest` de offlinetest.

Sube el AAB únicamente al canal de pruebas internas de PokeApp en Play
Console. Play Store debe ofrecerlo como actualización de la app original.
Prueba dos recorridos después de instalar el AAB:

1. En un teléfono que conserve el catálogo incluido `2026.11.05`, abre
   Ajustes y busca la actualización. Debe ofrecer `2026.11.14.1` directamente.
2. En otro teléfono con el catálogo intermedio `2026.11.13.5`, repite la
   búsqueda. También debe ofrecer `2026.11.14.1` directamente.

En ambos, instala el catálogo, reinicia y comprueba la Pokédex, favoritos y
equipos. Si Play Console indica que el código 11 ya se utilizó, no edites el
AAB: habrá que compilar uno nuevo con un código mayor.
