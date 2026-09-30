import os
import sys
import shutil
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable, Image
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """
    Canvas de doble pasada para calcular y mostrar el número total de páginas en el pie.
    Estilo institucional UCEVA.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        
        # Encabezado institucional superior
        self.setFont("Helvetica-Bold", 7.5)
        self.setFillColor(colors.HexColor("#1B365D"))
        self.drawString(38, 755, "UCEVA — FACULTAD DE INGENIERÍA | ELECTIVA PROFESIONAL 1 MÓVILES")
        self.setFont("Helvetica", 7.5)
        self.setFillColor(colors.HexColor("#555555"))
        self.drawRightString(612 - 38, 755, "Taller: Asincronía, Timer e Isolate en Flutter")

        self.setStrokeColor(colors.HexColor("#1B365D"))
        self.setLineWidth(1)
        self.line(38, 748, 612 - 38, 748)

        # Pie de página institucional inferior
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(38, 36, 612 - 38, 36)

        self.setFont("Helvetica", 7.5)
        self.setFillColor(colors.HexColor("#555555"))
        self.drawString(38, 25, "Estudiante: Samuel Alejandro Rincon Serna (230231045) — samuel.rincon01@uceva.edu.co")
        
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(612 - 38, 25, page_str)
        self.restoreState()


def build_taller2_pdf():
    desktop_pdf = r"F:\Users\Max\Desktop\Taller_Segundo_Plano_SamuelRincon.pdf"
    docs_pdf = r"F:\Users\Max\Desktop\moviles\flowbiz\docs\Taller_Segundo_Plano_SamuelRincon.pdf"
    screenshots_dir = r"F:\Users\Max\Desktop\moviles\flowbiz\docs\screenshots_taller2"

    doc = SimpleDocTemplate(
        desktop_pdf,
        pagesize=letter,
        leftMargin=38,
        rightMargin=38,
        topMargin=46,
        bottomMargin=44
    )

    styles = getSampleStyleSheet()

    # Paleta de colores profesional UCEVA
    c_primary = colors.HexColor("#1B365D")    # UCEVA Navy
    c_secondary = colors.HexColor("#0284C7")  # Cyan / Blue
    c_accent = colors.HexColor("#0F172A")     # Dark Slate
    c_dark = colors.HexColor("#1F2937")       # Text Grey Dark
    c_bg_light = colors.HexColor("#F8FAFC")   # Box Light Grey
    c_border = colors.HexColor("#CBD5E1")     # Border
    c_green = colors.HexColor("#166534")      # Green
    c_green_bg = colors.HexColor("#DCFCE7")   # Green Background
    c_red = colors.HexColor("#991B1B")        # Red
    c_red_bg = colors.HexColor("#FEE2E2")     # Red Background

    style_title = ParagraphStyle(
        'MainTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12.5,
        leading=15,
        textColor=c_primary,
        alignment=1,
        spaceAfter=2
    )

    style_subtitle = ParagraphStyle(
        'MainSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=10.5,
        textColor=c_secondary,
        alignment=1,
        spaceAfter=6
    )

    style_heading = ParagraphStyle(
        'HeadingSec',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=12,
        textColor=c_primary,
        spaceBefore=5,
        spaceAfter=3
    )

    style_subheading = ParagraphStyle(
        'SubHeadingSec',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11,
        textColor=c_accent,
        spaceBefore=3,
        spaceAfter=2
    )

    style_body = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.8,
        leading=10.5,
        textColor=c_dark,
        spaceAfter=3
    )

    style_body_bold = ParagraphStyle(
        'BodyDarkBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.8,
        leading=10.5,
        textColor=c_dark
    )

    style_code = ParagraphStyle(
        'CodeStyle',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7,
        leading=8.5,
        textColor=colors.HexColor("#0F172A")
    )

    style_table_cell = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.2,
        leading=9.5,
        textColor=c_dark
    )

    style_table_cell_bold = ParagraphStyle(
        'TableCellBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.2,
        leading=9.5,
        textColor=c_primary
    )

    story = []

    # =========================================================================
    # PÁGINA 1: PORTADA INSTITUCIONAL, FICHA TÉCNICA Y MARCO TEÓRICO
    # =========================================================================
    story.append(Paragraph("TALLER 2: ASINCRONÍA Y PROCESAMIENTO EN SEGUNDO PLANO", style_title))
    story.append(Paragraph("FUTURE, ASYNC/AWAIT, TIMER Y AISLAMIENTO DE CÓMPUTO INTENSIVO CON ISOLATE.SPAWN", style_subtitle))
    story.append(Spacer(1, 2))

    # Ficha Técnica con URL del Repositorio Destacada en la Primera Página
    info_data = [
        [
            Paragraph("<b>Institución:</b> Unidad Central del Valle del Cauca (UCEVA)", style_table_cell),
            Paragraph("<b>Asignatura:</b> Electiva Profesional 1 Móviles", style_table_cell)
        ],
        [
            Paragraph("<b>Estudiante:</b> Samuel Alejandro Rincon Serna", style_table_cell),
            Paragraph("<b>Código:</b> 230231045", style_table_cell)
        ],
        [
            Paragraph("<b>Repositorio GitHub:</b> <font color='#0284C7'><b><u>https://github.com/Sarincon508/flowbiz</u></b></font>", style_table_cell),
            Paragraph("<b>Ramas GitFlow:</b> <code>feature/taller_segundo_plano</code> ➔ <code>dev</code> ➔ <code>main</code>", style_table_cell)
        ],
        [
            Paragraph("<b>Entorno de Ejecución:</b> Android Pixel 7 (API 34) & Flutter 3.47 (Dart 3.13)", style_table_cell),
            Paragraph("<b>Fecha de Entrega:</b> 30 de Septiembre de 2026", style_table_cell)
        ]
    ]

    t_info = Table(info_data, colWidths=[268, 268])
    t_info.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), c_bg_light),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 7),
        ('RIGHTPADDING', (0,0), (-1,-1), 7),
    ]))
    story.append(t_info)
    story.append(Spacer(1, 6))

    # 1. OBJETIVO DEL TALLER
    story.append(Paragraph("1. Objetivo del Taller", style_heading))
    obj_text = (
        "Desarrollar una aplicación móvil profesional en Flutter que demuestre de manera práctica y rigurosa la gestión de "
        "concurrencia y segundo plano mediante: (1) <b>Asincronía con Future y async/await</b> para solicitudes I/O sin "
        "bloquear el hilo de usuario, evidenciando estados de <i>Cargando...</i>, <i>Éxito</i> y <i>Error</i> junto al orden "
        "estricto de ejecución en consola; (2) <b>Temporización reactiva con Timer</b> implementando un cronómetro/cuenta regresiva "
        "con controles (Iniciar, Pausar, Reanudar, Reiniciar, Vueltas) y limpieza estricta en <code>dispose()</code>; y (3) "
        "<b>Aislamiento de tareas pesadas CPU-bound con Isolate.spawn</b>, garantizando que una carga matemática de 30,000,000 "
        "de operaciones se procese en un hilo secundario independiente con memoria aislada, comunicándose por mensajes bidireccionales "
        "(<code>SendPort</code> / <code>ReceivePort</code>) mientras la UI mantiene una tasa de 60 FPS sin congelamientos."
    )
    story.append(Paragraph(obj_text, style_body))
    story.append(Spacer(1, 4))

    # 2. MARCO TEÓRICO COMPARATIVO
    story.append(Paragraph("2. Cuándo Usar Future, async/await, Timer e Isolate en Flutter", style_heading))
    theory_intro = (
        "Dart se rige por un modelo de ejecución basado en un <b>bucle de eventos (Event Loop) mono-hilo</b>. Para optimizar "
        "el rendimiento y evitar congelamientos de la interfaz gráfica, el desarrollador debe seleccionar la herramienta idónea:"
    )
    story.append(Paragraph(theory_intro, style_body))

    theory_table_data = [
        [
            Paragraph("<b>Mecanismo</b>", style_table_cell_bold),
            Paragraph("<b>Tipo de Carga</b>", style_table_cell_bold),
            Paragraph("<b>¿Crea Hilo Nuevo?</b>", style_table_cell_bold),
            Paragraph("<b>Cuándo Debe Utilizarse en Flutter</b>", style_table_cell_bold)
        ],
        [
            Paragraph("<b>Future & async/await</b>", style_table_cell_bold),
            Paragraph("Operaciones I/O bound (Red, Disco, Base de Datos)", style_table_cell),
            Paragraph("<b>No</b> (Mismo hilo principal, espera no bloqueante)", style_table_cell),
            Paragraph("Consultas a APIs REST, lecturas en SQLite/SharedPreferences, peticiones HTTP y timers diferidos donde el hilo principal queda libre para despachar eventos de interfaz.", style_table_cell)
        ],
        [
            Paragraph("<b>Timer & Timer.periodic</b>", style_table_cell_bold),
            Paragraph("Eventos programados por tiempo / temporizadores", style_table_cell),
            Paragraph("<b>No</b> (Encola eventos en el Event Loop tras un delay)", style_table_cell),
            Paragraph("Cronómetros, cuentas regresivas, debouncing de campos de búsqueda, polling periódico y animaciones ligeras. Requiere cancelación manual al pausar y en <code>dispose()</code>.", style_table_cell)
        ],
        [
            Paragraph("<b>Isolate (Isolate.spawn)</b>", style_table_cell_bold),
            Paragraph("Operaciones CPU-bound (Cómputo intensivo, hashing)", style_table_cell),
            Paragraph("<b>Sí</b> (Crea hilo nativo con Heap de memoria propio)", style_table_cell),
            Paragraph("Procesamiento de imágenes/video, cifrado criptográfico, compresión de archivos, parseo masivo de JSON (&gt;5MB) o algoritmos matemáticos pesados que congelarían la UI si se corrieran en el hilo principal.", style_table_cell)
        ]
    ]

    t_theory = Table(theory_table_data, colWidths=[90, 115, 105, 226])
    t_theory.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F1F5F9")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_theory)
    story.append(Spacer(1, 6))

    # 3. DIAGRAMA DE FLUJO Y PANTALLAS
    story.append(Paragraph("3. Arquitectura de Pantallas y Diagrama de Flujos de Ejecución", style_heading))
    arch_text = (
        "La aplicación se diseñó modularmente con una barra de navegación por pestañas (<code>TabBar</code>) y tres paneles especializados:<br/>"
        "• <b>Flujo 1 (Cronómetro / Timer):</b> Estado Inicial (00:00.0) ➔ <code>Iniciar</code> (dispara <code>Timer.periodic(100ms)</code>) ➔ "
        "Registro de vueltas ➔ <code>Pausar</code> (ejecuta <code>_timer.cancel()</code> y congela display) ➔ <code>Reanudar</code> / <code>Reiniciar</code>.<br/>"
        "• <b>Flujo 2 (Consulta Asíncrona):</b> Estado Inicial ➔ Disparo con <code>async/await</code> ➔ <i>1. ANTES (Consola)</i> ➔ Estado "
        "<i>Cargando...</i> (UI libre con clicks) ➔ <i>2. DURANTE (Consola)</i> ➔ <code>Future.delayed(2.5s)</code> ➔ Resolución en <i>3. DESPUÉS (Éxito u Error)</i>.<br/>"
        "• <b>Flujo 3 (Isolate CPU-bound):</b> UI ➔ Creación de <code>ReceivePort</code> ➔ Invocación de <code>Isolate.spawn()</code> ➔ "
        "Worker ejecuta 30M iteraciones en memoria aislada ➔ Emisión de progreso vía <code>SendPort</code> ➔ Recepción en UI sin perder frames a 60 FPS ➔ Cierre de puertos."
    )
    story.append(Paragraph(arch_text, style_body))

    story.append(PageBreak())

    # =========================================================================
    # PÁGINA 2: EVIDENCIAS MÓDULO 1 - TIMER (CRONÓMETRO Y CUENTA REGRESIVA)
    # =========================================================================
    story.append(Paragraph("4. Evidencias del Módulo 1: Cronómetro y Cuenta Regresiva con Timer", style_heading))
    story.append(Paragraph(
        "Se implementó un cronómetro de alta precisión con ticks periódicos cada 100 ms utilizando <code>Timer.periodic</code> de <code>dart:async</code>. "
        "Se garantiza el control de ciclo de vida para evitar fugas de memoria (memory leaks), cancelando el temporizador al pausar y en <code>dispose()</code>.",
        style_body
    ))
    story.append(Spacer(1, 4))

    img1 = os.path.join(screenshots_dir, "01_cronometro_iniciar.png")
    img2 = os.path.join(screenshots_dir, "02_cronometro_pausar_vueltas.png")
    img3 = os.path.join(screenshots_dir, "03_cronometro_reiniciar.png")
    img4 = os.path.join(screenshots_dir, "04_cuenta_regresiva.png")

    img_w = 126
    img_h = 272

    timer_table_data = [
        [
            Paragraph("<b>Figura 1: Iniciar (En Ejecución)</b>", style_table_cell_bold),
            Paragraph("<b>Figura 2: Pausar + Vueltas</b>", style_table_cell_bold),
            Paragraph("<b>Figura 3: Reiniciar (Reposo)</b>", style_table_cell_bold),
            Paragraph("<b>Figura 4: Cuenta Regresiva</b>", style_table_cell_bold)
        ],
        [
            Image(img1, width=img_w, height=img_h) if os.path.exists(img1) else Paragraph("N/A", style_body),
            Image(img2, width=img_w, height=img_h) if os.path.exists(img2) else Paragraph("N/A", style_body),
            Image(img3, width=img_w, height=img_h) if os.path.exists(img3) else Paragraph("N/A", style_body),
            Image(img4, width=img_w, height=img_h) if os.path.exists(img4) else Paragraph("N/A", style_body),
        ],
        [
            Paragraph("• Marcador LED: <code>00:14.7</code><br/>• Badge: <b>EN EJECUCIÓN</b>.<br/>• Botones <code>Pausar</code> y <code>Vuelta</code> activos.<br/>• Frecuencia: 100 ms continuos.", style_table_cell),
            Paragraph("• Marcador: <code>00:28.4</code>.<br/>• <b>Timer.cancel()</b> ejecutado.<br/>• Botones <code>Reanudar</code> y <code>Reiniciar</code>.<br/>• Historial con 3 vueltas parciales.", style_table_cell),
            Paragraph("• Marcador: <code>00:00.0</code>.<br/>• Estado: <b>EN REPOSO</b>.<br/>• Acumuladores en cero.<br/>• Memoria liberada y lista para nueva medición.", style_table_cell),
            Paragraph("• Modo regresivo desde 30s.<br/>• Tiempo actual: <code>00:18.2</code>.<br/>• Detención y SnackBar al llegar a cero (00:00.0).", style_table_cell),
        ]
    ]

    t_timer = Table(timer_table_data, colWidths=[134, 134, 134, 134])
    t_timer.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F1F5F9")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 4),
        ('RIGHTPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(t_timer)
    story.append(Spacer(1, 6))

    # Análisis técnico del Módulo 1
    timer_analysis = (
        "<b>Análisis Técnico del Módulo de Timer:</b><br/>"
        "1. <b>Instanciación y Ticks:</b> Se utiliza <code>_timer = Timer.periodic(const Duration(milliseconds: 100), (timer) { ... });</code>. "
        "Cada 10 décimas de segundo se recalcula el tiempo y se invoca <code>setState()</code> para refrescar el marcador digital.<br/>"
        "2. <b>Pausa Segura:</b> Al presionar <i>Pausar</i>, se ejecuta <code>_timer?.cancel(); _timer = null;</code>. La suscripción en el bucle "
        "de eventos se destruye de inmediato, reteniendo el valor acumulado en <code>_elapsedMilliseconds</code>.<br/>"
        "3. <b>Limpieza en dispose():</b> La clase <code>_TallerSegundoPlanoPageState</code> sobrescribe obligatoriamente <code>dispose()</code> "
        "ejecutando <code>_timer?.cancel()</code>. Esto previene fugas de memoria si el usuario navega fuera de la vista mientras el cronómetro corre."
    )
    story.append(Paragraph(timer_analysis, style_body))

    story.append(PageBreak())

    # =========================================================================
    # PÁGINA 3: EVIDENCIAS MÓDULO 2 - ASINCRONÍA CON FUTURE / ASYNC / AWAIT
    # =========================================================================
    story.append(Paragraph("5. Evidencias del Módulo 2: Asincronía con Future, async y await", style_heading))
    story.append(Paragraph(
        "Se diseñó el servicio <code>AsyncDataService</code> que simula la consulta remota a FlowBiz Cloud mediante <code>Future.delayed</code> "
        "(2 a 3 segundos). La función suspende de forma no bloqueante utilizando <code>async/await</code>, gestionando de forma reactiva los tres "
        "estados obligatorios: <b>Cargando...</b>, <b>Éxito</b> y <b>Error</b>, junto a la impresión estricta en consola del orden de ejecución.",
        style_body
    ))
    story.append(Spacer(1, 4))

    img5 = os.path.join(screenshots_dir, "05_future_cargando.png")
    img6 = os.path.join(screenshots_dir, "06_future_exito.png")
    img7 = os.path.join(screenshots_dir, "07_future_error.png")

    async_table_data = [
        [
            Paragraph("<b>Figura 5: Estado Cargando (UI Viva)</b>", style_table_cell_bold),
            Paragraph("<b>Figura 6: Estado Éxito (HTTP 200)</b>", style_table_cell_bold),
            Paragraph("<b>Figura 7: Estado Error (Captura en Catch)</b>", style_table_cell_bold)
        ],
        [
            Image(img5, width=170, height=360) if os.path.exists(img5) else Paragraph("N/A", style_body),
            Image(img6, width=170, height=360) if os.path.exists(img6) else Paragraph("N/A", style_body),
            Image(img7, width=170, height=360) if os.path.exists(img7) else Paragraph("N/A", style_body),
        ],
        [
            Paragraph(
                "• <code>CircularProgressIndicator</code> activo.<br/>"
                "• Retardo: <b>2.5 segundos</b>.<br/>"
                "• <b>Prueba de UI Viva:</b> 8 clicks registrados mientras se espera la respuesta (0 bloqueos).<br/>"
                "• Logs en terminal: <i>1. ANTES</i> y <i>2. DURANTE</i>.",
                style_table_cell
            ),
            Paragraph(
                "• Tarjeta verde de confirmación.<br/>"
                "• Latencia real: <b>2,514 ms</b>.<br/>"
                "• Datos procesados: Ventas <b>$1,845,000</b>, Flujo Neto <b>$1,425,000</b>, 18 citas.<br/>"
                "• Terminal: <i>3. DESPUÉS - ÉXITO</i>.",
                style_table_cell
            ),
            Paragraph(
                "• Switch 'Simular Fallo' activado.<br/>"
                "• Tarjeta roja de advertencia.<br/>"
                "• Captura controlada: <b>Exception: Error 503</b> tras 2,504 ms.<br/>"
                "• Botón <i>Reintentar Consulta</i> funcional.<br/>"
                "• Terminal: <i>3. DESPUÉS - ERROR</i>.",
                style_table_cell
            ),
        ]
    ]

    t_async = Table(async_table_data, colWidths=[178, 178, 178])
    t_async.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F1F5F9")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(t_async)
    story.append(Spacer(1, 6))

    # Análisis técnico del Módulo 2
    async_analysis = (
        "<b>Verificación del Orden de Ejecución en Consola (dart:developer / print):</b><br/>"
        "• <code>[ASYNC-ORDER] 1. [ANTES]:</code> Se imprime sincrónicamente antes de que la función se suspenda. La UI permanece interactiva.<br/>"
        "• <code>[ASYNC-ORDER] 2. [DURANTE]:</code> Se imprime al invocar <code>await Future.delayed(delay)</code>. Durante este lapso, el Event Loop atiende toques del usuario (ver contador de toques interactivo con 8 clicks sin retrasos).<br/>"
        "• <code>[ASYNC-ORDER] 3. [DESPUÉS]:</code> Si la operación finaliza normalmente, se deserializa el objeto <code>SimulatedReport</code> y se actualiza la interfaz con <code>setState()</code>. Si se activa el switch de error, se captura la excepción en el bloque <code>catch (e)</code> sin colapsar la app."
    )
    story.append(Paragraph(async_analysis, style_body))

    story.append(PageBreak())

    # =========================================================================
    # PÁGINA 4: EVIDENCIAS MÓDULO 3 - TAREA PESADA CON ISOLATE.SPAWN
    # =========================================================================
    story.append(Paragraph("6. Evidencias del Módulo 3: Procesamiento Pesado CPU-Bound con Isolate.spawn", style_heading))
    story.append(Paragraph(
        "Para cargas intensivas de CPU que degradarían la fluidez de la interfaz gráfica a 0 FPS, se implementó <code>IsolateHeavyService</code>. "
        "Mediante <code>Isolate.spawn</code> se instancia un worker en un hilo secundario con su propio espacio de memoria (Heap separado), comunicándose "
        "con el hilo principal exclusivamente a través de mensajes con <code>ReceivePort</code> y <code>SendPort</code>.",
        style_body
    ))
    story.append(Spacer(1, 4))

    img8 = os.path.join(screenshots_dir, "08_isolate_en_proceso.png")
    img9 = os.path.join(screenshots_dir, "09_isolate_resultado.png")

    isolate_table_data = [
        [
            Paragraph("<b>Figura 8: Isolate en Ejecución (Progreso 50% + UI Fluida)</b>", style_table_cell_bold),
            Paragraph("<b>Figura 9: Resultado Final Computado por el Isolate</b>", style_table_cell_bold)
        ],
        [
            Image(img8, width=220, height=440) if os.path.exists(img8) else Paragraph("N/A", style_body),
            Image(img9, width=220, height=440) if os.path.exists(img9) else Paragraph("N/A", style_body),
        ],
        [
            Paragraph(
                "• Carga seleccionada: <b>30 Millones de operaciones</b>.<br/>"
                "• Barra de progreso en tiempo real: <b>50% (15,000,000 ops)</b>.<br/>"
                "• <b>Monitor de Fluidez a 60 FPS:</b> El engranaje animado continuó girando a 60 FPS mientras el Isolate computaba a máxima potencia.<br/>"
                "• <b>Clicks interactivos:</b> 14 pulsaciones registradas instantáneamente.<br/>"
                "• Mensajes del hilo secundario recibidos en el <code>ReceivePort</code>.",
                style_table_cell
            ),
            Paragraph(
                "• Cómputo finalizado al <b>100%</b>.<br/>"
                "• Tiempo total transcurrido en segundo plano: <b>1,782 ms</b>.<br/>"
                "• <b>Sumatoria calculada:</b> <code>450,000,015,000,000</code>.<br/>"
                "• <b>Primos verificados:</b> <code>13,848</code> números primos.<br/>"
                "• Mensaje de finalización transferido por <code>SendPort</code>.<br/>"
                "• Cierre automático de puertos y liberación del Isolate.",
                style_table_cell
            ),
        ]
    ]

    t_iso = Table(isolate_table_data, colWidths=[268, 268])
    t_iso.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F1F5F9")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_iso)
    story.append(Spacer(1, 6))

    isolate_analysis = (
        "<b>Contraste Técnico: Isolate.spawn vs Hilo Principal (Main Thread):</b><br/>"
        "• <b>Con Isolate.spawn (Segundo Plano):</b> La tarea pesada corre en un hilo del sistema operativo con su propio recolector de basura. "
        "El hilo principal de Flutter queda 100% desocupado para seguir renderizando frames a 60/120 FPS y responder al instante a las interacciones del usuario.<br/>"
        "• <b>Sin Isolate (Ejecución Síncrona en Main Thread):</b> La aplicación incluye un botón comparativo. Al ejecutar la misma sumatoria de 30M en el hilo "
        "principal, la animación rotatoria del engranaje se <b>CONGELA por completo</b> durante 1.8 segundos y los toques de pantalla se descartan."
    )
    story.append(Paragraph(isolate_analysis, style_body))

    story.append(PageBreak())

    # =========================================================================
    # PÁGINA 5: CONSOLA DE EJECUCIÓN, FLUJO GIT FLOW Y CONCLUSIONES
    # =========================================================================
    story.append(Paragraph("7. Evidencia de Consola del Sistema y Depuración de Hilos", style_heading))
    story.append(Paragraph(
        "A continuación se documenta la captura de la consola oficial del sistema donde se verifica la salida estructurada de los mensajes "
        "inter-hilos del Isolate y el orden de ejecución asíncrono:",
        style_body
    ))
    story.append(Spacer(1, 2))

    img10 = os.path.join(screenshots_dir, "10_consola_mensajes_completos.png")
    if os.path.exists(img10):
        story.append(Image(img10, width=536, height=255))
    story.append(Spacer(1, 6))

    # 8. FLUJO GIT FLOW Y COMMITS
    story.append(Paragraph("8. Disciplina de Control de Versiones con Git Flow", style_heading))
    gitflow_text = (
        "El desarrollo del taller se rigió estrictamente por el modelo de ramificación <b>Git Flow</b> sobre el repositorio oficial de GitHub:<br/>"
        "1. <b>Rama Feature:</b> Se creó la rama <code>feature/taller_segundo_plano</code> a partir del estado limpio de <code>dev</code>.<br/>"
        "2. <b>Desarrollo e Implementación:</b> Se implementaron los modelos de datos, servicios (<code>AsyncDataService</code>, <code>IsolateHeavyService</code>), "
        "la pantalla interactiva con pestañas (<code>TallerSegundoPlanoPage</code>) y la suite de pruebas unitarias/widget automatizadas.<br/>"
        "3. <b>Pull Request & Merge a dev:</b> Se abrió la Pull Request desde <code>feature/taller_segundo_plano</code> hacia <code>dev</code>, integrando los cambios tras verificar pruebas exitosas.<br/>"
        "4. <b>Integración a main:</b> Los cambios estabilizados en <code>dev</code> se integraron hacia la rama <code>main</code>, manteniendo ambas ramas sincronizadas en el repositorio remoto de GitHub: "
        "<b>https://github.com/Sarincon508/flowbiz</b>."
    )
    story.append(Paragraph(gitflow_text, style_body))
    story.append(Spacer(1, 4))

    # 9. CONCLUSIONES
    story.append(Paragraph("9. Conclusiones Técnicas del Proyecto", style_heading))
    conclusions_text = (
        "• <b>Asincronía Efectiva:</b> <code>Future</code> y <code>async/await</code> son indispensables para operaciones I/O donde la espera no requiere cómputo del procesador local, permitiendo que la interfaz permanezca viva.<br/>"
        "• <b>Gestión Rigurosa de Recursos:</b> Todo temporizador instanciado con <code>Timer.periodic</code> debe ser cancelado explícitamente al pausar y en el método <code>dispose()</code> del State para prevenir fugas de memoria y consumo de batería en segundo plano.<br/>"
        "• <b>Aislamiento de Cómputo con Isolate:</b> Para cálculos pesados CPU-bound (&gt;16 ms de procesamiento continuo), el uso de <code>Isolate.spawn</code> con canales de mensajes (<code>ReceivePort</code> / <code>SendPort</code>) es el único mecanismo nativo en Dart que garantiza inmunidad total contra el congelamiento visual de la interfaz."
    )
    story.append(Paragraph(conclusions_text, style_body))

    # Compilar el documento PDF con NumberedCanvas
    doc.build(story, canvasmaker=NumberedCanvas)
    print("PDF successfully built at:", desktop_pdf, "Size:", os.path.getsize(desktop_pdf))

    # Copiar también a la carpeta docs del proyecto
    shutil.copyfile(desktop_pdf, docs_pdf)
    print("PDF copy saved at:", docs_pdf, "Size:", os.path.getsize(docs_pdf))


if __name__ == "__main__":
    build_taller2_pdf()
