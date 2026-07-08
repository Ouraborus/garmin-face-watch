# Handoff

Este documento existe para que cualquier persona (o sesión de trabajo) que retome este proyecto pueda orientarse rápido, sin tener que reconstruir el contexto desde el historial de git o una conversación anterior. Léelo antes de tocar el código.

## Qué es esto

Watch face para Garmin (Connect IQ / Monkey C). Repo: [Ouraborus/garmin-face-watch](https://github.com/Ouraborus/garmin-face-watch) (público).

## Estado actual

Funcional y verificado corriendo en el simulador. Muestra:

- Hora (respeta formato 12h/24h del dispositivo)
- Fecha (día de semana, día, mes)
- Batería, como aro de progreso en el borde externo (círculo completo al 100%, se reduce hasta desaparecer en 0%; track negro fijo + arco blanco, no depende del color de HR)
- Ritmo cardíaco (si el reloj lo reporta; `--` si no hay dato)
- Fondo completo del watch face que cambia de color según la zona de HR (gris/azul/verde/amarillo/rojo — ver tabla en el README)
- Suite de tests unitarios (`source/GarminFaceWatchViewTest.mc`) cubriendo la lógica pura (`getHeartRateZoneColor`, `getBatterySweepDegrees`)

Todo se dibuja "a mano" con `Dc.drawText` sobre una caja negra sólida por cada texto, para que se mantengan legibles sobre cualquiera de los 5 colores de fondo (sin `layout.xml`, sin diseño visual definido más allá de esto — ver [README](README.md) sección "Notas / próximos pasos" y el detalle de estructura de archivos).

## Estado del entorno de desarrollo

En esta máquina (macOS, Apple Silicon) ya está todo instalado y probado — no hace falta repetir el setup:

- Homebrew + casks `connectiq` y `connectiq-sdk-manager` instalados.
- `monkeyc` / `monkeydo` en el PATH (`/opt/homebrew/bin`).
- `developer_key.der` / `.pem` generados en la raíz del proyecto (gitignorados).
- Device images descargadas vía `SdkManager.app`: `fenix7` y ~25 relojes más de las familias fenix/vivoactive.
- Compilación verificada (`monkeyc -d fenix7 ...` → `BUILD SUCCESSFUL`) y corrida en el simulador (`ConnectIQ.app`) con resultado visual confirmado por el usuario.

Si alguien retoma esto en **otra máquina**, seguir la sección "Requisitos → Para instalar desde cero" del README.

## Convención de trabajo

Cada feature o bug se trackea como **issue en GitHub** antes de implementarse (templates en `.github/ISSUE_TEMPLATE/`). No se agregan funcionalidades directamente sin un issue que las respalde — así queda un registro de qué se pidió, por qué, y cuándo.

**Todo cambio pasa por PR, nunca commit directo a `main`.** Flujo completo por issue:

1. Se abre un issue (`feature_request.md` o `bug_report.md`).
2. Se crea una rama para el trabajo.
3. Se implementa y compila localmente (`monkeyc -d <device> ...`, ver README).
4. Se abre un PR (`gh pr create`) referenciando el issue.
5. Se corren las pruebas (`monkeyc -t ...` + `monkeydo ... -t`, ver sección "Tests" del README) — no alcanza con "compila". Ojo: `monkeydo` siempre sale con exit code 1 (leer el texto de salida), y correrlo dos veces seguidas sin reiniciar `ConnectIQ.app` a veces se cuelga.
6. Se hace una pasada de review sobre el diff del PR (con la skill `code-review`) antes de mergear.
7. Se corrige lo que la review encuentre.
8. Recién ahí se mergea el PR (`gh pr merge`) y se cierra el issue.

Este flujo quedó formalizado el 2026-07-07 — antes de eso, algunos commits se hicieron directo a `main` sin PR ni tests.

## Pendientes conocidos

- Diseño visual: tipografía, iconos y disposición quedan sin definir (el layout actual es un placeholder funcional; el color de fondo por zona de HR sí está definido).
- Refresco de alta frecuencia del ritmo cardíaco (modo "always-on"): requeriría implementar `onPartialUpdate()` + `WatchFaceDelegate`, dejado afuera intencionalmente en el scaffolding inicial.
- Lista de dispositivos soportados en `manifest.xml` (`iq:product`) cubre ~20 relojes recientes con sensor de HR de muñeca; se puede ampliar según necesidad.
- Ícono (`launcher_icon.png`) es un placeholder generado programáticamente, sin intención de diseño final.

## Dónde mirar primero

- [README.md](README.md): estructura del proyecto, cómo compilar/correr, cómo simular datos de ritmo cardíaco.
- `source/GarminFaceWatchView.mc`: toda la lógica de dibujo del watch face.
- `manifest.xml`: dispositivos soportados y metadata de la app.
