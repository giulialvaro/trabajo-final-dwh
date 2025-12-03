# Data Warehouse and Analytics Project

 Este repositorio alberga la implementación de un **Data Warehouse Analítico (DWA)** basado en el modelo Northwind, enriquecido con datos geográficos y construido utilizando **SQL estándar (SQLite)**.

El proyecto demuestra el flujo de datos **end-to-end** en un DWA, cubriendo la adquisición [cite: 3][cite_start], la gestión de la calidad (DQM) [cite: 30][cite_start], la gestión de metadata (MET) [cite: 30][cite_start], el modelado dimensional [cite: 3] y la preparación para la explotación analítica.

---

## 🏗️ Arquitectura de Datos: Capas del DWA

La implementación sigue las mejores prácticas, separando el Data Warehouse en capas de responsabilidad dentro de una única base de datos, utilizando prefijos estandarizados:

| Capa | Prefijo | Propósito | Equivalente (Medallion) |
| :--- | :--- | :--- | :--- |
| **Adquisición** | `TXT_` | [cite_start]Almacena los datos **brutos** de los archivos de origen (CSV), con todos los campos como `TEXT`[cite: 155]. | **Bronze** |
| **Staging** | `TMP_` | Datos **limpios**, tipados, con claves primarias y foráneas definidas. [cite_start]Listo para la validación[cite: 156]. | **Silver** |
| **Analítica** | `DWA_` | [cite_start]**Modelo Dimensional** (Esquema Estrella) optimizado para consultas analíticas[cite: 221]. | **Gold** |
| **Calidad** | `DQM_` | **Data Quality Mart**. [cite_start]Persistencia de indicadores, perfiles y resultados de validación de datos[cite: 148, 222]. | **Silver** |
| **Control** | `MET_` | **Metadata**. [cite_start]Diccionario de entidades/campos y registro de procesos[cite: 224]. | **Silver** |
| **Memoria** | `DWM_` | [cite_start]*(Pendiente de Implementación)* Capa para la persistencia del historial de cambios (SCD)[cite: 223]. | **Gold** |

---

## 🧭 Flujo de Proceso (Etapas Completadas)

Las siguientes etapas han sido implementadas y documentadas a través de scripts SQL:

### 1. 📥 Etapa 1: Adquisición y Validación (TXT → TMP)

[cite_start]**Objetivo:** Transferir datos de la fuente transaccional (Ingesta1) a la zona de Staging, aplicando validaciones de formato y tipado[cite: 151].

* [cite_start]**Creación de Estructura:** Scripts para crear las tablas en las capas `TXT_` [cite: 155] [cite_start]y `TMP_`[cite: 156].
* [cite_start]**Gestión de Logs:** Implementación de tablas `SCRIPT_INVENTORY` y `SCRIPT_LOG` para registrar el inicio, fin y resultado de cada ejecución de script[cite: 147].
* [cite_start]**Validación de Carga:** Scripts que validan la compatibilidad de datos (ej. casteo a tipos, formato de fechas) antes de la carga de `TXT_` a `TMP_`[cite: 161].
* [cite_start]**Validación de Integridad:** Scripts para chequear claves primarias duplicadas [cite: 163] [cite_start]y la integridad referencial (FK) sobre la capa `TMP_`[cite: 168].

### 2. 🏛️ Etapa 2: Modelado Dimensional y DQM Inicial

[cite_start]**Objetivo:** Definir el Modelo Dimensional del DWA y documentarlo en la Metadata[cite: 172].

* [cite_start]**Modelo Dimensional:** Creación del modelo `DWA_` centrado en la tabla de hechos **`DWA_FactOrderDetails`** (Ventas) y sus dimensiones asociadas[cite: 176].
* [cite_start]**Data Quality Mart:** Creación de las tablas DQM [cite: 169] [cite_start]para persistir los procesos ejecutados, los descriptivos y los indicadores de calidad[cite: 174].
* [cite_start]**Metadata:** Creación de las tablas MET_ y su uso para describir las entidades en las diferentes capas[cite: 171].

### 3. 🌐 Etapa 3: Enriquecimiento Geográfico y Estandarización

[cite_start]**Objetivo:** Incorporar la tabla de países (`World-Data-2023`) y vincularla a las tablas correspondientes, modificando todos los componentes afectados[cite: 184, 185].

* **Ingesta World Data:** Scripts para la ingesta y tipado de datos geográficos, creando la nueva dimensión **`DWA_DimCountry`**.
* **Estandarización de Países:** Implementación de una lógica de mapeo (`DIM_CountryMapping`) para corregir inconsistencias de nombres de países (ej. "UK" a "United Kingdom") y asegurar la referencialidad.
* **Validación de Integración:** Scripts que verifican y registran en DQM la integridad referencial entre las dimensiones existentes y la nueva `DWA_DimCountry`.

---

## 🛠️ Tecnologías y Herramientas

* [cite_start]**Base de Datos:** SQLite (Utilizando comandos SQL Estándar)[cite: 34, 35].
* [cite_start]**Herramientas:** SQLLiteStudio[cite: 35].
* **Versionamiento:** Git / GitHub.

---

## ⏳ Próximos Pasos (Pendientes)

El trabajo a futuro se centrará en los siguientes requisitos clave del proyecto, correspondientes a la **Etapa 3 (Actualización)** y la **Etapa 4 (Publicación)**:

1.  [cite_start]**Actualización (Ingesta2):** Persistir en área temporal (TXT/TMP) [cite: 187] [cite_start]los datos de la Ingesta2, repetir validaciones [cite: 188][cite_start], e implementar la lógica de **Altas, Bajas y Modificaciones** en el DWA[cite: 189].
2.  [cite_start]**Memoria Institucional:** Desarrollar la capa de Memoria (`DWM_`) para persistir la historia de los campos que han sido modificados[cite: 193].
3.  [cite_start]**Publicación y Explotación:** Publicar un Producto de Datos (`DPxx_`) [cite: 202] [cite_start]y desarrollar los tableros de visualización correspondientes (Analítico y DQM)[cite: 207, 209].

---
