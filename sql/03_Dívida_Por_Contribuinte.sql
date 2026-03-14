SELECT 
    D.titprpcod AS "Inscrição",
    C.prpnom AS "Contribuinte",
    C.prpcpf AS "CPF",
    C.prpcnpj AS "CNPJ",

    -- Somatório do valor original da dívida
    SUM(V.pclvlrori) AS "Valor Original",

    -- Somatório dos juros aplicados
    SUM(V.pclvlrjur) AS "Juros",

    -- Somatório das multas aplicadas
    SUM(V.pclvlrmul) AS "Multa",

    -- Somatório da correção monetária
    SUM(V.pclvlrcorr) AS "Correção",

    -- Cálculo do valor total da dívida
    SUM(
        V.pclvlrori +
        V.pclvlrjur +
        V.pclvlrmul +
        V.pclvlrcorr
    ) AS "Total"

FROM Valores V

-- Relação com a tabela de títulos da dívida
JOIN Débitos D 
    ON V.titnum = D.titnum

-- Relação com a tabela de contribuintes
JOIN Contribuintes C 
    ON D.titprpcod = C.prpcod

WHERE 
    -- Considera apenas parcelas em aberto
    V.pclsit = 'A'

    -- Filtra pelo exercício desejado
    AND D.titexerc = 2025

GROUP BY 
    D.titprpcod,
    C.prpnom,
    C.prpcpf,
    C.prpcnpj

-- Ordena do maior valor de dívida para o menor
ORDER BY 
    "Total" DESC;
