SELECT 
	'Dealer' as SYSORIGEM,
	T.Titulo_PessoaCod AS COD_CLIENTE,
	P.Pessoa_Nome AS CLIENTE,	
    P.Pessoa_DocIdentificador AS DOCCLI,
	replace(cast(T.Titulo_Valor as varchar(30)),'.',',') AS VALOR_TITULO_teste,
	E.Empresa_Codigo AS COD_EMPRESA,
	E.Empresa_Nome AS Empresa,
	e.Empresa_EmpresaCodMatriz as MATRIZ,
	CASE T.Titulo_MovimentoFinanceiro WHEN 'P' THEN 'A PAGAR' WHEN 'R' THEN 'A RECEBER' ELSE 'DESCONHECIDO' END AS TIPO_MOVIMENTO,
	TPT.TipoTitulo_Descricao AS TIPO_TITULO,
	T.Titulo_Status AS STATUS_TITULO,
	AC.AgenteCobrador_Descricao AS AGENTE_COBRADOR,
	NOP.NaturezaOperacao_Descricao AS NATUREZA_OPERACAO,
	DPTO.Departamento_Descricao AS DEPARTAMENTO,
	T.Titulo_Codigo AS LANCAMENTO_FINANCEIRO,
	T.Titulo_NossoNumero AS NOSSO_NUMERO_BOLETO,
	T.Titulo_Numero AS NUM_TITULO,
	T.Titulo_Parcela AS PARCELA,
	T.Titulo_DataEmissao AS DATA_EMISSAO,
	T.Titulo_DataVencimento AS DATA_VENCIMENTO,
	T.Titulo_DataPrevisaoPagamento AS DATA_PREVISAO_PAGAMENTO,
	T.Titulo_DataPagamento AS DATA_PAGAMENTO,
	T.Titulo_Valor AS VALOR_TITULO,
	T.Titulo_Saldo AS TITULO_SALDO,
	U.Usuario_Nome AS VENDEDOR, 
	T.Titulo_NotaFiscalCod AS NOTA_FISCAL_CODIGO, 
	NF.NotaFiscal_Numero AS NOTA_FISCAL_NUMERO, 
	NF.NotaFiscal_Serie AS NOTA_FISCAL_SERIE
FROM Titulo T
INNER JOIN Pessoa P ON P.Pessoa_Codigo = T.Titulo_PessoaCod 
INNER JOIN Empresa E ON E.Empresa_Codigo = T.Titulo_EmpresaCod
LEFT JOIN NotaFiscal NF ON NF.NotaFiscal_Codigo = T.Titulo_NotaFiscalCod
LEFT JOIN TipoTitulo TPT ON TPT.TipoTitulo_Codigo = T.Titulo_TipoTituloCod
LEFT JOIN AgenteCobrador AC ON AC.AgenteCobrador_Codigo = T.Titulo_AgenteCobradorCod
LEFT JOIN NaturezaOperacao NOP ON NOP.NaturezaOperacao_Codigo = T.Titulo_NaturezaOperacaoCod
LEFT JOIN Departamento DPTO ON DPTO.Departamento_Codigo = T.Titulo_DepartamentoCod
LEFT JOIN Usuario U ON U.Usuario_Codigo = T.Titulo_UsuarioCodVendedor

WHERE T.Titulo_DataEmissao between '2023-01-01' and '2023-09-21'
AND T.Titulo_Status NOT IN ('PAG','CAN')
and T.Titulo_MovimentoFinanceiro = 'R'
and E.Empresa_Codigo <> 26 

