SELECT 
	'NBS' AS SYSORIGEM, 
	'N' AS TEM_DEVOLUCAO,
	'N' AS EH_DEVOLUCAO,
   	C.COD_CLIENTE AS CODCLIENTE,
	C.NOME AS CLIENTE,    
    CASE WHEN CD.CPF IS NULL THEN CD.CGC
         WHEN CD.CGC IS NULL THEN CD.CPF 
         END AS DOCCLI,    
	CAST(E.COD_EMPRESA AS VARCHAR(10)) AS COD_EMPRESA,
	CAST(E.NOME AS VARCHAR(150)) AS EMPRESA,
	(SELECT NOME FROM EMPRESAS WHERE COD_EMPRESA = E.COD_MATRIZ) AS MATRIZ, 
	'A RECEBER' as TIPO_MOVIMENTO,	
	CC.NOME AS TIPO_TITULO,
	'CARTAO DE CREDITO' AS FORMA_PAGAMENTO,
	'1' AS STATUS_TITULO,
	'ATIVO' AS DESC_STATUS,
	NULL AS AGENTE_COBRADOR,
	'RECEBIMENTO CARTÃO DE CRÉDITO' AS NATUREZA_OPERACAO,	
	NULL AS DEPARTAMENTO,
	RPAD('0',9-LENGTH(CAST(cr.COD_CONTROLE_CARTAO AS VARCHAR(9))),'0') || CAST(cr.COD_CONTROLE_CARTAO AS VARCHAR(9)) || RPAD('0',2-LENGTH(CAST(CP.PARCELA AS VARCHAR(2))),'0') || CAST(CP.PARCELA AS VARCHAR(2)) AS LANCAMENTO_FINANCEIRO,
	NULL AS NOSSO_NUMERO,	
	CR.COD_CONTROLE_CARTAO AS NUM_TITULO,
	CP.PARCELA AS PARCELA,
	NULL AS NEGATIVADO,
	NULL AS DATA_CANCELAMENTO,
	CR.DATA AS DATA_EMISSAO,
	CP.DATA_VENCIMENTO AS DATA_VENCIMENTO,
	CP.DATA_VENCIMENTO AS DATA_PREVISAO_PAGAMENTO,
	CP.DATA_BAIXA AS DATA_PAGAMENTO,
	CP.VALOR AS VALOR_TITULO,
	CP.VALOR AS VALOR_DEVIDO,
	CP.VALOR AS TITULO_SALDO,
	Cc.Comissao_Cartao AS VALOR_COMISSAO,														--- ????????
    GETVENDEDORCARTAO (CR.COD_EMPRESA, CR.COD_CONTROLE_CARTAO) AS COD_VENDEDOR,	
	NULL AS NOTA_FISCAL_CODIGO, 
	NULL AS NOTA_FISCAL_NUMERO, 
	NULL AS NOTA_FISCAL_SERIE	

FROM CRECEBER_CARTAO CR

INNER JOIN CRECEBER_CARTAO_PARC CP 
ON 
CR.COD_EMPRESA = CP.COD_EMPRESA AND CR.COD_CONTROLE_CARTAO = CP.COD_CONTROLE_CARTAO AND CR.DATA = CP.DATA

INNER JOIN CARTAO_CREDITO CC 
ON
CC.COD_EMPRESA = CR.COD_EMPRESA AND CC.COD_CARTAO_CREDITO = CR.COD_CARTAO_CREDITO

INNER JOIN CLIENTES C  
ON
C.COD_CLIENTE = CR.COD_CLIENTE 

INNER JOIN CLIENTE_DIVERSO CD 
ON
CR.COD_CLIENTE = CD.COD_CLIENTE 

INNER JOIN EMPRESAS E
ON
E.COD_EMPRESA = CR.COD_EMPRESA

LEFT JOIN VENDAS VD
ON
VD.COD_EMPRESA = CR.COD_EMPRESA AND VD.CONTROLE = CR.CONTROLE_VENDA AND VD.SERIE = CR.SERIE_VENDA

LEFT JOIN CONTA_CORRENTE CT
ON 
CT.COD_EMPRESA = CP.COD_EMPRESA AND CT.COD_CONTA_CORRENTE = CP.CONTA_BAIXA

LEFT JOIN NATUREZA_RECEITA_DESPESA NAT
ON 
NAT.COD_NATUREZA_RECEITA_DESPESA  = CR.COD_NATUREZA_RECEITA_DESPESA AND NAT.COD_GRUPO_PC = CR.COD_GRUPO_PC

WHERE Trunc(CP.Data_Vencimento) BETWEEN TO_DATE('2023-09-01', 'YYYY-MM-DD') AND TO_DATE('2023-09-28', 'YYYY-MM-DD')
	  AND CP.Conta_Baixa is Null 
	  --AND E.COD_EMPRESA IN (401)	  
	  

UNION ALL   
	  

SELECT DISTINCT
	'NBS' as SYSORIGEM, 
	NVL(FR.TEM_DEVOLUCAO,'N') AS TEM_DEVOLUCAO,
	NVL(FR.EH_DEVOLUCAO,'N') AS EH_DEVOLUCAO,
   	C.COD_CLIENTE AS CODCLIENTE,
	C.NOME AS CLIENTE,    
    CASE WHEN CD.CPF IS NULL THEN CD.CGC
         WHEN CD.CGC IS NULL THEN CD.CPF 
         END AS DOCCLI,    
	CAST(E.COD_EMPRESA AS VARCHAR(10)) AS COD_EMPRESA,
	CAST(E.NOME AS VARCHAR(150)) AS EMPRESA,
	(SELECT NOME FROM EMPRESAS WHERE COD_EMPRESA = E.COD_MATRIZ) AS MATRIZ, 
	'A RECEBER' as TIPO_MOVIMENTO,	
	FP.DESCRICAO AS TIPO_TITULO,
	fc.DESCRICAO  AS FORMA_PAGAMENTO,
	CR.STATUS_COBRANCA AS STATUS_TITULO,
	SF.DESCRICAO AS DESC_STATUS,
	NULL AS AGENTE_COBRADOR,
	nrd.DESCRICAO AS NATUREZA_OPERACAO,	
	NULL AS DEPARTAMENTO,
	RPAD('0',9-LENGTH(CAST(cr.NR_FATURA AS VARCHAR(9))),'0') || CAST(cr.NR_FATURA AS VARCHAR(9)) || RPAD('0',2-LENGTH(CAST(cr.PARCELA AS VARCHAR(2))),'0') || CAST(cr.PARCELA AS VARCHAR(2)) AS LANCAMENTO_FINANCEIRO,
	TO_CHAR(NVL(CR.NOSSO_NUMERO,'')) || '-' || 	NVL(CR.DG_NOSSO_NUMERO,'') AS NOSSO_NUMERO,	
	CR.NR_FATURA AS NUM_TITULO,
	CR.PARCELA AS PARCELA,
	NVL(CR.NEGATIVADO,'N') as NEGATIVADO,
	FR.DATA_CANCEL AS DATA_CANCELAMENTO,
	CR.DATA_EMISSAO AS DATA_EMISSAO,
	CR.DATA_VENCIMENTO AS DATA_VENCIMENTO,
	CR.DATA_VENCIMENTO AS DATA_PREVISAO_PAGAMENTO,
	CR.DATA_BAIXA AS DATA_PAGAMENTO,
	CR.VALOR_PARCELA AS VALOR_TITULO,
	CR.SALDO_PARCELA AS VALOR_DEVIDO,
	--V.TOTAL_NOTA, 
	CR.SALDO_PARCELA AS TITULO_SALDO,
	CR.VALOR_COMISSAO  AS VALOR_COMISSAO,
	EU.NOME AS COD_VENDEDOR,	
	NULL AS NOTA_FISCAL_CODIGO, 
	NULL AS NOTA_FISCAL_NUMERO, 
	NULL AS NOTA_FISCAL_SERIE	
FROM CONTAS_RECEBER CR 

INNER JOIN FATURA_RECEBER FR  
ON 
CR.NR_FATURA = FR.NR_FATURA AND CR.COD_EMPRESA = FR.COD_EMPRESA AND CR.COD_TIPO_FATURA = FR.COD_TIPO_FATURA AND CR.DATA_EMISSAO = FR.DATA_EMISSAO 

LEFT JOIN VW_FATURA_RECEBER_DETALHE FRD 
ON 
frd.COD_EMPRESA = CR.COD_EMPRESA AND frd.NR_FATURA = fr.NR_FATURA AND FRD.COD_TIPO_FATURA = FR.COD_TIPO_FATURA AND FR.DATA_EMISSAO = CR.DATA_EMISSAO 

INNER JOIN CLIENTES C 
ON 
C.COD_CLIENTE = FR.COD_CLIENTE 

LEFT JOIN FORMA_COBRANCA FC 
ON 
CR.COD_EMPRESA_FC = FC.COD_EMPRESA AND CR.COD_FORMA_COBRANCA = FC.COD_FORMA_COBRANCA

LEFT JOIN GRUPO_FORMA_COBRANCA GF 
ON 
FC.COD_MATRIZ  = GF.COD_MATRIZ AND FC.COD_GR_FORMA_COBRANCA = GF.COD_GR_FORMA_COBRANCA

LEFT JOIN CLIENTE_DIVERSO CD 
ON 
CD.COD_CLIENTE = C.COD_CLIENTE

LEFT JOIN EMPRESAS E 
ON 
E.COD_EMPRESA = FR.COD_EMPRESA

LEFT JOIN FORMA_PGTO FP 
ON 
FP.COD_EMPRESA = CR.COD_EMPRESA AND FP.COD_FORMA_PGTO = CR.COD_FORMA_PGTO 

LEFT JOIN FORMA_COBRANCA FC 
ON 
FC.COD_EMPRESA = CR.COD_EMPRESA AND FC.COD_FORMA_COBRANCA = CR.COD_FORMA_PGTO

LEFT JOIN NATUREZA_RECEITA_DESPESA NRD
ON 
NRD.COD_NATUREZA_RECEITA_DESPESA  = FR.COD_NATUREZA_RECEITA_DESPESA  AND NRD.COD_GRUPO_PC = FR.COD_GRUPO_PC 

LEFT JOIN EMPRESAS_USUARIOS EU 
ON 
EU.NOME = FR.USUARIO AND EU.COD_EMPRESA = FR.COD_EMPRESA 

LEFT JOIN STATUS_FINANCEIRO SF
ON 
FR.COD_STATUS = SF.COD_STATUS

WHERE 	CR.DATA_BAIXA IS NULL
		AND FR.COD_STATUS = 0
		AND CR.TIPO_CARTEIRA = 0 
		AND CR.DATA_VENCIMENTO  BETWEEN TO_DATE('2023/01/01', 'YYYY-MM-DD')  AND TO_DATE('2023/12/31', 'YYYY-MM-DD')
--		AND CR.COD_EMPRESA IN ('400','401','402') 

--SELECT * FROM FATURA_RECEBER WHERE NR_FATURA IN (4884) AND COD_EMPRESA = 101 
--SELECT * FROM FATURA_RECEBER_DETALHE WHERE NR_FATURA IN (4884) AND COD_EMPRESA = 101
--SELECT * FROM CONTAS_RECEBER WHERE COD_EMPRESA  = 101  AND NR_FATURA = 4884
--SELECT * FROM VENDAS WHERE COD_EMPRESA = 101 AND CONTROLE = 724 AND SERIE IN ('1','A1') AND COD_CLIENTE IN ('2255007797','45437547000197')