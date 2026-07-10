-- ============================================================================
-- ECOSISTEMA CRM VENTAS FAMILIA PARRA — FASE 2 EXTENDIDA
-- Schema SQL Extendido: Planes de Ahorro, Cuotas, Análisis Mensual
-- Versión: 2.0.0
-- Arquitectura: MULTITENANT + ANALYTICS + FINANCIACIÓN
-- ============================================================================

-- ============================================================================
-- 1. TIPOS ENUMERADOS ADICIONALES
-- ============================================================================

-- Tipo de plan de ahorro
CREATE TYPE tipo_plan_ahorro AS ENUM (
    'fiat_plan_84',           -- Plan Fiat 84 cuotas
    'fiat_plan_120',          -- Plan Fiat 120 cuotas
    'citroen_plan_84',        -- Plan Citroën 84 cuotas
    'byd_plan_36',            -- Plan BYD 36 cuotas USD
    'credito_prendario_60',   -- Crédito prendario 60 cuotas
    'credito_prendario_48',   -- Crédito prendario 48 cuotas
    'adjudicacion_pactada',   -- Adjudicación pactada
    'licitacion',             -- Licitación
    'sorteo'                  -- Sorteo
);

-- Modalidad de pago
CREATE TYPE modalidad_pago AS ENUM (
    'anticipo_70_30',         -- 70% anticipo, 30% en cuotas
    'anticipo_80_20',         -- 80% anticipo, 20% en cuotas
    'anticipo_90_10',         -- 90% anticipo, 10% en cuotas
    'sin_anticipo',           -- Sin anticipo (Plan Fiat)
    'anticipo_20_porciento'   -- 20% anticipo estándar
);

-- Fuente de lead
CREATE TYPE fuente_lead_crm AS ENUM (
    'whatsapp_web',
    'whatsapp_directo',
    'landing_page',
    'google_ads',
    'facebook_ads',
    'instagram_ads',
    'llamada_directa',
    'recomendacion',
    'evento',
    'otro'
);

-- Categoría de vehículo
CREATE TYPE categoria_vehiculo AS ENUM (
    'sedan_compacto',
    'sedan_mediano',
    'sedan_premium',
    'suv_like_entrada',
    'suv_compacto',
    'suv_mediano',
    'hatchback',
    'electrico',
    'hibrido',
    'pickup'
);

-- ============================================================================
-- 2. TABLA: planes_ahorro
-- Planes de financiación disponibles por marca/entidad
-- ============================================================================
CREATE TABLE planes_ahorro (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Identificación del plan
    nombre          VARCHAR(150) NOT NULL,
    tipo_plan       tipo_plan_ahorro NOT NULL,
    descripcion     TEXT,
    
    -- Entidad financiera
    entidad         VARCHAR(150) NOT NULL,  -- Ej: FCA Automobiles, Banco Nación, etc.
    
    -- Parámetros
    cuotas_minimas  SMALLINT NOT NULL DEFAULT 36,
    cuotas_maximas  SMALLINT NOT NULL DEFAULT 84,
    tna_fija        NUMERIC(5, 2),          -- TNA fija si aplica
    tna_variable    NUMERIC(5, 2),          -- TNA variable si aplica
    
    -- Requisitos y modalidades
    anticipo_porcentaje_minimo    SMALLINT DEFAULT 0,
    modalidades_pago              JSONB DEFAULT '[]'::jsonb,  -- Array de modalidad_pago
    requisitos                    JSONB DEFAULT '[]'::jsonb,  -- Array de requisitos
    
    -- Características especiales
    puntaje_crediticio_requerido  BOOLEAN DEFAULT false,
    acepta_llave_por_llave        BOOLEAN DEFAULT true,
    tiene_sorteo                  BOOLEAN DEFAULT false,
    tiene_licitacion              BOOLEAN DEFAULT false,
    
    -- Control
    activo          BOOLEAN NOT NULL DEFAULT true,
    visible         BOOLEAN NOT NULL DEFAULT true,
    orden           INTEGER DEFAULT 0,
    
    -- Auditoría
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_planes_tenant ON planes_ahorro (tenant_id);
CREATE INDEX idx_planes_activo ON planes_ahorro (tenant_id, activo) WHERE activo = true;
CREATE INDEX idx_planes_tipo ON planes_ahorro (tenant_id, tipo_plan);

COMMENT ON TABLE planes_ahorro IS 'Planes de ahorro y financiación disponibles. Define cuotas, TNA, requisitos y modalidades.';

-- ============================================================================
-- 3. TABLA: cotizaciones_presupuestos
-- Presupuestos generados para clientes (cálculos de cuotas)
-- ============================================================================
CREATE TABLE cotizaciones_presupuestos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    lead_id         UUID REFERENCES leads_conversaciones(id) ON DELETE SET NULL,
    vehiculo_id     UUID NOT NULL REFERENCES productos_vehiculos(id) ON DELETE RESTRICT,
    
    -- Datos del cliente
    nombre_cliente  VARCHAR(255),
    email_cliente   VARCHAR(255),
    whatsapp_cliente VARCHAR(20),
    
    -- Vehículo y precio
    marca           VARCHAR(100) NOT NULL,
    modelo          VARCHAR(150) NOT NULL,
    version         VARCHAR(200),
    precio_lista    NUMERIC(15, 2) NOT NULL,
    moneda          VARCHAR(3) NOT NULL DEFAULT 'ARS',
    
    -- Plan seleccionado
    plan_ahorro_id  UUID NOT NULL REFERENCES planes_ahorro(id) ON DELETE RESTRICT,
    tipo_plan       tipo_plan_ahorro NOT NULL,
    modalidad_pago  modalidad_pago NOT NULL,
    
    -- Cálculos
    anticipo_monto  NUMERIC(15, 2) NOT NULL,
    anticipo_porciento NUMERIC(5, 2) NOT NULL,
    monto_financiado NUMERIC(15, 2) NOT NULL,
    cantidad_cuotas SMALLINT NOT NULL,
    valor_cuota     NUMERIC(12, 2) NOT NULL,
    tna_aplicada    NUMERIC(5, 2),
    interes_total   NUMERIC(15, 2),
    monto_total_pagar NUMERIC(15, 2) NOT NULL,
    
    -- Detalle de cálculo (JSON para auditoría)
    detalles_calculo JSONB,
    
    -- Control
    estado          VARCHAR(50) DEFAULT 'generada',  -- generada, enviada, aceptada, rechazada
    comentarios     TEXT,
    
    -- Auditoría
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    enviada_en      TIMESTAMPTZ,
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_cotizaciones_tenant ON cotizaciones_presupuestos (tenant_id);
CREATE INDEX idx_cotizaciones_lead ON cotizaciones_presupuestos (lead_id);
CREATE INDEX idx_cotizaciones_vehiculo ON cotizaciones_presupuestos (vehiculo_id);
CREATE INDEX idx_cotizaciones_plan ON cotizaciones_presupuestos (plan_ahorro_id);
CREATE INDEX idx_cotizaciones_estado ON cotizaciones_presupuestos (tenant_id, estado);

COMMENT ON TABLE cotizaciones_presupuestos IS 'Cotizaciones y presupuestos generados. Contiene cálculos de cuotas, intereses y modalidades de pago.';

-- ============================================================================
-- 4. TABLA: analisis_demanda_mensual
-- Análisis de demanda, fuentes y tendencias mensuales
-- ============================================================================
CREATE TABLE analisis_demanda_mensual (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Período
    año             SMALLINT NOT NULL,
    mes             SMALLINT NOT NULL CHECK (mes >= 1 AND mes <= 12),
    
    -- Resumen de actividad
    total_leads     INTEGER NOT NULL DEFAULT 0,
    leads_nuevo     INTEGER DEFAULT 0,
    leads_contactado INTEGER DEFAULT 0,
    leads_en_negociacion INTEGER DEFAULT 0,
    leads_visita_agendada INTEGER DEFAULT 0,
    leads_propuesta_enviada INTEGER DEFAULT 0,
    leads_ganados   INTEGER DEFAULT 0,
    leads_perdidos  INTEGER DEFAULT 0,
    
    -- Conversión
    tasa_conversion_porciento NUMERIC(5, 2),
    promedio_dias_conversion INTEGER,
    
    -- Fuentes de leads
    fuentes_leads   JSONB DEFAULT '{}'::jsonb,  -- Ej: {"whatsapp_web": 45, "landing_page": 32, ...}
    
    -- Vehículos más solicitados
    top_vehiculos   JSONB DEFAULT '[]'::jsonb,  -- Array de {modelo, cantidad, porcentaje}
    
    -- Planes más populares
    top_planes      JSONB DEFAULT '[]'::jsonb,  -- Array de {tipo_plan, cantidad, porcentaje}
    
    -- Precio promedio de cotización
    precio_promedio_cotizado NUMERIC(15, 2),
    
    -- Análisis eléctricos e híbridos
    interes_electrico_porciento NUMERIC(5, 2),
    interes_hibrido_porciento NUMERIC(5, 2),
    
    -- Notas y observaciones
    observaciones   TEXT,
    
    -- Auditoría
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_analisis_tenant_periodo ON analisis_demanda_mensual (tenant_id, año, mes);
CREATE UNIQUE INDEX idx_analisis_unique_periodo ON analisis_demanda_mensual (tenant_id, año, mes);

COMMENT ON TABLE analisis_demanda_mensual IS 'Análisis mensual de demanda, conversiones, fuentes y tendencias de vehículos.';

-- ============================================================================
-- 5. TABLA: configuracion_calculo_cuotas
-- Configuración de parámetros para cálculo de cuotas (TNA, comisiones, etc.)
-- ============================================================================
CREATE TABLE configuracion_calculo_cuotas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    plan_ahorro_id  UUID NOT NULL REFERENCES planes_ahorro(id) ON DELETE CASCADE,
    
    -- Parámetros de cálculo
    tna_aplicable   NUMERIC(5, 2) NOT NULL,
    comision_inicial_porciento NUMERIC(5, 2) DEFAULT 0,
    seguro_vida_porciento NUMERIC(5, 2) DEFAULT 0,
    gastos_admin_porciento NUMERIC(5, 2) DEFAULT 0,
    
    -- Ajustes según modalidad
    modalidad_pago  modalidad_pago NOT NULL,
    descuento_anticipo_porciento NUMERIC(5, 2) DEFAULT 0,  -- Descuento por mayor anticipo
    
    -- Vigencia
    vigente_desde   DATE NOT NULL,
    vigente_hasta   DATE,
    
    -- Estado
    activo          BOOLEAN DEFAULT true,
    
    -- Auditoría
    creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_config_tenant_plan ON configuracion_calculo_cuotas (tenant_id, plan_ahorro_id);
CREATE INDEX idx_config_activo ON configuracion_calculo_cuotas (tenant_id, activo) WHERE activo = true;

COMMENT ON TABLE configuracion_calculo_cuotas IS 'Configuración de TNA, comisiones y parámetros para cálculo de cuotas según plan y modalidad.';

-- ============================================================================
-- 6. TABLA: historico_precios_vehiculos
-- Histórico de precios actualizados mensualmente
-- ============================================================================
CREATE TABLE historico_precios_vehiculos (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehiculo_id     UUID NOT NULL REFERENCES productos_vehiculos(id) ON DELETE CASCADE,
    
    -- Período
    año             SMALLINT NOT NULL,
    mes             SMALLINT NOT NULL CHECK (mes >= 1 AND mes <= 12),
    
    -- Precios
    precio_anterior NUMERIC(15, 2),
    precio_actual   NUMERIC(15, 2) NOT NULL,
    precio_usd_referencia NUMERIC(12, 2),
    tasa_cambio_referencia NUMERIC(8, 4),
    
    -- Cambio
    variacion_absoluta NUMERIC(15, 2),
    variacion_porciento NUMERIC(5, 2),
    
    -- Stock
    stock_disponible INTEGER DEFAULT 0,
    
    -- Auditoría
    registrado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_historico_vehiculo ON historico_precios_vehiculos (vehiculo_id);
CREATE INDEX idx_historico_periodo ON historico_precios_vehiculos (ano, mes);
CREATE UNIQUE INDEX idx_historico_unique ON historico_precios_vehiculos (vehiculo_id, ano, mes);

COMMENT ON TABLE historico_precios_vehiculos IS 'Histórico de precios mensuales. Permite auditoría y análisis de variaciones.';

-- ============================================================================
-- 7. VISTA: v_top_vehiculos_demanda
-- Top vehículos por demanda (últimos 30 días)
-- ============================================================================
CREATE OR REPLACE VIEW v_top_vehiculos_demanda AS
SELECT
    pv.id,
    pv.marca,
    pv.modelo,
    pv.version,
    pv.anio,
    pv.precio,
    COUNT(lc.id) AS cantidad_leads,
    ROUND(COUNT(lc.id)::numeric / 
          (SELECT COUNT(*) FROM leads_conversaciones 
           WHERE tenant_id = lc.tenant_id 
           AND ultima_interaccion >= NOW() - INTERVAL '30 days')::numeric * 100, 2) AS porcentaje_demanda
FROM productos_vehiculos pv
LEFT JOIN leads_conversaciones lc ON lc.vehiculo_interes_id = pv.id
WHERE lc.ultima_interaccion >= NOW() - INTERVAL '30 days'
   OR lc.id IS NULL
GROUP BY pv.id, pv.marca, pv.modelo, pv.version, pv.anio, pv.precio, lc.tenant_id
ORDER BY cantidad_leads DESC;

-- ============================================================================
-- 8. VISTA: v_analisis_fuentes_leads
-- Análisis de leads por fuente (últimos 30 días)
-- ============================================================================
CREATE OR REPLACE VIEW v_analisis_fuentes_leads AS
SELECT
    lc.tenant_id,
    lc.fuente,
    COUNT(*) AS total_leads,
    ROUND(AVG(EXTRACT(DAY FROM (lc.ultima_interaccion - lc.primera_interaccion)))::numeric, 1) AS dias_promedio,
    COUNT(CASE WHEN lc.estado_lead = 'ganado' THEN 1 END) AS leads_convertidos,
    ROUND(
        COUNT(CASE WHEN lc.estado_lead = 'ganado' THEN 1 END)::numeric / 
        COUNT(*)::numeric * 100, 2
    ) AS tasa_conversion_porciento,
    ROUND(AVG(COALESCE(lc.intencion_compra, 0))::numeric, 1) AS intencion_compra_promedio
FROM leads_conversaciones lc
WHERE lc.primera_interaccion >= NOW() - INTERVAL '30 days'
GROUP BY lc.tenant_id, lc.fuente
ORDER BY total_leads DESC;

-- ============================================================================
-- 9. FUNCIÓN: calcular_cuota_plan
-- Función para calcular cuota de un plan de financiación
-- ============================================================================
CREATE OR REPLACE FUNCTION calcular_cuota_plan(
    p_monto_principal NUMERIC,
    p_tna NUMERIC,
    p_cantidad_cuotas SMALLINT,
    p_comision_inicial_porciento NUMERIC DEFAULT 0,
    p_seguro_vida_porciento NUMERIC DEFAULT 0
) RETURNS TABLE (
    cuota_valor NUMERIC,
    interes_total NUMERIC,
    monto_total NUMERIC,
    comision_monto NUMERIC,
    seguro_monto NUMERIC
) AS $$
DECLARE
    v_comision NUMERIC;
    v_seguro NUMERIC;
    v_tasa_mensual NUMERIC;
    v_cuota NUMERIC;
    v_interes_total NUMERIC;
    v_monto_total NUMERIC;
BEGIN
    -- Calcular comisión inicial
    v_comision := p_monto_principal * (p_comision_inicial_porciento / 100);
    
    -- Calcular seguro de vida
    v_seguro := p_monto_principal * (p_seguro_vida_porciento / 100);
    
    -- Monto a financiar (principal + comisión + seguro)
    p_monto_principal := p_monto_principal + v_comision + v_seguro;
    
    -- Tasa mensual
    v_tasa_mensual := p_tna / 12 / 100;
    
    -- Calcular cuota con fórmula de anualidad ordinaria
    IF v_tasa_mensual = 0 THEN
        v_cuota := p_monto_principal / p_cantidad_cuotas;
        v_interes_total := 0;
    ELSE
        v_cuota := p_monto_principal * 
                  (v_tasa_mensual * POWER(1 + v_tasa_mensual, p_cantidad_cuotas)) / 
                  (POWER(1 + v_tasa_mensual, p_cantidad_cuotas) - 1);
        v_interes_total := (v_cuota * p_cantidad_cuotas) - p_monto_principal;
    END IF;
    
    v_monto_total := v_cuota * p_cantidad_cuotas;
    
    RETURN QUERY SELECT v_cuota, v_interes_total, v_monto_total, v_comision, v_seguro;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calcular_cuota_plan IS 'Calcula cuota mensuales usando fórmula de anualidad ordinaria. Incluye comisión y seguro.';

-- ============================================================================
-- 10. FUNCIÓN: actualizar_analisis_mensual
-- Función para actualizar el análisis de demanda mensual
-- ============================================================================
CREATE OR REPLACE FUNCTION actualizar_analisis_mensual(
    p_tenant_id UUID,
    p_ano SMALLINT,
    p_mes SMALLINT
) RETURNS void AS $$
DECLARE
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_total_leads INTEGER;
    v_fuentes_json JSONB;
    v_top_vehiculos_json JSONB;
    v_top_planes_json JSONB;
BEGIN
    -- Calcular rango de fechas
    v_fecha_inicio := DATE_TRUNC('month', MAKE_DATE(p_ano, p_mes, 1))::date;
    v_fecha_fin := (DATE_TRUNC('month', MAKE_DATE(p_ano, p_mes, 1)) + INTERVAL '1 month' - INTERVAL '1 day')::date;
    
    -- Actualizar o crear registro de análisis
    INSERT INTO analisis_demanda_mensual (
        tenant_id, ano, mes,
        total_leads,
        leads_nuevo,
        leads_contactado,
        leads_en_negociacion,
        leads_visita_agendada,
        leads_propuesta_enviada,
        leads_ganados,
        leads_perdidos,
        tasa_conversion_porciento,
        precio_promedio_cotizado
    ) 
    SELECT
        p_tenant_id,
        p_ano,
        p_mes,
        COUNT(lc.id),
        COUNT(CASE WHEN lc.estado_lead = 'nuevo' THEN 1 END),
        COUNT(CASE WHEN lc.estado_lead = 'contactado' THEN 1 END),
        COUNT(CASE WHEN lc.estado_lead = 'en_negociacion' THEN 1 END),
        COUNT(CASE WHEN lc.estado_lead = 'visita_agendada' THEN 1 END),
        COUNT(CASE WHEN lc.estado_lead = 'propuesta_enviada' THEN 1 END),
        COUNT(CASE WHEN lc.estado_lead = 'ganado' THEN 1 END),
        COUNT(CASE WHEN lc.estado_lead = 'perdido' THEN 1 END),
        ROUND(
            COUNT(CASE WHEN lc.estado_lead = 'ganado' THEN 1 END)::numeric / 
            COUNT(lc.id)::numeric * 100, 2
        ),
        ROUND(AVG(COALESCE(cp.precio_lista, 0)), 2)
    FROM leads_conversaciones lc
    LEFT JOIN cotizaciones_presupuestos cp ON cp.lead_id = lc.id
    WHERE lc.tenant_id = p_tenant_id
      AND DATE_TRUNC('month', lc.creado_en) = MAKE_DATE(p_ano, p_mes, 1)::timestamp
    ON CONFLICT (tenant_id, ano, mes) DO UPDATE SET
        actualizado_en = NOW()
    ;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION actualizar_analisis_mensual IS 'Actualiza el análisis de demanda mensual automáticamente.';

-- ============================================================================
-- 11. TRIGGERS PARA AUDITORÍA Y ACTUALIZACIÓN DE TIMESTAMPS
-- ============================================================================

CREATE TRIGGER set_actualizado_en_planes
    BEFORE UPDATE ON planes_ahorro
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

CREATE TRIGGER set_actualizado_en_cotizaciones
    BEFORE UPDATE ON cotizaciones_presupuestos
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

CREATE TRIGGER set_actualizado_en_config_cuotas
    BEFORE UPDATE ON configuracion_calculo_cuotas
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

CREATE TRIGGER set_actualizado_en_analisis
    BEFORE UPDATE ON analisis_demanda_mensual
    FOR EACH ROW EXECUTE FUNCTION trigger_set_actualizado_en();

-- ============================================================================
-- FIN DEL SCHEMA EXTENDIDO
-- ============================================================================
