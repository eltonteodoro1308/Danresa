#include 'totvs.ch'
#include 'fwmvcdef.ch'

static function menudef()

	local aRet := {}

	aAdd( aRet, { 'Gerar Pedido'            , 'U_XINC410'  , 0, 8, 0,,, } )
	aAdd( aRet, { 'Compatibilizar Cliente'  , 'U_XINC980'  , 0, 8, 0,,, } )
	aAdd( aRet, { 'Compatibilizar Produto'  , 'U_XINC010'  , 0, 8, 0,,, } )
	aAdd( aRet, { 'Visualizar Oportunidade' , 'U_viewZZY'  , 0, 8, 0,,, } )
	aAdd( aRet, { 'Excluir Oportunidade'    , 'U_ExclZZY'  , 0, 8, 0,,, } )
	aAdd( aRet, { 'Alterar Oportunidade'    , 'U_updatZZY' , 0, 8, 0,,, } )

return aRet

user function XINC980()

	Local aArea     := getArea()
	Local jEndereco := jsonObject():new()
	local cSeekZZX  := ZZY->( xFilial( 'ZZV' ) + alltrim( ZZY_CLIENT ) )
	local cSeekSA1  := ''
	local lSeekSA1  := .F.
	local cCnpj     := ''
	local cPessoa   := ''
	local aParambox := {}
	local aRetParam := {}
	local aOption   := { 'Jurídica', 'Física' }

	Private _cEndereco := ''
	Private _cBairro   := ''
	Private _cEstado   := ''
	Private _codMnIbge := ''

	dbSelectArea( 'ZZX' )
	ZZX->( dbSetOrder(3) )

	if ZZX->( msSeek( cSeekZZX ) .And.  cSeekZZX == xFilial( 'ZZX' ) + alltrim( ZZX_ID ) )

		cSeekSA1  := xFilial( 'SA1' ) + AllTrim( ZZX->( ZZX_CPF + ZZX_CNPJ ) )

		dbSelectArea( 'SA1' )
		SA1->( dbSetOrder( 3 ) )
		SA1->( lSeekSA1 := msSeek( cSeekSA1 ) .And. cSeekSA1 == A1_FILIAL + A1_CGC )

		if ! lSeekSA1

			cSeekSA1  := xFilial( 'SA1' ) + ZZX->ZZX_ID

			SA1->( DbOrderNickname( 'IDNECTAR' ) )
			SA1->( lSeekSA1 := msSeek( cSeekSA1 ) .And. cSeekSA1 == A1_FILIAL + A1_XIDNECT )

		end if

	end if

	if ZZY->ZZY_CLICMP .Or. lSeekSA1

		apMsgInfo( 'Cliente já Compatibilizado !!!', 'Atenção !!!' )

		cmpCliOpt() // Marcar Oportunidade como cliente compatibilizado

	else

		if apMsgYesNo( 'Cliente não localizado pelo CNPJ e/ou ID Nectar, deseja compatibilizar com cliente já cadastrado ?',;
				'Atenção !!!' )

			aAdd( aParambox, { 1, 'Cliente: ', space(getSx3Cache( 'A1_COD' , 'X3_TAMANHO' )), '', '', 'SA1', '', 050, .T.} )
			aAdd( aParambox, { 1, 'Loja: '   , space(getSx3Cache( 'A1_LOJA', 'X3_TAMANHO' )), '', '', ''   , '', 050, .T.} )

			if parambox( aParambox, 'Informe o Cliente.', aRetParam )

				DbSelectArea('SA1')
				SA1->( dbSetOrder( 1 ) )
				cSeekSA1 := SA1->( xFilial() + aRetParam[ 1 ] + aRetParam[ 2 ] )

				if SA1->( msSeek( cSeekSA1 ) .And. cSeekSA1 == A1_FILIAL + A1_COD + A1_LOJA )

					aSize( aParambox, 0 )

					aAdd( aParambox, { 2, 'Tipo de Pessoa', 1, aOption, 050, '', .T. } )
					aAdd( aParambox, { 1, 'CNPJ: ', space(getSx3Cache( 'A1_CGC' , 'X3_TAMANHO' )), '@R 99.999.999/9999-99', '', '', 'alltrim(MV_PAR01) == "Jurídica" .Or. alltrim(MV_PAR01) != "Física"', 080, .F.} )
					aAdd( aParambox, { 1, 'CPF: ' , space(getSx3Cache( 'A1_CGC' , 'X3_TAMANHO' )), '@R 999.999.999-99'    , '', '', 'alltrim(MV_PAR01) == "Física"'  , 080, .F.} )

					if empty( SA1->A1_CGC ) .And.;
							apMsgYesNo( 'Cliente sem CPF/CNPJ informado, deseja informar ?', 'Atenção !!!' ) .And.;
							parambox( aParambox, 'Informe o tipo do Cliente e o CNPJ/CPF.', aRetParam )

						if ( cPessoa := subStr( aOption[ aRetParam[ 1 ] ], 1, 1 ) ) == 'J'

							cCnpj := aRetParam[ 2 ]

						else

							cCnpj := aRetParam[ 3 ]

						end if

						if ! ( cgc( aRetParam[ 2 ] ) .Or. cgc(aRetParam[ 3 ] ) )

							apMsgStop( 'CNPJ/CPF inválido, reinicie a compatibilização', 'Atenção !!!' )

							return

						end if

						SA1->( dbSetOrder( 3 ) )
						cSeekSA1 := SA1->( xFilial() + if( allTrim( aRetParam[ 1 ] ) == 'Jurídica' ,aRetParam[ 2 ], aRetParam[ 3 ] ) )

						if SA1->( msSeek( cSeekSA1 ) .And. cSeekSA1 == A1_FILIAL + allTrim(A1_CGC) )

							apMsgStop( 'CNPJ/CPF já utilizado, reinicie a compatibilização', 'Atenção !!!' )

							return

						end if

					else

						cCnpj   := SA1->A1_CGC
						cPessoa := SA1->A1_PESSOA

					end if

					recLock( 'SA1', .F. )

					SA1->A1_XIDNECT := ZZY->ZZY_IDCLI
					SA1->A1_CGC     := cCnpj
					SA1->A1_PESSOA  := cPessoa

					SA1->( msUnlock() )

					recLock( 'ZZX', .F. )

					if cPessoa == 'F'

						ZZX->ZZX_CPF  := cCnpj

					else

						ZZX->ZZX_CNPJ := cCnpj

					end if

					ZZX->( msUnlock() )

					cmpCliOpt() // Marcar Oportunidade como cliente compatibilizado

				else

					apMsgInfo( 'Cliente inválido !!!', 'Atenção !!!' )

				end if

			end if

		else

			dbSelectArea( 'ZZX' )
			ZZX->( dbSetOrder( 3 ) )

			if ZZX->( msSeek( xFilial('ZZX') + ZZY->ZZY_IDCLI ) )

				jEndereco:fromJson( ZZX->ZZX_ENDERE )

				_cEndereco := strTokArr2( cValToChar( jEndereco['endereco']), ',', .T. )[1]
				_cMunicipi := cValToChar( jEndereco['municipio'] )
				_cBairro   := cValToChar( jEndereco['bairro'] )
				_cEstado   := cValToChar( jEndereco['estado'] )
				_codMnIbge := right( cValToChar( jEndereco[ 'codigoMunicipioIbge' ] ), 5)

				dbSelectArea('SA1')
				FWExecView("Incluir","CRMA980",MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

			else

				apMsgStop( 'Cliente não localizado na tabela ZZX.', 'Atenção !!!' )

			end if

		end if

	end if

	restArea( aArea )

return

user function XINC010()

	Local aArea    := getArea()
	local cSeek    :=  ZZY->( xFilial( 'ZZZ' ) + allTrim( ZZY_PRODUT ) )
	local lSeekZZZ := .F.
	local cCommand := ''

	dbSelectArea( 'ZZZ' )
	ZZZ->( dbSetOrder( 2 ) ) //ZZZ_FILIAL+ZZZ_CDNECT+ZZZ_CDPROT
	ZZZ->( lSeekZZZ := msSeek( cSeek ) .And. cSeek == ZZZ_FILIAL + allTrim( ZZZ_CDNECT ) )

	if ZZY->ZZY_PRDCMP .Or. lSeekZZZ

		apMsgInfo( 'Produto já Compatibilizado !!!', 'Atenção !!!' )

		// Marcar Oportunidade como produto compatibilizado
		cCommand := " UPDATE " + retSqlName( 'ZZY' )
		cCommand += " SET ZZY_PRDCMP = 'T' "
		cCommand += " WHERE ZZY_PRODUT = '" + ZZV->ZZV_CODIGO + "' "

		if tcSqlExec(cCommand ) < 0

			autoGrLog( 'Erro ao gravar no Banco de Dados: ' + CRLF + TCSQLError() )
			mostraErro()

		end if

	else

		dbSelectArea( 'ZZV' )
		ZZV->( dbSetOrder( 1 ) )

		if ZZV->( msSeek( xFilial('ZZV') + ZZY->ZZY_PRODUT ) )

			A010INCLUI(/*cAlias*/,/*nReg*/,/*nOpc*/)

		else

			apMsgStop( 'Produto não localizado na tabela ZZV.', 'Atenção !!!' )

		end if

	end if

	restArea( aArea )

return

user function XINC410()

	Local nOpc      := 3
	Local aArea     := getArea()
	Local nPos      := 0
	Local cSeekZZX  := ''
	Local cSeekSA1  := ''
	Local cSeekSB2  := ''
	Local cPrdNcomp := ''

	Private lIndireta := .T.

	Private jSC5   := jsonObject():new()
	Private aSC6   := {}

	Private cCadastro  := "Atualização de Pedidos de Venda"
	Private INCLUI     := .T.
	Private aRotina    := FWLoadMenuDef( 'MATA410' )

	public _aLstOport := {}

	dbSelectArea('ZZX')
	ZZX->( dbSetOrder( 3 ) )

	dbselectarea('ZZZ')
	ZZZ->( dbSetOrder( 2 ) ) // ZZZ_FILIAL+ZZZ_CDNECT+ZZZ_CDPROT

	dbSelectArea( 'SB1' )
	SB1->( dbSetOrder( 1 ) )

	dbSelectArea( 'SB2' )
	SB2->( dbSetOrder( 1 ) )

	dbSelectArea( 'SA1' )
	SA1->( dbSetOrder( 3 ) )

	ZZY->( DbGoTop() )

	do while ZZY->( ! eof() )

		if _oBrowseUp:isMark( _oBrowseUp:Mark() )

			if empty( nPos := aScan( _aLstOport, ZZY->ZZY_CODIGO ) )

				aAdd( _aLstOport, ZZY->ZZY_CODIGO )

			end if

			if ZZX->( msSeek( cSeekZZX := xFilial( 'ZZX' ) + allTrim( ZZY->ZZY_CLIENT ) ) .And.;
					cSeekZZX == ZZX_FILIAL + allTrim( ZZX_ID ) )

				if SA1->( msSeek( cSeekSA1 := xFilial( 'SA1' ) + allTrim( ZZX->( ZZX_CPF + ZZX_CNPJ ) ) ) .And.;
						cSeekSA1 == A1_FILIAL + A1_CGC ) .Or.;
						SA1->( eval( {|| DbOrderNickname( 'IDNECTAR' ),;
						msSeek( cSeekSA1 := xFilial() + ZZX->ZZX_ID ) .And. cSeekSA1 == A1_FILIAL + A1_XIDNECT } ) )

					jSC5['CLIENTE']  := SA1->A1_COD
					jSC5['LOJA']     := SA1->A1_LOJA
					jSC5['TIPO']     := SA1->A1_TIPO
					jSC5['CONDPAG']  := SA1->A1_COND
					jSC5['NATUREZA'] := SA1->A1_NATUREZ

				end if

			end if

			if ! ZZY->ZZY_PRDCMP

				cPrdNcomp += allTrim( ZZY->ZZY_PRODUT ) + CRLF

			end if

			aAdd( aSC6, jsonObject():new() )

			if ZZY->ZZY_PRDCMP .And. ZZZ->( msSeek( cSeekZZX := xFilial( 'ZZZ' ) + allTrim( ZZY->ZZY_PRODUT ) ) .And.;
					cSeekZZX == ZZZ_FILIAL + allTrim( ZZZ_CDNECT ) )

				if SB1->( msSeek( cSeekSA1 := xFilial( 'SB1' ) + allTrim( ZZZ->ZZZ_CDPROT ) ) .And.;
						cSeekSA1 == B1_FILIAL + alltrim( B1_COD ) )

					aTail( aSc6 )['PRODUTO'          ] := SB1->B1_COD
					aTail( aSc6 )['DESCRICAO_PRODUTO'] := SB1->B1_DESC
					aTail( aSc6 )['UNIDADE_MEDIDA'   ] := SB1->B1_UM
					aTail( aSc6 )['SEG_UNID_MEDIDA'  ] := SB1->B1_SEGUM
					aTail( aSc6 )['TES_SAIDA'        ] := SB1->B1_TS
					aTail( aSc6 )['ARMAZEM'          ] := SB1->B1_LOCPAD

					if ! SB2->( msSeek( cSeekSB2 := xFilial( 'SB2' ) + SB1->( B1_COD + B1_LOCPAD ) ) .And.;
							cSeekSB2 == B2_FILIAL + B2_COD + B2_LOCAL )

						SB1->( CriaSB2( B1_COD, B1_LOCPAD ) ) // Gera Local de Estocagem do Produto

					end if

				end if

			end if

			//if ZZY->ZZY_PRDCMP

			aTail( aSc6 )['QUANTIDADE'          ] := ZZY->ZZY_QTDPRD
			aTail( aSc6 )['VALOR_UNITARIO'      ] := ZZY->ZZY_VLUNPD
			aTail( aSc6 )['VALOR_TOTAL'         ] := ZZY->( ZZY_QTDPRD * ZZY_VLUNPD )
			aTail( aSc6 )['OPORTUNIDADE'        ] := ZZY->ZZY_CODIGO
			aTail( aSc6 )['CLIENTE_OPORTUNIDADE'] := if( Empty( jSC5['CLIENTE'] ), '', jSC5['CLIENTE'] )
			aTail( aSc6 )['LOJA_OPORTUNIDADE'   ] := if( Empty( jSC5['LOJA']    ), '', jSC5['LOJA']    )
			aTail( aSc6 )['ITEM_OPORTUNIDADE'   ] := ZZY->ZZY_ITEM
			aTail( aSc6 )['PROPOSTA'            ] := ZZY->ZZY_XPROPO
			aTail( aSc6 )['NOME_CONTATO'        ] := ZZY->ZZY_NOME

			//end if

		end if

		ZZY->( DbSkip() )

	end do

	if len( _aLstOport ) == 0 //Nenhuma Oportunidade Marcada

		return

	end if


	if len( _aLstOport ) == 1

		lIndireta := aviso( 'Tipo de Venda', 'Informe o tipo de venda', { 'Direta', 'indireta' }, 3 ) == 2

	end if

	if ! lIndireta .And. ! empty( cPrdNcomp )

		apMsgStop( 'Há Produtos que não foram compatibilizados', 'Atenção !!!' )

		autoGrLog( 'Produtos não Compatibilizados:' + CRLF )
		autoGrLog( '------------------------------' + CRLF )
		autoGrLog( cPrdNcomp )

		return

	end if

	if lIndireta .And. pergunte( 'NECINDIRET')

		SA1->( dbSetOrder( 1 ) )

		if SA1->( msSeek( cSeekSA1 := xFilial( 'SA1' ) + MV_PAR01 + MV_PAR02 ) .And.;
				cSeekSA1 == A1_FILIAL + A1_COD + A1_LOJA )

			jSC5['CLIENTE']  := SA1->A1_COD
			jSC5['LOJA']     := SA1->A1_LOJA
			jSC5['TIPO']     := SA1->A1_TIPO
			jSC5['CONDPAG']  := SA1->A1_COND
			jSC5['NATUREZA'] := SA1->A1_NATUREZ

			if SB1->( msSeek( cSeekSA1 := xFilial( 'SB1' ) + allTrim( superGetMV( 'MX_PCOMNEC' ) ) ) .And.;
					cSeekSA1 == B1_FILIAL + alltrim( B1_COD ) )

				for nPos := 1 to len( aSc6 )

					aSc6[nPos]['PRODUTO'          ] := SB1->B1_COD
					aSc6[nPos]['DESCRICAO_PRODUTO'] := SB1->B1_DESC
					aSc6[nPos]['UNIDADE_MEDIDA'   ] := SB1->B1_UM
					aSc6[nPos]['SEG_UNID_MEDIDA'  ] := SB1->B1_SEGUM
					aSc6[nPos]['TES_SAIDA'        ] := SB1->B1_TS
					aSc6[nPos]['ARMAZEM'          ] := SB1->B1_LOCPAD
					aSc6[nPos]['QUANTIDADE'       ] := 1
					aSc6[nPos]['VALOR_UNITARIO'   ] := 0
					aSc6[nPos]['VALOR_TOTAL'      ] := 0

				next nPos

				if ! SB2->( msSeek( cSeekSB2 := xFilial( 'SB2' ) + SB1->( B1_COD + B1_LOCPAD ) ) .And.;
						cSeekSB2 == B2_FILIAL + B2_COD + B2_LOCAL )

					SB1->( CriaSB2( B1_COD, B1_LOCPAD ) ) // Gera Local de Estocagem do Produto

				end if

			end if

		else

			apMsgStop( 'Cliente inválido, processo interrompido !!!', 'Atenção !!!' )

			return

		end if

	end if

	A410Inclui(/*cAlias*/,/*nReg*/, nOpc /*,lOrcamento,nStack,aRegSCK,lContrat,nTpContr,cCodCli,cLoja,cMedPMS*/)

	restArea( aArea )

	recLock( cAliasTMP, .F. )

	(cAliasTMP)->ZZY_CODIGO := ZZY->ZZY_CODIGO
	(cAliasTMP)->ZZY_XPROPO := ZZY->ZZY_XPROPO
	(cAliasTMP)->ZZY_NOME   := ZZY->ZZY_NOME
	(cAliasTMP)->ZZY_XDTLIB := ZZY->ZZY_XDTLIB
	(cAliasTMP)->ZZY_PEDGER := ZZY->ZZY_PEDGER

	( cAliasTMP )->( msUnlock() )

return

user function viewZZV()

	local aArea := getArea()
	local cSeek := xFilial( 'ZZV' ) + ZZY->ZZY_PRODUT

	Private cCadastro := "Produto da Oportunidade"

	dbSelectArea( 'ZZV' )
	ZZV->( dbSetOrder( 1 ) )

	if ZZV->( msSeek( cSeek ) .And. cSeek == ZZV_FILIAL + ZZV_CODIGO )

		AxVisual( 'ZZV', ZZV->(RecNo()), 2 )

	else

		apMsgStop( 'Produto da Oportunidade não localizado', 'Atenção !!!' )

	end

	restArea( aArea )

return

user function viewZZX()

	local aArea := getArea()
	local cSeek := xFilial( 'ZZX' ) + ZZY->ZZY_IDCLI

	Private cCadastro := "Contato da Oportunidade"

	dbSelectArea( 'ZZX' )
	ZZX->( dbSetOrder( 3 ) )

	if ZZX->( msSeek( cSeek ) .And. cSeek == ZZX_FILIAL + ZZX_ID )

		AxVisual( 'ZZX', ZZX->(RecNo()), 2 )

	else

		apMsgStop( 'Produto da Oportunidade não localizado', 'Atenção !!!' )

	end

	restArea( aArea )

return

user function viewZZY()

	local aRotinas    := {}
	Private cCadastro := "Oportunidades"

	aAdd( aRotinas, { '', { || U_viewZZV() }, 'Produto da Oportunidade' } )
	aAdd( aRotinas, { '', { || U_viewZZX() }, 'Contato da Oportunidade' } )

	AxVisual( 'ZZY', ZZY->(RecNo()), 2,,,,, aRotinas )

return

user function updatZZY()

	local aCampos := ZZY->( DBStruct() )
	local nX      := 0
	local cCommand := ''
	local cField   := ''
	local cValue   := ''

	Private cCadastro := "Oportunidades"
	Public lCliAlter  := .F.

	if ZZY->ZZY_PEDGER

		complement()

	else

		AxAltera( 'ZZY', ZZY->( RecNo() ), 4,,,,,;
		/*cTudoOk*/ '( u_recCust(), u_atuOpor(), .T. )', /*cTransact*/, /*cFunc*/,;
		 /*aButtons*/ { { '', { || u_recCust() }, 'Recalcula Custeio' },;
			{ '', { || u_altCli() }, 'Altera Cliente' } } )

		cCommand := " UPDATE " + retSqlName( 'ZZY' ) + " SET "

		for nX := 1 to len( aCampos )

			cField := aCampos[ nX, 1 ]
			cValue := tranfValue( aCampos[ nX, 2 ], ZZY->(&cField) )

			if ! allTrim( cField ) $ 'ZZY_FILIAL/ZZY_ID/ZZY_ITEM/ZZY_PRODUT/ZZY_QTDPRD/ZZY_VLUNPD/ZZY_VLTLPD'

				cCommand += " " + cField + " = " + cValue

				if nX != len( aCampos )

					cCommand += ", "

				end if

			end if

		next nX

		cCommand += " WHERE ZZY_CODIGO = '" + ZZY->ZZY_CODIGO + "' "

		if tcSqlExec(cCommand ) < 0

			autoGrLog( 'Erro ao gravar no Banco de Dados: ' + CRLF + TCSQLError() )
			mostraErro()

		end if

		recLock( cAliasTMP, .F. )

		(cAliasTMP)->ZZY_CODIGO := ZZY->ZZY_CODIGO
		(cAliasTMP)->ZZY_XPROPO := ZZY->ZZY_XPROPO
		(cAliasTMP)->ZZY_NOME   := ZZY->ZZY_NOME
		(cAliasTMP)->ZZY_XDTLIB := ZZY->ZZY_XDTLIB
		(cAliasTMP)->ZZY_PEDGER := ZZY->ZZY_PEDGER

		( cAliasTMP )->( msUnlock() )

		// _oBrowseMain:refresh()

	end if

return

static function complement()

	local aCampos := { 'ZZY_RESPON', 'ZZY_XNCONT', 'ZZY_DTATUA', 'ZZY_XOBSST', 'ZZY_XPROPO', 'ZZY_XSTATU',;
		'ZZY_XFABRI', 'ZZY_XPREVE', 'ZZY_XDISTR', 'ZZY_XPEDCO', 'ZZY_XOVPD', 'ZZY_XOVSDV', 'NOUSER'  }

	apMsgStop( 'Oportunidade com pedido já gerado,'+;
		' só será permitido complementar a oportunidade.', 'Atenção !!!')

	AxAltera( 'ZZY', ZZY->( RecNo() ), 4, aCampos, aCampos )

return

user function recCust()

	local lReal := allTrim( M->ZZY_XMOEDV ) == 'R$'

	M->ZZY_XVARCA := if( lReal, 1, M->ZZY_VLRTOT / (  M->ZZY_XMESES * M->ZZY_VLRMES )  )
	M->ZZY_XVLSME := ( ( M->ZZY_XQTHPL * M->ZZY_XVLHPL ) + ( M->ZZY_XQTHPS * M->ZZY_XVLHSR ) ) * M->ZZY_XMESES
	M->ZZY_XVLTOC := M->ZZY_XVLCOM * M->ZZY_XMESES * M->ZZY_XVARCA
	M->ZZY_XTOTCU := M->ZZY_XVLTOC + M->ZZY_XVLSME
	M->ZZY_XMARKU := M->ZZY_VLRTOT / M->ZZY_XTOTCU
	M->ZZY_XTOTMA := ( M->ZZY_VLRTOT - M->ZZY_XTOTCU ) - ( ( M->ZZY_VLRTOT - M->ZZY_XTOTCU ) * M->ZZY_XPIDIS)

return

user function altCli()

	local jContato := nil

	If ConPad1(,,, 'SA1' )

		if ! empty( SA1->A1_XIDNECT )

			jContato := buscaCliente( SA1->A1_XIDNECT, 0 )

		elseif ! empty( SA1->A1_CGC )

			jContato := buscaCliente( SA1->A1_CGC, 1 )

		else

			apMsgStop( 'Cliente não tem o CNPJ informado, integração com Nectar mnão foi possível.', 'Atenção !!!' )

			return

		end if

		if valType( jContato ) != 'J'

			apMsgStop( 'Cliente não localizado no Nectar', 'Atenção !!!' )

			return

		end if

		M->ZZY_IDCLI  := cValToChar( jContato['id'] )
		M->ZZY_CLIENT := cValToChar( jContato['id'] )
		M->ZZY_CNPJ   := jContato['cnpj']
		M->ZZY_NOME   := jContato['nome']
		M->ZZY_CNPJ   := SA1->A1_CGC
		M->ZZY_CDCLIP := SA1->A1_COD
		M->ZZY_LJCLIP := SA1->A1_LOJA
		M->ZZY_NMCLIP := SA1->A1_NOME

		if empty( SA1->A1_XIDNECT )

			reclock( 'SA1', .F. )

			SA1->A1_XIDNECT := cValToChar( jContato['id'] )

			SA1->( msUnlock() )

		end if

		lCliAlter := .T.

	end if

return

static function buscaCliente( cIdCnpj, nTipo )

	local cUrl        := superGetMv( 'MX_URLNECT' )
	local cToken      := superGetMv( 'MX_TOKNECT' )
	local cUrlContato := ''
	local jRet        := nil
	local cId         := ''

	if nTipo != 0

		cUrlContato := cUrl
		cUrlContato += 'contatos/cnpj/'
		cUrlContato += cIdCnpj
		cUrlContato += '?api_token=' + cToken

		cId := fetch( cUrlContato, 'GET', /* cGETParms */, /* cPOSTParms */, /* nTimeOut */, /* aHeadStr */,;
			{ | cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType | ;
			buscaId( cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType ) } )

		if empty( cId )

			return

		end if

	end if

	cUrlContato := cUrl
	cUrlContato += 'contatos/'
	cUrlContato += cId
	cUrlContato += '?api_token=' + cToken

	jRet := fetch( cUrlContato, 'GET', /* cGETParms */, /* cPOSTParms */, /* nTimeOut */, /* aHeadStr */,;
		{ | cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType | ;
		buscaContato( cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType ) } )

return jRet

static function buscaId( cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType )

	local jContato := jsonObject():new()
	local cRet     := ''

	if cHttpCode == '200'

		jContato:fromJson( DecodeUtf8( uResponse ) )

		if len(jContato) > 0

			cRet := cValToChar( jContato[1]['id'] )

		end if

	end if

return cRet

static function buscaContato( cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType )

	local jRet

	if cHttpCode == '200'

		jRet := jsonObject():new()

		jRet:fromJson( DecodeUtf8( uResponse ) )

	end if

return jRet[1]

user function atuOpor()

	local cUrl        := superGetMv( 'MX_URLNECT' )
	local cToken      := superGetMv( 'MX_TOKNECT' )
	local cUrlOportun := ''
	local cPOSTParms  := ''
	local jPOSTParms  := jsonObject():new()

	if lCliAlter

		jPOSTParms['cliente']       := jsonObject():new()
		jPOSTParms['cliente']['id'] :=  val( ZZY->ZZY_IDCLI )

		cPOSTParms := jPOSTParms:toJson()

		cUrlOportun := cUrl
		cUrlOportun += 'oportunidades/'
		cUrlOportun += allTrim( ZZY->ZZY_ID )
		cUrlOportun += '?api_token=' + cToken

		if fetch( cUrlOportun, 'PUT', /* cGETParms */, /* cPOSTParms */FWhttpEncode( cPOSTParms ),;
		 /* nTimeOut */, /* aHeadStr */{'Content-Type: application/json'},;
				{ | cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType | cHttpCode } ) == '200'

			apMsgStop( 'Cliente da oportunidade alterado na base do nectar.', 'Atenção !!!' )

		else

			apMsgStop( 'Não foi possível alterar o cliente da oportunidade na base do nectar.', 'Atenção !!!' )

		end if

	end if

return

static function tranfValue( cType, xValue )

	local cRet := ''

	if cType $ 'CM'

		cRet := "'" + xValue + "'"

	elseif cType == 'N'

		cRet := cValToChar( xValue )

	elseif cType == 'D'

		cRet := "'" + Dtos( xValue ) + "'"

	elseif cType == 'L'

		cRet := "'" + if( xValue, 'T', 'F' ) + "'"

	end if

return cRet

user function ExclZZY()

	local cCommand := ''

	if ZZY->ZZY_PEDGER

		apMsgStop( 'Oportunidade com pedido já gerado.', 'Atenção !!!')

	else

		cCommand := " DELETE " + retSqlName( 'ZZY' )
		cCommand += " WHERE ZZY_CODIGO = '" + ZZY->ZZY_CODIGO + "' "

		if tcSqlExec(cCommand ) < 0

			autoGrLog( 'Erro ao gravar no Banco de Dados: ' + CRLF + TCSQLError() )
			mostraErro()

		else

			apMsgInfo( 'Oportunidade excluída com sucesso.', 'Atenção !!!' )

		end if

	end if

	recLock( cAliasTMP,  )

	( cAliasTMP )->( DbDelete() )

	( cAliasTMP )->( MsUnlock() )

return

static function cmpCliOpt()

	local cCommand  := ''

	// Marcar Oportunidade como cliente compatibilizado
	cCommand := " UPDATE " + retSqlName( 'ZZY' )
	cCommand += " SET ZZY_CLICMP = 'T' ,"
	cCommand += " SET ZZY_ZZY_CDCLIP = '" + SA1->A1_COD + "' ,"
	cCommand += " SET ZZY_LJCLIP = '" + SA1->A1_LOJA + "' ,"
	cCommand += " SET ZZY_NMCLIP = '" + SA1->A1_NOME + "' ,"
	cCommand += " WHERE ZZY_IDCLI = '" + ZZX->ZZX_ID + "' "

	if tcSqlExec(cCommand ) < 0

		autoGrLog( 'Erro ao gravar no Banco de Dados: ' + CRLF + TCSQLError() )
		mostraErro()

	end if

return

static function fetch( cUrl, cMethod, cGETParms, cPOSTParms, nTimeOut, aHeadStr, bProcess )

	Local cHeaderRet   := ''
	Local aHeaderRet   := {}
	Local cProperty    := ''
	Local cValue       := ''
	Local nPos         := 0
	Local cHttpCode    := ''
	Local cContentType := ''
	Local uResponse    := nil
	Local uJsonXml     := nil
	Local aAux         := {}
	Local nX           := 0

	uResponse  := HttpQuote ( cUrl, cMethod, cGETParms, cPOSTParms, nTimeOut, aHeadStr, @cHeaderRet )

	aAux := StrTokArr2( StrTran( cHeaderRet, Chr(13), '' ), Chr(10), .T. )

	cHttpCode := StrTokArr2( aAux[ 1 ], " ", .T. )[2]

	for nX := 2 to len( aAux )

		nPos := At( ":", aAux[ nX ] )

		cProperty := SubString( aAux[ nX ], 1, nPos - 1 )
		cValue    := SubString( aAux[ nX ], nPos + 2, Len( aAux[ nX ] )  )

		aAdd( aHeaderRet, { cProperty, cValue } )

		if cProperty == 'Content-Type'

			cContentType := cValue

		end if

	next nX

	if 'application/xml' $ Lower(cContentType) .Or.;
			'application/xhtml+xml' $ Lower(cContentType)

		uJsonXml := TXmlManager():New()

		uJsonXml:Parse( uResponse )

	elseif 'application/json' $ Lower(cContentType)

		uJsonXml := JsonObject():New()

		uJsonXml:FromJson( uResponse )

	endif

return Eval( bProcess, cHeaderRet, uResponse, uJsonXml, cHttpCode, cContentType )
