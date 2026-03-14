/*
Projeto: Transformação de Dados Cadastrais de Imóveis

Descrição:
Esta consulta consolida informações cadastrais de imóveis e contribuintes,
realizando tratamento e transformação de dados para análise tributária.

A consulta realiza:
- integração de múltiplas tabelas cadastrais
- tratamento de atributos do imóvel
- consolidação de categorias em colunas (pivot)
- recuperação do lançamento tributário mais recente

Técnicas utilizadas:
- CTE (Common Table Expression)
- DISTINCT ON (PostgreSQL)
- STRING_AGG para agregação de atributos
- CASE para tratamento de valores
- pivot de atributos utilizando MAX()
*/

WITH base AS (

SELECT

    -- Identificação do contribuinte
    C.taxpayer_id,
    C.taxpayer_name,

    -- Identificação do imóvel
    P.property_id,
    P.district_code,
    P.sector_code,
    P.block_code,
    P.lot_number,
    P.unit_number,

    -- Informações do logradouro
    A.street_name,
    A.street_id,

    -- Informações de área
    P.built_area_unit,
    P.land_area_m2,
    P.total_built_area,

    -- Informações tributárias
    T.tax_rate,
    T.tax_amount,
    T.land_value,
    T.building_value,

    -- Informações complementares
    P.block_face,
    P.is_exempt,
    P.is_immune,

    -- Informações do logradouro
    A.street_type,
    P.street_number,

    -- Atributo do imóvel
    btrim(F.attribute_name) AS attribute_name,

    STRING_AGG(
        DISTINCT
        CASE
            WHEN AT.category_id IS NULL OR AT.category_id = 0
                THEN NULL
            ELSE CT.category_description
        END,
        ' / '
        ORDER BY
        CASE
            WHEN AT.category_id IS NULL OR AT.category_id = 0
                THEN NULL
            ELSE CT.category_description
        END
    ) AS attribute_value

FROM Properties P

-- Lançamento mais recente do imóvel
LEFT JOIN (
    SELECT DISTINCT ON (property_id)

        property_id,
        tax_rate,
        tax_amount,
        land_value,
        building_value

    FROM PropertyTaxes
    WHERE fiscal_year = 2025
      AND tax_record > 0

    ORDER BY
        property_id,
        tax_sequence DESC
) T
    ON P.property_id = T.property_id

GROUP BY

    C.taxpayer_id,
    C.taxpayer_name,

    P.property_id,
    P.district_code,
    P.sector_code,
    P.block_code,
    P.lot_number,
    P.unit_number,

    A.street_name,
    A.street_id,

    P.built_area_unit,
    P.land_area_m2,
    P.total_built_area,

    T.tax_rate,
    T.tax_amount,
    T.land_value,
    T.building_value,

    P.block_face,
    P.is_exempt,
    P.is_immune,

    A.street_type,
    P.street_number,

    F.attribute_name
)

SELECT

    taxpayer_id AS "Inscrição Contribuinte",
    taxpayer_name AS "Nome Contribuinte",

    property_id AS "Inscrição Imóvel",

    district_code AS "Distrito",
    sector_code AS "Setor",
    block_code AS "Quadra",
    lot_number AS "Lote",
    unit_number AS "Unidade",

    block_face AS "Face de Quadra",

    is_exempt AS "Isento",
    is_immune AS "Imune",

    street_type AS "Tipo Logradouro",
    street_name AS "Logradouro",
    street_id AS "Código Logradouro",
    street_number AS "Número",

    built_area_unit AS "Área Edificada da Unidade",
    land_area_m2 AS "Área Terreno m²",
    total_built_area AS "Área Total Edificada",

    tax_rate AS "Alíquota",
    tax_amount AS "Valor IPTU Lançado",

    land_value AS "Valor Venal Terreno",
    building_value AS "Valor Venal Edificado",

    CASE property_status
        WHEN 'S' THEN 'Ativo'
        WHEN 'N' THEN 'Desativado'
        WHEN 'I' THEN 'Incorporado'
        WHEN 'T' THEN 'Temporário'
        WHEN 'R' THEN 'Imóvel Rural'
        WHEN 'B' THEN 'Bloqueado'
    END AS "Status do Imóvel"

FROM base

GROUP BY

    taxpayer_id,
    taxpayer_name,
    property_id,

    district_code,
    sector_code,
    block_code,
    lot_number,
    unit_number,

    street_name,
    street_id,

    built_area_unit,
    land_area_m2,
    total_built_area,

    tax_rate,
    tax_amount,
    land_value,
    building_value,

    property_status,
    street_type,
    block_face,
    street_number,

    is_exempt,
    is_immune

ORDER BY property_id;
