# Data Warehouse and Analytics Project

 Este repositorio alberga la implementación de un **Data Warehouse Analítico (DWA)** basado en el modelo Northwind, enriquecido con datos geográficos y construido utilizando **SQL estándar (SQLite)**.

El proyecto demuestra el flujo de datos **end-to-end** en un DWA, cubriendo la adquisición , la gestión de la calidad (DQM) , la gestión de metadata (MET), el modelado dimensional  y la preparación para la explotación analítica.

---

## 🏗️ Arquitectura de Datos: Capas del DWA

La implementación sigue las mejores prácticas, separando el Data Warehouse en capas de responsabilidad dentro de una única base de datos, utilizando prefijos estandarizados:

| Capa | Prefijo | Propósito | Equivalente (Medallion) |
| :--- | :--- | :--- | :--- |
| **Adquisición** | `TXT_` | Almacena los datos **brutos** de los archivos de origen (CSV), con todos los campos como `TEXT` | **Bronze** |
| **Staging** | `TMP_` | Datos **limpios**, tipados, con claves primarias y foráneas definidas. Listo para la validación | **Silver** |
| **Analítica** | `DWA_` | **Modelo Dimensional** (Esquema Estrella) optimizado para consultas analíticas. | **Gold** |
| **Calidad** | `DQM_` | **Data Quality Mart**. Persistencia de indicadores, perfiles y resultados de validación de datos. | **Silver** |
| **Control** | `MET_` | **Metadata**. Diccionario de entidades/campos y registro de procesos. | **Silver** |
| **Memoria** | `DWM_` | Capa para la persistencia del historial de cambios (SCD). | **Gold** |

---

## 🧭 Flujo de Proceso (Etapas Completadas)

Las siguientes etapas han sido implementadas y documentadas a través de scripts SQL:

### 1. 📥 Etapa 1: Adquisición y Validación (TXT → TMP)

**Objetivo:** Transferir datos de la fuente transaccional (Ingesta1) a la zona de Staging, aplicando validaciones de formato y tipado.

* **Creación de Estructura:** Scripts para crear las tablas en las capas `TXT_` y `TMP_`.
* **Gestión de Logs:** Implementación de tablas `SCRIPT_INVENTORY` y `SCRIPT_LOG` para registrar el inicio, fin y resultado de cada ejecución de script.
* **Validación de Carga:** Scripts que validan la compatibilidad de datos (ej. casteo a tipos, formato de fechas) antes de la carga de `TXT_` a `TMP_`.
* **Validación de Integridad:** Scripts para chequear claves primarias duplicadas y la integridad referencial (FK) sobre la capa `TMP_`.

### 2. 🏛️ Etapa 2: Modelado Dimensional y DQM Inicial

**Objetivo:** Definir el Modelo Dimensional del DWA y documentarlo en la Metadata.

* **Modelo Dimensional:** Creación del modelo `DWA_` centrado en la tabla de hechos **`DWA_FactOrderDetails`** (Ventas) y sus dimensiones asociadas.
* **Data Quality Mart:** Creación de las tablas DQM para persistir los procesos ejecutados, los descriptivos y los indicadores de calidad.
* **Metadata:** Creación de las tablas MET_ y su uso para describir las entidades en las diferentes capas.

### 3. 🌐 Etapa 3: Enriquecimiento Geográfico y Estandarización

**Objetivo:** Incorporar la tabla de países (`World-Data-2023`) y vincularla a las tablas correspondientes, modificando todos los componentes afectados.

* **Ingesta World Data:** Scripts para la ingesta y tipado de datos geográficos, creando la nueva dimensión **`DWA_DimCountry`**.
* **Estandarización de Países:** Implementación de una lógica de mapeo (`DIM_CountryMapping`) para corregir inconsistencias de nombres de países (ej. "UK" a "United Kingdom") y asegurar la referencialidad.
* **Validación de Integración:** Scripts que verifican y registran en DQM la integridad referencial entre las dimensiones existentes y la nueva `DWA_DimCountry`.
**Actualización (Ingesta2):** Persistir en área temporal (TXT/TMP)los datos de la Ingesta2, repetir validaciones , e implementar la lógica de **Altas, Bajas y Modificaciones** en el DWA.
**Memoria Institucional:** Scripts para insertar en la capa de Memoria (`DWM_`) para persistir la historia de los campos que han sido modificados.

### 4. 🌐 Etapa 4: Publicación y explotación
**Objetivo:** Publicar un Producto de Datos (`DPxx_`) y desarrollar los tableros de visualización correspondientes (Analítico y DQM).

* **Publicación:** Script de creación del producto de datos
* **Explotación:** Desarrollo de tablero
---

## 🛠️ Tecnologías y Herramientas

* **Base de Datos:** SQLite (Utilizando comandos SQL Estándar).
* **Herramientas:** SQLLiteStudio.
* **Versionamiento:** Git / GitHub.

---
