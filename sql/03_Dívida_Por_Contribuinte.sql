/*
Projeto: Relatório de Dívida Total por Contribuinte

Descrição:
Esta consulta calcula o valor total da dívida de cada contribuinte,
considerando todas as parcelas em aberto registradas no sistema.

O cálculo do total considera:
- valor original
- juros
- multa
- correção monetária

O objetivo é identificar os contribuintes com maior volume de dívida
para fins de análise financeira e priorização de cobrança.

Técnicas utilizadas:
- agregação de dados com SUM
- JOIN entre múltiplas tabelas
- criação de campo calculado
- agrupamento por contribuinte
- ordenação por valor total da dívida
*/

SELECT

    -- Identificação do contribuinte
    D.taxpayer_id AS "Inscrição",
    C.taxpayer_name AS "Contribuinte",
    C.cpf AS "CPF",
    C.cnpj AS "CNPJ",

    -- Somatório do valor original da dívida
    SUM(V.original_amount) AS "Valor Original",

    -- Somatório dos juros aplicados
    SUM(V.interest_amount) AS "Juros",

    -- Somatório das multas aplicadas
    SUM(V.penalty_amount) AS "Multa",

    -- Somatório da correção monetária
    SUM(V.monetary_correction) AS "Correção",

    -- Cálculo do valor total da dívida
    SUM(
        V.original_amount +
        V.interest_amount +
        V.penalty_amount +
        V.monetary_correction
    ) AS "Total"

FROM Valores V

-- Relação com a tabela de títulos da dívida
JOIN Débitos D
    ON V.debt_id = D.debt_id

-- Relação com a tabela de contribuintes
JOIN Contribuintes C
    ON D.taxpayer_id = C.taxpayer_id

WHERE

    -- Considera apenas parcelas em aberto
    V.status = 'ACTIVE'

    -- Filtra pelo exercício desejado
    AND D.fiscal_year = 2025

GROUP BY

    D.taxpayer_id,
    C.taxpayer_name,
    C.cpf,
    C.cnpj

-- Ordena do maior valor de dívida para o menor
ORDER BY
    "Total" DESC;
