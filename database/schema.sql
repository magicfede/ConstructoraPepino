-- ============================================================================
-- ECOSISTEMA DE VENTAS WHATSAPP — FASE 1
-- Schema SQL para PostgreSQL / Supabase
-- Versión: 1.0.0
-- Arquitectura: MULTITENANT (Marca Blanca)
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONES REQUERIDAS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- Generación de UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";        -- Funciones criptográficas

-- ============================================================================
-- 2. TIPOS ENUMERADOS
-- ============================================================================

-- Estado del vehículo en el catálogo
CREATE TYPE estado_vehiculo AS ENUM ('nuevo', 'usado');

-- Tipo de combustible
CREATE TYPE tipo_combustible AS ENUM (
    'nafta',
    'diesel',
    'gnc',
    'hibrido',
    'electrico',
    'nafta_gnc'
);

-- Tipo de transmisión
CREATE TYPE tipo_transmision AS ENUM ('manual', 'automatica', 'cvt', 'automatizada');

-- Estado del lead en el funnel de ventas
CREATE TYPE estado_lead AS ENUM (
    'nuevo',              -- Primer contacto recibido
    'contactado',         -- Se respondió al cliente
    'en_negociacion',     -- Conversación activa sobre precio/financiación
    'visita_agendada',    -- Cliente agendó visita al concesionario
    'propuesta_enviada',  -- Se envió cotización formal
    'ganado',             -- Venta concretada
    'perdido',            -- Lead descartado o perdido
    'dormido'             -- Sin actividad, para reactivación futura
);

-- ============================================================================
-- 3. TABLA: tenants
-- Almacena cada empresa/marca blanca del ecosistema multitenant
-- ============================================================================
CREATE TABLE tenants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(255) NOT NULL,
    slug            VARCHAR(100) NOT NULL UNIQUE,  -- Identificador URL-friendly
    rubro           VARCHAR(150) NOT NULL,
    
    -- Configuración completa del tenant en formato JSON flexible
    -- Incluye: colores, contacto, beneficios, hero, SEO, metadata
    configuracion_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Estado del tenant
    activo          BOOLEAN NOT NULL DEFAULT true,
    
    -- Auditoría
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para tenants
CREATE INDEX idx_tenants_slug ON tenants (slug);
CREATE INDEX idx_tenants_activo ON tenants (activo) WHERE activo = true;

COMMENT ON TABLE tenants IS 'Tabla principal multitenant. Cada registro representa una empresa/marca blanca independiente.';
COMMENT ON COLUMN tenants.configuracion_json IS 'JSON flexible con: colores, contacto (whatsapp, dirección), beneficios, hero section, SEO, metadata del negocio.';

-- ============================================================================
-- 4. TABLA: productos_vehiculos
-- Catálogo de vehículos por tenant, preparado para RAG con IA
-- ============================================================================
CREATE TABLE productos_vehiculos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Información del vehículo
    marca           VARCHAR(100) NOT NULL,
    modelo          VARCHAR(150) NOT NULL,
    version         VARCHAR(200),                   -- Ej: "1.3 GSE Drive", "Shine Pack"
    anio            INTEGER NOT NULL CHECK (anio >= 1900 AND anio <= 2030),
    
    -- Precio y moneda
    precio          NUMERIC(15, 2) NOT NULL CHECK (precio >= 0),
    moneda          VARCHAR(3) NOT NULL DEFAULT 'ARS' CHECK (moneda IN ('ARS', 'USD')),
    precio_desde    BOOLEAN NOT NULL DEFAULT false,  -- Si es "desde $X"
    
    -- Especificaciones técnicas
    tipo_combustible    tipo_combustible NOT NULL,
    transmision         tipo_transmision NOT NULL,
    kilometraje         INTEGER NOT NULL DEFAULT 0 CHECK (kilometraje >= 0),
    estado              estado_vehiculo NOT NULL,
    color               VARCHAR(80),
    motor               VARCHAR(100),                -- Ej: "1.3L 99CV", "Motor Eléctrico 95kW"
    puertas             SMALLINT CHECK (puertas >= 2 AND puertas <= 5),
    
    -- Contenido
    descripcion         TEXT,
    descripcion_corta   VARCHAR(300),                -- Para cards y previews
    caracteristicas     JSONB DEFAULT '[]'::jsonb,   -- Array de features destacadas
    
    -- Stock e imágenes
    stock               INTEGER NOT NULL DEFAULT 1 CHECK (stock >= 0),
    url_imagen          TEXT,                         -- URL principal
    galeria_imagenes    JSONB DEFAULT '[]'::jsonb,   -- Array de URLs adicionales
    
    -- IA / RAG
    -- Campo JSONB para almacenar embeddings, chunks de texto procesado,
    -- keywords semánticas, y cualquier metadata que el agente IA necesite
    metadata_ia         JSONB DEFAULT '{}'::jsonb,
    
    -- Visibilidad
    destacado           BOOLEAN NOT NULL DEFAULT false,
    visible             BOOLEAN NOT NULL DEFAULT true,
    orden               INTEGER DEFAULT 0,
    
    -- Auditoría
    creado_en           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices optimizados para queries frecuentes
CREATE INDEX idx_vehiculos_tenant ON productos_vehiculos (tenant_id);
CREATE INDEX idx_vehiculos_estado ON productos_vehiculos (tenant_id, estado);
CREATE INDEX idx_vehiculos_marca ON productos_vehiculos (tenant_id, marca);
CREATE INDEX idx_vehiculos_precio ON productos_vehiculos (tenant_id, precio);
CREATE INDEX idx_vehiculos_visible ON productos_vehiculos (tenant_id, visible) WHERE visible = true;
CREATE INDEX idx_vehiculos_destacado ON productos_vehiculos (tenant_id, destacado) WHERE destacado = true;
CREATE INDEX idx_vehiculos_metadata_ia ON productos_vehiculos USING GIN (metadata_ia);
CREATE INDEX idx_vehiculos_caracteristicas ON productos_vehiculos USING GIN (caracteristicas);

COMMENT ON TABLE productos_vehiculos IS 'Catálogo de vehículos por tenant. Preparado para alimentar agentes IA mediante RAG con el campo metadata_ia.';
COMMENT ON COLUMN productos_vehiculos.metadata_ia IS 'JSONB para embeddings vectoriales, chunks de texto procesado, keywords semánticas y metadata para el agente IA/RAG.';
COMMENT ON COLUMN productos_vehiculos.caracteristicas IS 'Array JSON de features destacadas del vehículo. Ej: ["Aire acondicionado", "Dirección asistida", "Airbags frontales"]';

-- ============================================================================
-- 5. TABLA: leads_conversaciones
-- Tracking de leads desde WhatsApp con estado del funnel y resumen IA
-- ============================================================================
CREATE TABLE leads_conversaciones (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id           UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Datos del cliente
    whatsapp_cliente    VARCHAR(20) NOT NULL,         -- Número completo con código país
    nombre_cliente      VARCHAR(255),
    email_cliente       VARCHAR(255),
    
    -- Estado del lead
    estado_lead         estado_lead NOT NULL DEFAULT 'nuevo',
    
    -- Vehículo de interés (opcional, puede interesar en varios)
    vehiculo_interes_id UUID REFERENCES productos_vehiculos(id) ON DELETE SET NULL,
    
    -- IA
    resumen_ia          TEXT,                          -- Resumen generado por IA de la conversación
    sentimiento         VARCHAR(20),                   -- positivo, neutral, negativo
    intencion_compra    SMALLINT CHECK (intencion_compra >= 1 AND intencion_compra <= 10),
    tags                JSONB DEFAULT '[]'::jsonb,     -- Tags automáticos de la IA
    
    -- Interacciones
    cantidad_mensajes   INTEGER NOT NULL DEFAULT 0,
    primera_interaccion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ultima_interaccion  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Fuente
    fuente              VARCHAR(100) DEFAULT 'whatsapp_web',  -- whatsapp_web, whatsapp_directo, landing_page
    utm_source          VARCHAR(100),
    utm_medium          VARCHAR(100),
    utm_campaign        VARCHAR(100),
    
    -- Auditoría
    creado_en           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para leads
CREATE INDEX idx_leads_tenant ON leads_conversaciones (tenant_id);
CREATE INDEX idx_leads_estado ON leads_conversaciones (tenant_id, estado_lead);
CREATE INDEX idx_leads_whatsapp ON leads_conversaciones (tenant_id, whatsapp_cliente);
CREATE INDEX idx_leads_vehiculo ON leads_conversaciones (vehiculo_interes_id);
CREATE INDEX idx_leads_ultima_interaccion ON leads_conversaciones (tenant_id, ultima_interaccion DESC);
CREATE INDEX idx_leads_tags ON leads_conversaciones USING GIN (tags);

-- Índice único para evitar duplicados de WhatsApp por tenant
CREATE UNIQUE INDEX idx_leads_unique_whatsapp_tenant 
    ON leads_conversaciones (tenant_id, whatsapp_cliente);

COMMENT ON TABLE leads_conversaciones IS 'Registro de leads y conversaciones de WhatsApp por tenant. Incluye análisis IA (resumen, sentimiento, intención de compra).';

-- ============================================================================
-- 6. FUNCIONES Y TRIGGERS
-- ============================================================================

-- Función para actualizar automáticamente el campo updated_at
CREATE OR REPLACE FUNCTION trigger_set_actualizado_en()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas
CREATE TRIGGER set_actualizado_en_tenants
    BEFORE UPDATE ON tenants
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

CREATE TRIGGER set_actualizado_en_vehiculos
    BEFORE UPDATE ON productos_vehiculos
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

CREATE TRIGGER set_actualizado_en_leads
    BEFORE UPDATE ON leads_conversaciones
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

-- ============================================================================
-- 7. ROW LEVEL SECURITY (RLS) — Preparado para Supabase
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos_vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads_conversaciones ENABLE ROW LEVEL SECURITY;

-- Política de lectura pública para vehículos visibles (landing page)
CREATE POLICY "Vehiculos visibles son públicos"
    ON productos_vehiculos
    FOR SELECT
    USING (visible = true);

-- Política de lectura pública para datos de tenants activos
CREATE POLICY "Tenants activos son públicos"
    ON tenants
    FOR SELECT
    USING (activo = true);

-- Política de inserción de leads (cualquier visitante puede crear un lead)
CREATE POLICY "Cualquier visitante puede crear leads"
    ON leads_conversaciones
    FOR INSERT
    WITH CHECK (true);

-- ============================================================================
-- 8. VISTAS ÚTILES
-- ============================================================================

-- Vista de catálogo público (lo que ve la landing page)
CREATE OR REPLACE VIEW v_catalogo_publico AS
SELECT
    pv.id,
    pv.tenant_id,
    t.nombre AS tenant_nombre,
    t.slug AS tenant_slug,
    pv.marca,
    pv.modelo,
    pv.version,
    pv.anio,
    pv.precio,
    pv.moneda,
    pv.precio_desde,
    pv.tipo_combustible,
    pv.transmision,
    pv.kilometraje,
    pv.estado,
    pv.color,
    pv.motor,
    pv.descripcion_corta,
    pv.caracteristicas,
    pv.stock,
    pv.url_imagen,
    pv.galeria_imagenes,
    pv.destacado,
    pv.orden
FROM productos_vehiculos pv
JOIN tenants t ON t.id = pv.tenant_id
WHERE pv.visible = true
  AND pv.stock > 0
  AND t.activo = true
ORDER BY pv.destacado DESC, pv.orden ASC, pv.creado_en DESC;

-- Vista de dashboard de leads por tenant
CREATE OR REPLACE VIEW v_leads_dashboard AS
SELECT
    lc.id,
    lc.tenant_id,
    lc.whatsapp_cliente,
    lc.nombre_cliente,
    lc.estado_lead,
    lc.resumen_ia,
    lc.sentimiento,
    lc.intencion_compra,
    lc.cantidad_mensajes,
    lc.ultima_interaccion,
    lc.fuente,
    pv.marca AS vehiculo_marca,
    pv.modelo AS vehiculo_modelo,
    pv.version AS vehiculo_version
FROM leads_conversaciones lc
LEFT JOIN productos_vehiculos pv ON pv.id = lc.vehiculo_interes_id
ORDER BY lc.ultima_interaccion DESC;

-- ============================================================================
-- FIN DEL SCHEMA
-- ============================================================================
