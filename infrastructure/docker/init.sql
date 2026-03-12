CREATE USER n8n WITH PASSWORD 'n8n_password';
CREATE DATABASE n8n;
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;
ALTER DATABASE n8n OWNER TO n8n;

CREATE USER chatwoot WITH PASSWORD 'chatwoot_password' SUPERUSER;
CREATE DATABASE chatwoot;
GRANT ALL PRIVILEGES ON DATABASE chatwoot TO chatwoot;
ALTER DATABASE chatwoot OWNER TO chatwoot;

CREATE USER metabase WITH PASSWORD 'metabase_password';
CREATE DATABASE metabase;
GRANT ALL PRIVILEGES ON DATABASE metabase TO metabase;
ALTER DATABASE metabase OWNER TO metabase;

-- Base de datos adicional para el almacenamiento de facturas
CREATE DATABASE invoices;
GRANT ALL PRIVILEGES ON DATABASE invoices TO postgres;
