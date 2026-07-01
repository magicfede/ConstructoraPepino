-- ============================================================================
-- SEED DATA: Familia Parra — Concesionaria Oficial, Córdoba, Argentina
-- ============================================================================

-- ============================================================================
-- 1. TENANT: Familia Parra
-- ============================================================================
INSERT INTO tenants (id, nombre, slug, rubro, configuracion_json) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Familia Parra',
    'familia-parra',
    'Concesionaria Automotriz Oficial',
    '{
        "brand": {
            "nombre": "Familia Parra",
            "slogan": "Tu próximo auto está acá",
            "fundacion": 1987,
            "descripcion": "Concesionaria oficial multimarca con más de 35 años de trayectoria en Córdoba, Argentina. Representantes oficiales de Fiat, Citroën, BYD, Baic, Jeep y RAM.",
            "marcas_oficiales": ["Fiat", "Citroën", "BYD", "Baic", "Jeep", "RAM"]
        },
        "colors": {
            "primary": "#1a1a2e",
            "secondary": "#c0392b",
            "accent": "#e74c3c",
            "background": "#0f0f1a",
            "surface": "#16213e",
            "text_primary": "#ffffff",
            "text_secondary": "#a0aec0",
            "gradient_start": "#1a1a2e",
            "gradient_end": "#16213e"
        },
        "contact": {
            "whatsapp": "5493515551234",
            "telefono": "+54 351 555-1234",
            "email": "ventas@familiaparra.com.ar",
            "direccion": "Av. Castro Barros 2500, Córdoba, Argentina",
            "sucursales": [
                {"nombre": "Casa Central", "direccion": "Av. Castro Barros 2500, Córdoba"},
                {"nombre": "Villa Cabrera", "direccion": "Rafael Núñez 4100, Córdoba"}
            ],
            "horarios": {
                "lunes_viernes": "08:30 - 18:30",
                "sabados": "09:00 - 13:00"
            }
        },
        "benefits": [
            {
                "icon": "currency",
                "titulo": "Financiación en Cuotas Fijas",
                "descripcion": "Planes accesibles con cuotas fijas en pesos. Financiación directa de fábrica y opciones bancarias."
            },
            {
                "icon": "swap",
                "titulo": "Llave por Llave",
                "descripcion": "Tomamos tu usado como parte de pago. Tasación justa e inmediata en cualquiera de nuestras sucursales."
            },
            {
                "icon": "shield",
                "titulo": "Garantía de Fábrica",
                "descripcion": "Todos nuestros 0km con garantía oficial. Usados seleccionados con garantía Parra de 6 meses."
            },
            {
                "icon": "bot",
                "titulo": "Atención Personalizada IA 24/7",
                "descripcion": "Nuestro asistente inteligente responde tus consultas al instante, cualquier día y a cualquier hora."
            }
        ],
        "hero": {
            "titulo": "Tu próximo auto te espera en Familia Parra",
            "subtitulo": "Más de 35 años siendo la concesionaria de confianza de Córdoba. Encontrá 0km y usados seleccionados de las mejores marcas con financiación a tu medida.",
            "cta_principal": "Ver Catálogo",
            "cta_secundario": "Hablar con un Asesor"
        },
        "seo": {
            "title": "Familia Parra | Concesionaria Oficial en Córdoba — Fiat, Citroën, BYD, Jeep",
            "description": "Concesionaria multimarca en Córdoba, Argentina. Autos 0km y usados seleccionados. Financiación en cuotas fijas, llave por llave. Fiat, Citroën, BYD, Jeep y más.",
            "keywords": ["concesionaria córdoba", "autos 0km córdoba", "familia parra", "fiat córdoba", "byd argentina", "usados seleccionados"]
        }
    }'::jsonb
);

-- ============================================================================
-- 2. CATÁLOGO DE VEHÍCULOS
-- ============================================================================

-- Vehículo 1: Fiat Cronos 0km
INSERT INTO productos_vehiculos (
    tenant_id, marca, modelo, version, anio, precio, moneda, precio_desde,
    tipo_combustible, transmision, kilometraje, estado, color, motor, puertas,
    descripcion, descripcion_corta, caracteristicas, stock, url_imagen,
    metadata_ia, destacado, visible, orden
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Fiat', 'Cronos', '1.3 GSE Drive', 2025, 28500000.00, 'ARS', true,
    'nafta', 'manual', 0, 'nuevo', 'Blanco Alaska', '1.3L 99CV Firefly', 4,
    'El Fiat Cronos 1.3 Drive es el sedán más vendido de Argentina. Ideal para la ciudad y la ruta, combina un motor eficiente con un diseño moderno y espacioso. Disponible con financiación de fábrica Fiat Plan y créditos bancarios en Córdoba.',
    'Sedán compacto líder en ventas. Motor 1.3L Firefly 99CV. Ideal ciudad y ruta.',
    '["Aire acondicionado", "Dirección asistida eléctrica", "Cierre centralizado", "Alzacristales eléctricos x4", "Radio con pantalla táctil 7\"", "Conectividad Android Auto / Apple CarPlay", "Airbags frontales", "ABS + EBD", "Computadora de a bordo", "Baúl de 525 litros"]'::jsonb,
    3, '/images/fiat-cronos.webp',
    '{
        "texto_embedding": "Fiat Cronos 1.3 GSE Drive 2025 0km sedán compacto nafta manual 99CV blanco concesionario oficial Familia Parra Córdoba Argentina financiación cuotas plan Fiat",
        "keywords": ["fiat", "cronos", "sedán", "0km", "nafta", "económico", "plan fiat", "cuotas"],
        "categoria_ia": "sedan_compacto",
        "segmento": "entrada",
        "competidores": ["Volkswagen Virtus", "Chevrolet Onix Plus", "Peugeot 208 Sedán"],
        "planes_financiacion": [
            {"tipo": "Fiat Plan", "cuotas": 84, "descripcion": "Plan de ahorro oficial Fiat"},
            {"tipo": "Crédito Prendario", "cuotas": 60, "descripcion": "Financiación bancaria con tasa preferencial"}
        ],
        "puntos_venta_clave": ["Más vendido de Argentina", "Baúl más grande del segmento", "Bajo costo de mantenimiento"]
    }'::jsonb,
    true, true, 1
);

-- Vehículo 2: Citroën C3 0km
INSERT INTO productos_vehiculos (
    tenant_id, marca, modelo, version, anio, precio, moneda, precio_desde,
    tipo_combustible, transmision, kilometraje, estado, color, motor, puertas,
    descripcion, descripcion_corta, caracteristicas, stock, url_imagen,
    metadata_ia, destacado, visible, orden
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Citroën', 'Nuevo C3', '1.0 Feel', 2025, 26900000.00, 'ARS', true,
    'nafta', 'manual', 0, 'nuevo', 'Gris Artense', '1.0L 75CV Firefly', 5,
    'El Nuevo Citroën C3 redefine el segmento de entrada con su diseño SUV-Like. Espacioso, cómodo y con una altura al piso ideal para las calles de Córdoba. Disponible en Parra Citroën con planes de financiación exclusivos.',
    'SUV-Like de entrada. Diseño elevado, espacioso y moderno. Motor 1.0L eficiente.',
    '["Aire acondicionado", "Dirección asistida", "Alzacristales eléctricos delanteros", "Radio Bluetooth", "Faros halógenos", "Airbags frontales", "ABS", "Altura al piso 180mm", "Baúl de 315 litros", "Asiento trasero rebatible 60/40"]'::jsonb,
    2, '/images/citroen-c3.webp',
    '{
        "texto_embedding": "Citroën Nuevo C3 1.0 Feel 2025 0km SUV-Like hatchback nafta manual 75CV gris concesionario oficial Familia Parra Córdoba Argentina",
        "keywords": ["citroën", "c3", "suv-like", "0km", "económico", "entrada", "córdoba"],
        "categoria_ia": "suv_like_entrada",
        "segmento": "entrada",
        "competidores": ["Fiat Mobi", "Renault Kwid", "Volkswagen Gol"],
        "planes_financiacion": [
            {"tipo": "Citroën Plan", "cuotas": 84, "descripcion": "Plan de ahorro oficial Citroën"},
            {"tipo": "Crédito Prendario", "cuotas": 48, "descripcion": "Financiación bancaria"}
        ],
        "puntos_venta_clave": ["Diseño SUV elevado", "El más espacioso del segmento de entrada", "Bajo consumo"]
    }'::jsonb,
    true, true, 2
);

-- Vehículo 3: BYD Dolphin Mini 0km (Eléctrico)
INSERT INTO productos_vehiculos (
    tenant_id, marca, modelo, version, anio, precio, moneda, precio_desde,
    tipo_combustible, transmision, kilometraje, estado, color, motor, puertas,
    descripcion, descripcion_corta, caracteristicas, stock, url_imagen,
    metadata_ia, destacado, visible, orden
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'BYD', 'Dolphin Mini', 'EV Comfort', 2025, 21900.00, 'USD', false,
    'electrico', 'automatica', 0, 'nuevo', 'Azul Coral', 'Motor Eléctrico 75kW (102CV)', 5,
    'El BYD Dolphin Mini es la puerta de entrada a la movilidad eléctrica. Compacto, ágil y con 0 emisiones. Autonomía de hasta 205km ideal para uso urbano en Córdoba. Carga completa en 8hs con cargador doméstico.',
    '100% eléctrico, 205km de autonomía. El futuro de la movilidad urbana ya está en Córdoba.',
    '["100% Eléctrico - 0 emisiones", "Autonomía 205km NEDC", "Pantalla táctil 10.1\"", "Cámara de retroceso", "Climatizador automático", "Carga rápida DC 40kW", "Frenado regenerativo", "6 Airbags", "Control de estabilidad ESP", "Batería Blade LFP"]'::jsonb,
    1, '/images/byd-dolphin-mini.webp',
    '{
        "texto_embedding": "BYD Dolphin Mini EV eléctrico 2025 0km automático azul 102CV 205km autonomía Familia Parra Córdoba Argentina movilidad sustentable cero emisiones",
        "keywords": ["byd", "dolphin mini", "eléctrico", "ev", "0km", "sustentable", "autonomía"],
        "categoria_ia": "electrico_urbano",
        "segmento": "electrico",
        "competidores": ["Fiat 500e", "Renault Kwid E-Tech"],
        "planes_financiacion": [
            {"tipo": "Crédito USD", "cuotas": 36, "descripcion": "Financiación en dólares"},
            {"tipo": "Crédito Prendario", "cuotas": 60, "descripcion": "Financiación en pesos"}
        ],
        "puntos_venta_clave": ["Más económico en costo por km que nafta", "Mantenimiento mínimo", "Batería Blade ultra-segura"],
        "datos_electrico": {
            "autonomia_km": 205,
            "tipo_bateria": "Blade LFP",
            "capacidad_bateria_kwh": 38,
            "carga_rapida_minutos": 60,
            "carga_domestica_horas": 8
        }
    }'::jsonb,
    true, true, 3
);

-- Vehículo 4: Jeep Renegade Usado Seleccionado
INSERT INTO productos_vehiculos (
    tenant_id, marca, modelo, version, anio, precio, moneda, precio_desde,
    tipo_combustible, transmision, kilometraje, estado, color, motor, puertas,
    descripcion, descripcion_corta, caracteristicas, stock, url_imagen,
    metadata_ia, destacado, visible, orden
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Jeep', 'Renegade', 'Sport 1.8 AT', 2022, 32500000.00, 'ARS', false,
    'nafta', 'automatica', 45000, 'usado', 'Negro Sólido', '1.8L E.TorQ 130CV', 5,
    'Jeep Renegade Sport con transmisión automática de 6 velocidades. Único dueño, service oficial completo en concesionario Familia Parra. Excelente estado general, cubiertas nuevas. Garantía Parra Usados de 6 meses.',
    'SUV automática, único dueño, 45.000km. Service oficial completo. Garantía Parra 6 meses.',
    '["Transmisión automática 6AT", "Aire acondicionado", "Dirección asistida", "Control de tracción", "Hill Start Assist", "Pantalla Uconnect 7\"", "Bluetooth + USB", "4 Airbags", "Cubiertas nuevas", "Service oficial completo"]'::jsonb,
    1, '/images/jeep-renegade.webp',
    '{
        "texto_embedding": "Jeep Renegade Sport 1.8 automática 2022 usado seleccionado 45000km negro SUV Familia Parra Usados Córdoba Argentina garantía service oficial",
        "keywords": ["jeep", "renegade", "suv", "usado", "automática", "garantía", "parra usados"],
        "categoria_ia": "suv_compacto",
        "segmento": "suv",
        "competidores": ["Fiat Pulse", "Volkswagen T-Cross", "Citroën C4 Cactus"],
        "historial_service": [
            {"km": 10000, "fecha": "2022-06", "tipo": "Service 10.000km"},
            {"km": 20000, "fecha": "2023-01", "tipo": "Service 20.000km"},
            {"km": 30000, "fecha": "2023-08", "tipo": "Service 30.000km"},
            {"km": 40000, "fecha": "2024-03", "tipo": "Service 40.000km + cubiertas nuevas"}
        ],
        "estado_detallado": {
            "unico_duenio": true,
            "garantia_meses": 6,
            "tipo_garantia": "Garantía Parra Usados",
            "chapa_pintura": "Excelente",
            "interior": "Excelente",
            "mecanica": "Excelente"
        },
        "puntos_venta_clave": ["Único dueño con service oficial", "Garantía Parra 6 meses", "Automática ideal para ciudad"]
    }'::jsonb,
    false, true, 4
);

-- ============================================================================
-- 3. LEAD DE EJEMPLO
-- ============================================================================
INSERT INTO leads_conversaciones (
    tenant_id, whatsapp_cliente, nombre_cliente, estado_lead,
    vehiculo_interes_id, resumen_ia, sentimiento, intencion_compra,
    tags, cantidad_mensajes, fuente
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    '5493516781234',
    'María González',
    'en_negociacion',
    (SELECT id FROM productos_vehiculos WHERE marca = 'Fiat' AND modelo = 'Cronos' LIMIT 1),
    'Cliente interesada en Fiat Cronos 1.3 Drive. Consulta por financiación en cuotas fijas y posibilidad de entregar su Fiat Palio 2018 como parte de pago. Vive en barrio Nueva Córdoba. Disponibilidad para visitar el concesionario el sábado.',
    'positivo',
    7,
    '["financiación", "llave_por_llave", "cronos", "visita_sabado"]'::jsonb,
    12,
    'whatsapp_web'
);

-- ============================================================================
-- FIN DEL SEED
-- ============================================================================
