import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable, Image
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """
    Two-pass canvas to dynamically compute and display total page count in the footer.
    Matches UCEVA institutional styling.
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
        
        # Header
        self.setFont("Helvetica-Bold", 7.5)
        self.setFillColor(colors.HexColor("#1B365D"))
        self.drawString(40, 755, "UCEVA — FACULTAD DE INGENIERÍA | ELECTIVA PROFESIONAL 1 MÓVILES")
        self.setFont("Helvetica", 7.5)
        self.setFillColor(colors.HexColor("#555555"))
        self.drawRightString(612 - 40, 755, "Taller 1: Flutter + Widgets + Git Flow")

        self.setStrokeColor(colors.HexColor("#1B365D"))
        self.setLineWidth(1)
        self.line(40, 748, 612 - 40, 748)

        # Footer
        self.setStrokeColor(colors.HexColor("#D1D5DB"))
        self.setLineWidth(0.5)
        self.line(40, 36, 612 - 40, 36)

        self.setFont("Helvetica", 7.5)
        self.setFillColor(colors.HexColor("#555555"))
        self.drawString(40, 25, "Estudiante: Samuel Alejandro Rincon Serna (230231045) — samuel.rincon01@uceva.edu.co")
        
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(612 - 40, 25, page_str)
        self.restoreState()


def build_taller1_pdf():
    pdf_filename = r"F:\Users\Max\Desktop\moviles\taller1-flutter+witgets+gitflow\Taller_1_Flutter_Widgets_GitFlow_SamuelRincon.pdf"
    screenshots_dir = r"F:\Users\Max\Desktop\moviles\taller1-flutter+witgets+gitflow\screenshots"
    
    doc = SimpleDocTemplate(
        pdf_filename,
        pagesize=letter,
        leftMargin=38,
        rightMargin=38,
        topMargin=46,
        bottomMargin=44
    )

    styles = getSampleStyleSheet()

    c_primary = colors.HexColor("#1B365D")    # UCEVA Navy
    c_secondary = colors.HexColor("#0284C7")  # Cyan / Blue
    c_accent = colors.HexColor("#0F172A")     # Dark Slate
    c_dark = colors.HexColor("#1F2937")       # Text Grey Dark
    c_bg_light = colors.HexColor("#F8FAFC")   # Box Light Grey
    c_border = colors.HexColor("#CBD5E1")     # Border
    c_green = colors.HexColor("#166534")      # Green Tag
    c_green_bg = colors.HexColor("#DCFCE7")   # Green Background

    style_title = ParagraphStyle(
        'MainTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=c_primary,
        alignment=1,
        spaceAfter=2
    )

    style_subtitle = ParagraphStyle(
        'MainSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=11,
        textColor=c_secondary,
        alignment=1,
        spaceAfter=8
    )

    style_heading = ParagraphStyle(
        'HeadingSec',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=12,
        textColor=c_primary,
        spaceBefore=6,
        spaceAfter=3
    )

    style_body = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=11,
        textColor=c_dark,
        spaceAfter=4
    )

    style_body_bold = ParagraphStyle(
        'BodyDarkBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=11,
        textColor=c_dark
    )

    style_code = ParagraphStyle(
        'CodeStyle',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7,
        leading=9,
        textColor=colors.HexColor("#0F172A")
    )

    style_table_cell = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=c_dark
    )

    style_table_cell_bold = ParagraphStyle(
        'TableCellBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10,
        textColor=c_primary
    )

    style_tag = ParagraphStyle(
        'TagStyle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7,
        leading=8,
        textColor=c_green,
        alignment=1
    )

    story = []

    # =========================================================================
    # ENCABEZADO Y PORTADA INSTITUCIONAL
    # =========================================================================
    story.append(Paragraph("TALLER 1: FLUTTER + WIDGETS + GIT FLOW", style_title))
    story.append(Paragraph("INFORME DE EVIDENCIAS TÉCNICAS, ARQUITECTURA REACTIVA Y CONTROL DE VERSIONES", style_subtitle))
    story.append(Spacer(1, 4))

    # Ficha técnica del estudiante y proyecto
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
            Paragraph("<b>Repositorio GitHub:</b> <font color='#0284C7'><u>https://github.com/Sarincon508/flowbiz</u></font>", style_table_cell),
            Paragraph("<b>Rama Taller:</b> <code>feature/taller1</code> (Integrada a <code>dev</code> y <code>main</code>)", style_table_cell)
        ],
        [
            Paragraph("<b>Entorno de Ejecución:</b> Android Emulator (Pixel 7 • API 34)", style_table_cell),
            Paragraph("<b>Fecha de Entrega:</b> 23 de Septiembre de 2026", style_table_cell)
        ]
    ]

    t_info = Table(info_data, colWidths=[268, 268])
    t_info.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), c_bg_light),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_info)
    story.append(Spacer(1, 8))

    # =========================================================================
    # SECCIÓN 1: OBJETIVO DEL TALLER
    # =========================================================================
    story.append(Paragraph("1. Objetivo del Taller", style_heading))
    obj_text = (
        "Construir una pantalla interactiva y profesional en Flutter implementando <b>StatefulWidget</b> y "
        "evidenciando la mutación reactiva de la interfaz mediante <b>setState()</b>. Asimismo, integrar buenas "
        "prácticas de desarrollo móvil incluyendo diseño jerárquico (Column, Row, Padding, SizedBox), renderizado "
        "híbrido de imágenes locales (<code>Image.asset()</code>) y remotas (<code>Image.network()</code>), retroalimentación "
        "inmediata al usuario con <b>SnackBar</b> flotante, e incorporación de widgets adicionales. Finalmente, aplicar "
        "una disciplina estricta de control de versiones basada en <b>Git Flow</b> sobre el repositorio oficial del curso en GitHub."
    )
    story.append(Paragraph(obj_text, style_body))
    story.append(Spacer(1, 6))

    # =========================================================================
    # SECCIÓN 2: EXPLICACIÓN TÉCNICA DE STATEFULWIDGET Y SETSTATE()
    # =========================================================================
    story.append(Paragraph("2. Fundamento de StatefulWidget y setState() en la Solución", style_heading))
    state_explanation = (
        "En Flutter, los widgets son inmutables por definición. Para gestionar componentes visuales cuyos datos cambian "
        "en respuesta a eventos del usuario o procesos asíncronos, se utiliza <b>StatefulWidget</b>, el cual delega su ciclo "
        "de vida y variables a una clase complementaria <b>State&lt;HomePage&gt;</b>.<br/>"
        "• <b>Variable de Estado:</b> Se definió <code>String _tituloAppBar = 'Hola, Flutter';</code> y <code>int _contadorCambios = 0;</code>.<br/>"
        "• <b>Método <code>setState()</code>:</b> Al presionar el botón <i>ElevatedButton</i>, se ejecuta <code>_alternarTitulo()</code>, "
        "envolviendo la actualización de las variables dentro de <code>setState(() { ... })</code>. Esto notifica formalmente al "
        "framework de Flutter que el estado interno ha mutado, desencadenando la ejecución eficiente de <code>build()</code> para "
        "reconstruir únicamente los subárboles de widgets dependientes (el título del AppBar, el texto sincronizado en el Stack y el badge)."
    )
    story.append(Paragraph(state_explanation, style_body))
    story.append(Spacer(1, 6))

    # =========================================================================
    # SECCIÓN 3: EVIDENCIAS DE CAPTURA EN EL EMULADOR ANDROID
    # =========================================================================
    story.append(Paragraph("3. Evidencias de Ejecución en Emulador Android (API 34)", style_heading))
    story.append(Paragraph(
        "A continuación se documentan las capturas de pantalla reales tomadas directamente desde el emulador activo "
        "(<code>emulator-5554</code>) utilizando la herramienta <code>adb screencap</code>:",
        style_body
    ))
    story.append(Spacer(1, 4))

    # Tabla con las dos capturas principales lado a lado
    img1_path = os.path.join(screenshots_dir, "01_estado_inicial.png")
    img2_path = os.path.join(screenshots_dir, "02_titulo_cambiado_snackbar.png")

    img_w = 170
    img_h = 377

    captures_table_data = [
        [
            Paragraph("<b>Figura 1: Estado Inicial de la App</b>", style_table_cell_bold),
            Paragraph("<b>Figura 2: Botón Presionado + setState() + SnackBar</b>", style_table_cell_bold)
        ],
        [
            Image(img1_path, width=img_w, height=img_h) if os.path.exists(img1_path) else Paragraph("Imagen no disponible", style_body),
            Image(img2_path, width=img_w, height=img_h) if os.path.exists(img2_path) else Paragraph("Imagen no disponible", style_body)
        ],
        [
            Paragraph(
                "• Título AppBar: <code>Hola, Flutter</code><br/>"
                "• Nombre de estudiante y código centrados.<br/>"
                "• Galería en Row: <code>Image.network()</code> (búho CDN) e <code>Image.asset()</code> (recurso local).<br/>"
                "• Botón listo para interacción.",
                style_table_cell
            ),
            Paragraph(
                "• Título AppBar mutado: <code>¡Título cambiado!</code><br/>"
                "• Contador de interacciones incrementado a 3.<br/>"
                "• <b>SnackBar flotante activo:</b> <i>'Título actualizado (Estado: ¡Título cambiado!)'</i>.<br/>"
                "• Stack sincronizado con el nuevo título.",
                style_table_cell
            )
        ]
    ]

    t_caps = Table(captures_table_data, colWidths=[268, 268])
    t_caps.setStyle(TableStyle([
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
    story.append(t_caps)

    story.append(PageBreak())

    # =========================================================================
    # SECCIÓN 4: WIDGETS ADICIONALES IMPLEMENTADOS
    # =========================================================================
    story.append(Paragraph("4. Evidencias y Análisis de Widgets Adicionales Implementados", style_heading))
    story.append(Paragraph(
        "El taller exigía incorporar al menos dos widgets adicionales de una lista selecta. En esta solución se diseñaron "
        "e implementaron con excelencia visual cuatro componentes fundamentales:",
        style_body
    ))
    story.append(Spacer(1, 4))

    img3_path = os.path.join(screenshots_dir, "03_widgets_adicionales_scroll.png")

    w_desc_text = (
        "<b>1. Container Estilizado:</b> Encabeza la interfaz con gradiente azul institucional UCEVA Navy (#1B365D a #0284C7), "
        "bordes redondeados (16px), sombras gaussianas de elevación, divisor interior y presentación centrada de los datos del estudiante.<br/><br/>"
        "<b>2. Stack (Superposición de Texto sobre Imagen):</b> Superpone sobre una imagen de fondo con filtro semitransparente "
        "una etiqueta superior ('STACK • TEXTO SUPERPUESTO SOBRE IMAGEN') y texto dinámico en la parte inferior "
        "que muta de forma inmediata al cambiar el título con setState(). Cumple fielmente con el requerimiento de la guía.<br/><br/>"
        "<b>3. ListView con ListTile:</b> Lista estructurada de 4 tarjetas informativas con scroll controlado, presentando las competencias "
        "del taller, cada una con icono distintivo en contenedor cromático, título jerárquico y descripción detallada.<br/><br/>"
        "<b>4. OutlinedButton:</b> Botón de acción secundaria con icono de reinicio para restablecer de inmediato el estado inicial "
        "a valores por defecto ('Hola, Flutter', interacciones: 0) acompañado de un SnackBar informativo."
    )

    widgets_table_data = [
        [
            Paragraph("<b>Figura 3: Widgets Adicionales (Stack, ListView, Botones)</b>", style_table_cell_bold),
            Paragraph("<b>Detalle Técnico de Implementación</b>", style_table_cell_bold)
        ],
        [
            Image(img3_path, width=165, height=366) if os.path.exists(img3_path) else Paragraph("Imagen no disponible", style_body),
            Paragraph(w_desc_text, style_body)
        ]
    ]

    t_widgets = Table(widgets_table_data, colWidths=[200, 336])
    t_widgets.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F1F5F9")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_widgets)
    story.append(Spacer(1, 8))

    # =========================================================================
    # SECCIÓN 5: EVIDENCIA DEL FLUJO GIT FLOW
    # =========================================================================
    story.append(Paragraph("5. Evidencia de Flujo de Ramas Git Flow", style_heading))
    git_text = (
        "El ciclo de vida del código fuente se gestionó íntegramente siguiendo el modelo profesional de Git Flow:<br/>"
        "1. <b>Rama <code>main</code>:</b> Rama estable de producción.<br/>"
        "2. <b>Rama <code>dev</code>:</b> Creada a partir de <code>main</code> para consolidar las fases de desarrollo.<br/>"
        "3. <b>Rama <code>feature/taller1</code>:</b> Rama de trabajo aislada nacida desde <code>dev</code>, donde se implementaron "
        "los commits atómicos del Taller 1 (StatefulWidget, imágenes, widgets adicionales, pruebas y documentación).<br/>"
        "4. <b>Pull Request e Integración:</b> Simulación de Pull Request con fusión de tipo non-fast-forward (<code>--no-ff</code>) "
        "de <code>feature/taller1</code> hacia <code>dev</code>, y posterior integración final de <code>dev</code> hacia <code>main</code>.<br/>"
        "5. <b>Verificación Remota:</b> Ambas ramas <code>dev</code> y <code>feature/taller1</code> se encuentran publicadas en GitHub. "
        "La rama <code>main</code> cuenta con reglas activas de Branch Protection que restringen pushes directos y exigen Pull Request."
    )
    story.append(Paragraph(git_text, style_body))
    story.append(Spacer(1, 4))

    # Árbol de commits Git
    git_tree_code = (
        "*   06e7fca (HEAD -> main) merge: release v1.0.0 integrating dev into main - Taller 1 Complete\n"
        "|\\  \n"
        "| * 7a9dd46 (dev, origin/dev) merge: pull request #1 from feature/taller1 into dev - Taller 1 Flutter Widgets & Git Flow\n"
        "|/| \n"
        "| * 2d0c7a1 (feature/taller1, origin/feature/taller1) docs(taller1): add Taller 1 execution steps and emulator screenshots\n"
        "| * cf9478f docs(taller1): add emulator screenshots and reference documentation\n"
        "| * 4f928b6 test(taller1): add widget tests verifying state updates and SnackBar display\n"
        "| * 8257c9d feat(taller1): implement HomePage with StatefulWidget, setState toggle and custom widgets\n"
        "|/  \n"
        "* 942120b (origin/main) feat: initial commit with project structure and collaboration rules"
    )

    t_git = Table([[Paragraph(f"<pre>{git_tree_code}</pre>", style_code)]], colWidths=[536])
    t_git.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#0F172A")),
        ('TEXTCOLOR', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_git)

    story.append(PageBreak())

    # =========================================================================
    # SECCIÓN 6: CÓDIGO FUENTE CLAVE (SETSTATE)
    # =========================================================================
    story.append(Paragraph("6. Extracto de Código Fuente: Gestión del Estado con setState()", style_heading))
    story.append(Paragraph(
        "A continuación se presenta el fragmento de código de <code>lib/screens/taller1_home_page.dart</code> donde "
        "se evidencia la manipulación del estado y la activación del SnackBar:",
        style_body
    ))
    story.append(Spacer(1, 4))

    code_snippet = (
        "class _HomePageState extends State&lt;HomePage&gt; {\n"
        "  String _tituloAppBar = 'Hola, Flutter';\n"
        "  int _contadorCambios = 0;\n"
        "\n"
        "  void _alternarTitulo() {\n"
        "    setState(() {\n"
        "      if (_tituloAppBar == 'Hola, Flutter') {\n"
        "        _tituloAppBar = '¡Título cambiado!';\n"
        "      } else {\n"
        "        _tituloAppBar = 'Hola, Flutter';\n"
        "      }\n"
        "      _contadorCambios++;\n"
        "    });\n"
        "\n"
        "    ScaffoldMessenger.of(context).hideCurrentSnackBar();\n"
        "    ScaffoldMessenger.of(context).showSnackBar(\n"
        "      SnackBar(\n"
        "        content: Text('Título actualizado (Estado: $_tituloAppBar)'),\n"
        "        backgroundColor: const Color(0xFF1B365D),\n"
        "        duration: const Duration(seconds: 2),\n"
        "        behavior: SnackBarBehavior.floating,\n"
        "      ),\n"
        "    );\n"
        "  }\n"
        "  ...\n"
        "}"
    )

    t_code = Table([[Paragraph(f"<pre>{code_snippet}</pre>", style_code)]], colWidths=[536])
    t_code.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_code)
    story.append(Spacer(1, 8))

    # =========================================================================
    # SECCIÓN 7: LISTA DE COMPROBACIÓN (CHECKLIST)
    # =========================================================================
    story.append(Paragraph("7. Lista de Comprobación y Verificación de Requisitos", style_heading))
    story.append(Paragraph(
        "Verificación formal de cada uno de los ítems requeridos en la guía del taller:",
        style_body
    ))
    story.append(Spacer(1, 4))

    checklist_items = [
        ("Repositorio público creado y accesible en GitHub", "https://github.com/Sarincon508/flowbiz", "CUMPLIDO"),
        ("Ramas main y dev configuradas según Git Flow", "main protegida y dev rama base", "CUMPLIDO"),
        ("feature/taller1 creada desde dev", "Desarrollo completo en rama de características", "CUMPLIDO"),
        ("StatefulWidget implementado", "HomePage hereda de StatefulWidget con clase State", "CUMPLIDO"),
        ("setState() implementado y funcional", "Alternancia de títulos y contador reactivo", "CUMPLIDO"),
        ("Image.network() implementado", "Carga desde CDN oficial de Flutter con fallbacks", "CUMPLIDO"),
        ("Image.asset() implementado", "Carga local desde assets/images/flutter_taller.png", "CUMPLIDO"),
        ("Mínimo 2 widgets adicionales implementados", "4 widgets: Container, Stack, ListView, OutlinedButton", "CUMPLIDO"),
        ("SnackBar funcionando", "Mensaje flotante: 'Título actualizado' al presionar botón", "CUMPLIDO"),
        ("README.md completado con instrucciones y capturas", "Documentación exhaustiva en repo y workspace", "CUMPLIDO"),
        ("PR feature/taller1 -> dev realizado", "Fusión no fast-forward con mensaje de Pull Request", "CUMPLIDO"),
        ("Integración dev -> main realizada", "Release consolidado en rama de producción", "CUMPLIDO"),
        ("PDF de evidencias preparado para entrega en Moodle", "Documento formal institucional UCEVA generado", "CUMPLIDO"),
    ]

    check_table_data = [
        [
            Paragraph("<b>Ítem de la Guía Oficial</b>", style_table_cell_bold),
            Paragraph("<b>Detalle de Cumplimiento Técnico</b>", style_table_cell_bold),
            Paragraph("<b>Estado</b>", style_tag)
        ]
    ]

    for item, det, st in checklist_items:
        check_table_data.append([
            Paragraph(f"☑ {item}", style_table_cell),
            Paragraph(det, style_table_cell),
            Paragraph(f"<b><font color='#166534'>{st}</font></b>", style_table_cell)
        ])

    t_check = Table(check_table_data, colWidths=[236, 230, 70])
    t_check.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#E2E8F0")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('ALIGN', (2,0), (2,-1), 'CENTER'),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_check)

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF successfully generated at: {pdf_filename}")

if __name__ == '__main__':
    build_taller1_pdf()
