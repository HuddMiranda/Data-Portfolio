/*
Projeto: Relatório de Maiores Créditos Individuais

Descrição:
Esta consulta identifica os maiores créditos individuais registrados
no sistema, considerando o valor total da dívida de cada parcela.

O cálculo do total considera:
- valor original
- juros
- multa
- correção monetária

O objetivo é identificar os maiores débitos ativos para fins de análise
ou priorização de cobrança.

Técnicas utilizadas:
- JOIN entre múltiplas tabelas
- criação de campo calculado
- ordenação por valor
- limitação de resultados (ranking)


-- Relatório de maiores créditos individuais

SELECT 
    D.taxpayer_id AS "Inscrição",
    C.taxpayer_name AS "Contribuinte",
    C.cpf AS "CPF",
    C.cnpj AS "CNPJ",

    D.debt_id AS "Crédito",
    V.installment_number AS "Parcela",

    D.tax_type AS "Tributo",
    D.fiscal_year AS "Exercício",

    -- Valores financeiros da parcela
    V.original_amount AS "Valor Original",
    V.interest_amount AS "Juros",
    V.penalty_amount AS "Multa",
    V.monetary_correction AS "Correção",

    -- Cálculo do valor total da parcela
    (
        V.original_amount +
        V.interest_amount +
        V.penalty_amount +
        V.monetary_correction
    ) AS "Total"

FROM Valores V

-- Tabela de títulos da dívida
JOIN Débitos D 
    ON V.debt_id = D.debt_id

-- Tabela de contribuintes
JOIN Contribuintes C 
    ON D.taxpayer_id = C.taxpayer_id

WHERE 
    -- Considera apenas parcelas em aberto
    V.status = 'ACTIVE'

    -- Filtra pelo exercício
    AND D.fiscal_year = 2021

-- Ordena pelos maiores valores de dívida
ORDER BY 
    "Total" DESC

-- Retorna apenas os 200 maiores registros
LIMIT 200;
