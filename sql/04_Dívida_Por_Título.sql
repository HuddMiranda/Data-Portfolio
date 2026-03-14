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
    t64.taxpayer_id AS "Inscrição",
    t153.taxpayer_name AS "Contribuinte",
    t153.cpf AS "CPF",
    t153.cnpj AS "CNPJ",

    t64.debt_id AS "Crédito",
    t65.installment_number AS "Parcela",

    t64.tax_type AS "Tributo",
    t64.fiscal_year AS "Exercício",

    -- Valores financeiros da parcela
    t65.original_amount AS "Valor Original",
    t65.interest_amount AS "Juros",
    t65.penalty_amount AS "Multa",
    t65.monetary_correction AS "Correção",

    -- Cálculo do valor total da parcela
    (
        t65.original_amount +
        t65.interest_amount +
        t65.penalty_amount +
        t65.monetary_correction
    ) AS "Total"

FROM tax_debt_installments t65

-- Tabela de títulos da dívida
JOIN tax_debt_titles t64 
    ON t65.debt_id = t64.debt_id

-- Tabela de contribuintes
JOIN taxpayers t153 
    ON t64.taxpayer_id = t153.taxpayer_id

WHERE 
    -- Considera apenas parcelas em aberto
    t65.status = 'ACTIVE'

    -- Filtra pelo exercício
    AND t64.fiscal_year = 2021

-- Ordena pelos maiores valores de dívida
ORDER BY 
    "Total" DESC

-- Retorna apenas os 200 maiores registros
LIMIT 200;
