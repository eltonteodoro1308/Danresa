#include 'totvs.ch'

user function axCadZZZ()

	Local cAlias := "ZZZ"

	Private cCadastro := "Produto Nectar x Protheus"
	Private aRotina := {}

	AADD(aRotina,{"Pesquisar"  ,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
	AADD(aRotina,{"Incluir"    ,"AxInclui",0,3})
	AADD(aRotina,{"Alterar"    ,"AxAltera",0,4})
	AADD(aRotina,{"Excluir"    ,"AxDeleta",0,5})
	AADD(aRotina,{"Comp. Oportunidades","u_cmpZZY",0,6})

	chkfile( cAlias )

	dbSelectArea(cAlias)
	dbSetOrder(1)

	mBrowse(6,1,22,75,cAlias)

Return

user function cmpZZY()

	local cCommand  := ''

	if pergunte( 'CMPOPORTUN' )

		cCommand  := mntComp()

		if tcSqlExec(cCommand ) < 0

			autoGrLog( 'Erro ao gravar no Banco de Dados: ' + CRLF + TCSQLError() )
			mostraErro()

		end if

		cCommand  := mntUnComp()

		if tcSqlExec(cCommand ) < 0

			autoGrLog( 'Erro ao gravar no Banco de Dados: ' + CRLF + TCSQLError() )
			mostraErro()

		end if

	end if

return

static function mntComp()

	local cCommand := ''
	local cProdDe     := MV_PAR01
	local cProdAte    := MV_PAR02
	local cZZYTable   := retSqlName('ZZY')
	local cZZVTable   := retSqlName('ZZV')
	local cZZYFilial  := FwXFilial('ZZY')

	BeginContent var cCommand

	UPDATE %Exp:cZZYTable% SET ZZY_PRDCMP = 'T'

	WHERE ZZY_CODIGO IN

	( SELECT DISTINCT ZZY_CODIGO FROM %Exp:cZZYTable% ZZY

	INNER JOIN %Exp:cZZVTable% ZZV
	ON  ZZY.D_E_L_E_T_ = ZZV.D_E_L_E_T_
	AND ZZY.ZZY_PRODUT = ZZV.ZZV_CODIGO

	WHERE ZZY.D_E_L_E_T_ = ' '
	AND ZZY.ZZY_FILIAL = '%Exp:cZZYFilial%'
	AND ZZV.ZZV_CODIGO BETWEEN '%Exp:cProdDe%' AND '%Exp:cProdAte%' )
	AND ZZY_PEDGER = 'F'

	EndContent

return cCommand

static function mntUnComp()

	local cCommand := ''
	local cProdDe     := MV_PAR01
	local cProdAte    := MV_PAR02
	local cZZYTable   := retSqlName('ZZY')
	local cZZVTable   := retSqlName('ZZV')
	local cZZYFilial  := FwXFilial('ZZY')

	BeginContent var cCommand

	UPDATE %Exp:cZZYTable% SET ZZY_PRDCMP = 'F'

	WHERE ZZY_CODIGO NOT IN

	( SELECT DISTINCT ZZY_CODIGO FROM %Exp:cZZYTable% ZZY

	INNER JOIN %Exp:cZZVTable% ZZV
	ON  ZZY.D_E_L_E_T_ = ZZV.D_E_L_E_T_
	AND ZZY.ZZY_PRODUT = ZZV.ZZV_CODIGO

	WHERE ZZY.D_E_L_E_T_ = ' '
	AND ZZY.ZZY_FILIAL = '%Exp:cZZYFilial%'
	AND ZZV.ZZV_CODIGO BETWEEN '%Exp:cProdDe%' AND '%Exp:cProdAte%' )
	AND ZZY_PEDGER = 'F'

	EndContent

return cCommand
