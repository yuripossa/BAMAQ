SELECT 
	'Quiver' as SYSORIGEM,
	C.Cliente AS COD_CLIENTE,
	C.Nome AS CLIENTE,	
	c.Cgc_cpf AS DOCCLI,
	div.Divisao AS COD_EMPRESA,
	DIV.Nome as Empresa,
	'CGF-Seguros' as MATRIZ,
	'A RECEBER' as TIPO_MOVIMENTO,
	MP.Descricao AS TIPO_TITULO,
	CASE d.Situacao 
		WHEN 1 THEN 'Ativa'
		WHEN 2 THEN 'Cancelada'
		WHEN 3 THEN 'Suspensa'
		WHEN 4 THEN 'Renovada'
		WHEN 5 THEN 'Vencida' 
		WHEN 6 THEN 'Perda Total' 
		ELSE 'Desconhecida'
	END AS STATUS_TITULO,
	SG.Nome AS AGENTE_COBRADOR,
	NULL AS NATUREZA_OPERACAO,
	NULL AS DEPARTAMENTO,
	CO.Parc_comissao AS LANCAMENTO_FINANCEIRO,   -- ?
	NULL AS NOSSO_NUMERO_BOLETO,
	d.Proposta AS NUM_TITULO,
	CR.PARCELA AS PARCELA,
	d.DATA_EMISSAO AS DATA_EMISSAO,
	CR.Data_vencimento AS DATA_VENCIMENTO,
	CR.Data_vencimento AS DATA_PREVISAO_PAGAMENTO,
	CR.Data_pagamento AS DATA_PAGAMENTO,
	CO.Valor AS VALOR_TITULO,
	NULL AS TITULO_SALDO,
	GH.NOME AS VENDEDOR, 
	NULL AS NOTA_FISCAL_CODIGO, 
	NULL AS NOTA_FISCAL_NUMERO, 
	NULL AS NOTA_FISCAL_SERIE

FROM TABELA_DOCSPARCSCOM co

INNER JOIN TABELA_DOCSPARCSPREM CR 
(nolock) ON 
CR.Documento = CO.Documento AND CR.Alteracao = CO.Alteracao and CR.Parcela = CO.Parcela

INNER JOIN Tabela_DocsRepasses DR
(nolock) ON 
co.Documento = dr.Documento AND co.Alteracao = dr.Alteracao  

INNER JOIN Tabela_Documentos d
(nolock) ON
Co.Documento = d.Documento and Co.Alteracao = d.Alteracao 

INNER JOIN TABELA_CLIENTES C 
(nolock) ON 
D.CLIENTE = C.CLIENTE

INNER JOIN Tabela_NiveisHierarq NH 
(nolock) ON 
NH.Nivel = DR.Nivel  

LEFT JOIN TABELA_TIPOSDOCEMISS TD 
ON
TD.TIPO_DOCUMENTO = D.TIPO_DOCUMENTO

LEFT JOIN TABELA_MEIOSPAGTO MP 
ON
MP.Meio_pagto = CR.Meio_pagto

LEFT JOIN TABELA_DIVISOES DIV 
ON
DIV.Divisao =  DR.Divisao

LEFT JOIN TABELA_SEGURADORAS SG 
ON 
SG.Seguradora = d.Seguradora

LEFT JOIN TABELA_GRUPOSHIERARQ GH
ON 
GH.Grupo_hierarquico = d.Grupo_hierarquico

WHERE	DR.Nivel = 1 
		AND NH.Descricao = 'CORRETORA' 
		AND CO.Operacao = 'D' 
		AND D.Comissao_quitada = 1 
		AND CO.Data_Operacao BETWEEN '2023-09-01' AND '2023-09-22'
		AND CR.Data_pagamento IS NULL
		AND d.Situacao not in (2,3) 
		--AND CO.Documento = 130725


--select * from TABELA_DOCSPARCSCOM WHERE documento IN (143309)  AND ALTERACAO = 0 ORDER BY Parcela
--select * from [Tabela_DocsParcsPrem] where Documento in (143404,139953,134893) AND CAST(Data_pagamento AS DATE) between '2023-09-01' and '2023-09-12'
--SELECT * FROM [dbo].[Tabela_DocsParcsPrem] Where Documento in (143122,135733)
--select * from Tabela_Documentos where Proposta in (23773) and Data_proposta  between '2023-09-01' and '2023-09-12'
--select * from TABELA_DOCSPARCSCOM WHERE documento IN (143122,135733)
--select * from Tabela_DocsRepasses
--select top 10 * from TABELA_CLIENTES 
--select top 10 * from TABELA_SEGURADORAS
--select top 10 * from TABELA_TIPOSDOCEMISS
--select top 10 * from TABELA_SUBTIPOSDOC
--select top 10 * from TABELA_GRUPOSHIERARQ 
-- SELECT * FROM TABELA_DIVISOES
---select * from [dbo].[Tabela_TiposSitItens]
--SELECT * FROM Tabela_DocsParcsPrem WHERE DOCUMENTO = '130725'

/*
select --c.*, 
d.documento, d.proposta, d.Comissao_quitada, cr.Data_Vencimento, CO.* 
from TABELA_DOCSPARCSCOM co
inner join TABELA_DOCSPARCSPREM cr on cr.Documento = co.Documento and cr.Alteracao = co.Alteracao and cr.Parcela = co.Parcela
inner JOIN Tabela_DocsRepasses DR (nolock) ON co.Documento = dr.Documento AND co.Alteracao = dr.Alteracao 
inner JOIN Tabela_Documentos d on d.Documento = co.Documento and d.Alteracao = co.Alteracao 
inner JOIN TABELA_CLIENTES C  (nolock) ON  D.CLIENTE = C.CLIENTE
where 
--cast(cr.Data_vencimento as date) BETWEEN '2023-09-01' AND '2023-09-22' and
co.Data_operacao BETWEEN '2023-09-01' AND '2023-09-22' and
co.Operacao = 'D' and
DR.Nivel = 1 AND 
cr.Data_pagamento is null and 
d.Comissao_quitada = 1 and
d.Situacao not in (2,3) 
--d.Documento = 138065
--d.Proposta = 14807
order by 1

*/

