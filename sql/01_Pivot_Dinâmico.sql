--Informações dos atributos do terreno e edificação.
SELECT STRING_AGG(linha, E',\n' ORDER BY atrdsc, infcod)
FROM (
         -- format() cria texto dinâmico substituindo os placeholders
         -- %s → valor simples
         -- %L → literal SQL seguro (usado para strings)
         -- %I → identificador SQL (nome de coluna)
    SELECT
        CASE
         -- Quando existe apenas um infcod para o atributo
            WHEN cnt = 1 THEN
                format(
                    '--   MAX(CASE WHEN atrdsc = %L THEN val END) AS %I',
                    atrdsc,
                    atrdsc
                )

            -- Quando existe mais de um infcod
            ELSE
                format(
                    '--   MAX(CASE WHEN atrdsc = %L AND infcod = %s THEN val END) AS %I',
                    atrdsc,
                    infcod,
                    atrdsc || ' (infcod ' || infcod || ')'
                )
        END AS linha,
        atrdsc,
        infcod

    FROM (
        SELECT
            btrim(atrdsc) AS atrdsc,
            infcod,
            COUNT(*) OVER (PARTITION BY atrdsc) AS cnt
        FROM (
            SELECT DISTINCT atrdsc, infcod
            FROM Fatores_Imoveis
        ) a
    ) x

) t;
