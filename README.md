# FlowPDF 📱
> **"Tus PDFs. Tu ritmo."**  
> Convierte documentos PDF en una experiencia de lectura cómoda, limpia y personalizable tipo eReader.

---

## 💡 Filosofía del Producto

1. **Reading First:** La lectura es lo más importante. La interfaz desaparece cuando estás leyendo.
2. **Cero Saturación:** Sin barras de navegación intrusivas durante la lectura; los controles aparecen al tocar el centro y desaparecen solos.
3. **Continuidad Instantánea:** Empezar a leer en menos de 3 segundos al abrir la app. Recuerda siempre el libro actual, posición exacta, modo y configuración.
4. **Modo Flow ⭐ (Diferencial Clave):** No más zoom molesto de documentos PDF a dos columnas. FlowPDF extrae y reorganiza el contenido adaptándolo fluidamente a la pantalla del móvil.
5. **Offline-First:** Colección, progreso, notas y marcadores persistentes 100% de forma local.

---

## 🗺️ Mapa de Navegación

```
                     FLOWPDF
                        │
          ┌─────────────┼─────────────┐
          │             │             │
        INICIO      BIBLIOTECA     AJUSTES
     (Continuar)     (Colección)  (Preferencias)
          │             │
          └──────┬──────┘
                 ▼
              LECTOR (Full screen, sin barra inferior)
                 │
          ┌──────┴──────┐
          ▼             ▼
       MODO PDF     MODO FLOW ⭐
    (Fiel original) (Texto fluido eReader)
          │             │
          └──────┬──────┘
                 ▼
          PANEL "Aa" / MENÚ
   (Tipografía, Margen, Sepia/Oscuro, Marcadores, Notas)
```

---

## 📱 Pantallas Principales

1. **🏠 Inicio (Home):**
   - Tarjeta destacada *Continuar Leyendo* (portada, título, progreso %, tiempo restante estimado y acceso en un toque).
   - Carrusel de lectura reciente y botón flotante/visible de importación rápida.
2. **📚 Biblioteca:**
   - Lista vertical optimizada para móviles (portada, título, autor, % leído, última lectura).
   - Filtros: *Todos*, *Recientes*, *En progreso*, *Terminados*.
   - Menú contextual al mantener pulsado: Abrir, Información, Marcadores, Notas, Compartir, Eliminar.
3. **📖 Lector Inmersivo:**
   - Modo pantalla completa con auto-hide de controles.
   - Alternancia instantánea entre **Modo PDF** (zoom/pinch libre) y **Modo FLOW** (texto adaptativo).
   - Hoja inferior de ajustes instantáneos (**Aa**): tamaño de fuente, tipografía (*Literata* / *Inter*), interlineado, márgenes y temas (*Claro*, *Papel/Sepia*, *Oscuro*, *AMOLED*).
   - Gestor de marcas 🔖 y notas de texto seleccionado.
4. **🔖 Marcadores & Notas:**
   - Vista agrupada por libro con salto directo a la posición exacta.
5. **⚙️ Ajustes:**
   - Preferencias de lectura globales, orden de biblioteca y datos de la app.

---

## 🧱 Arquitectura Modular

```
                FLOWPDF
                   │
        ┌──────────┴──────────┐
        │                     │
       UI                  CORE
        │                     │
   ┌────┼────┐          ┌─────┼─────┐
   │    │    │          │     │     │
 Inicio Biblio Lector   PDF  Texto FlowEngine
                         │     │     │
                         └─────┼─────┘
                               │
                          Persistencia
                               │
                          Base de Datos Local
```

---

## 🚀 Fases de Lanzamiento (Roadmap MVP)

- [ ] **V1.0 (MVP Esencial):**
  - Importación y validación de PDF local.
  - Generación de portadas y extracción de metadatos.
  - Biblioteca vertical con progreso persistente.
  - Lector PDF con controles que se ocultan al leer y gestos básicos.
  - Marcadores de página y modo Claro/Oscuro/Sepia.
- [ ] **V1.1 (Flow Mode Engine):**
  - Motor Flow: extracción de texto, limpieza de columnas y adaptación responsiva a pantalla móvil.
  - Selector tipográfico (Literata/Inter), tamaño e interlineado en tiempo real.
- [ ] **V1.2 (Anotaciones):**
  - Resaltados (Highlights) multicolores y notas al pie.
  - Tabla de contenidos (TOC) interactiva y búsqueda interna.
- [ ] **V2.0 (Futuro):**
  - Motor OCR para PDFs escaneados, estadísticas de hábitos de lectura y sincronización opcional.
