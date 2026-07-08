# Garmin Face Watch

Watch face para dispositivos Garmin compatibles con Connect IQ, escrito en Monkey C.

Muestra cuatro datos básicos:
- Hora (formato 12h/24h según la configuración del reloj)
- Fecha (día de semana, día, mes)
- Nivel de batería del dispositivo
- Ritmo cardíaco actual (si el reloj lo reporta)

El fondo completo del watch face cambia de color según la zona de ritmo cardíaco actual, para dar una lectura de intensidad de un vistazo:

| Color | Zona | Rango |
|---|---|---|
| Gris | Sin lectura | HR no disponible |
| Azul | Bajo / reposo | hasta 99 bpm |
| Verde | Normal | 100–119 bpm |
| Amarillo | Elevado | 120–149 bpm |
| Rojo | Alto | 150 bpm o más |

Cada texto (hora, fecha, batería, HR) se dibuja sobre una caja negra sólida para mantenerse legible sin importar el color de fondo activo.

Todavía no tiene diseño visual definido más allá de esto — es un scaffolding funcional pensado como punto de partida.

> ¿Retomando este proyecto después de un tiempo, o desde cero? Empezá por [HANDOFF.md](HANDOFF.md) — resume el estado actual, el entorno de desarrollo y la convención de trabajo.

## Estructura del proyecto

```
GarminFaceWatch/
├── manifest.xml                       # metadata de la app, dispositivos soportados, permisos
├── monkey.jungle                      # config de build
├── source/
│   ├── GarminFaceWatchApp.mc          # entry point de la app (Application.AppBase)
│   └── GarminFaceWatchView.mc         # watch face (WatchUi.WatchFace) con el dibujo de los 4 datos
└── resources/
    ├── strings/strings.xml            # nombre de la app
    └── drawables/
        ├── drawables.xml              # referencia al ícono
        └── launcher_icon.png          # ícono placeholder (círculo azul 40x40)
```

## Requisitos

### Estado del setup en esta máquina

Ya instalado (vía Homebrew):

```bash
brew install --cask connectiq connectiq-sdk-manager
```

Esto deja disponibles `monkeyc`, `monkeydo`, `monkeydoc` en el PATH (`/opt/homebrew/bin`), y las apps `ConnectIQ.app` (simulador) y `SdkManager.app` en `/Applications`. También se generó ya un `developer_key.der` / `developer_key.pem` en la raíz del proyecto (gitignorado, sirve para firmar builds locales — no hace falta regenerarlo).

Las *imágenes de dispositivo* (device images) ya se descargaron desde `SdkManager.app` — incluye `fenix7` y ~25 relojes más de las familias fenix/vivoactive. `monkeyc -d fenix7 ...` compila sin errores (`BUILD SUCCESSFUL`) y se verificó corriendo en el simulador. Si en otro momento necesitás un dispositivo que no esté en la lista, abrí `SdkManager.app` y descargalo desde la pestaña de dispositivos (no requiere cuenta de Garmin Connect, solo aceptar la licencia la primera vez).

### Para instalar desde cero (otra máquina)

1. **Connect IQ SDK Manager** — vía Homebrew (`brew install --cask connectiq connectiq-sdk-manager`) o descargándolo desde [developer.garmin.com/connect-iq/sdk](https://developer.garmin.com/connect-iq/sdk/). Desde el SDK Manager instalá al menos un SDK y las imágenes de dispositivo (device images) de los relojes que quieras probar (ej. `fenix7`, `vivoactive4`, `venu3`) — ver pasos arriba.
2. **Editor**: se recomienda VS Code + extensión oficial **Monkey C** (`garmin.monkey-c-tools`), que agrega comandos, autocompletado, debugger y tareas de build/simulación. También se puede compilar 100% por línea de comandos con las herramientas que trae el SDK (`monkeyc`, `monkeydo`, `connectiq`).
3. **Developer key**: Connect IQ requiere firmar los builds con un par de llaves de desarrollador (no es para publicar, es solo para poder compilar/correr localmente).
   - Con la extensión de VS Code: paleta de comandos → `Monkey C: Generate Developer Key Pair`.
   - Por CLI (ejemplo con OpenSSL):
     ```bash
     openssl genrsa -out developer_key.pem 4096
     openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
     ```
   - El `developer_key.der` está gitignorado (ver `.gitignore`) y configurá su ruta en la extensión (`Settings > Monkey C > Developer Key`) o pasala con `-y` en el CLI.

## Compilar y correr en el simulador

### Opción A — VS Code (recomendada)

1. Abrí la carpeta `GarminFaceWatch/` en VS Code.
2. `Cmd+Shift+P` → `Monkey C: Build Current Project` (o simplemente presioná `F5`).
3. Elegí el dispositivo target (ej. `fenix7`).
4. VS Code compila, abre el **Connect IQ Simulator** y corre la app automáticamente.

### Opción B — Línea de comandos

Con el SDK instalado vía Homebrew, `monkeyc` y `monkeydo` ya están en el PATH:

```bash
# Compilar para un dispositivo específico
monkeyc -d fenix7 -f monkey.jungle -o bin/GarminFaceWatch.prg -y developer_key.der

# Levantar el simulador (una vez, queda corriendo en background)
open /Applications/ConnectIQ.app &

# Cargar y correr el build compilado en el simulador
monkeydo bin/GarminFaceWatch.prg fenix7
```

## Probar el ritmo cardíaco en el simulador

El simulador no tiene un sensor real, así que `Activity.getActivityInfo().currentHeartRate` devuelve `null` (se muestra como `HR --`) hasta que le inyectes datos:

- En el simulador: menú **Simulation → Fit Data → Simulate Data To...**, ahí podés cargar/generar un stream de datos que incluya heart rate.
- Alternativamente, correr la app en un reloj físico conectado y con el sensor de muñeca activo va a mostrar el valor real.

## Notas / próximos pasos

- El watch face dibuja todo "a mano" con `Dc.drawText` (sin `layout.xml`) para mantenerlo simple; el diseño visual (tipografía, iconos, disposición) queda pendiente de definir más allá del color de fondo por zona de HR.
- `onUpdate()` se llama ~1 vez por minuto por defecto (comportamiento estándar de Connect IQ para ahorrar batería). Si más adelante se quiere refrescar el ritmo cardíaco con mayor frecuencia (modo "always-on" / alta frecuencia), hay que implementar `onPartialUpdate()` y `WatchFaceDelegate`, algo que se dejó afuera a propósito en este scaffolding inicial.
- La lista de `iq:product` en `manifest.xml` incluye ~20 relojes recientes con sensor de HR de muñeca; se puede ampliar/editar con `Monkey C: Edit Products` en VS Code o agregando `<iq:product id="..."/>` a mano.
- El ícono (`launcher_icon.png`) es un placeholder generado programáticamente (círculo azul), sin intención de diseño final.

## Tests

Pruebas unitarias con el framework nativo de Connect IQ (funciones anotadas `(:test)`, en `source/GarminFaceWatchViewTest.mc`). Cubren la lógica pura del watch face (por ahora, `getHeartRateZoneColor`) — no verifican píxeles renderizados, Connect IQ no tiene mocking de `Dc`.

```bash
# Compilar en modo test
monkeyc -t -d fenix7 -f monkey.jungle -o bin/GarminFaceWatchTest.prg -y developer_key.der

# Correr contra el simulador (debe estar abierto)
monkeydo bin/GarminFaceWatchTest.prg fenix7 -t
```

**Ojo:** `monkeydo` siempre termina con exit code 1, incluso cuando todos los tests pasan — el resultado real hay que leerlo del texto de salida (`PASSED (passed=N, failed=0, errors=0)` vs `FAILED (...)`), no confiar en el exit code.

## Contribuir

Cada feature o bug se trackea como issue en GitHub (hay templates en `.github/ISSUE_TEMPLATE/`). Abrí un issue antes de empezar a trabajar en algo nuevo. Todo cambio pasa por PR (branch → PR → tests → review → merge) — ver [HANDOFF.md](HANDOFF.md) para el flujo completo.

## Licencia

[MIT](LICENSE).
