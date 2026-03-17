# Ecosistema de Inteligencia Operativa y Atención al Cliente con IA 🚀

![Arquitectura del Proyecto](https://img.shields.io/badge/Architecture-Microservices-blue.svg)
![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED.svg?logo=docker)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o--mini-412991.svg?logo=openai)
![Status](https://img.shields.io/badge/Status-Production_Ready-success.svg)

## 📌 Título y Descripción Ejecutiva

Bienvenido al **Ecosistema de Inteligencia Operativa y Atención al Cliente**, una solución de arquitectura moderna diseñada para revolucionar la gestión de soporte y análisis de interacciones de usuarios. 

**Valor de Negocio:** Este proyecto logra la **reducción del tiempo de auditoría de servicio al cliente al 0% mediante Inteligencia Artificial**. Al automatizar la extracción de sentimiento, categorización de problemas y generación de resúmenes ejecutivos tras el cierre de cada ticket, el sistema elimina la necesidad de revisión manual de chats, habilitando la toma de decisiones basada en datos empíricos y analítica en tiempo real.

---

## 🏗 Arquitectura y Tecnologías

Todo el ecosistema está completamente contenerizado y orquestado bajo una red interna privada para maximizar la seguridad y facilitar el despliegue.

*   **Docker & Docker Compose:** Tecnologías base de contenerización y orquestación. Garantizan un entorno reproducible, escalable y aislado bajo una red privada (`backend_network`).
*   **Ngrok:** Actúa como túnel seguro, exponiendo el puerto local para recibir los eventos (Webhooks) directamente desde la API de WhatsApp.
*   **Chatwoot:** Plataforma centralizada de bandeja de entrada omnicanal. Actúa como la interfaz principal donde los agentes humanos gestionan derivaciones, chatean con el cliente y resuelven tickets.
*   **n8n:** Motor de orquestación y automatización de flujos de trabajo (workflows). Recibe eventos de Chatwoot (ej. "ticket cerrado"), procesa la información y se encarga de la integración con servicios externos e internos.
*   **OpenAI (gpt-4o-mini):** El núcleo analítico del sistema. n8n envía el historial de chat a la API de OpenAI para extraer de manera estructurada (JSON) el sentimiento del cliente, la categoría del incidente y generar un resumen ejecutivo de la interacción.
*   **PostgreSQL:** 
    *   Una instancia principal (con soporte para `pgvector`) que aloja las bases de datos transaccionales para n8n, Chatwoot y Metabase.
    *   Una instancia dedicada (`analytics_db`) para almacenar el JSON estructurado con los insights extraídos por la IA, optimizada para analíticas.
*   **Redis:** Caché en memoria y gestor de colas de tareas de fondo utilizado por los workers de Chatwoot (`sidekiq`).
*   **Metabase:** Herramienta de Business Intelligence (BI) conectada a la base de datos de analíticas. Consume los datos procesados por OpenAI para generar visualizaciones y dashboards interactivos en tiempo real.

---

## 📂 Estructura del Repositorio

La estructura del proyecto está organizada siguiendo las mejores prácticas de DevOps y despliegue de infraestructuras:

```text
/
├── .env.example             # Plantilla de variables de entorno globales
├── .chatwoot_env            # Configuración específica para la instancia de Chatwoot
├── docker-compose.yml       # Orquestador de la infraestructura (servicios, redes, volúmenes)
├── database/
│   └── init.sql             # Esquemas de inicialización para tablas de facturación y logs
├── infrastructure/
│   └── docker/
│       └── init.sql         # Script de creación de bases de datos para los microservicios
├── workflows_backups/       # Los flujos de n8n exportados en formato .json para su fácil importación
└── ...
```

---

## ⚙️ Requisitos Previos

Para desplegar este entorno en una máquina o servidor, asegúrese de cumplir con los siguientes requisitos:

1.  **Motor de Contenedores:** Docker y Docker Compose (v2.x recomendado) instalados y ejecutándose.
2.  **Git:** Para clonar el repositorio.
3.  **Cuenta de OpenAI:** Clave de API válida con acceso a los modelos `gpt-4o-mini`.
4.  **Cuenta de Ngrok:** Para exponer los endpoints locales hacia Internet (esencial para recibir webhooks de WhatsApp).
5.  **Puertos Disponibles:** Asegúrese de tener libres los siguientes puertos en el host: `3000` (Chatwoot), `3001` (Metabase), `5679` (n8n), y `5433` (Analytics DB).

---

## 🚀 Instalación y Despliegue

Siga las siguientes instrucciones paso a paso para levantar la infraestructura completa.

### 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd chat_project
```

### 2. Configurar Variables de Entorno

El proyecto requiere archivos `.env` para inyectar credenciales y configuraciones de forma segura.

*   Copie la plantilla `.env.example` y configure sus contraseñas y claves (incluyendo la API de OpenAI):
    ```bash
    cp .env.example .env
    ```
*   Asegúrese de configurar correctamente las variables de Chatwoot en el archivo `.chatwoot_env` (o `.chatwoot_env.save` si lo está restaurando).

### 3. Levantar los Servicios

Utilice Docker Compose para construir y levantar todos los contenedores en modo 'detached' (segundo plano):

```bash
docker compose up -d
```

Puede verificar el estado de los contenedores ejecutando: `docker compose ps`.

---

## 🛠 Configuración Post-Despliegue

Una vez que los contenedores estén corriendo (`Up`), es necesario realizar configuraciones a nivel aplicativo para unificar el ecosistema:

### A. Exponer Chatwoot a Internet

Para que WhatsApp (u otras integraciones externas) pueda comunicarse con el sistema, utilice Ngrok para exponer el puerto de Chatwoot:

```bash
ngrok http 3000
```
*Copie la URL pública generada por Ngrok (ej. `https://xxxx-xx-xx.ngrok.io`).*

### B. Configurar Webhooks Internos (Chatwoot ➔ n8n)

Para notificar a n8n cuando un ticket se cierra:
1. Ingrese a **Chatwoot** (`http://localhost:3000`).
2. Diríjase a la configuración de su Bandeja de Entrada > **Integraciones** > **Webhooks**.
3. Añada un nuevo Webhook apuntando a n8n. Dado que ambos residen en la red de Docker (`backend_network`), utilice la URL interna:
   `http://n8n:5678/webhook/tu-ruta-de-webhook` 
   *(Nota: si necesita acceder externamente a n8n, está expuesto en el puerto `5679` del host).*

### C. Importar Flujos de IA en n8n

1. Acceda a **n8n** ingresando a `http://localhost:5679`.
2. Vaya al apartado de **Workflows** y seleccione **Import from File**.
3. Seleccione los archivos `.json` ubicados en el directorio `workflows_backups/` del repositorio. Estos flujos ya contienen la lógica de conexión con OpenAI y la inserción a PostgreSQL.
4. Configure sus credenciales (Nodos de Postgres y OpenAI) dentro de n8n para activar el flujo.

### D. Conectar Metabase a los Datos Analíticos

1. Acceda a **Metabase** en `http://localhost:3001` y complete la configuración inicial.
2. Añada una nueva base de datos.
3. Configure la conexión hacia la base de datos analítica usando los parámetros definidos en el contenedor `analytics_db` (accesible internamente):
   *   **Host:** `analytics_db`
   *   **Port:** `5432` *(puerto interno del contenedor)*
   *   **Database Name:** `insights_db`
   *   **Username:** `admin`
   *   **Password:** `adminpassword`
4. ¡Listo! Comience a armar dashboards en tiempo real consumiendo los JSON estructurados con los insights de la IA.

---
*Desarrollado con ❤️ y las mejores prácticas de Arquitectura Cloud / DevOps.*
