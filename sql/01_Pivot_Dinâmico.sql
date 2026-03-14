/*
Projeto: Gerar Colunas para Pivot de Atributos

Descrição:
Esta consulta gera automaticamente as expressões SQL necessárias
para transformar atributos de imóveis em colunas (pivot).

Cada linha retornada representa uma expressão SQL que pode ser
utilizada em consultas de transformação de dados cadastrais.

O script identifica:
- atributos que possuem apenas um grupo de informação
- atributos que possuem múltiplos grupos (infcod)

Isso evita conflitos de nomes e garante que cada coluna seja criada
corretamente no pivot final.

Técnicas utilizadas:
- geração dinâmica de SQL com format()
- agregação de texto com STRING_AGG
- funções de janela (COUNT OVER)
- tratamento de strings com BTRIM
*/

-- Geração automática das colunas do pivot
SELECT STRING_AGG(linha, E',\n' ORDER BY attribute_name, info_group)
FROM (

    SELECT
        CASE

            -- Quando existe apenas um grupo de informação para o atributo
            WHEN attribute_count = 1 THEN
                format(
                    '--   MAX(CASE WHEN attribute_name = %L THEN attribute_value END) AS %I',
                    attribute_name,
                    attribute_name
                )

            -- Quando o atributo existe em mais de um grupo
            ELSE
                format(
                    '--   MAX(CASE WHEN attribute_name = %L AND info_group = %s THEN attribute_value END) AS %I',
                    attribute_name,
                    info_group,
                    attribute_name || ' (grupo ' || info_group || ')'
                )

        END AS linha,

        attribute_name,
        info_group

    FROM (

        SELECT
            btrim(attribute_name) AS attribute_name,
            info_group,
            COUNT(*) OVER (PARTITION BY attribute_name) AS attribute_count

        FROM (
            SELECT DISTINCT
                attribute_name,
                info_group
            FROM PropertyAttributes
        ) base

    ) atributos

) resultado;
