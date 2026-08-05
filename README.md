content = """# BetterMe

**BetterMe** es una aplicación móvil integral de fitness y nutrición, desarrollada en Flutter. Su núcleo tecnológico se basa en una arquitectura *offline-first* utilizando SQLite, respaldada por **Supabase** para la sincronización en la nube, y potenciada por **Inteligencia Artificial (Gemini)** para la generación de planes altamente personalizados.

---

## Características Principales

*   **Planes Generados por IA:** Creación de rutinas de entrenamiento y dietas 100% personalizadas basadas en la biometría del usuario, objetivos, alergias y preferencias.
*   **Sincronización en la Nube (Supabase):** Autenticación de usuarios y respaldo en tiempo real de perfiles, métricas de progreso y planes generados.
*   **Entrenamiento Inteligente (RAG):** Las rutinas se generan utilizando *Retrieval-Augmented Generation*, cruzando los datos del usuario con la base de datos de ejercicios de **Wger API**.
*   **Libro de Cocina (Cookbook) y Ejercicios Favoritos:** El sistema aprende de las preferencias del usuario. La IA prioriza los ejercicios y comidas marcadas como favoritas en futuras generaciones.
*   **Seguimiento de Progreso:** Registro de peso histórico con gráficos interactivos y galería de fotos para visualizar la transformación física.
*   **Recordatorios Locales:** Sistema de notificaciones programables para la toma de suplementos o recordatorios diarios.
*   **Internacionalización (i18n):** Soporte nativo y dinámico para Español e Inglés.

---

## El Poder de la IA en BetterMe

El uso de Inteligencia Artificial en BetterMe no es un simple chatbot; es un motor de lógica central (Core Engine) estructurado de manera determinista.

### Arquitectura de Integración AI
La aplicación se comunica con el modelo **Gemini** a través de una **Edge Function de Supabase** (`generate-plan`). Esto garantiza que las claves de la API de IA permanezcan seguras en el backend y permite escalar la infraestructura fácilmente.

### Prompt Engineering Avanzado
El proyecto utiliza utilidades dedicadas (`DietPromptBuilder` y `TrainingPromptBuilder`) para construir *prompts* de sistema que actúan como "nutricionistas y entrenadores de élite".
*   **Contexto Inyectado:** Se inyectan datos precisos: edad, sexo, peso, altura, alergias, y el inventario local de ejercicios disponibles.
*   **JSON Estricto:** La IA está fuertemente condicionada (mediante restricciones de prompt) para devolver **exclusivamente objetos JSON válidos** que la aplicación pueda parsear directamente en objetos Dart (ej. `AiTrainingPlan` y `AiDietPlan`).
*   **Manejo de Alucinaciones:** Al proporcionar a la IA la lista exacta de ejercicios desde la base de datos local (Wger), se elimina el riesgo de que la IA invente ejercicios inexistentes o con nombres incompatibles.

---

## Stack Tecnológico

*   **Frontend:** Flutter / Dart
*   **Backend as a Service (BaaS):** Supabase (Auth, Postgres, Edge Functions)
*   **Base de Datos Local:** SQLite (`sqflite`) para una experiencia *offline-first*
*   **Inteligencia Artificial:** Google Gemini (vía Supabase Edge Functions)
*   **APIs Externas:** Wger API para el catálogo de ejercicios estandarizados
*   **Gestión del Estado:** `ChangeNotifier` (Arquitectura orientada a Controladores de Vistas)

---

## Arquitectura de Datos: Offline-First + Cloud Sync

BetterMe está diseñada para ser rápida y resistente a la pérdida de conexión:
1.  **Operaciones Locales:** Todas las lecturas y escrituras (crear perfiles, guardar pesos, generar entrenamientos) se realizan primero en la base de datos local SQLite (`DatabaseHelper`).
2.  **Sincronización Silenciosa:** El servicio `CloudSyncService` se encarga de realizar copias de seguridad de las dietas, entrenamientos y perfiles hacia **Supabase** en segundo plano.
3.  **Restauración:** Al iniciar sesión en un nuevo dispositivo, el sistema descarga y restaura de forma transparente todo el historial del usuario desde Supabase hacia el dispositivo local.

---

## Configuración e Instalación

### Requisitos Previos
*   Flutter SDK instalado.
*   Un proyecto activo en Supabase.

### Pasos de Instalación
1. Clona el repositorio:
   ```bash
   git clone [https://github.com/tu-usuario/better_me.git](https://github.com/tu-usuario/better_me.git)

### Configuración de la Base de Datos

El proyecto utiliza un sistema de bases de datos híbrido.

**1. Base de Datos Local (SQLite)**
No se requiere configuración manual. El motor local se inicializa automáticamente al ejecutar la aplicación por primera vez, creando toda la estructura necesaria de forma local (Offline-first).

**2. Base de Datos en la Nube (Supabase)**
Para que el sistema de sincronización (`CloudSyncService`) y la autenticación funcionen, debes preparar la base de datos en tu proyecto de Supabase.

Dirígete a la sección **SQL Editor** en tu panel de Supabase y ejecuta el siguiente script para crear las tablas necesarias:

```sql
-- Tabla de Perfiles
CREATE TABLE profile (
  id_profile SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  sex TEXT NOT NULL,
  weight REAL NOT NULL,
  height REAL NOT NULL,
  birth_date DATE NOT NULL,
  active_diet_id INTEGER,
  active_training_id INTEGER
);

-- Tabla de Dietas
CREATE TABLE diet (
  id_diet SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  profile_name TEXT NOT NULL,
  name TEXT NOT NULL,
  objective TEXT NOT NULL,
  allergies TEXT,
  additional_data TEXT,
  generated_content TEXT
);

-- Tabla de Entrenamientos
CREATE TABLE training (
  id_training SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  profile_name TEXT NOT NULL,
  name TEXT NOT NULL,
  objective TEXT NOT NULL,
  max_days INTEGER NOT NULL,
  max_time REAL NOT NULL,
  generated_content TEXT
);

-- Tabla del Catálogo de Ejercicios (Sincronizado vía Wger)
CREATE TABLE exercise_catalog (
  id INTEGER PRIMARY KEY,
  language TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category_id INTEGER,
  category_name TEXT,
  main_muscle_id INTEGER,
  secondary_muscle_ids TEXT,
  exercise_image_url TEXT
);