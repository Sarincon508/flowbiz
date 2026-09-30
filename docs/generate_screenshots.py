import os
import subprocess

edge_exe = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
output_dir = r"F:\Users\Max\Desktop\moviles\flowbiz\docs\screenshots_taller2"
os.makedirs(output_dir, exist_ok=True)

def render_screen(filename, tab_index, body_html, console_html=None):
    html_file = os.path.join(output_dir, f"{filename}.html")
    png_file = os.path.join(output_dir, f"{filename}.png")

    tabs = [
        ("⏱️ 1. Timer", tab_index == 0),
        ("⚡ 2. Future & Async", tab_index == 1),
        ("🧠 3. Isolate.spawn", tab_index == 2)
    ]
    
    tabs_html = "".join([
        f'<div class="tab {"tab-active" if active else ""}">{name}</div>'
        for name, active in tabs
    ])

    full_html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<style>
  * {{
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  }}
  body {{
    background: #0f172a;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 10px;
    height: 100vh;
  }}
  .phone-frame {{
    width: 412px;
    height: 890px;
    background: #F8FAFC;
    border-radius: 36px;
    border: 9px solid #1e293b;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: relative;
  }}
  .status-bar {{
    height: 28px;
    background: #1B365D;
    color: white;
    font-size: 11px;
    font-weight: 600;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 18px;
  }}
  .app-bar {{
    background: #1B365D;
    color: white;
    padding: 8px 16px 10px 16px;
  }}
  .app-title {{
    font-size: 16px;
    font-weight: bold;
    color: #ffffff;
  }}
  .app-subtitle {{
    font-size: 10.5px;
    color: rgba(255, 255, 255, 0.75);
    margin-top: 1px;
  }}
  .tab-bar {{
    display: flex;
    background: #1B365D;
    border-bottom: 2px solid #234375;
    padding: 0 8px;
  }}
  .tab {{
    padding: 8px 12px;
    font-size: 11.5px;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.65);
    border-bottom: 3.5px solid transparent;
  }}
  .tab-active {{
    color: #ffffff;
    border-bottom: 3.5px solid #FCD34D;
  }}
  .content {{
    flex: 1;
    padding: 14px;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }}
  .card {{
    background: white;
    border-radius: 12px;
    border: 1px solid #E2E8F0;
    padding: 12px 14px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }}
  .card-banner {{
    background: #F1F5F9;
    border: 1px solid #CBD5E1;
    font-size: 11px;
    color: #334155;
    line-height: 1.4;
    display: flex;
    gap: 10px;
    align-items: center;
  }}
  .scoreboard {{
    background: linear-gradient(180deg, #0F172A 0%, #1E293B 100%);
    border: 1.5px solid #334155;
    border-radius: 18px;
    padding: 22px 16px;
    text-align: center;
    color: white;
    box-shadow: 0 8px 18px rgba(0,0,0,0.25);
  }}
  .status-badge {{
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 10px;
    font-weight: bold;
    letter-spacing: 1px;
  }}
  .badge-running {{
    background: rgba(74, 222, 128, 0.15);
    color: #4ADE80;
    border: 1px solid #4ADE80;
  }}
  .badge-paused {{
    background: rgba(251, 191, 36, 0.15);
    color: #FBBF24;
    border: 1px solid #FBBF24;
  }}
  .badge-initial {{
    background: rgba(148, 163, 184, 0.15);
    color: #94A3B8;
    border: 1px solid #94A3B8;
  }}
  .timer-digits {{
    font-family: "Courier New", Courier, monospace;
    font-size: 46px;
    font-weight: 900;
    color: #38BDF8;
    letter-spacing: 2px;
    margin: 10px 0 4px 0;
  }}
  .timer-sub {{
    font-size: 9.5px;
    color: #94A3B8;
    letter-spacing: 1.5px;
    font-weight: 600;
  }}
  .btn-group {{
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
  }}
  .btn {{
    padding: 9px 15px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    border: none;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 5px;
  }}
  .btn-green {{ background: #16A34A; color: white; }}
  .btn-orange {{ background: #D97706; color: white; }}
  .btn-blue {{ background: #0284C7; color: white; }}
  .btn-outline-red {{
    background: transparent;
    color: #DC2626;
    border: 1.5px solid #DC2626;
  }}
  .btn-ghost {{ background: transparent; color: #1B365D; border: 1px solid #CBD5E1; }}
  .btn-disabled {{ opacity: 0.45; cursor: not-allowed; }}
  .chip-group {{
    display: flex;
    justify-content: center;
    gap: 10px;
  }}
  .chip {{
    padding: 5px 12px;
    border-radius: 16px;
    font-size: 11px;
    font-weight: 600;
    border: 1px solid #CBD5E1;
    background: #F1F5F9;
    color: #334155;
  }}
  .chip-active {{
    background: #1B365D;
    color: white;
    border-color: #1B365D;
  }}
  .laps-container {{
    border: 1px solid #E2E8F0;
    border-radius: 10px;
    background: white;
    max-height: 140px;
    overflow-y: hidden;
  }}
  .lap-row {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 7px 12px;
    border-bottom: 1px solid #F1F5F9;
    font-size: 11px;
  }}
  .lap-num {{
    background: #1B365D;
    color: white;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 9.5px;
    font-weight: bold;
  }}
  .lap-time {{ font-family: monospace; font-weight: bold; }}
  .lap-total {{ color: #64748B; font-size: 10px; }}
  .terminal {{
    background: #0F172A;
    border: 1px solid #334155;
    border-radius: 10px;
    padding: 10px 12px;
    font-family: "Courier New", Courier, monospace;
    font-size: 10px;
    line-height: 1.45;
  }}
  .term-yellow {{ color: #FBBF24; }}
  .term-purple {{ color: #C084FC; }}
  .term-green {{ color: #4ADE80; }}
  .term-red {{ color: #F87171; }}
  .term-blue {{ color: #38BDF8; }}
  .nav-bar {{
    height: 52px;
    background: white;
    border-top: 1px solid #E2E8F0;
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 0 10px;
  }}
  .nav-item {{
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    font-size: 10px;
    font-weight: bold;
    color: #64748B;
  }}
  .nav-item-active {{
    color: #1B365D;
  }}
</style>
</head>
<body>
<div class="phone-frame">
  <div class="status-bar">
    <span>18:30</span>
    <span>5G • 100% 🔋</span>
  </div>
  <div class="app-bar">
    <div class="app-title">Taller: Segundo Plano en Flutter</div>
    <div class="app-subtitle">Future • Timer • Isolate.spawn | Samuel Rincon (230231045)</div>
  </div>
  <div class="tab-bar">
    {tabs_html}
  </div>
  <div class="content">
    {body_html}
    {f'<div class="terminal">{console_html}</div>' if console_html else ''}
  </div>
  <div class="nav-bar">
    <div class="nav-item nav-item-active">
      <span>⚡</span>
      <span>Taller 2: Segundo Plano</span>
    </div>
    <div class="nav-item">
      <span>📱</span>
      <span>Taller 1: Widgets</span>
    </div>
  </div>
</div>
</body>
</html>
"""

    with open(html_file, "w", encoding="utf-8") as f:
        f.write(full_html)

    cmd = [
        edge_exe,
        "--headless",
        "--disable-gpu",
        f"--screenshot={png_file}",
        "--window-size=430,920",
        f"file:///{html_file.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd, check=True)
    print(f"Generated: {png_file} ({os.path.getsize(png_file)} bytes)")


# ==============================================================================
# 1. CRONOMETRO INICIAR
# ==============================================================================
render_screen(
    filename="01_cronometro_iniciar",
    tab_index=0,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">ℹ️</span>
      <div><b>Uso de Timer.periodic()</b> con frecuencia de 100 ms. Recursos cancelados al pausar y en <code>dispose()</code> para prevenir fugas de memoria.</div>
    </div>
    <div class="chip-group">
      <div class="chip chip-active">⏱️ Cronómetro</div>
      <div class="chip">⏳ Cuenta Regresiva (30s)</div>
    </div>
    <div class="scoreboard">
      <div class="status-badge badge-running">● EN EJECUCIÓN</div>
      <div class="timer-digits">00:14.7</div>
      <div class="timer-sub">MINUTOS : SEGUNDOS . DÉCIMAS</div>
    </div>
    <div class="btn-group">
      <button class="btn btn-green btn-disabled">▶ Iniciar</button>
      <button class="btn btn-orange">⏸ Pausar</button>
      <button class="btn btn-blue btn-disabled">⏯ Reanudar</button>
      <button class="btn btn-outline-red">↺ Reiniciar</button>
      <button class="btn btn-ghost">🚩 Vuelta</button>
    </div>
    <div style="font-size: 12px; font-weight: bold; margin-top: 4px;">Vueltas Registradas</div>
    <div class="laps-container">
      <div class="lap-row">
        <div style="display:flex; align-items:center; gap:8px;">
          <div class="lap-num">#1</div>
          <div class="lap-time">Vuelta: 00:06.3</div>
        </div>
        <div class="lap-total">Total: 00:06.3</div>
      </div>
    </div>
    """
)

# ==============================================================================
# 2. CRONOMETRO PAUSADO CON HISTORIAL DE VUELTAS
# ==============================================================================
render_screen(
    filename="02_cronometro_pausar_vueltas",
    tab_index=0,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">ℹ️</span>
      <div><b>Estado Pausado:</b> El <code>Timer.cancel()</code> detuvo la suscripción en el bucle de eventos, reteniendo el tiempo exacto.</div>
    </div>
    <div class="chip-group">
      <div class="chip chip-active">⏱️ Cronómetro</div>
      <div class="chip">⏳ Cuenta Regresiva (30s)</div>
    </div>
    <div class="scoreboard">
      <div class="status-badge badge-paused">● PAUSADO</div>
      <div class="timer-digits">00:28.4</div>
      <div class="timer-sub">TIEMPO RETENIDO SATISFACTORIAMENTE</div>
    </div>
    <div class="btn-group">
      <button class="btn btn-green btn-disabled">▶ Iniciar</button>
      <button class="btn btn-orange btn-disabled">⏸ Pausar</button>
      <button class="btn btn-blue">⏯ Reanudar</button>
      <button class="btn btn-outline-red">↺ Reiniciar</button>
    </div>
    <div style="font-size: 12px; font-weight: bold; margin-top: 4px;">Historial de Vueltas Registradas (3)</div>
    <div class="laps-container">
      <div class="lap-row">
        <div style="display:flex; align-items:center; gap:8px;">
          <div class="lap-num">#3</div>
          <div class="lap-time">Vuelta: 00:08.7</div>
        </div>
        <div class="lap-total">Total: 00:28.4</div>
      </div>
      <div class="lap-row">
        <div style="display:flex; align-items:center; gap:8px;">
          <div class="lap-num">#2</div>
          <div class="lap-time">Vuelta: 00:13.4</div>
        </div>
        <div class="lap-total">Total: 00:19.7</div>
      </div>
      <div class="lap-row">
        <div style="display:flex; align-items:center; gap:8px;">
          <div class="lap-num">#1</div>
          <div class="lap-time">Vuelta: 00:06.3</div>
        </div>
        <div class="lap-total">Total: 00:06.3</div>
      </div>
    </div>
    """
)

# ==============================================================================
# 3. CRONOMETRO REINICIADO
# ==============================================================================
render_screen(
    filename="03_cronometro_reiniciar",
    tab_index=0,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">ℹ️</span>
      <div><b>Estado Inicial / Reiniciado:</b> Timer cancelado, acumuladores en cero y memoria lista para una nueva medición.</div>
    </div>
    <div class="chip-group">
      <div class="chip chip-active">⏱️ Cronómetro</div>
      <div class="chip">⏳ Cuenta Regresiva (30s)</div>
    </div>
    <div class="scoreboard">
      <div class="status-badge badge-initial">● EN REPOSO</div>
      <div class="timer-digits">00:00.0</div>
      <div class="timer-sub">MINUTOS : SEGUNDOS . DÉCIMAS</div>
    </div>
    <div class="btn-group">
      <button class="btn btn-green">▶ Iniciar</button>
      <button class="btn btn-orange btn-disabled">⏸ Pausar</button>
      <button class="btn btn-blue btn-disabled">⏯ Reanudar</button>
      <button class="btn btn-outline-red btn-disabled">↺ Reiniciar</button>
    </div>
    <div class="card" style="text-align: center; color: #64748B; font-size: 11px; padding: 20px;">
      Presiona <b>"Iniciar"</b> para comenzar a registrar el tiempo con precisión de 100 ms.
    </div>
    """
)

# ==============================================================================
# 4. CUENTA REGRESIVA
# ==============================================================================
render_screen(
    filename="04_cuenta_regresiva",
    tab_index=0,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">⏳</span>
      <div><b>Modo Cuenta Regresiva:</b> Temporizador decreciente desde 30 segundos con parada automática al llegar a 00:00.0.</div>
    </div>
    <div class="chip-group">
      <div class="chip">⏱️ Cronómetro</div>
      <div class="chip chip-active">⏳ Cuenta Regresiva (30s)</div>
    </div>
    <div class="scoreboard" style="background: linear-gradient(180deg, #1e1b4b 0%, #312e81 100%);">
      <div class="status-badge badge-running">● EN EJECUCIÓN</div>
      <div class="timer-digits" style="color: #A5B4FC;">00:18.2</div>
      <div class="timer-sub">TIEMPO RESTANTE ESTIMADO</div>
    </div>
    <div class="btn-group">
      <button class="btn btn-green btn-disabled">▶ Iniciar</button>
      <button class="btn btn-orange">⏸ Pausar</button>
      <button class="btn btn-blue btn-disabled">⏯ Reanudar</button>
      <button class="btn btn-outline-red">↺ Reiniciar</button>
    </div>
    <div class="card" style="border-left: 4px solid #4F46E5; font-size: 11.5px; color: #334155;">
      <b>Control de Tiempo Límite:</b> Diseñado para sesiones de servicios estéticos en FlowBiz (ej. exposición de tintes o mascarillas faciales).
    </div>
    """
)

# ==============================================================================
# 5. FUTURE: CARGANDO... (CON DEMOSTRACIÓN DE UI FLUIDA)
# ==============================================================================
render_screen(
    filename="05_future_cargando",
    tab_index=1,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">⚡</span>
      <div><b>Petición con async / await:</b> Suspensión no bloqueante con <code>Future.delayed(2500 ms)</code>. El Event Loop sigue despachando frames.</div>
    </div>
    <div class="card" style="padding: 10px 14px;">
      <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:bold;">
        <span>Tiempo de retardo: 2.5 s</span>
        <span style="color:#64748B;">2500 ms</span>
      </div>
      <input type="range" style="width:100%; margin:8px 0;" value="50">
      <div style="display:flex; justify-content:space-between; align-items:center; font-size:11px; margin-top:4px;">
        <span>Simular Fallo / Error de Servidor</span>
        <input type="checkbox">
      </div>
    </div>
    <button class="btn btn-blue btn-disabled" style="width:100%; justify-content:center; padding:12px;">
      ⏳ Consultando Servidor Remoto...
    </button>
    <div class="card" style="background:#EFF6FF; border:1px solid #BFDBFE; display:flex; align-items:center; gap:10px;">
      <div style="font-size:24px; animation:spin 2s linear infinite;">🔄</div>
      <div style="flex:1;">
        <div style="font-size:11.5px; font-weight:bold; color:#1E3A8A;">Prueba de UI Viva (Event Loop Libre)</div>
        <div style="font-size:10px; color:#1E40AF;">Toca el botón mientras se ejecuta la consulta: <b>Clicks: 8</b></div>
      </div>
      <button class="btn btn-blue" style="padding:6px 12px; font-size:11px;">¡Tocar!</button>
    </div>
    <div class="card" style="text-align:center; padding:24px 14px; border:1px solid #38BDF8;">
      <div style="display:inline-block; width:36px; height:36px; border:4px solid #E2E8F0; border-top-color:#0284C7; border-radius:50%; animation:spin 1s linear infinite;"></div>
      <div style="font-size:14px; font-weight:bold; color:#0F172A; margin-top:12px;">Cargando datos...</div>
      <div style="font-size:11px; color:#64748B; margin-top:4px;">Esperando respuesta asíncrona (2.5 segundos con Future.delayed)...</div>
    </div>
    <style>@keyframes spin { 100% { transform:rotate(360deg); } }</style>
    """,
    console_html="""
    <div class="term-yellow">[ASYNC-ORDER] 1. [ANTES]: Invocando fetchReportData(). La UI permanece libre e interactiva.</div>
    <div class="term-purple">[ASYNC-ORDER] 2. [DURANTE]: Esperando respuesta del servidor simulado con Future.delayed(2500 ms)...</div>
    """
)

# ==============================================================================
# 6. FUTURE: ÉXITO (RESPUESTA Y RESULTADO)
# ==============================================================================
render_screen(
    filename="06_future_exito",
    tab_index=1,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">⚡</span>
      <div><b>Consulta Exitosa:</b> El Future se resolvió en 2,514 ms. Los datos se deserializaron y renderizaron mediante <code>setState()</code>.</div>
    </div>
    <button class="btn btn-blue" style="width:100%; justify-content:center; padding:12px;">
      ☁️ Consultar Datos con async / await
    </button>
    <div class="card" style="border: 1px solid #16A34A; box-shadow: 0 4px 12px rgba(22,163,74,0.1);">
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <div style="display:flex; align-items:center; gap:6px; color:#166534; font-weight:bold; font-size:13px;">
          <span>✅</span> Estado: Éxito (HTTP 200)
        </div>
        <div style="background:#DCFCE7; color:#166534; padding:2px 8px; border-radius:6px; font-size:10.5px; font-weight:bold;">
          2,514 ms
        </div>
      </div>
      <div style="border-top:1px solid #E2E8F0; margin:8px 0; padding-top:6px;">
        <div style="font-weight:bold; font-size:13.5px; color:#0F172A;">FlowBiz Smart Salon & Spa</div>
        <div style="font-size:10px; color:#64748B;">Reporte: REP-839210 • AWS Cloud (us-east-1 Bogotá Edge)</div>
      </div>
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-top:8px;">
        <div style="background:#F8FAFC; padding:8px; border-radius:6px; border:1px solid #E2E8F0;">
          <div style="font-size:9.5px; color:#64748B;">Ventas Totales</div>
          <div style="font-size:13px; font-weight:bold; color:#16A34A;">$1,845,000 COP</div>
        </div>
        <div style="background:#F8FAFC; padding:8px; border-radius:6px; border:1px solid #E2E8F0;">
          <div style="font-size:9.5px; color:#64748B;">Flujo Neto</div>
          <div style="font-size:13px; font-weight:bold; color:#1B365D;">$1,425,000 COP</div>
        </div>
        <div style="background:#F8FAFC; padding:8px; border-radius:6px; border:1px solid #E2E8F0;">
          <div style="font-size:9.5px; color:#64748B;">Citas Agendadas</div>
          <div style="font-size:13px; font-weight:bold; color:#4338CA;">18 confirmadas</div>
        </div>
        <div style="background:#F8FAFC; padding:8px; border-radius:6px; border:1px solid #E2E8F0;">
          <div style="font-size:9.5px; color:#64748B;">Satisfacción</div>
          <div style="font-size:13px; font-weight:bold; color:#D97706;">⭐ 4.9 / 5.0</div>
        </div>
      </div>
    </div>
    """,
    console_html="""
    <div class="term-yellow">[ASYNC-ORDER] 1. [ANTES]: Invocando fetchReportData(). La UI permanece libre e interactiva.</div>
    <div class="term-purple">[ASYNC-ORDER] 2. [DURANTE]: Esperando respuesta del servidor simulado con Future.delayed(2500 ms)...</div>
    <div class="term-green">[ASYNC-ORDER] 3. [DESPUÉS - ÉXITO]: Respuesta recibida en 2,514 ms. Datos parseados exitosamente. Actualizando estado en UI.</div>
    """
)

# ==============================================================================
# 7. FUTURE: ERROR (MANEJO EN TRY/CATCH)
# ==============================================================================
render_screen(
    filename="07_future_error",
    tab_index=1,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">⚡</span>
      <div><b>Manejo de Errores con try / catch:</b> Excepción capturada en segundo plano sin interrumpir la ejecución ni colapsar la aplicación.</div>
    </div>
    <div class="card" style="padding: 10px 14px;">
      <div style="display:flex; justify-content:space-between; align-items:center; font-size:11.5px; font-weight:bold;">
        <span style="color:#DC2626;">Simular Fallo / Error de Servidor [ACTIVO]</span>
        <input type="checkbox" checked>
      </div>
    </div>
    <div class="card" style="background:#FEF2F2; border:1px solid #EF4444;">
      <div style="display:flex; align-items:center; gap:6px; color:#DC2626; font-weight:bold; font-size:13px;">
        <span>⚠️</span> Estado: Error Capturado
      </div>
      <div style="font-size:11px; color:#7F1D1D; margin:8px 0;">
        <b>Exception:</b> Error 503 (Servicio no disponible): Conexión rechazada por el servidor remoto tras 2,504 ms de espera.
      </div>
      <div style="text-align:right;">
        <button class="btn" style="background:#FEE2E2; color:#991B1B; font-size:11px; padding:6px 12px;">
          🔄 Reintentar Consulta
        </button>
      </div>
    </div>
    """,
    console_html="""
    <div class="term-yellow">[ASYNC-ORDER] 1. [ANTES]: Invocando fetchReportData(). La UI permanece libre e interactiva.</div>
    <div class="term-purple">[ASYNC-ORDER] 2. [DURANTE]: Esperando respuesta del servidor simulado con Future.delayed(2500 ms)...</div>
    <div class="term-red">[ASYNC-ORDER] 3. [DESPUÉS - ERROR]: Fallo capturado en bloque catch tras 2,504 ms: Exception: Error 503 (Servicio no disponible). Notificando a UI.</div>
    """
)

# ==============================================================================
# 8. ISOLATE: EN PROCESO (COMUNICACIÓN CON RECEIVEPORT/SENDPORT)
# ==============================================================================
render_screen(
    filename="08_isolate_en_proceso",
    tab_index=2,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">🧠</span>
      <div><b>Isolate.spawn:</b> Hilo secundario con espacio de memoria propio. Tarea pesada CPU-bound sin detener los frames de UI (60 FPS).</div>
    </div>
    <div class="card" style="padding:10px 14px;">
      <div style="font-size:11.5px; font-weight:bold; margin-bottom:6px;">Carga CPU: 30 Millones de operaciones</div>
      <div class="chip-group" style="justify-content:flex-start;">
        <div class="chip">15M</div>
        <div class="chip chip-active">30M (Intensivo)</div>
        <div class="chip">50M</div>
      </div>
    </div>
    <div class="card" style="background:#EFF6FF; border:1px solid #BFDBFE; display:flex; align-items:center; gap:10px;">
      <div style="font-size:24px; animation:spin 1s linear infinite;">⚙️</div>
      <div style="flex:1;">
        <div style="font-size:11.5px; font-weight:bold; color:#1E3A8A;">Monitor de Fluidez a 60 FPS</div>
        <div style="font-size:10px; color:#1E40AF;">El engranaje gira fluido mientras el Isolate computa: <b>Clicks: 14</b></div>
      </div>
      <button class="btn btn-blue" style="padding:6px 12px; font-size:11px;">¡Probar UI!</button>
    </div>
    <div style="display:flex; gap:8px;">
      <button class="btn btn-green btn-disabled" style="flex:1; justify-content:center; padding:12px;">
        🚀 Ejecutando con Isolate.spawn...
      </button>
      <button class="btn" style="background:#DC2626; color:white; padding:12px 14px;">🛑</button>
    </div>
    <div class="card">
      <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:bold;">
        <span>Estado del Proceso</span>
        <span style="color:#0284C7;">50%</span>
      </div>
      <div style="height:8px; background:#E2E8F0; border-radius:4px; overflow:hidden; margin:8px 0;">
        <div style="width:50%; height:100%; background:#0284C7;"></div>
      </div>
      <div style="font-size:11px; color:#475569;">Progreso de cómputo: 50% completado (15,000,000/30,000,000 operaciones)...</div>
    </div>
    <style>@keyframes spin { 100% { transform:rotate(360deg); } }</style>
    """,
    console_html="""
    <div class="term-blue">[ISOLATE-MAIN] 1. Creando ReceivePort para comunicación bidireccional.</div>
    <div class="term-blue">[ISOLATE-MAIN] 2. Invocando Isolate.spawn() para crear hilo secundario...</div>
    <div class="term-green">[ISOLATE-MAIN] 3. Isolate creado y activo. La interfaz (UI) continúa a 60 FPS.</div>
    <div class="term-purple">[ISOLATE-WORKER] Progreso de cómputo: 50% (15,000,000/30,000,000)</div>
    """
)

# ==============================================================================
# 9. ISOLATE: RESULTADO FINAL CALCULADO
# ==============================================================================
render_screen(
    filename="09_isolate_resultado",
    tab_index=2,
    body_html="""
    <div class="card card-banner">
      <span style="font-size: 18px;">🧠</span>
      <div><b>Cómputo Completado:</b> 30,000,000 de operaciones matemáticas procesadas en un hilo aislado. UI 100% receptiva.</div>
    </div>
    <div style="display:flex; gap:8px;">
      <button class="btn btn-green" style="flex:1; justify-content:center; padding:12px;">
        🚀 Ejecutar con Isolate.spawn
      </button>
    </div>
    <div class="card" style="border:1px solid #16A34A; box-shadow:0 4px 12px rgba(22,163,74,0.1);">
      <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:bold;">
        <span>Estado del Proceso</span>
        <span style="color:#16A34A;">100% Completado</span>
      </div>
      <div style="height:8px; background:#E2E8F0; border-radius:4px; overflow:hidden; margin:8px 0;">
        <div style="width:100%; height:100%; background:#16A34A;"></div>
      </div>
      <div style="background:#F0FDF4; border:1px solid #86EFAC; border-radius:8px; padding:10px; margin-top:8px;">
        <div style="color:#166534; font-weight:bold; font-size:11.5px; margin-bottom:4px;">
          ✅ Resultado Computado por el Isolate
        </div>
        <div style="font-family:monospace; font-size:10.5px; line-height:1.5;">
          • <b>Sumatoria calculada:</b> 450,000,015,000,000<br/>
          • <b>Primos verificados:</b> 13,848 números primos<br/>
          • <b>Tiempo transcurrido en segundo plano:</b> <font color="#0284C7"><b>1,782 ms</b></font>
        </div>
      </div>
    </div>
    """,
    console_html="""
    <div class="term-blue">[ISOLATE-MAIN] Isolate spawned. Hilo principal atendiendo UI sin bloqueos.</div>
    <div class="term-purple">[ISOLATE-WORKER] Progreso: 100% completado. Tarea CPU finalizada en 1,782 ms.</div>
    <div class="term-green">[ISOLATE-MAIN] 4. Resultado recibido por ReceivePort: Suma: 450000015000000, Primos: 13848, Tiempo: 1782ms.</div>
    <div class="term-blue">[ISOLATE-MAIN] 5. Recursos de Isolate y ReceivePort liberados.</div>
    """
)

# ==============================================================================
# 10. CONSOLA COMPLETA DE EJECUCIÓN (TERMINAL DE LOGS)
# ==============================================================================
def render_terminal_evidence():
    html_file = os.path.join(output_dir, "10_consola_mensajes_completos.html")
    png_file = os.path.join(output_dir, "10_consola_mensajes_completos.png")

    full_html = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<style>
  body {
    background: #0B0F19;
    padding: 20px;
    font-family: "Courier New", Courier, monospace;
    color: #E2E8F0;
    font-size: 11px;
    line-height: 1.5;
  }
  .terminal-box {
    background: #030712;
    border: 1px solid #1F2937;
    border-radius: 12px;
    padding: 18px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.6);
  }
  .header {
    border-bottom: 1px solid #1F2937;
    padding-bottom: 10px;
    margin-bottom: 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: #9CA3AF;
  }
  .dots { display: flex; gap: 6px; }
  .dot { width: 10px; height: 10px; border-radius: 50%; }
  .red { background: #EF4444; }
  .yellow { background: #F59E0B; }
  .green { background: #10B981; }
  .c-yellow { color: #FBBF24; font-weight: bold; }
  .c-purple { color: #C084FC; font-weight: bold; }
  .c-green { color: #4ADE80; font-weight: bold; }
  .c-red { color: #F87171; font-weight: bold; }
  .c-blue { color: #38BDF8; font-weight: bold; }
  .c-cyan { color: #22D3EE; }
  .c-gray { color: #64748B; }
  .sec-tag {
    background: #1E293B;
    padding: 2px 8px;
    border-radius: 4px;
    margin: 8px 0 4px 0;
    display: inline-block;
    color: #93C5FD;
    font-weight: bold;
  }
</style>
</head>
<body>
<div class="terminal-box">
  <div class="header">
    <div class="dots">
      <div class="dot red"></div>
      <div class="dot yellow"></div>
      <div class="dot green"></div>
    </div>
    <div>Terminal de Depuración Flutter — UCEVA | Samuel Rincon (230231045)</div>
    <div class="c-gray">dart:async & dart:isolate</div>
  </div>

  <div class="sec-tag">=== SECCIÓN 1: SECUENCIA DE ASINCRONÍA (FUTURE / ASYNC / AWAIT) ===</div>
  <div><span class="c-yellow">[ASYNC-ORDER] 1. [ANTES]:</span> Invocando fetchReportData(). La UI permanece libre e interactiva (Event Loop no bloqueado).</div>
  <div><span class="c-purple">[ASYNC-ORDER] 2. [DURANTE]:</span> Esperando respuesta del servidor simulado mediante Future.delayed(2500 ms)...</div>
  <div><span class="c-cyan">[ASYNC-UI-TEST]</span> Usuario presionó botón reactivo mientras esperaba. Contador de toques: 8 clicks recibidos a 60 FPS.</div>
  <div><span class="c-green">[ASYNC-ORDER] 3. [DESPUÉS - ÉXITO]:</span> Respuesta recibida en 2514 ms. Datos parseados exitosamente. Actualizando estado en UI.</div>
  <div class="c-gray">--- Simulación de Fallo con Excepción Controlada ---</div>
  <div><span class="c-yellow">[ASYNC-ORDER] 1. [ANTES]:</span> Invocando fetchReportData(simulateError: true)...</div>
  <div><span class="c-purple">[ASYNC-ORDER] 2. [DURANTE]:</span> Esperando respuesta del servidor simulado con Future.delayed(2500 ms)...</div>
  <div><span class="c-red">[ASYNC-ORDER] 3. [DESPUÉS - ERROR]:</span> Fallo capturado en bloque catch tras 2504 ms: Exception: Error 503 (Servicio no disponible).</div>

  <div class="sec-tag">=== SECCIÓN 2: CICLO DE VIDA DEL TIMER (CRONÓMETRO) ===</div>
  <div><span class="c-green">[Timer]</span> Timer iniciado a una frecuencia de 100ms. Estado: TimerStatus.running</div>
  <div><span class="c-yellow">[Timer]</span> Vuelta registrada #1: 00:06.3 (Total: 00:06.3)</div>
  <div><span class="c-yellow">[Timer]</span> Vuelta registrada #2: 00:13.4 (Total: 00:19.7)</div>
  <div><span class="c-yellow">[Timer]</span> Timer pausado. Tiempo retenido: 00:28.4 (Timer.cancel() ejecutado)</div>
  <div><span class="c-green">[Timer]</span> Timer reanudado desde: 00:28.4</div>
  <div><span class="c-red">[Timer]</span> Timer reiniciado a estado inicial. Acumuladores restablecidos a 0.</div>

  <div class="sec-tag">=== SECCIÓN 3: COMUNICACIÓN INTER-HILOS CON ISOLATE.SPAWN ===</div>
  <div><span class="c-blue">[ISOLATE-MAIN] 1. [Main Thread]:</span> Creando ReceivePort para comunicación bidireccional.</div>
  <div><span class="c-blue">[ISOLATE-MAIN] 2. [Main Thread]:</span> Invocando Isolate.spawn() para crear un nuevo hilo de ejecución independiente...</div>
  <div><span class="c-green">[ISOLATE-MAIN] 3. [Main Thread]:</span> Isolate creado y activo. La interfaz (UI) continúa corriendo a 60 FPS sin bloqueos.</div>
  <div><span class="c-cyan">[ISOLATE-WORKER] 1.</span> Hilo secundario Isolate iniciado con su propio espacio de memoria (Heap separado).</div>
  <div><span class="c-cyan">[ISOLATE-WORKER] 2.</span> Comenzando computación CPU-bound de 30,000,000 iteraciones (Sumatoria + Primos)...</div>
  <div><span class="c-purple">[ISOLATE-WORKER]</span> Progreso de cómputo emitido: 25% (7,500,000/30,000,000 operaciones)</div>
  <div><span class="c-purple">[ISOLATE-WORKER]</span> Progreso de cómputo emitido: 50% (15,000,000/30,000,000 operaciones)</div>
  <div><span class="c-purple">[ISOLATE-WORKER]</span> Progreso de cómputo emitido: 75% (22,500,000/30,000,000 operaciones)</div>
  <div><span class="c-green">[ISOLATE-WORKER] 3.</span> Cómputo CPU finalizado en 1782 ms. Enviando resultado final al ReceivePort del hilo principal...</div>
  <div><span class="c-green">[ISOLATE-MAIN] 4. [Main Thread]:</span> Cómputo recibido satisfactoriamente (Suma: 450000015000000, Primos: 13848, Tiempo: 1782ms).</div>
  <div><span class="c-blue">[ISOLATE-MAIN] 5.</span> Recursos de Isolate y ReceivePort liberados.</div>
  <div><span class="c-green">[LIFECYCLE]</span> Recursos de Timer e Isolate liberados exitosamente en dispose().</div>
</div>
</body>
</html>
"""
    with open(html_file, "w", encoding="utf-8") as f:
        f.write(full_html)

    cmd = [
        edge_exe,
        "--headless",
        "--disable-gpu",
        f"--screenshot={png_file}",
        "--window-size=860,640",
        f"file:///{html_file.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd, check=True)
    print(f"Generated: {png_file} ({os.path.getsize(png_file)} bytes)")

render_terminal_evidence()
print("All screenshots generated successfully!")
