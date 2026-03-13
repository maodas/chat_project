-- Script de inicialización para bases de datos de reportes y facturación

-- Nos conectamos a la base de datos invoices (previamente creada en infrastructure/docker/init.sql)
\c invoices;

-- Crear la tabla invoices para simular los estados de cuenta de las flotillas
CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    id_cliente VARCHAR(50) NOT NULL,
    numero_factura VARCHAR(50) UNIQUE NOT NULL,
    monto NUMERIC(12, 2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion_servicio TEXT,
    estado_pago VARCHAR(20) NOT NULL -- Ej: 'Pagado', 'Pendiente', 'Vencido'
);

-- Crear la tabla chat_logs que Metabase consumirá para los reportes
CREATE TABLE IF NOT EXISTS chat_logs (
    id SERIAL PRIMARY KEY,
    id_interaccion VARCHAR(50) UNIQUE NOT NULL,
    departamento VARCHAR(50),
    duracion_segundos INTEGER,
    tema_principal VARCHAR(100),
    fecha TIMESTAMP NOT NULL
);

-- Insertar algunos datos de prueba en invoices para visualizar en Metabase (opcional)
INSERT INTO invoices (id_cliente, numero_factura, monto, fecha, descripcion_servicio, estado_pago) VALUES
('CL-001', 'FAC-2023-001', 1500.00, '2023-10-01', 'Mantenimiento preventivo flotilla A', 'Pagado'),
('CL-002', 'FAC-2023-002', 450.50, '2023-10-05', 'Cambio de aceite y filtros', 'Pendiente'),
('CL-001', 'FAC-2023-003', 3200.00, '2023-10-10', 'Reparación de transmisión', 'Vencido')
ON CONFLICT DO NOTHING;

-- Insertar algunos datos de prueba en chat_logs para visualizar en Metabase (opcional)
INSERT INTO chat_logs (id_interaccion, departamento, duracion_segundos, tema_principal, fecha) VALUES
('INT-001', 'Ventas', 120, 'Cotización de servicio', '2023-10-10 10:15:00'),
('INT-002', 'Soporte', 300, 'Estado de reparación', '2023-10-10 11:30:00'),
('INT-003', 'Facturación', 180, 'Consulta de saldo', '2023-10-10 14:45:00')
ON CONFLICT DO NOTHING;

--.--