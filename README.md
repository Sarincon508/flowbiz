# FlowBiz 🚀
> **Gestión Integral de Operaciones, Agenda Inteligente, Caja y Finanzas para Pequeños Comercios**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Architecture: Clean](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg)](#)

---

## ⚡ Taller 2 – Asincronía y Procesamiento en Segundo Plano (Future, Timer, Isolate)
> **Implementación práctica y rigurosa de concurrencia en Flutter: Peticiones asíncronas I/O con Future y async/await, temporización periódica de precisión con Timer, y aislamiento de tareas pesadas CPU-bound con Isolate.spawn.**

### 👤 Datos del Estudiante y Entrega
- **Nombre Completo:** Samuel Alejandro Rincon Serna
- **Código Estudiantil:** 230231045
- **Institución:** Unidad Central del Valle del Cauca (UCEVA) — Tuluá, Valle
- **Asignatura:** Electiva Profesional 1 Móviles (Ingeniería de Sistemas)
- **Repositorio Oficial:** [https://github.com/Sarincon508/flowbiz](https://github.com/Sarincon508/flowbiz)
- **Ramas GitFlow:** `feature/taller_segundo_plano` ➔ Pull Request a `dev` ➔ Fusión a `main`
- **Documento PDF de Evidencias:** [Taller_Segundo_Plano_SamuelRincon.pdf](docs/Taller_Segundo_Plano_SamuelRincon.pdf) (Ubicado en Escritorio F: y en `docs/`)

---

### 📚 1. Cuándo Usar Future, async/await, Timer e Isolate en Flutter

Dart opera bajo un modelo de **Event Loop mono-hilo** (Single Threaded Event Loop). Comprender qué mecanismo aplicar según el tipo de carga computacional es vital para garantizar una tasa constante de 60/120 FPS sin congelamientos:

| Mecanismo | Naturaleza de la Carga | ¿Crea un Hilo Nuevo? | Cuándo Debe Utilizarse en Flutter |
| :--- | :--- | :---: | :--- |
| **`Future` & `async`/`await`** | **I/O-Bound** (Red, Disco, DB) | **No** (Espera no bloqueante en el mismo hilo) | Ideal para operaciones donde el procesador local espera una respuesta externa: consultas a APIs REST, peticiones HTTP, lecturas en SQLite/SharedPreferences y delays temporizados. Permite que el Event Loop continúe atendiendo gestos y animaciones. |
| **`Timer` & `Timer.periodic`** | **Temporización Programada** | **No** (Encola eventos en el Event Loop tras un delay) | Cronómetros, cuentas regresivas, debouncing de inputs de búsqueda, polling periódico a servidores y animaciones secuenciales. **Regla de oro:** Debe cancelarse siempre con `_timer?.cancel()` al pausar y en el método `dispose()` para evitar fugas de memoria. |
| **`Isolate` (`Isolate.spawn`)** | **CPU-Bound** (Cómputo Intensivo) | **Sí** (Crea un hilo nativo del SO con su propio Heap de memoria) | Procesamiento/compresión de imágenes y video, algoritmos criptográficos, parseo masivo de JSON (>5MB) o cálculos matemáticos complejos (>16 ms). Al ejecutarse en un espacio de memoria aislado, se comunica exclusivamente por paso de mensajes (`SendPort` / `ReceivePort`). |

---

### 🗺️ 2. Diagrama de Arquitectura y Flujos de Ejecución

```mermaid
flowchart TD
    subgraph UI_Thread ["🧵 Hilo Principal de Flutter (Main Thread / Event Loop)"]
        A["📱 Usuario Interactúa en UI"] --> B{"Selección de Módulo"}
        
        %% Flujo 1: Timer
        B -->|Módulo 1: Timer| C1["⏱️ Iniciar Timer.periodic(100ms)"]
        C1 --> C2["Refresco reactivo de dígitos en pantalla"]
        C2 --> C3["⏸️ Pausar: _timer.cancel() / Tiempo retenido"]
        C3 --> C4["↺ Reiniciar / Historial de Vueltas"]
        C2 --> C5["🧹 dispose(): Liberación estricta de memoria"]

        %% Flujo 2: Future & Async
        B -->|Módulo 2: Future| D1["⚡ Invocación con async/await"]
        D1 --> D2["1. [ANTES] Impreso en Consola"]
        D2 --> D3["⏳ Estado Cargando... + Spinner activo"]
        D3 --> D4["2. [DURANTE] Future.delayed(2.5s)"]
        D4 --> D5["🖱️ UI 100% Viva (Clicks interactivos sin bloqueo)"]
        D5 --> D6{"¿Simular Error?"}
        D6 -->|No| D7["3. [DESPUÉS - ÉXITO] Datos FlowBiz HTTP 200"]
        D6 -->|Sí| D8["3. [DESPUÉS - ERROR] Captura en bloque catch (e)"]

        %% Flujo 3: Isolate.spawn
        B -->|Módulo 3: Isolate| E1["🧠 Iniciar Cómputo CPU-Bound (30M ops)"]
        E1 --> E2["Creación de ReceivePort y SendPort"]
        E2 --> E3["🚀 Isolate.spawn() a hilo secundario"]
        E3 --> E4["Monitor UI: Engranaje gira a 60 FPS sin tirones"]
        E5["📥 Mensajes recibidos en ReceivePort"] --> E6["Actualización de barra de progreso (25%, 50%, 75%, 100%)"]
        E6 --> E7["🏁 Resultado recibido: Suma BigInt + Primos + Tiempo en ms"]
        E7 --> E8["🔒 Cierre de puertos y liberación del Isolate"]
    end

    subgraph Secondary_Isolate ["⚙️ Hilo Secundario Nativo (Worker Isolate - Heap Separado)"]
        E3 -.->|Spawn con SendPort| W1["Punto de Entrada: _heavyComputationWorker"]
        W1 --> W2["Bucle Intensivo de 30,000,000 iteraciones"]
        W2 --> W3["Cálculo de Sumatoria Ponderada + Primos"]
        W3 -.->|Reporte de Progreso| E5
        W3 --> W4["Finalización en cronómetro interno"]
        W4 -.->|Envío de resultado final vía SendPort| E5
    end
```

---

### 📸 3. Evidencias Visuales del Taller 2 en Emulador Android

#### Módulo 1: Cronómetro & Cuenta Regresiva (Timer)
| 1. Iniciar (En Ejecución) | 2. Pausar + Vueltas | 3. Reiniciar (En Reposo) | 4. Cuenta Regresiva (30s) |
| :---: | :---: | :---: | :---: |
| ![Cronómetro Iniciar](docs/screenshots_taller2/01_cronometro_iniciar.png) | ![Cronómetro Pausar](docs/screenshots_taller2/02_cronometro_pausar_vueltas.png) | ![Cronómetro Reiniciar](docs/screenshots_taller2/03_cronometro_reiniciar.png) | ![Cuenta Regresiva](docs/screenshots_taller2/04_cuenta_regresiva.png) |
| *Display LED activo, ticks cada 100ms* | *Timer.cancel() ejecutado, 3 vueltas registradas* | *Acumuladores reseteados a 00:00.0* | *Temporizador regresivo con alerta final* |

#### Módulo 2: Asincronía con Future y async/await
| 5. Estado Cargando (UI Viva) | 6. Estado Éxito (HTTP 200) | 7. Estado Error (try / catch) |
| :---: | :---: | :---: |
| ![Future Cargando](docs/screenshots_taller2/05_future_cargando.png) | ![Future Éxito](docs/screenshots_taller2/06_future_exito.png) | ![Future Error](docs/screenshots_taller2/07_future_error.png) |
| *CircularProgressIndicator + 8 clicks interactivos* | *Datos de FlowBiz recibidos en 2,514 ms* | *Excepción 503 controlada con reintento* |

#### Módulo 3: Procesamiento Pesado CPU-Bound con Isolate.spawn
| 8. Isolate en Proceso (Progreso 50%) | 9. Resultado Computado por el Isolate | 10. Consola del Sistema Completa |
| :---: | :---: | :---: |
| ![Isolate Progreso](docs/screenshots_taller2/08_isolate_en_proceso.png) | ![Isolate Resultado](docs/screenshots_taller2/09_isolate_resultado.png) | ![Consola Completa](docs/screenshots_taller2/10_consola_mensajes_completos.png) |
| *30M de operaciones en hilo separado, UI a 60 FPS* | *Suma BigInt, 13,848 primos en 1,782 ms* | *Trazas inter-hilos y orden 1-Antes, 2-Durante, 3-Después* |

---

### 💻 4. Verificación de la Salida en Consola (Orden de Ejecución)

```bash
# ==============================================================================
# SECCIÓN 1: SECUENCIA DE ASINCRONÍA (FUTURE / ASYNC / AWAIT)
# ==============================================================================
[ASYNC-ORDER] 1. [ANTES]: Invocando fetchReportData(). La UI permanece libre e interactiva (Event Loop no bloqueado).
[ASYNC-ORDER] 2. [DURANTE]: Esperando respuesta del servidor simulado mediante Future.delayed(2500 ms)...
[ASYNC-UI-TEST] Usuario presiona botón reactivo mientras espera: 8 clicks registrados a 60 FPS sin lag.
[ASYNC-ORDER] 3. [DESPUÉS - ÉXITO]: Respuesta recibida en 2514 ms. Datos parseados exitosamente. Actualizando estado en UI.

# Caso de Simulación de Error con try / catch:
[ASYNC-ORDER] 1. [ANTES]: Invocando fetchReportData(simulateError: true)...
[ASYNC-ORDER] 2. [DURANTE]: Esperando respuesta del servidor simulado con Future.delayed(2500 ms)...
[ASYNC-ORDER] 3. [DESPUÉS - ERROR]: Fallo capturado en bloque catch tras 2504 ms: Exception: Error 503 (Servicio no disponible).

# ==============================================================================
# SECCIÓN 2: CICLO DE VIDA DEL TIMER (CRONÓMETRO)
# ==============================================================================
[Timer] Timer iniciado a una frecuencia de 100ms. Estado: TimerStatus.running
[Timer] Vuelta registrada #1: 00:06.3 (Total: 00:06.3)
[Timer] Timer pausado. Tiempo retenido: 00:28.4 (Timer.cancel() ejecutado)
[Timer] Timer reanudado desde: 00:28.4
[Timer] Timer reiniciado a estado inicial. Acumuladores restablecidos a 0.

# ==============================================================================
# SECCIÓN 3: COMUNICACIÓN INTER-HILOS CON ISOLATE.SPAWN
# ==============================================================================
[ISOLATE-MAIN] 1. [Main Thread]: Creando ReceivePort para comunicación bidireccional.
[ISOLATE-MAIN] 2. [Main Thread]: Invocando Isolate.spawn() para crear un nuevo hilo de ejecución independiente...
[ISOLATE-MAIN] 3. [Main Thread]: Isolate creado y activo. La interfaz (UI) continúa corriendo a 60 FPS sin bloqueos.
[ISOLATE-WORKER] 1. Hilo secundario Isolate iniciado con su propio espacio de memoria (Heap separado).
[ISOLATE-WORKER] 2. Comenzando computación CPU-bound de 30,000,000 iteraciones (Sumatoria + Primos)...
[ISOLATE-WORKER] Progreso de cómputo emitido: 25% (7,500,000/30,000,000 operaciones)
[ISOLATE-WORKER] Progreso de cómputo emitido: 50% (15,000,000/30,000,000 operaciones)
[ISOLATE-WORKER] Progreso de cómputo emitido: 75% (22,500,000/30,000,000 operaciones)
[ISOLATE-WORKER] 3. Cómputo CPU finalizado en 1782 ms. Enviando resultado final al ReceivePort del hilo principal...
[ISOLATE-MAIN] 4. [Main Thread]: Cómputo recibido satisfactoriamente (Suma: 450000015000000, Primos: 13848, Tiempo: 1782ms).
[ISOLATE-MAIN] 5. Recursos de Isolate y ReceivePort liberados.
[LIFECYCLE] Recursos de Timer e Isolate liberados exitosamente en dispose().
```

---

## 📱 Taller 1 – Flutter + Widgets + Git Flow
> **Implementación práctica de StatefulWidget, reactividad con setState(), layouts con imágenes híbridas y gestión de control de versiones con Git Flow.**

### 👤 Datos del Estudiante
- **Nombre Completo:** Samuel Alejandro Rincon Serna
- **Código Estudiantil:** 230231045
- **Institución:** Unidad Central del Valle del Cauca (UCEVA) — Tuluá, Valle
- **Asignatura:** Electiva Profesional 1 Móviles (Ingeniería de Sistemas)
- **Repositorio:** [https://github.com/Sarincon508/flowbiz](https://github.com/Sarincon508/flowbiz)
- **Rama del Taller:** `feature/taller1` (integrada hacia `dev` y luego hacia `main`)

---

### 🚀 Instrucciones de Ejecución
Para clonar, preparar y ejecutar este proyecto en tu emulador o dispositivo físico Android:

```bash
# 1. Clonar el repositorio
git clone https://github.com/Sarincon508/flowbiz.git
cd flowbiz

# 2. Cambiar a la rama de desarrollo o del taller
git checkout dev

# 3. Descargar dependencias de Flutter
flutter pub get

# 4. Verificar dispositivos/emuladores activos
flutter devices

# 5. Ejecutar la aplicación en el emulador Android
flutter run
```

---

### 📸 Evidencias Visuales de la Aplicación en Emulador

| 1. Estado Inicial (`Hola, Flutter`) | 2. Estado Interactivo (`¡Título cambiado!` + SnackBar) | 3. Widgets Adicionales (Stack & ListView) |
| :---: | :---: | :---: |
| ![Estado Inicial](docs/screenshots/01_estado_inicial.png) | ![Estado Interactivo](docs/screenshots/02_titulo_cambiado_snackbar.png) | ![Widgets Adicionales](docs/screenshots/03_widgets_adicionales_scroll.png) |

---

### 🧩 Resumen Técnico de Widgets Implementados
1. **StatefulWidget & setState():** Control reactivo del título del `AppBar` (`_tituloAppBar`), alternando entre `"Hola, Flutter"` y `"¡Título cambiado!"` mediante un botón `ElevatedButton`.
2. **SnackBar Flotante:** Notificación en tiempo real (`ScaffoldMessenger.of(context).showSnackBar()`) con el mensaje `"Título actualizado"`.
3. **Galería de Imágenes en Row:**
   - `Image.network()`: Carga remota asíncrona con indicadores de progreso y manejo de excepciones con fallback.
   - `Image.asset()`: Renderizado de recurso local empaquetado (`assets/images/flutter_taller.png`).
4. **Widgets Adicionales:**
   - **`Container` decorativo:** Gradiente institucional UCEVA Navy (`#1B365D`), bordes redondeados (`BorderRadius.circular(16)`), sombras de elevación y badge del estudiante centrado.
   - **`Stack` interactivo:** Superposición multicapa de marcas de agua dinámicas, etiquetas flotantes y texto en tiempo real que refleja el estado de la variable `_tituloAppBar`.
   - **`ListView` con `ListTile`:** Lista estructurada de 4 módulos y competencias técnicas con iconos personalizados y tipografía jerárquica.
   - **`OutlinedButton`:** Acción secundaria para restablecer el estado inicial a valores por defecto.

---

## 📌 1. Descripción del Proyecto

**FlowBiz** es una solución móvil de gestión operativa y financiera concebida para cerrar la brecha entre el agendamiento de citas, el punto de venta (POS) y la auditoría contable en micro y pequeños comercios de servicios (barberías, estéticas, spas, consultorios médicos, restaurantes pequeños y talleres).

La aplicación resuelve de raíz los descuadres diarios de efectivo integrando:
- **Apertura de Día:** Registro formal del saldo base en efectivo.
- **Punto de Venta (POS):** Registro ágil de ventas directas de productos y servicios por catálogo.
- **Agenda Inteligente con Cobro Flexible:** Sincronización automática de citas terminadas hacia la caja del día, gestionando abonos parciales, saldos pendientes y notas de cobro extra.
- **Control de Egresos y Caja Menor:** Registro instantáneo de salidas de dinero con captura fotográfica de comprobantes.
- **Cierre de Jornada y Arqueo:** Conciliación matemática asistida (Base Inicial + Ingresos - Egresos vs Efectivo Físico) con detección automática de faltantes o sobrantes.
- **Dashboard Analítico:** Métricas de rendimiento, ganancias netas y cuentas por cobrar en tiempo real.

---

## 🛠️ 2. Stack Tecnológico

- **Framework:** Flutter (Single Codebase para Android e iOS)
- **Lenguaje:** Dart
- **Persistencia Local (Offline-First):** Drift (SQLite reactivo tipado) / Hive
- **Backend & Sincronización:** Supabase / Firebase BaaS
- **Gestión de Estado:** Flutter BLoC / Riverpod
- **Almacenamiento Seguro:** flutter_secure_storage (Cifrado de credenciales y tokens)

---

## 🤝 3. Reglas de Colaboración y Flujo de Trabajo

Dado que el proyecto es ejecutado por **un único desarrollador (Solo Developer)**, el flujo de desarrollo está optimizado para garantizar la máxima disciplina, trazabilidad y calidad sin introducir burocracias innecesarias. Se adopta una variante profesional de **GitHub Flow Adaptado con Auto-Revisión (Self-Review PR Flow)**.

### 3.1 Estructura de Ramas

1. **Rama Principal (main):**
   - Es la rama de producción y código estable.
   - **Queda estrictamente prohibido hacer git push directo sobre main**.
   - Solo recibe cambios a través de **Pull Requests (PR)** aprobados y verificados.
   - Cada fusión a main debe generar una versión etiquetada (git tag) semántica (ej. v1.0.0).

2. **Ramas de Trabajo Temporales (Feature/Fix Branches):**
   - Toda nueva tarea nace a partir de la última versión de main.
   - Nomenclatura obligatoria:
     - eat/<nombre-funcionalidad>: Para nuevas características (ej. feat/caja-arqueo, feat/agenda-citas).
     - ix/<identificador-bug>: Para corrección de fallos (ej. fix/descuadre-abonos).
     - 
efactor/<modulo>: Para mejoras de arquitectura o rendimiento sin alterar comportamiento (ej. refactor/drift-database).
     - docs/<tema>: Para documentación (ej. docs/api-specs).
     - 	est/<suite>: Para ampliación de pruebas unitarias o de integración.

### 3.2 Convención de Commits (Conventional Commits)

Los mensajes de commit deben seguir el estándar de Conventional Commits:
- eat: implementar arqueo de caja con deteccion automatica de diferencias
- ix: corregir precision de decimales en abonos de citas
- 
efactor: desacoplar logica de balance de caja del bloc de presentacion
- 	est: agregar casos de prueba para cierre de jornada con faltante
- docs: actualizar guia de arquitectura offline-first en README

### 3.3 Protocolo de Pull Request y Auto-Revisión (Self-Review)

Aun trabajando en solitario, el uso de Pull Requests es obligatorio como mecanismo de control de calidad:
1. **Creación del PR:** Toda rama de trabajo debe publicarse en GitHub y abrir un PR hacia main.
2. **Plantilla de PR Obligatoria:**
   - **Descripción del Cambio:** Qué resuelve y qué módulos toca.
   - **Checklist de Calidad:** Verificación de tipos sin coma flotante para dinero, widgets const, y paso del linter (flutter analyze).
   - **Evidencia Visual / Pruebas:** Captura de pantalla del cambio o salida exitosa de flutter test.
3. **Integración Continua (GitHub Actions CI):**
   - Ejecución automática de flutter analyze y flutter test.
   - El PR no puede fusionarse si hay pruebas fallidas o warnings de estilo.
4. **Estrategia de Fusión:** Squash and Merge para mantener un historial limpio y legible en la rama main.

### 3.4 Protección de Ramas (Branch Protection Rules)

La rama main cuenta con las siguientes reglas configuradas en GitHub:
- [x] **Require a pull request before merging:** Bloquea pushes directos a main.
- [x] **Require approvals:** Requiere al menos 1 revisión/aprobación formal del PR.
- [x] **Require status checks to pass before merging:** Obliga a que los workflows de CI pasen satisfactoriamente.
- [x] **Require conversation resolution before merging:** Todos los comentarios y notas de revisión deben marcarse como resueltos.
- [x] **Do not allow bypassing the above settings:** Aplica las restricciones incluso para el administrador del repositorio.

---

## 👤 Autor

- **Desarrollador:** Samuel Rincón
- **Usuario GitHub:** [@Sarincon508](https://github.com/Sarincon508)
- **Correo Institucional:** [samuel.rincon01@uceva.edu.co](mailto:samuel.rincon01@uceva.edu.co)
- **Institución:** Unidad Central del Valle del Cauca (UCEVA) — Tuluá, Colombia
- **Programa:** Facultad de Ingeniería — Ingeniería de Sistemas
- **Asignatura:** Desarrollo de Aplicaciones Móviles
