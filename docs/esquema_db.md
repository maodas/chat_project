# Diccionario de Datos: Insights de Conversaciones

## Base de Datos: `insights_db`
Esta base de datos es el repositorio central de analíticas operativas. Almacena la metadata extraída por Inteligencia Artificial (OpenAI) a partir de los historiales de chat cerrados en Chatwoot.

### Tabla: `conversation_insights`
Almacena el análisis individual de cada conversación procesada por el flujo de n8n.

| Columna | Tipo de Dato | Llave | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | SERIAL | PRIMARY KEY | Identificador único y autoincremental del registro en la base de datos. |
| `conversation_id` | INTEGER | FOREIGN KEY | ID original de la conversación proveniente de Chatwoot. Permite cruzar datos (hacer JOINs) si en el futuro se conecta la base de datos de Chatwoot a Metabase. |
| `sentimiento` | VARCHAR(50) | - | Clasificación del tono del cliente según la IA. Valores esperados: `Positivo`, `Neutral`, `Negativo`. Utilizado para medir la satisfacción (CSAT). |
| `categoria` | VARCHAR(100) | - | Clasificación del motivo del contacto. (Ej. `Soporte`, `Ventas`, `Información`, `Queja`). |
| `resumen` | TEXT | - | Resumen ejecutivo de 1 a 2 líneas generado por la IA explicando el problema y la resolución del ticket. |
| `fecha` | TIMESTAMP | - | Fecha y hora exacta (generada automáticamente por el sistema `CURRENT_TIMESTAMP`) en la que se insertó el análisis. |