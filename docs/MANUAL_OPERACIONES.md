# Manual de Operaciones, Seguridad y Escalabilidad
**Ecosistema de Atención al Cliente Automática e Insights**

Este documento detalla los procedimientos para adaptar, asegurar y operar la arquitectura basada en Docker (Chatwoot, n8n, OpenAI, PostgreSQL, Metabase).

---

## 1. Adaptación a Otros Negocios (Escalabilidad)
Para implementar este mismo flujo en un negocio diferente, solo necesitas modificar tres capas de la arquitectura:

* **Chatwoot (La Cara Visible):** Crea una nueva "Bandeja de entrada" (Inbox) en los ajustes, personaliza el mensaje de bienvenida y asigna los agentes correspondientes al nuevo negocio.
* **n8n (El Cerebro):**
  * Modifica el "System Prompt" en el nodo de OpenAI para que entienda el contexto del nuevo negocio.
  * Cambia las categorías de extracción (Ej. en vez de "Ventas/Soporte", usar "Reservas/Quejas/Información" si es un restaurante).
* **Metabase (Los Ojos):** Crea un nuevo "Dashboard" (Panel) y ajusta los filtros de las gráficas para que reflejen las nuevas categorías configuradas en n8n.

---

## 2. Guardrails (Contención de la IA)
Para evitar que la IA responda a preguntas fuera de contexto (como problemas matemáticos o chistes), se debe implementar un "Guardrail" estricto en el nodo de OpenAI dentro de n8n.

**Solución a implementar en el "System Prompt" de n8n:**
Debes agregar instrucciones de negación absoluta. Ejemplo de Prompt:

> "Eres el asistente virtual oficial de [Nombre de la Empresa]. Tu único propósito es ayudar a los clientes con [Productos/Servicios].
> **REGLA ESTRICTA:** Bajo ninguna circunstancia debes responder a preguntas que no estén relacionadas con la empresa (ej. matemáticas, política, programación, tareas escolares). 
> Si el usuario hace una pregunta fuera de tema, debes responder EXACTAMENTE esto: *'Lo siento, soy un asistente virtual dedicado exclusivamente a los servicios de [Nombre de la Empresa]. ¿En qué te puedo ayudar respecto a nuestros servicios?'*."

---

## 3. Seguridad y Buenas Prácticas (Paso a Producción)
El entorno actual está diseñado para desarrollo local. Para llevarlo a producción de forma segura, se deben aplicar las siguientes medidas:

1. **Eliminar Ngrok:** Ngrok es temporal. En producción, el proyecto debe alojarse en un Servidor Virtual (VPS como DigitalOcean o AWS).
2. **Proxy Inverso y SSL:** Se debe usar Traefik o Nginx Proxy Manager para enrutar el tráfico y proveer certificados HTTPS reales y gratuitos (Let's Encrypt).
3. **Credenciales Fuertes:** Cambiar todas las contraseñas por defecto en el archivo `.env` (Postgres, Metabase, n8n) antes de levantar los contenedores en la nube.
4. **Cierre de Puertos:** En producción, las bases de datos (`postgres`, `analytics_db`, `redis`) NO deben mapear puertos al exterior (eliminar la sección `ports: - "5433:5432"` del `docker-compose.yml`), asegurando que solo n8n y Metabase puedan leerlas internamente.

---

## 4. Proceso de Verificación de Meta (WhatsApp Business API)
Para pasar del entorno de pruebas a un número de teléfono real y enviar mensajes masivos, se debe completar la verificación comercial:

1. **Crear la App:** Ingresar a [Meta for Developers](https://developers.facebook.com/), crear una aplicación tipo "Negocios" y agregar el producto "WhatsApp".
2. **Vincular Página de Facebook:** En la configuración de WhatsApp, enlazar la cuenta con una Página de Facebook Business existente del negocio.
3. **Business Verification (Verificación del Negocio):** En el *Business Manager* de Meta, ir a Centro de Seguridad y subir los documentos legales de la empresa (patente de comercio, registro fiscal, recibos de luz) para demostrar que el negocio es real.
4. **Agregar Método de Pago:** Meta cobra por "Conversación" (ventanas de 24 horas). Es obligatorio agregar una tarjeta de crédito para salir del modo de prueba.
5. **Añadir el Número Real:** Una vez verificado, se puede agregar el número telefónico oficial de la empresa (este número no debe estar activo en la app normal de WhatsApp del celular).

---

## 5. Manual de Usuario: Chatwoot
Chatwoot es la consola de mando de los operadores humanos.

* **Añadir/Quitar Usuarios:**
  1. Ir a `Ajustes` > `Agentes`.
  2. Clic en `Añadir Agente`. Introducir correo y rol (Administrador o Agente).
  3. El usuario recibirá un correo para crear su contraseña. Para eliminarlo, hacer clic en el botón de la papelera en la misma pantalla.
* **Uso de la Bandeja de Entrada:**
  * **Mío:** Chats asignados específicamente a ti.
  * **Sin Asignar:** Chats nuevos gestionados por el bot que requieren intervención humana.
  * **Notas Privadas:** Usar el icono de "candado" en el chat para dejar notas internas que el cliente no verá (útil para pasar contexto a otro compañero).
* **Informes:**
  * Ir a la sección `Informes` en el menú izquierdo.
  * **Visión General:** Muestra el volumen de mensajes y tiempos promedios de respuesta.
  * **CSAT:** Si se activan las encuestas de satisfacción al resolver un ticket, aquí se ven las calificaciones de los clientes.
  * **Agentes:** Mide el rendimiento individual de cada operador humano.