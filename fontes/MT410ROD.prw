#include 'totvs.ch'

user function MT410ROD()

	Local nX       := 0

	if type('_lAcolsPop') == 'U'

		public _lAcolsPop := .F.

	end if

    /*
    PARAMIXB[1] - Objeto   - Objeto do rodape do pedido de venda.	
    PARAMIXB[2] - Caracter - Descrição do cliente/fornecedor	
    PARAMIXB[3] - Numérico - Valor bruto do pedido de venda.		
    PARAMIXB[4] - Numérico - Valor do desconto/acrescimo	
    PARAMIXB[5] - Numérico - Valor liquido do pedido de venda.
    */

	if fwIsInCallStack('U_nectarCockipt') .and. !_lAcolsPop

		_lAcolsPop := .T.

		M->C5_CLIENTE := jSC5['CLIENTE']
		M->C5_LOJACLI := jSC5['LOJA']
		M->C5_TIPOCLI := jSC5['TIPO']
		M->C5_CONDPAG := jSC5['CONDPAG']
		M->C5_NATUREZ := jSC5['NATUREZA']

		for nX := 1 to len( aSC6 )

			if ( lIndireta .And. val( aSc6[ nX ][ 'ITEM_OPORTUNIDADE' ] ) == 1 ) .Or. !lIndireta

				if nX > 1

					oGetDad:AddLine(.T.)

				end if

				GDFieldPut( 'C6_PRODUTO',      cValToChar( aSc6[nX]['PRODUTO'             ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_UM'     ,      cValToChar( aSc6[nX]['UNIDADE_MEDIDA'      ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_SEGUM'  ,      cValToChar( aSc6[nX]['SEG_UNID_MEDIDA'     ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_DESCRI' ,      cValToChar( aSc6[nX]['DESCRICAO_PRODUTO'   ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_TES'    ,      cValToChar( aSc6[nX]['TES_SAIDA'           ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_LOCAL'  ,      cValToChar( aSc6[nX]['ARMAZEM'             ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_XOPORTU',      cValToChar( aSc6[nX]['OPORTUNIDADE'        ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_XCOPORT',      cValToChar( aSc6[nX]['CLIENTE_OPORTUNIDADE'] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_XLJOPOR',      cValToChar( aSc6[nX]['LOJA_OPORTUNIDADE'   ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_XITOPOR',      cValToChar( aSc6[nX]['ITEM_OPORTUNIDADE'   ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_XPROPOS',      cValToChar( aSc6[nX]['PROPOSTA'            ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_XNOMCON',      cValToChar( aSc6[nX]['NOME_CONTATO'        ] )  , n, aHeader , aCols )
				GDFieldPut( 'C6_QTDVEN' , val( cValToChar( aSc6[nX]['QUANTIDADE'          ] ) ), n, aHeader , aCols )
				GDFieldPut( 'C6_PRCVEN ', val( cValToChar( aSc6[nX]['VALOR_UNITARIO'      ] ) ), n, aHeader , aCols )
				GDFieldPut( 'C6_VALOR'  , val( cValToChar( aSc6[nX]['VALOR_TOTAL'         ] ) ), n, aHeader , aCols )

				oGetDad:LinhaOk(.T.,.T.)

			end if

		next nX

	end if

return
