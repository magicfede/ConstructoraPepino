-- ============================================================================
-- SEED DATA EXTENDIDO: Familia Parra — Planes de Ahorro y Configuración
-- Versión: 2.0.0
-- ============================================================================

-- ============================================================================
-- 1. PLANES DE AHORRO: Fiat Plan
-- ============================================================================
INSERT INTO planes_ahorro (tenant_id, nombre, tipo_plan, descripcion, entidad, cuotas_minimas, cuotas_maximas, tna_fija, anticipo_porcentaje_minimo, modalidades_pago, requisitos, puntaje_crediticio_requerido, acepta_llave_por_llave, tiene_sorteo, tiene_licitacion, visible, orden)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Fiat Plan 84',
    'fiat_plan_84',
    'Plan de ahorro oficial Fiat. 84 cuotas fijas sin anticipo inicial. Sorteo y licitación mensual.',
    'FCA Automobiles Argentina',
    84,
    84,
    NULL,
    0,
    '["sin_anticipo"]'::jsonb,
    '["DNI", "Último recibo de sueldo", "Servicio a nombre del titular"]'::jsonb,
    false,
    true,
    true,
    true,
    true,
    1
);

INSERT INTO planes_ahorro (tenant_id, nombre, tipo_plan, descripcion, entidad, cuotas_minimas, cuotas_maximas, tna_fija, anticipo_porcentaje_minimo, modalidades_pago, requisitos, puntaje_crediticio_requerido, acepta_llave_por_llave, tiene_sorteo, tiene_licitacion, visible, orden)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Fiat Plan 120',
    'fiat_plan_120',
    'Plan de ahorro extendido. 120 cuotas fijas sin anticipo. Ideal para mayor plazo.',
    'FCA Automobiles Argentina',
    120,
    120,
    NULL,
    0,
    '["sin_anticipo"]'::jsonb,
    '["DNI", "Último recibo de sueldo", "Servicio a nombre del titular"]'::jsonb,
    false,
    true,
    true,
    false,
    true,
    2
);

-- ============================================================================
-- 2. PLANES DE AHORRO: Crédito Prendario
-- ============================================================================
INSERT INTO planes_ahorro (tenant_id, nombre, tipo_plan, descripcion, entidad, cuotas_minimas, cuotas_maximas, tna_fija, anticipo_porcentaje_minimo, modalidades_pago, requisitos, puntaje_crediticio_requerido, acepta_llave_por_llave, tiene_sorteo, tiene_licitacion, visible, orden)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Crédito Prendario 60',
    'credito_prendario_60',
    'Financiación bancaria con garantía prendaria. TNA variable según banco. Cuotas fijas en pesos.',
    'Bancos Adheridos',
    48,
    60,
    12.5,
    20,
    '["anticipo_80_20", "anticipo_70_30"]'::jsonb,
    '["DNI", "Últimos 3 recibos de sueldo", "Buen historial crediticio"]'::jsonb,
    true,
    true,
    false,
    false,
    true,
    3
);

INSERT INTO planes_ahorro (tenant_id, nombre, tipo_plan, descripcion, entidad, cuotas_minimas, cuotas_maximas, tna_fija, anticipo_porcentaje_minimo, modalidades_pago, requisitos, puntaje_crediticio_requerido, acepta_llave_por_llave, tiene_sorteo, tiene_licitacion, visible, orden)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Crédito Prendario 48',
    'credito_prendario_48',
    'Financiación bancaria a plazo reducido. Menor costo de interés. Máximo 48 cuotas.',
    'Bancos Adheridos',
    24,
    48,
    10.8,
    20,
    '["anticipo_80_20"]'::jsonb,
    '["DNI", "Últimos 3 recibos de sueldo", "Buen historial crediticio"]'::jsonb,
    true,
    true,
    false,
    false,
    true,
    4
);

-- ============================================================================
-- 3. PLANES DE AHORRO: BYD Eléctrico
-- ============================================================================
INSERT INTO planes_ahorro (tenant_id, nombre, tipo_plan, descripcion, entidad, cuotas_minimas, cuotas_maximas, tna_fija, anticipo_porcentaje_minimo, modalidades_pago, requisitos, puntaje_crediticio_requerido, acepta_llave_por_llave, tiene_sorteo, tiene_licitacion, visible, orden)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'BYD Financiación USD',
    'byd_plan_36',
    'Plan especial para vehículos BYD eléctricos. Financiación en dólares. Máximo 36 cuotas.',
    'BYD Finance',
    24,
    36,
    8.5,
    0,
    '["sin_anticipo"]'::jsonb,
    '["DNI", "Passport", "Cuenta en dólares"]'::jsonb,
    false,
    false,
    false,
    false,
    true,
    5
);

-- ============================================================================
-- 4. CONFIGURACIÓN DE CÁLCULO DE CUOTAS: Fiat Plan 84
-- ============================================================================
INSERT INTO configuracion_calculo_cuotas (tenant_id, plan_ahorro_id, tna_aplicable, comision_inicial_porciento, seguro_vida_porciento, gastos_admin_porciento, modalidad_pago, descuento_anticipo_porciento, vigente_desde, vigente_hasta, activo)
SELECT
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    (SELECT id FROM planes_ahorro WHERE tipo_plan = 'fiat_plan_84' LIMIT 1),
    0,           -- Sin TNA
    0,           -- Sin comisión
    1.5,         -- Seguro 1.5%
    0.8,         -- Gastos admin 0.8%
    'sin_anticipo',
    0,
    '2026-07-01'::date,
    NULL,
    true;

-- ============================================================================
-- 5. CONFIGURACIÓN DE CÁLCULO DE CUOTAS: Crédito Prendario 60
-- ============================================================================
INSERT INTO configuracion_calculo_cuotas (tenant_id, plan_ahorro_id, tna_aplicable, comision_inicial_porciento, seguro_vida_porciento, gastos_admin_porciento, modalidad_pago, descuento_anticipo_porciento, vigente_desde, vigente_hasta, activo)
SELECT
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    (SELECT id FROM planes_ahorro WHERE tipo_plan = 'credito_prendario_60' LIMIT 1),
    12.5,        -- TNA 12.5%
    2.0,         -- Comisión 2%
    0.8,         -- Seguro 0.8%
    0.5,         -- Gastos admin 0.5%
    'anticipo_80_20',
    2.0,         -- 2% descuento por anticipo mayor
    '2026-07-01'::date,
    NULL,
    true;

INSERT INTO configuracion_calculo_cuotas (tenant_id, plan_ahorro_id, tna_aplicable, comision_inicial_porciento, seguro_vida_porciento, gastos_admin_porciento, modalidad_pago, descuento_anticipo_porciento, vigente_desde, vigente_hasta, activo)
SELECT
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    (SELECT id FROM planes_ahorro WHERE tipo_plan = 'credito_prendario_60' LIMIT 1),
    12.5,        -- TNA 12.5%
    2.0,         -- Comisión 2%
    0.8,         -- Seguro 0.8%
    0.5,         -- Gastos admin 0.5%
    'anticipo_70_30',
    1.0,         -- 1% descuento
    '2026-07-01'::date,
    NULL,
    true;

-- ============================================================================
-- 6. CONFIGURACIÓN DE CÁLCULO DE CUOTAS: BYD Plan
-- ============================================================================
INSERT INTO configuracion_calculo_cuotas (tenant_id, plan_ahorro_id, tna_aplicable, comision_inicial_porciento, seguro_vida_porciento, gastos_admin_porciento, modalidad_pago, descuento_anticipo_porciento, vigente_desde, vigente_hasta, activo)
SELECT
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    (SELECT id FROM planes_ahorro WHERE tipo_plan = 'byd_plan_36' LIMIT 1),
    8.5,         -- TNA 8.5%
    1.5,         -- Comisión 1.5%
    2.0,         -- Seguro 2.0% (EV más seguro)
    0.5,         -- Gastos admin 0.5%
    'sin_anticipo',
    0,
    '2026-07-01'::date,
    NULL,
    true;

-- ============================================================================
-- 7. REGISTRO DE ANÁLISIS MENSUAL INICIAL
-- ============================================================================
INSERT INTO analisis_demanda_mensual (
    tenant_id, ano, mes, total_leads, leads_nuevo, leads_contactado,
    leads_en_negociacion, leads_visita_agendada, leads_propuesta_enviada,
    leads_ganados, leads_perdidos, tasa_conversion_porciento,
    fuentes_leads, interes_electrico_porciento, interes_hibrido_porciento,
    observaciones
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    2026,
    7,
    1,
    1,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    '{"whatsapp_web": 1}'::jsonb,
    15.0,
    5.0,
    'Mes inicial de operación - Base de datos de prueba'
);

-- ============================================================================
-- 8. REGISTRO DE HISTÓRICO DE PRECIOS INICIAL
-- ============================================================================
INSERT INTO historico_precios_vehiculos (vehiculo_id, ano, mes, precio_anterior, precio_actual, precio_usd_referencia, tasa_cambio_referencia, variacion_absoluta, variacion_porciento, stock_disponible)
SELECT
    (SELECT id FROM productos_vehiculos WHERE marca = 'Fiat' AND modelo = 'Cronos' LIMIT 1),
    2026,
    7,
    28200000.00,
    28500000.00,
    23800,
    1200.00,
    300000.00,
    1.06,
    3;

INSERT INTO historico_precios_vehiculos (vehiculo_id, ano, mes, precio_anterior, precio_actual, precio_usd_referencia, tasa_cambio_referencia, variacion_absoluta, variacion_porciento, stock_disponible)
SELECT
    (SELECT id FROM productos_vehiculos WHERE marca = 'Citroën' AND modelo = 'Nuevo C3' LIMIT 1),
    2026,
    7,
    26650000.00,
    26900000.00,
    22400,
    1200.00,
    250000.00,
    0.94,
    2;

INSERT INTO historico_precios_vehiculos (vehiculo_id, ano, mes, precio_anterior, precio_actual, precio_usd_referencia, tasa_cambio_referencia, variacion_absoluta, variacion_porciento, stock_disponible)
SELECT
    (SELECT id FROM productos_vehiculos WHERE marca = 'BYD' AND modelo = 'Dolphin Mini' LIMIT 1),
    2026,
    7,
    21500.00,
    21900.00,
    23800,
    1200.00,
    400.00,
    1.86,
    1;

-- ============================================================================
-- FIN DEL SEED DATA EXTENDIDO
-- ============================================================================
