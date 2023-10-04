-- LISTA DAS PARCELAS PAGAS NOS ULTIMOS 5 ANOS
SELECT 
	'NEWCON' AS SYSORIGEM, 
	CORCC023.ID_Pessoa as CODCLIENTE,
	CORCC023.NM_Pessoa as CLIENTE,
	CORCC023.CD_Inscricao_Nacional as DOCCLI,
	'1' AS COD_EMPRESA,
	'BAMAQ CONSÓRCIO' AS EMPRESA,
	'BAMAQ CONSÓRCIO' AS MATRIZ,
	'CONTAS A RECEBER' AS TIPO_MOVIMENTO,
	CONCC025.NM_Tipo_Documento AS TIPO_TITULO,
	NULL AS FORMA_PAGAMENTO,
	a.NM_CD_Movto_Fin AS STATUS_TITULO,
	CONFI008I.NM_Banco_Reduzido AS AGENTE_COBRADOR,
	NULL AS NATUREZA_OPERACAO,
	CONVE001.NM_Fantasia AS DEPARTAMENTO,
	a.ID_Movimento_Grupo AS LANCAMENTO_FINANCEIRO,
	CONFI008I.Nosso_Numero AS NOSSO_NUMERO,	
	REPLICATE('0',(10-LEN(CAST(CONVE002.id_cota AS varchar(10))))) + CAST(CONVE002.id_cota AS varchar(10)) +  + ' - ' + CAST(a.NO_Parcela AS VARCHAR(2))  AS NUM_TITULO,
	A.NO_PARCELA AS PARCELA,
	NULL AS NEGATIVADO,
	NULL AS DATA_CANCELAMENTO,
	NULL AS DATA_EMISSAO,
	A.DT_VENCIMENTO AS DATA_VENCIMENTO,
	A.DT_Pagamento AS DATA_PAGAMENTO,
	A.DT_VENCIMENTO AS DATA_PREVISAO_PAGAMENTO,
	A.VL_Ideal AS VALOR_NOMINAL_TITULO,
	A.VL_MU AS MULTA,
	A.VL_JU AS JUROS,
	(A.VL_Ideal + A.VL_MJ)  AS VALOR_DEVIDO,
	0 AS TITULO_SALDO,
	A.VL_Pago  AS VALORPAGO,
	A.VL_SG AS VALOR_SEGURO,
	A.VL_FR AS VALOR_FUNDO_RESERVA,
	A.VL_TA AS VALOR_TAXA_ADMINSTRATIVA,
	NULL AS VALOR_COMISSAO,
	'N' AS TEM_DEVOLUCAO,
	'N' AS EH_DEVOLUCAO,
	NULL AS VENDEDOR,
	NULL AS NOTA_FISCAL_CODIGO, 
	NULL AS NOTA_FISCAL_NUMERO, 
	NULL AS NOTA_FISCAL_SERIE

FROM CORCC000  
CROSS JOIN CONVE002  
INNER JOIN fn_rsFiMovtoFinCotaExtrato() a on a.id_cota = CONVE002.ID_Cota

INNER JOIN CORCC023 -- PESSOA
ON 
CORCC023.ID_Pessoa = CONVE002.ID_Pessoa

INNER JOIN CONCC030
ON
CONCC030.ID_CONCC030 = CONVE002.ID_CONCC030

LEFT JOIN CONCC025 -- TIPO DE DOCUMENTO
ON 
CONCC025.ID_Tipo_Documento = CONCC030.ID_Tipo_Documento

LEFT JOIN CONVE001  -- CADASTRO DA EQUIPE DE BEM
ON
CONVE001.ID_Ponto_Venda = CONVE002.ID_Ponto_Venda

LEFT JOIN CONFI008G 
ON 
CONFI008G.ID_Movimento_Grupo = a.ID_Movimento_Grupo

LEFT JOIN CONFI008 
ON 
CONFI008.ID_Cota = a.ID_Cota AND CONFI008.ID_CONFI008 = CONFI008G.ID_CONFI008

LEFT JOIN CONFI008I 
ON 
CONFI008I.ID_CONFI008 = CONFI008.ID_CONFI008

WHERE CONVE002.Versao < 50  
AND A.DT_Vencimento >= DATEADD(yy,-5,getdate()) 
--AND A.ID_Cota = 45942


UNION ALL

-- LISTA DAS PARCELAS EM ABERTO, VENCIDAS E A VENCER NO PRÓXIMO MÊS
SELECT 
	'NEWCON' AS SYSORIGEM, 
	CORCC023.ID_Pessoa as CODCLIENTE,
	CORCC023.NM_Pessoa as CLIENTE,
	CORCC023.CD_Inscricao_Nacional as DOCCLI,
	'1' AS COD_EMPRESA,
	'BAMAQ CONSÓRCIO' AS EMPRESA,
	'BAMAQ CONSÓRCIO' AS MATRIZ,
	'CONTAS A RECEBER' AS TIPO_MOVIMENTO,
	CONCC025.NM_Tipo_Documento AS TIPO_TITULO,
	NULL AS FORMA_PAGAMENTO,
	'EM ABERTO' AS STATUS_TITULO,
	NULL AS AGENTE_COBRADOR,
	NULL AS NATUREZA_OPERACAO,
	CONVE001.NM_Fantasia AS DEPARTAMENTO,
	NULL AS LANCAMENTO_FINANCEIRO,
	NULL AS NOSSO_NUMERO,	
	REPLICATE('0',(10-LEN(CAST(CONVE002.id_cota AS varchar(10))))) + CAST(CONVE002.id_cota AS varchar(10)) +  + ' - ' + CAST(a.NO_Parcela AS VARCHAR(2))  AS NUM_TITULO,
	A.NO_PARCELA AS PARCELA,
	NULL AS NEGATIVADO, 
	NULL AS DATA_CANCELAMENTO,
	NULL AS DATA_EMISSAO,
	A.DT_VENCIMENTO AS DATA_VENCIMENTO,
	NULL AS DATA_PAGAMENTO,
	A.DT_VENCIMENTO AS DATA_PREVISAO_PAGAMENTO,
	A.VL_LANCAMENTO AS VALOR_NOMINAL_TITULO,
	A.VL_MU AS MULTA,
	A.VL_JU AS JUROS,
	(A.VL_LANCAMENTO + A.VL_MJ) AS VALOR_DEVIDO,
	0 AS TITULO_SALDO,
	0 AS VL_PAGO,
	0 AS VALOR_SEGURO,
	0 AS VALOR_FUNDO_RESERVA,
	0 AS VALOR_TAXA_ADMINSTRATIVA,
	NULL AS VALOR_COMISSAO,
	'N' AS TEM_DEVOLUCAO,
	'N' AS EH_DEVOLUCAO,
	NULL AS VENDEDOR,
	NULL AS NOTA_FISCAL_CODIGO, 
	NULL AS NOTA_FISCAL_NUMERO, 
	NULL AS NOTA_FISCAL_SERIE
FROM CORCC000  
CROSS JOIN CONVE002  
CROSS APPLY dbo.fn_dsCoAvisoCobranca(CONVE002.ID_Cota, CORCC000.DT_Base_Processamento, CORCC000.DT_Base_Processamento) AS a  

INNER JOIN CORCC023 -- PESSOA
ON 
CORCC023.ID_Pessoa = CONVE002.ID_Pessoa

INNER JOIN CONCC030
ON
CONCC030.ID_CONCC030 = CONVE002.ID_CONCC030

LEFT JOIN CONCC025 -- TIPO DE DOCUMENTO
ON 
CONCC025.ID_Tipo_Documento = CONCC030.ID_Tipo_Documento

LEFT JOIN CONVE001  -- CADASTRO DA EQUIPE DE BEM
ON
CONVE001.ID_Ponto_Venda = CONVE002.ID_Ponto_Venda

WHERE CONVE002.Versao < 50
AND A.DT_Vencimento between DATEADD(yy,-5,getdate()) and DATEADD(mm,1,getdate())
--AND ID_Cota = 45942
order by A.DT_Vencimento desc



/*


--select * from fn_rsFiMovtoFinCotaExtrato() where ID_Cota = 45942
--SELECT * FROM fn_dsCoAvisoCobranca (45942,GETDATE(),GETDATE())

select * from fn_dsCoPlanoCobranca (45942,getdate(), 1,1000) where SN_Paga <> 'S'  -- Esse aqui possui TODAS as parcelas a vencer

select * from sysobjects where name like '%RECOBRAN%' and xtype = 'IF'

SP_HELPTEXT vw_ReCobranca
select * from fn_dsCoAvisoCobranca (56201,'2023-09-29', '2023-09-29')
select * from fn_dsFiMovtoFinCotaExtrato (56201,'CO','S') order by NO_Parcela        ----------- ****** MELHOR OPÇÃO PARA PARCELAS JÁ PAGAS

select name, 'select top 3 * from ' + name from sysobjects where name like '%rec%' and xtype = 'V'

select top 1000 * from CONVE002 where id_cota = 153497

select * from fn_dsFiMovtoFinCotaExtrato (56201,'CO','S') order by NO_Parcela        ----------- ****** MELHOR OPÇÃO PARA PARCELAS JÁ PAGAS
select * from fn_rsFiMovtoFinCota()  -- DADOS DE PARCELAS, bem mais completo, MAS SOMENTE QUE JÁ FORAM PAGAS
select * from [dbo].[CONFI005C] where id_cota = 56201  -- DADOS DE PARCELAS, MAS SOMENTE QUE JÁ FORAM PAGAS
select * from [dbo].[vw_rel_contasareceber] where ID_Cota = 56201					--******* MELHOR OPCAO PARA INFORMAÇÕES DAS COTAS EM ABERTO, MAS NÃO É O QUE PRECISO AINDA
select * from [dbo].[CONFI004] -- Armazena os tipos de contribuições com suas  características
select * from [dbo].[CONFI001]  -- Tipo de movimento financeiro
--SELECT TOP 10 * FROM CONCC030
--select * from fn_dsFiMovtoFinCotaExtrato (153497,'CO','S')

select * from CONVE036 where id_cota = 56201  -- Percentuais do FC e FA de cada parcela de uma cota
select * from CONVE038 where id_cota = 56201  -- Ligação da parcela da cota com o histograma e ID da assembleia.
select * from CONVE037 where ID_Histograma in (10,40,100) -- relaciona com as parcelas e permite identificar a situação da parcela.
select * from [dbo].[CONGR005]
select * from fn_rsFiMovtoFinCota() where ID_Cota = 56201
select * from fn_rsRDMovFin
sp_helptext fn_dsFiMovtoFinCotaExtrato
select * from fn_dsFiMovtoFinCotaExtrato (56201,'CO','S') order by NO_Parcela   
SELECT * FROM fn_rsFiMovtoFinCotaExtrato() WHERE ID_COTA = 56201 order by NO_Parcela   
*/