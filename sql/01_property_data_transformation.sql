--Select final utilizando as informações do 
--dynamic_pivot_generator.sql.
--(Linhas 206 a 233)

WITH base AS (

    SELECT

		d.prpcod,
        d.prpnom,

        a.bcicod,
        a.discod,
        a.setcod,
        a.qdacod,
        a.bcilot,
        a.bciund,

        b.lgrnom,
        b.lgrcod,

        a.bciareediund,
        a.bciareterm2,
        a.bciaretotedif,

        x.bcitrbalq,
        x.bcitrbvlr,
        x.bcivlrvenalterr,
        x.bcivlrvenaledif,

        a.qdaseg,
        bcilgrcomp,
        bcicomplemaux,
        a.baicod,
        bainom,

        a.ltmcod,
        ltmnom,
        ltmqda,
        ltmlot,
        BciLtmcod,
        bciltmblq,
        bciltmapto,

        Bcitesprinc,
        bciprof,
        lgrseg,
        bcilgrnum,
        bciisento,
        bciimune,

        f.infcod,
        bciativo,
        lgrtip,

        -- BTRIM remove espaços no início e fim do texto
        btrim(f.atrdsc) AS atrdsc,

        -- Função de agregação que concatena múltiplas linhas
        --  em uma única string;
        -- DISTINCT evita valores repetidos;
        -- ' / ' é o separador entre os valores concatenados;
        -- ORDER BY dentro do STRING_AGG garante a ordem
        --  dos valores concatenados.

        STRING_AGG(
            DISTINCT
                CASE
                    -- CASE usado para ignorar categorias inválidas
                    WHEN e.catcod IS NULL OR e.catcod = 0
                        THEN NULL
                    ELSE g.catdscred
                END,
            ' / '
            ORDER BY
                CASE
                    WHEN e.catcod IS NULL OR e.catcod = 0
                        THEN NULL
                    ELSE g.catdscred
                END
        ) AS val

    FROM Imoveis AS a


    -- DISTINCT ON é uma funcionalidade do PostgreSQL que
    -- retorna apenas uma linha por chave especificada;
    -- Neste caso, pega o registro mais recente
    -- (bciseqlanc DESC).

    LEFT JOIN (
        SELECT DISTINCT ON (bcicod)
            bcicod,
            bcitrbalq,
            bcitrbvlr,
            bcivlrvenalterr,
            bcivlrvenaledif
        FROM Calculo_IPTU
        WHERE bciexerc = 2025
          AND bcititnum > 0
        ORDER BY
            bcicod,
            bciseqlanc DESC
    ) x
        ON a.bcicod = x.bcicod


    -- Todas as colunas que não estão em agregações
    -- precisam estar no GROUP BY.

    GROUP BY
        d.prpcod,
        d.prpnom,

        a.bcicod,
        a.discod,
        a.setcod,
        a.qdacod,
        a.bcilot,
        a.bciund,

        b.lgrnom,
        b.lgrcod,

        a.bciareediund,
        a.bciareterm2,
        a.bciaretotedif,

        a.qdaseg,
        bcilgrcomp,
        bcicomplemaux,
        a.baicod,
        bainom,

        a.ltmcod,
        ltmnom,
        ltmqda,
        ltmlot,
        BciLtmcod,
        bciltmblq,
        bciltmapto,

        Bcitesprinc,
        bciprof,
        lgrseg,
        bcilgrnum,
        bciisento,
        bciimune,

        x.bcitrbalq,
        x.bcitrbvlr,
        x.bcivlrvenalterr,
        x.bcivlrvenaledif,

        f.infcod,
        f.atrdsc,

        bciativo,
        lgrtip
)

SELECT

    prpcod AS "inscrição Contribuinte",
    prpnom AS "Nome Contribuinte",
    bcicod AS "Inscrição imóvel",

    discod AS "Distrito",
    setcod AS "Setor",
    qdacod AS "Quadra",
    bcilot AS "Lote",
    bciund AS "Unidade",

    qdaseg   AS "Face de quadra",
    bciisento AS "Isento",
    bciimune  AS "imune",

    lgrtip AS "Tipo",
    lgrnom AS "Logradouro",
    lgrcod AS "Código Logradouro",
    bcilgrnum AS "Número",

    bciareediund  AS "Área Edificada da Unidade",
    bciareterm2   AS "Área Terreno m²",
    bciaretotedif AS "Área Total Edificada",

    bcitrbalq AS "Alíquota",
    bcitrbvlr AS "Valor IPTU Lançado",

    bcivlrvenalterr AS "Valor Venal Terreno",
    bcivlrvenaledif AS "Valor Venal Edificado",

    CASE bciativo
        WHEN 'S' THEN 'Ativo'
        WHEN 'N' THEN 'Desativado'
        WHEN 'I' THEN 'Incorporado'
        WHEN 'T' THEN 'Temporário'
        WHEN 'R' THEN 'Imóvel Rural'
        WHEN 'B' THEN 'Bloqueado'
    END AS "Status do Imóvel",

    -- Cada atributo vira uma coluna;
    -- MAX() é usado apenas como agregador para permitir o pivot das linhas;
    -- O CASE seleciona apenas o atributo correspondente.

    MAX(CASE WHEN atrdsc = 'ABASTECIMENTO D''AGUA'      THEN val END) AS "ABASTECIMENTO D'AGUA",
    MAX(CASE WHEN atrdsc = 'ACABAMENTO EXTERNO'         THEN val END) AS "ACABAMENTO EXTERNO",
    MAX(CASE WHEN atrdsc = 'ACABAMENTO INTERNO'         THEN val END) AS "ACABAMENTO INTERNO",
    MAX(CASE WHEN atrdsc = 'ADEQUAÇÃO PARA OCUPAÇÃO'    THEN val END) AS "ADEQUAÇÃO PARA OCUPAÇÃO",
    MAX(CASE WHEN atrdsc = 'ARVORE NO PASSEIO'          THEN val END) AS "ARVORE NO PASSEIO",
    MAX(CASE WHEN atrdsc = 'ATRIBUTOS ESPECIAIS'        THEN val END) AS "ATRIBUTOS ESPECIAIS",
    MAX(CASE WHEN atrdsc = 'BENFEITORIA'                THEN val END) AS "BENFEITORIA",
    MAX(CASE WHEN atrdsc = 'CLASSIFICAÇÃO ARQ.'         THEN val END) AS "CLASSIFICAÇÃO ARQ.",
    MAX(CASE WHEN atrdsc = 'COBERTURA'                  THEN val END) AS "COBERTURA",
    MAX(CASE WHEN atrdsc = 'CONSERVAÇÃO'                THEN val END) AS "CONSERVAÇÃO",
    MAX(CASE WHEN atrdsc = 'ESQUADRIA'                  THEN val END) AS "ESQUADRIA",
    MAX(CASE WHEN atrdsc = 'ESTRUTURA'                  THEN val END) AS "ESTRUTURA",
    MAX(CASE WHEN atrdsc = 'FORRO'                      THEN val END) AS "FORRO",
    MAX(CASE WHEN atrdsc = 'INSTALAÇÃO ELETRICA'        THEN val END) AS "INSTALAÇÃO ELETRICA",
    MAX(CASE WHEN atrdsc = 'INSTALAÇÃO SANITARIA'       THEN val END) AS "INSTALAÇÃO SANITARIA",
    MAX(CASE WHEN atrdsc = 'NATUREZA'                   THEN val END) AS "NATUREZA",
    MAX(CASE WHEN atrdsc = 'OCUPAÇÃO DO LOTE'           THEN val END) AS "OCUPAÇÃO DO LOTE",
    MAX(CASE WHEN atrdsc = 'PASSEIO PARA PEDESTRE'      THEN val END) AS "PASSEIO PARA PEDESTRE",
    MAX(CASE WHEN atrdsc = 'PATRIMONIO'                 THEN val END) AS "PATRIMONIO",
    MAX(CASE WHEN atrdsc = 'PISO'                       THEN val END) AS "PISO",
    MAX(CASE WHEN atrdsc = 'POSICAO FISCAL'             THEN val END) AS "POSICAO FISCAL",
    MAX(CASE WHEN atrdsc = 'RESERVATORIO D''AGUA'       THEN val END) AS "RESERVATORIO D'AGUA",
    MAX(CASE WHEN atrdsc = 'SANITARIO'                  THEN val END) AS "SANITARIO",
    MAX(CASE WHEN atrdsc = 'SANITÁRIO'                  THEN val END) AS "SANITÁRIO",
    MAX(CASE WHEN atrdsc = 'SITUAÇÃO PATRIMONIO'        THEN val END) AS "SITUAÇÃO PATRIMONIO",
    MAX(CASE WHEN atrdsc = 'TIPO'                       THEN val END) AS "TIPO",
    MAX(CASE WHEN atrdsc = 'TIPO DE EDIFICAÇÃO'         THEN val END) AS "TIPO DE EDIFICAÇÃO",
    MAX(CASE WHEN atrdsc = 'TOPOGRAFIA DO LOTE'         THEN val END) AS "TOPOGRAFIA DO LOTE",

    -- Alguns atributos existem em mais de um grupo
    -- (identificado por infcod).

    MAX(CASE WHEN atrdsc = 'SITUAÇÃO'  AND infcod = 4 THEN val END) AS "SITUAÇÃO (Terreno)",
    MAX(CASE WHEN atrdsc = 'SITUAÇÃO'  AND infcod = 5 THEN val END) AS "SITUAÇÃO (Prédio)",

    MAX(CASE WHEN atrdsc = 'UTILIZAÇÃO' AND infcod = 4 THEN val END) AS "UTILIZAÇÃO (Terreno)",
    MAX(CASE WHEN atrdsc = 'UTILIZAÇÃO' AND infcod = 5 THEN val END) AS "UTILIZAÇÃO (Prédio)"

FROM base


-- GROUP BY final
-- Necessário porque usamos MAX() nas colunas pivotadas.

GROUP BY
    prpcod,
    prpnom,
    bcicod,
    discod,
    setcod,
    qdacod,
    bcilot,
    bciund,

    lgrnom,
    lgrcod,

    bciareediund,
    bciareterm2,
    bciaretotedif,

    bcitrbalq,
    bcitrbvlr,

    bcivlrvenalterr,
    bcivlrvenaledif,

    bciativo,
    lgrtip,

    qdaseg,
    bcilgrcomp,
    bcicomplemaux,

    baicod,
    bainom,

    ltmcod,
    ltmnom,
    ltmqda,
    ltmlot,

    BciLtmcod,
    bciltmblq,
    bciltmapto,

    Bcitesprinc,
    bciprof,
    lgrseg,
    bcilgrnum,

    bciisento,
    bciimune

ORDER BY bcicod;
