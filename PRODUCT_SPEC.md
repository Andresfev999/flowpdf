# FLOWPDF — Especificación Detallada de Producto

## 1. Concepto y Filosofía

- **Nombre:** FlowPDF
- **Slogan:** *"Tus PDFs. Tu ritmo."*
- **Categoría:** Aplicación móvil de lectura y biblioteca personal de PDFs (eReader experience).
- **Diferenciador Clave:** **Modo Flow ⭐** — reorganiza el texto de los PDFs para que fluya con el ancho de la pantalla del smartphone sin necesidad de zoom horizontal continuo ni desbordamiento de columnas.

### Principios UX
1. **Reading first:** La lectura es prioritaria.
2. **Cero saturación:** Los controles aparecen solo bajo demanda (tap central) y desaparecen automáticamente al leer.
3. **Continuidad:** La app recuerda siempre el libro, página, scroll offset, modo de lectura y ajustes visuales. El usuario debe poder retomar la lectura en menos de 3 segundos tras abrir la app.
4. **Personalización:** Modificaciones tipográficas, de margen y de tema aplicadas en tiempo real sin recargar la vista.
5. **Offline-first:** Todo el contenido, índices, notas y progreso se guardan en base de datos local.

---

## 2. Flujo de Navegación y Vistas

### Navegación Inferior (Bottom Bar)
Presente únicamente en las vistas principales (se oculta completamente dentro del Lector):
- 🏠 **Inicio (Home)**
- 📚 **Biblioteca**
- 🔖 **Marcadores**
- ⚙️ **Configuración**

### 2.1 Vista Inicio (Home)
- **Tarjeta "Continuar Leyendo":**
  - Muestra la portada, título, autor, porcentaje completado (`67%`), barra de progreso visual, capítulo actual y tiempo estimado restante (`≈ 24 min restantes`).
  - Botón directo `[ Continuar leyendo ]`.
- **Mis Libros / Recientes:**
  - Carrusel horizontal con las portadas de los últimos libros abiertos.
- **Estado Vacío (Empty State):**
  - Ilustración y mensaje: *"Tu biblioteca comienza aquí. Importa tu primer PDF y empieza a leer."*
  - Botón prominente `[ + Importar PDF ]`.

### 2.2 Importación de PDF
- Accesible desde Inicio, Biblioteca y mediante compartir archivo desde otras apps.
- **Pipeline de procesamiento reactivo:**
  1. Selección de archivo local (`.pdf`).
  2. Validación y verificación de integridad.
  3. Extracción de metadatos (Título, Autor, Conteo de páginas).
  4. Generación y almacenamiento de miniatura de portada (página 1).
  5. Extracción y análisis estructural de texto para el *Flow Engine*.
  6. Guardado en base de datos local y apertura inmediata o redirección a biblioteca.
- Barra de progreso interactiva durante la carga (*"Analizando libro... 82%"*).

### 2.3 Vista Biblioteca
- Lista vertical optimizada para pantallas móviles.
- Filtros por pestañas: `[Todos]` | `[Recientes]` | `[En progreso]` | `[Terminados]`.
- Cada elemento muestra: miniatura de portada, título, autor, barra de progreso (`%`) y fecha de última lectura.
- **Acciones táctiles:**
  - *Tap corto:* Abrir detalle del libro o reanudar lectura directa.
  - *Long press:* Menú modal de opciones (Continuar, Información, Marcadores, Notas, Compartir, Eliminar).

### 2.4 Vista Lector (Reader)
- **Modo Inmersivo:** Pantalla completa sin barra de navegación inferior.
- **Modos de Lectura:**
  - **Modo PDF:** Renderizado fiel del documento original, con soporte para pinch-to-zoom y doble tap.
  - **Modo FLOW ⭐:** El texto se extrae, se limpia de saltos de línea duros y formateo de dos columnas, adaptándose al ancho exacto del dispositivo como un eReader nativo.
- **Controles Emergentes (Tap central):**
  - *Barra superior:* Botón volver `←`, Título del libro, Marcador directo `🔖`, Menú `⋮`.
  - *Barra inferior:* Indicador de página (`124 / 421`) y barra deslizante de progreso, botón de Ajustes de Lectura `Aa`, controles de navegación rápida `◀` `▶`, y tabla de contenidos `☰`.
  - Los controles se desvanecen automáticamente tras inactividad o al comenzar a deslizar.
- **Panel de Ajustes de Lectura ("Aa" Bottom Sheet):**
  - Control de tamaño de fuente (`A ────●──── A`).
  - Selector de fuente: **Literata** (estilo libro editorial) / **Inter** (estilo moderno).
  - Control de interlineado y márgenes laterales.
  - Selector de Tema: **Claro** (blanco cálido), **Papel/Sepia** (crema descansado), **Oscuro** (gris carbón `#101014`), **AMOLED** (negro puro `#000000`).
  - *Feedback instantáneo:* La vista de lectura actualiza su estilo dinámicamente mientras el usuario mueve los controles.
- **Interacciones Táctiles y Gestos:**
  - *Tap central:* Alternar barra de herramientas.
  - *Swipe lateral:* Pasar a página/sección siguiente o anterior.
  - *Long-press en texto:* Barra de herramientas contextual (`Copiar`, `Resaltar` con selector de color, `Añadir Nota`, `Compartir`).

### 2.5 Marcadores y Notas
- Panel organizado por libro con listado cronológico de páginas marcadas y fragmentos citados.
- Salto directo a la página y offset exacto al hacer tap.

---

## 3. Modelo de Datos Local

```sql
-- Libros
CREATE TABLE books (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT,
    file_path TEXT NOT NULL,
    cover_path TEXT,
    total_pages INTEGER NOT NULL,
    current_page INTEGER DEFAULT 1,
    progress REAL DEFAULT 0.0,
    last_read_at INTEGER,
    created_at INTEGER NOT NULL
);

-- Ajustes por libro / usuario
CREATE TABLE reading_settings (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL,
    font_family TEXT DEFAULT 'Literata',
    font_size REAL DEFAULT 16.0,
    line_height REAL DEFAULT 1.5,
    margin REAL DEFAULT 16.0,
    theme TEXT DEFAULT 'dark', -- light, paper, dark, amoled
    reading_mode TEXT DEFAULT 'flow', -- pdf, flow
    FOREIGN KEY(book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- Marcadores
CREATE TABLE bookmarks (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL,
    page INTEGER NOT NULL,
    position REAL,
    title TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- Resaltados (Highlights)
CREATE TABLE highlights (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL,
    page INTEGER NOT NULL,
    text TEXT NOT NULL,
    start_position INTEGER,
    end_position INTEGER,
    color TEXT DEFAULT '#FFD54F',
    created_at INTEGER NOT NULL,
    FOREIGN KEY(book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- Notas
CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL,
    page INTEGER NOT NULL,
    selected_text TEXT,
    content TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(book_id) REFERENCES books(id) ON DELETE CASCADE
);
```

---

## 4. Guía de Identidad y Estilo Visual

- **Paleta de Colores de la App:**
  - `Primary / Brand`: `#6C63FF` (Morado suave, reservado para acentos y estados activos).
  - `Background`: `#F7F7F8` (Modo claro) / `#101014` (Modo oscuro).
  - `Surface`: `#FFFFFF` (Modo claro) / `#18181B` (Modo oscuro).
  - `Text Primary`: `#18181B` (Modo claro) / `#F4F4F5` (Modo oscuro).
  - `Text Secondary`: `#71717A`.
- **Temas del Lector:**
  - *Claro:* Fondo `#FAFAFA`, Texto `#18181B`.
  - *Papel / Sepia:* Fondo `#F5EFEB`, Texto `#3E2723`.
  - *Oscuro:* Fondo `#18181B`, Texto `#E4E4E7`.
  - *AMOLED:* Fondo `#000000`, Texto `#D4D4D8`.
- **Tipografías:**
  - *Inter:* UI, navegación, botones, listas y configuración.
  - *Literata:* Cuerpo de lectura en Modo Flow y títulos de capítulos.
