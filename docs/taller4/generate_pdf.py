import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable, Image, PageBreak
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

def generate_pdf():
    pdf_path = r"F:\Users\Max\Desktop\moviles\taller 4\docs\entregable_taller.pdf"
    os.makedirs(os.path.dirname(pdf_path), exist_ok=True)

    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=32,
        bottomMargin=32
    )

    styles = getSampleStyleSheet()

    primary_color = colors.HexColor("#1E3A8A")
    secondary_color = colors.HexColor("#B45309")
    dark_text = colors.HexColor("#0F172A")
    muted_text = colors.HexColor("#475569")
    bg_light = colors.HexColor("#F8FAFC")

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=primary_color,
        spaceAfter=4
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=15,
        textColor=secondary_color,
        spaceAfter=6
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=primary_color,
        spaceBefore=10,
        spaceAfter=5
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=dark_text
    )

    caption_style = ParagraphStyle(
        'Caption_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=11,
        textColor=primary_color,
        alignment=1, # Center
        spaceBefore=3,
        spaceAfter=8
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.white
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=11,
        textColor=dark_text
    )

    code_style = ParagraphStyle(
        'CodeStyle',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7.5,
        leading=10,
        textColor=colors.HexColor("#1E293B")
    )

    story = []

    # Title & Header
    story.append(Paragraph("TALLER PRÁCTICO — DESARROLLO DE APLICACIONES MÓVILES", subtitle_style))
    story.append(Paragraph("🇨🇴 Datos Abiertos de Colombia (Flutter)", title_style))
    story.append(HRFlowable(width="100%", thickness=2.5, color=primary_color, spaceBefore=2, spaceAfter=8))

    # Metadata Box
    repo_url = "https://github.com/Sarincon508/-taller_datos_abiertos"
    flowbiz_url = "https://github.com/Sarincon508/flowbiz/tree/taller_4"
    main_url = f"{repo_url}/tree/main"
    dev_url = f"{repo_url}/tree/dev"
    feature_url = f"{repo_url}/tree/feature/taller_api_colombia"

    meta_data = [
        [Paragraph("<b>Estudiante / Autor:</b>", body_style), Paragraph("Samuel Rincón — Ingeniería de Sistemas (UCEVA)", body_style)],
        [
            Paragraph("<b>Repositorio Oficial:</b>", body_style),
            Paragraph(f'<a href="{repo_url}"><font color="#1E3A8A"><b><u>{repo_url}</u></b></font></a>', body_style)
        ],
        [
            Paragraph("<b>Ramas GitFlow (Verificables):</b>", body_style),
            Paragraph(
                f'<a href="{main_url}"><font color="#1E3A8A"><u>main</u></font></a> (estable) &nbsp;•&nbsp; '
                f'<a href="{dev_url}"><font color="#1E3A8A"><u>dev</u></font></a> (integración) &nbsp;•&nbsp; '
                f'<a href="{feature_url}"><font color="#1E3A8A"><u>feature/taller_api_colombia</u></font></a>',
                body_style
            )
        ],
        [
            Paragraph("<b>Repositorio Alterno:</b>", body_style),
            Paragraph(f'Proyecto Flowbiz: <a href="{flowbiz_url}"><font color="#1E3A8A"><u>flowbiz (rama taller_4)</u></font></a>', body_style)
        ],
        [Paragraph("<b>API Base Oficial:</b>", body_style), Paragraph('<a href="https://api-colombia.com/"><font color="#1E3A8A"><u>https://api-colombia.com/</u></font></a> (Swagger v1)', body_style)],
        [Paragraph("<b>Paquetes Implementados:</b>", body_style), Paragraph("<b>http</b> (^1.6.0) • <b>go_router</b> (^18.1.1) • <b>flutter_dotenv</b> (^6.0.1) • <b>intl</b> (^0.20.3)", body_style)],
    ]

    meta_table = Table(meta_data, colWidths=[140, 400])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), bg_light),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 8))

    # 1. Endpoints
    story.append(Paragraph("1. Endpoints de API Colombia Implementados (4 Recursos)", h1_style))
    story.append(Paragraph("Se implementó el ciclo completo de consumo HTTP (GET) con decodificación UTF-8, modelo con <code>fromJson</code> y navegación Maestro-Detalle:", body_style))
    story.append(Spacer(1, 4))

    endpoints_data = [
        [
            Paragraph("Recurso", table_header_style),
            Paragraph("Listado (GET)", table_header_style),
            Paragraph("Detalle (GET)", table_header_style),
            Paragraph("Datos Extraídos y Atributos Visualizados", table_header_style)
        ],
        [
            Paragraph("<b>1. Departamentos</b>", table_cell_style),
            Paragraph("/api/v1/Department", code_style),
            Paragraph("/api/v1/Department/{id}", code_style),
            Paragraph("32 departamentos con capital, población, superficie (km²), municipios y prefijo.", table_cell_style)
        ],
        [
            Paragraph("<b>2. Atracciones Turísticas</b>", table_cell_style),
            Paragraph("/api/v1/TouristicAttraction", code_style),
            Paragraph("/api/v1/TouristicAttraction/{id}", code_style),
            Paragraph("Parques naturales y monumentos con galería, ciudad y coordenadas geográficas.", table_cell_style)
        ],
        [
            Paragraph("<b>3. Presidentes</b>", table_cell_style),
            Paragraph("/api/v1/President", code_style),
            Paragraph("/api/v1/President/{id}", code_style),
            Paragraph("Mandatarios republicanos con retratos oficiales, periodos, afiliación y biografía.", table_cell_style)
        ],
        [
            Paragraph("<b>4. Platos Típicos</b>", table_cell_style),
            Paragraph("/api/v1/TypicalDish", code_style),
            Paragraph("/api/v1/TypicalDish/{id}", code_style),
            Paragraph("Gastronomía tradicional colombiana, fotografía, origen e ingredientes.", table_cell_style)
        ],
    ]

    endpoints_table = Table(endpoints_data, colWidths=[105, 120, 130, 185])
    endpoints_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), primary_color),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, bg_light]),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(endpoints_table)
    story.append(Spacer(1, 8))

    # 2. Arquitectura
    story.append(Paragraph("2. Arquitectura de Software y Separación por Capas", h1_style))
    story.append(Paragraph("Estructura conforme a las directrices de clase y buenas prácticas en Flutter:", body_style))
    story.append(Spacer(1, 4))

    arch_data = [
        [Paragraph("Capa", table_header_style), Paragraph("Directorio", table_header_style), Paragraph("Responsabilidad y Patrones", table_header_style)],
        [Paragraph("<b>Config</b>", table_cell_style), Paragraph("lib/config/", code_style), Paragraph("Variables de entorno (.env) con <code>flutter_dotenv</code> y clase <code>Environment</code>.", table_cell_style)],
        [Paragraph("<b>Models</b>", table_cell_style), Paragraph("lib/models/", code_style), Paragraph("Modelos fuertemente tipados con métodos <code>fromJson</code> y <code>toJson</code>.", table_cell_style)],
        [Paragraph("<b>Services</b>", table_cell_style), Paragraph("lib/services/", code_style), Paragraph("Cliente HTTP <code>ApiColombiaService</code>, control de excepciones (<code>ApiException</code>) y timeouts.", table_cell_style)],
        [Paragraph("<b>Routes</b>", table_cell_style), Paragraph("lib/routes/", code_style), Paragraph("Enrutamiento declarativo <code>go_router</code> con paso de parámetros (ID y objetos extra).", table_cell_style)],
        [Paragraph("<b>Themes</b>", table_cell_style), Paragraph("lib/themes/", code_style), Paragraph("Diseño Material 3 adaptativo con paleta tricolor nacional.", table_cell_style)],
        [Paragraph("<b>Views</b>", table_cell_style), Paragraph("lib/views/", code_style), Paragraph("Dashboard con 4 tarjetas de acceso rápido, 4 Listados con búsqueda y 4 Vistas Detalle.", table_cell_style)],
        [Paragraph("<b>Widgets</b>", table_cell_style), Paragraph("lib/widgets/", code_style), Paragraph("Componentes reutilizables: <code>LoadingView</code>, <code>ErrorView</code>, <code>EmptyView</code>, etc.", table_cell_style)],
    ]

    arch_table = Table(arch_data, colWidths=[70, 105, 365])
    arch_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), primary_color),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, bg_light]),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(arch_table)
    story.append(Spacer(1, 8))

    # 3. go_router
    story.append(Paragraph("3. Navegación con go_router (Rutas y Parámetros)", h1_style))
    routes_data = [
        [Paragraph("Nombre", table_header_style), Paragraph("Path", table_header_style), Paragraph("Parámetros", table_header_style), Paragraph("Vista Destino", table_header_style)],
        [Paragraph("dashboard", code_style), Paragraph("/", code_style), Paragraph("Ninguno", table_cell_style), Paragraph("DashboardView", table_cell_style)],
        [Paragraph("departments", code_style), Paragraph("/departments", code_style), Paragraph("Ninguno", table_cell_style), Paragraph("DepartmentsListView", table_cell_style)],
        [Paragraph("department-detail", code_style), Paragraph("/departments/:id", code_style), Paragraph(":id (int), extra: Department?", table_cell_style), Paragraph("DepartmentDetailView", table_cell_style)],
        [Paragraph("attractions", code_style), Paragraph("/attractions", code_style), Paragraph("Ninguno", table_cell_style), Paragraph("AttractionsListView", table_cell_style)],
        [Paragraph("attraction-detail", code_style), Paragraph("/attractions/:id", code_style), Paragraph(":id (int), extra: TouristicAttraction?", table_cell_style), Paragraph("AttractionDetailView", table_cell_style)],
        [Paragraph("presidents", code_style), Paragraph("/presidents", code_style), Paragraph("Ninguno", table_cell_style), Paragraph("PresidentsListView", table_cell_style)],
        [Paragraph("president-detail", code_style), Paragraph("/presidents/:id", code_style), Paragraph(":id (int), extra: President?", table_cell_style), Paragraph("PresidentDetailView", table_cell_style)],
        [Paragraph("typical-dishes", code_style), Paragraph("/typical-dishes", code_style), Paragraph("Ninguno", table_cell_style), Paragraph("TypicalDishesListView", table_cell_style)],
        [Paragraph("typical-dish-detail", code_style), Paragraph("/typical-dishes/:id", code_style), Paragraph(":id (int), extra: TypicalDish?", table_cell_style), Paragraph("TypicalDishDetailView", table_cell_style)],
    ]

    routes_table = Table(routes_data, colWidths=[105, 115, 160, 160])
    routes_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), primary_color),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, bg_light]),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(routes_table)

    # PAGE 2: Evidencias fotográficas (Capturas reales)
    story.append(PageBreak())
    story.append(Paragraph("4. Evidencias de Funcionamiento (Capturas en Android Emulator)", h1_style))
    story.append(Paragraph("A continuación se presentan las capturas reales obtenidas directamente de la ejecución en el emulador Android:", body_style))
    story.append(Spacer(1, 6))

    sc_dir = r"F:\Users\Max\Desktop\moviles\taller 4\docs\screenshots"
    img_w = 125
    img_h = 245

    def safe_img(name):
        p = os.path.join(sc_dir, name)
        if os.path.exists(p):
            return Image(p, width=img_w, height=img_h)
        return Paragraph("(Imagen no disponible)", body_style)

    # Grid 1: Dashboard, Departamentos Listado, Departamentos Detalle, Atracciones Listado
    row1 = [
        [safe_img("01_dashboard.png"), safe_img("02_departamentos_list.png"), safe_img("03_departamento_detalle.png"), safe_img("04_atracciones_list.png")],
        [
            Paragraph("<b>Dashboard Principal</b>", caption_style),
            Paragraph("<b>Listado Departamentos</b>", caption_style),
            Paragraph("<b>Detalle Departamento</b>", caption_style),
            Paragraph("<b>Listado Atracciones</b>", caption_style)
        ]
    ]

    grid1 = Table(row1, colWidths=[135, 135, 135, 135])
    grid1.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(grid1)
    story.append(Spacer(1, 8))

    # Grid 2: Atraccion Detalle, Presidentes Listado, Presidente Detalle, Platos Detalle
    row2 = [
        [safe_img("05_atraccion_detalle.png"), safe_img("06_presidentes_list.png"), safe_img("07_presidente_detalle.png"), safe_img("09_plato_tipico_detalle.png")],
        [
            Paragraph("<b>Detalle Atracción</b>", caption_style),
            Paragraph("<b>Listado Presidentes</b>", caption_style),
            Paragraph("<b>Detalle Presidente</b>", caption_style),
            Paragraph("<b>Detalle Plato Típico</b>", caption_style)
        ]
    ]

    grid2 = Table(row2, colWidths=[135, 135, 135, 135])
    grid2.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(grid2)
    story.append(Spacer(1, 6))

    # Summary footer
    story.append(Paragraph(
        "<b>Video de Demostración:</b> Incluido en el entregable como <code>video_demostracion.mp4</code> (7.47 MB), grabado a 60 fps mediante ADB demostrando la fluidez de navegación, estados de carga y búsqueda reactiva.<br/>"
        f"<b>Verificación en GitHub:</b> <a href=\"{repo_url}\"><font color=\"#1E3A8A\"><u>{repo_url}</u></font></a> con historial completo de commits GitFlow.",
        body_style
    ))

    doc.build(story)
    print("Enhanced PDF generated successfully at:", pdf_path)

if __name__ == "__main__":
    generate_pdf()
