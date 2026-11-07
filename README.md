# Final Fight 2 para macOS — 0.1.1

Proyecto experimental de **Final Fight 2 (USA)** para Mac Apple Silicon, basado
en [SNESRecomp](https://github.com/RetroPortingToolKit/snesrecomp) y
[recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui).
Combina código recompilado AOT con ejecución interpretada LLE; no es una
recompilación estática completa ni un emulador general para otras ROMs.

Incluye correcciones de los personajes al golpear y del parpadeo inferior,
configuración durante la pausa, soporte de dos jugadores y dos perfiles de
scanlines finas opcionales. El usuario ha probado satisfactoriamente esta
versión local; no se ha verificado el juego completo.

**Debes aportar tu propia ROM compatible.** Este repositorio no incluye ROM,
código generado desde ella, partidas ni ejecutables jugables. No es un producto
oficial ni está afiliado a Capcom. Consulta [NOTICE.md](NOTICE.md).

## Compilar

La app portable se ha probado en Apple Silicon con macOS 26 o posterior.
Necesitas las herramientas de línea de comandos de Xcode, Python 3, CMake,
Ninja y SDL2-compat (junto con SDL3). En el equipo de desarrollo las librerías
proceden de Homebrew; el empaquetador utiliza `/opt/homebrew/opt`.

```sh
git clone --recursive https://github.com/EddyKine/final-fight-2-snes.git
cd final-fight-2-snes
bash scripts/prepare-framework.sh
bash tools/regen.sh --rom "/ruta/a/Final Fight 2 (USA).sfc"
zsh portable/build.sh
```

`prepare-framework.sh` aplica el parche a la revisión fijada del motor; puede
repetirse sin aplicar el parche dos veces. La regeneración verifica el hash y
crea localmente `src/gen/` y `recomp/funcs.h`, excluidos de Git.

La app y el ZIP personales aparecen en `dist/`. No necesitan las herramientas
de compilación para ejecutarse. Al abrir la app, selecciona tu ROM con
**Browse For ROM**. No borres ni muevas ese archivo mientras esté en uso.

Para probar el ejecutable sin empaquetar:

```sh
bash scripts/run.sh --launcher --rom "/ruta/a/Final Fight 2 (USA).sfc"
```

Este script activa las tres opciones de ejecución necesarias: interrupciones
asíncronas, raster en vivo y captura de línea en H=512. La app portable las
activa automáticamente.

## Configuración y pausa

- **Ctrl+L** abre el menú y congela la partida y el audio.
- **Settings → Shader → Scanlines Finas Suaves** es el filtro recomendado.
  También hay una variante Marcadas. Usan una sola fila física oscura por
  grupo entero; sin rejilla LCD ni tinte cálido. Necesitan Renderer OpenGL.
- **Back → RESUME** vuelve al juego. Si pausaste antes con **Shift+P**, vuelve
  a pulsarlo para continuar. Cerrar la ventana del menú también regresa.
- Cambios que requieren reiniciar, como renderizador o frecuencia de audio,
  se guardan para la próxima apertura, conservando la partida actual.
- Los perfiles nuevos usan OpenGL con el filtro apagado. En un perfil antiguo
  con Auto/SDL, selecciona OpenGL y vuelve a abrir el juego una vez.

Estados guardados y rewind están deshabilitados hasta validar la serialización
del scheduler. Run-ahead se mantiene apagado y no aparece como opción.

La app guarda configuración y registros en
`~/Library/Application Support/EddyKine/Final Fight 2/`.
Para cambiar de Mac conservando los ajustes, copia también esa carpeta y tu ROM.
Consulta [portable/LEEME.txt](portable/LEEME.txt) para los controles.

## ROM admitida

Final Fight 2 (USA), LoROM, sin coprocesador.

- SHA-256: `744d1a16c3f99970283597ae8f43b7c3621c5f995c4566ef24b8d70b0692007b`
- CRC32: `8c37ff55`

Los archivos `.sfc` y `.smc` de la revisión correcta pueden verificarse con las
herramientas del motor; no se proporcionan enlaces de descarga del juego.

## Validación y créditos

Ambos filtros y la ejecución sin filtro pasaron pruebas locales de arranque,
combate y reinicio de 3868 frames por caso, con salida correcta. Se comprobó
visualmente el filtro suave y el acceso a Settings desde la pausa, regresando
sin reinicializar la SNES. El ZIP extraído conservó su firma ad hoc después de
las ejecuciones. La app no está notarizada por Apple. Intel, Windows y Linux
no están verificados para esta integración.

Los siete cambios del motor se distribuyen como un parche revisable en
[patches/snesrecomp-finalfight2.patch](patches/snesrecomp-finalfight2.patch).
Las revisiones originales se conservan en los submódulos y
[framework_pins.txt](framework_pins.txt). Se mantienen las licencias y créditos
originales: SNESRecomp usa **PolyForm Noncommercial 1.0.0**; otros componentes
tienen sus propias licencias. Consulta [LICENSE](LICENSE) y [NOTICE.md](NOTICE.md).
