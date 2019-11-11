#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'Protheus.ch'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------------------
/*/{TESTE.doc} TESTE

@author	 	Pedro Missaglia
@since		12/10/2019
@version	12.1.25
/*/
//------------------------------------------------------------------------------
WSRESTFUL TESTE DESCRIPTION "Retorna uma lista de informações baseadas no que foi solicitado via rota"

WSDATA SearchKey 		AS STRING	OPTIONAL
WSDATA Status			AS STRING  	OPTIONAL
WSDATA Page				AS INTEGER	OPTIONAL
WSDATA PageSize			AS INTEGER	OPTIONAL
WSDATA Code				AS STRING	OPTIONAL

/*------------------------GETs--------------------------------------------*/

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  Products;
DESCRIPTION "Retorna uma lista de Produtos";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}"; 
PATH "products"       PRODUCES APPLICATION_JSON 

/*-------------------Get Armazens--------------------------------------*/
WSMETHOD GET  Warehouse;
DESCRIPTION "Retorna uma lista de Armazéns";
WSSYNTAX "warehouse/{SearchKey, Status, Page, PageSize}"; 
PATH "warehouse"       PRODUCES APPLICATION_JSON 

/*-------------------Get Endereços--------------------------------------*/
WSMETHOD GET  Address;
DESCRIPTION "Retorna uma lista de Endereços";
WSSYNTAX "address/{SearchKey, Status, Page, PageSize}"; 
PATH "address"       PRODUCES APPLICATION_JSON 

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  Purchases;
DESCRIPTION "Retorna uma lista de Produtos";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}"; 
PATH "purchases"       PRODUCES APPLICATION_JSON 

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  Top3;
DESCRIPTION "Retorna uma lista de Produtos";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}"; 
PATH "top3"       PRODUCES APPLICATION_JSON

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  lotValidity;
DESCRIPTION "Retorna uma lista de Produtos";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}"; 
PATH "lotValidity"       PRODUCES APPLICATION_JSON

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  getCompEstoque;
DESCRIPTION "Retorna uma lista de Produtos";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}"; 
PATH "getCompEstoque"       PRODUCES APPLICATION_JSON

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  saldoSeguranca;
DESCRIPTION "Retorna uma lista de Produtos";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize}"; 
PATH "saldoSeguranca"       PRODUCES APPLICATION_JSON

END WSRESTFUL


//-------------------------------------------------------------------
/*/{TESTE.doc} GET/TESTE
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas 
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Pedro Antonio Missaglia
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Products WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE TESTE

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0     
Local nEntJson          := 0
Local nStart            := 0
Local lHasNext			:= .F.

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

//PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01 " USER 'admin' PASSWORD '1234'	
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" USER 'admin' PASSWORD ''

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
		GetProd(cAlias)
	    If (cAlias)->(!EOF())
	
	         COUNT TO nRecord
	        (cAlias)->(DBGoTop()) 
	
	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1 
	        EndIf
	        oJsonProd 			:=  JsonObject():New()
	        
	        SX2->( DbSetOrder( 1 ))
	        If SX2->( DbSeek ( "SB1" ) ) 
	        	oJsonProd["branch"	]	:= SX2->X2_MODO
	        	oJsonProd["business"]	:= SX2->X2_MODOEMP
	        	oJsonProd["unit"	]	:= SX2->X2_MODOUN
	        Endif
	        While (cAlias)->(!EOF())
	            nCount++
	            
	
	            If (nCount >= nStart) 
	                
	                nEntJson++
	                aAdd( aJsonProd,  JsonObject():New() )                 
	               
	                aJsonProd[nEntJson]["code"			]	:= (cAlias)->PRODUTO 				
					aJsonProd[nEntJson]["description"	]	:= (cAlias)->DESCRICAO				
					aJsonProd[nEntJson]["unity_mesure"	]	:= (cAlias)->UNIDADE
					aJsonProd[nEntJson]["address_control"]	:= AllTrim( (cAlias)->CONTROLE_ENDERECO 				) // S=sublote,L=lote,N= não controla
					aJsonProd[nEntJson]["warehouse"		]	:= (cAlias)->ARMAZEM
					aJsonProd[nEntJson]["batch_control"	]	:= (cAlias)->CONTROLE_LOTE
					aJsonProd[nEntJson]["quantity"		]	:= (cAlias)->QUANTIDADE_ESTOQUE
					aJsonProd[nEntJson]["value"			]	:= (cAlias)->VALOR_CUSTO
						
					If nEntJson < Self:PageSize .And. nCount < nRecord
	                
	                Else
	                    Exit 
	                EndIf
	            
	            	               
	            EndIf   
	
	            If ( nEntJson == Self:PageSize )	            	
	                Exit
				EndIf
				
				(cAlias)->(DbSkip())	
	            
	        EndDo
	                                  
	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize
	            
	            lHasNext	:= .F.
	        Else	            
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd 
	    	oJsonProd["hasNext"] 	:= lHasNext
	       
	    EndIf       
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= "Parametros de paginacao com valores Negativo"
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd 
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )	
    Self:SetResponse(cResponse)
Else	
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonProd) == "O"
	FreeObj(oJsonProd)
	oJsonProd := Nil
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{TESTE.doc} GET/TESTE
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas 
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Pedro Antonio Missaglia
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Purchases WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE TESTE

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0     
Local nEntJson          := 0
Local nStart            := 0
Local lHasNext			:= .F.

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

//PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01 " USER 'admin' PASSWORD '1234'	
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" USER 'admin' PASSWORD ''

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
		GetPurchase(cAlias)
	    If (cAlias)->(!EOF())
	
	         COUNT TO nRecord
	        (cAlias)->(DBGoTop()) 
	
	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1 
	        EndIf
	        oJsonProd 			:=  JsonObject():New()
	        
	        SX2->( DbSetOrder( 1 ))
	        If SX2->( DbSeek ( "SB1" ) ) 
	        	oJsonProd["branch"	]	:= SX2->X2_MODO
	        	oJsonProd["business"]	:= SX2->X2_MODOEMP
	        	oJsonProd["unit"	]	:= SX2->X2_MODOUN
	        Endif
	        While (cAlias)->(!EOF())
	            nCount++
	            
	
	            If (nCount >= nStart) 
	                
	                nEntJson++
	                aAdd( aJsonProd,  JsonObject():New() )                 
	               
	                aJsonProd[nEntJson]["code"			]	:= (cAlias)->Produto 				
					aJsonProd[nEntJson]["quantity"		]	:= (cAlias)->Quant				
					aJsonProd[nEntJson]["price"			]	:= (cAlias)->Preco
					aJsonProd[nEntJson]["total"			]	:= (cAlias)->Total 
					aJsonProd[nEntJson]["normal_price"	]	:= (cAlias)->Custo_Normal
					aJsonProd[nEntJson]["date"			]	:= (cAlias)->Data_Compra

					If ((cAlias)->Custo_Normal >= (cAlias)->Preco)
						aJsonProd[nEntJson]["analysis"		]	:= 'Boa Compra'
						aJsonProd[nEntJson]["status"		]	:= 'success'
					Else	
						aJsonProd[nEntJson]["analysis"		]	:= 'Analisar'
						aJsonProd[nEntJson]["status"		]	:= 'danger'
					EndIf

					If nEntJson < Self:PageSize .And. nCount < nRecord
	                
	                Else
	                    Exit 
	                EndIf
	            
	            	               
	            EndIf   
	
	            If ( nEntJson == Self:PageSize )	            	
	                Exit
				EndIf
				
				(cAlias)->(DbSkip())	
	            
	        EndDo
	                                  
	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize
	            
	            lHasNext	:= .F.
	        Else	            
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["purchases"]	:= aJsonProd 
	    	oJsonProd["hasNext"] 	:= lHasNext
	       
	    EndIf       
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= "Parametros de paginacao com valores Negativo"
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["purchases"]		:= aJsonProd 
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )	
    Self:SetResponse(cResponse)
Else	
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonProd) == "O"
	FreeObj(oJsonProd)
	oJsonProd := Nil
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{TESTE.doc} GET/TESTE
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas 
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Pedro Antonio Missaglia
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Top3 WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE TESTE

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0     
Local nEntJson          := 0
Local nStart            := 0
Local lHasNext			:= .F.

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

//PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01 " USER 'admin' PASSWORD '1234'	
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" USER 'admin' PASSWORD ''

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
		GetTop3(cAlias)
	    If (cAlias)->(!EOF())
	
	         COUNT TO nRecord
	        (cAlias)->(DBGoTop()) 
	
	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1 
	        EndIf
	        oJsonProd 			:=  JsonObject():New()
	        
	        SX2->( DbSetOrder( 1 ))
	        If SX2->( DbSeek ( "SB1" ) ) 
	        	oJsonProd["branch"	]	:= SX2->X2_MODO
	        	oJsonProd["business"]	:= SX2->X2_MODOEMP
	        	oJsonProd["unit"	]	:= SX2->X2_MODOUN
	        Endif
	        While (cAlias)->(!EOF())
	            nCount++
	            
	
	            If (nCount >= nStart) 
	                
	                nEntJson++
	                aAdd( aJsonProd,  JsonObject():New() )                 
	               
	                aJsonProd[nEntJson]["code"				]	:= (cAlias)->Produto 				
					aJsonProd[nEntJson]["revenues"			]	:= (cAlias)->Total				
					aJsonProd[nEntJson]["quantity_remaining"]	:= (cAlias)->Quant
					aJsonProd[nEntJson]["description"		]	:= Alltrim((cAlias)->Descr)
					aJsonProd[nEntJson]["position"			]	:= (cAlias)->Position		
					If nEntJson < Self:PageSize .And. nCount < nRecord
	                
	                Else
	                    Exit 
	                EndIf
	            
	            	               
	            EndIf   
	
	            If ( nEntJson == Self:PageSize )	            	
	                Exit
				EndIf
				
				(cAlias)->(DbSkip())	
	            
	        EndDo
	                                  
	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize
	            
	            lHasNext	:= .F.
	        Else	            
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd 
	    	oJsonProd["hasNext"] 	:= lHasNext
	       
	    EndIf       
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= "Parametros de paginacao com valores Negativo"
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd 
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )	
    Self:SetResponse(cResponse)
Else	
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonProd) == "O"
	FreeObj(oJsonProd)
	oJsonProd := Nil
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{TESTE.doc} GET/TESTE
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas 
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Pedro Antonio Missaglia
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET getCompEstoque WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE TESTE

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0     
Local nEntJson          := 0
Local nStart            := 0
Local lHasNext			:= .F.

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

//PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01 " USER 'admin' PASSWORD '1234'	
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" USER 'admin' PASSWORD ''

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
		GetCompEstoque(cAlias)
	    If (cAlias)->(!EOF())
	
	         COUNT TO nRecord
	        (cAlias)->(DBGoTop()) 
	
	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1 
	        EndIf
	        oJsonProd 			:=  JsonObject():New()
	        
	        SX2->( DbSetOrder( 1 ))
	        If SX2->( DbSeek ( "SB1" ) ) 
	        	oJsonProd["branch"	]	:= SX2->X2_MODO
	        	oJsonProd["business"]	:= SX2->X2_MODOEMP
	        	oJsonProd["unit"	]	:= SX2->X2_MODOUN
	        Endif
	        While (cAlias)->(!EOF())
	            nCount++
	            
	
	            If (nCount >= nStart) 
	                
	                nEntJson++
	                aAdd( aJsonProd,  JsonObject():New() )                 
	               
	                aJsonProd[nEntJson]["code"				]	:= (cAlias)->cod 				
					aJsonProd[nEntJson]["description"		]	:= Alltrim((cAlias)->descr)				
					aJsonProd[nEntJson]["quantity"			]	:= (cAlias)->Quant	
					If nEntJson < Self:PageSize .And. nCount < nRecord
	                
	                Else
	                    Exit 
	                EndIf
	            
	            	               
	            EndIf   
	
	            If ( nEntJson == Self:PageSize )	            	
	                Exit
				EndIf
				
				(cAlias)->(DbSkip())	
	            
	        EndDo
	                                  
	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize
	            
	            lHasNext	:= .F.
	        Else	            
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd 
	    	oJsonProd["hasNext"] 	:= lHasNext
	       
	    EndIf       
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= "Parametros de paginacao com valores Negativo"
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd 
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )	
    Self:SetResponse(cResponse)
Else	
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonProd) == "O"
	FreeObj(oJsonProd)
	oJsonProd := Nil
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{TESTE.doc} GET/TESTE
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas 
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Pedro Antonio Missaglia
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET lotValidity WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE TESTE

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0     
Local nEntJson          := 0
Local nStart            := 0
Local lHasNext			:= .F.

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

//PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01 " USER 'admin' PASSWORD '1234'	
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" USER 'admin' PASSWORD ''

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
		GetLotValidity(cAlias)
	    If (cAlias)->(!EOF())
	
	         COUNT TO nRecord
	        (cAlias)->(DBGoTop()) 
	
	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1 
	        EndIf
	        oJsonProd 			:=  JsonObject():New()
	        
	        SX2->( DbSetOrder( 1 ))
	        If SX2->( DbSeek ( "SB1" ) ) 
	        	oJsonProd["branch"	]	:= SX2->X2_MODO
	        	oJsonProd["business"]	:= SX2->X2_MODOEMP
	        	oJsonProd["unit"	]	:= SX2->X2_MODOUN
	        Endif
	        While (cAlias)->(!EOF())
	            nCount++
	            
	
	            If (nCount >= nStart) 
	                
	                nEntJson++
	                aAdd( aJsonProd,  JsonObject():New() )                 
	               
	                aJsonProd[nEntJson]["code"				]	:= (cAlias)->Produto 				
					aJsonProd[nEntJson]["description"		]	:= Alltrim((cAlias)->Descr)				
					aJsonProd[nEntJson]["lot"				]	:= Alltrim((cAlias)->Lote)
					aJsonProd[nEntJson]["quantity"			]	:= (cAlias)->Quant
					aJsonProd[nEntJson]["remaining_days"	]	:= (cAlias)->DiffEmDias

					If ((cAlias)->DiffEmDias > 0)
						aJsonProd[nEntJson]["status"		]	:= 'Expirando'
						aJsonProd[nEntJson]["status_color"	]	:= 'warning'
					Else
						aJsonProd[nEntJson]["status"		]	:= 'Expirou'
						aJsonProd[nEntJson]["status_color"	]	:= 'danger'
					EndIf

					If nEntJson < Self:PageSize .And. nCount < nRecord
	                
	                Else
	                    Exit 
	                EndIf
	            
	            	               
	            EndIf   
	
	            If ( nEntJson == Self:PageSize )	            	
	                Exit
				EndIf
				
				(cAlias)->(DbSkip())	
	            
	        EndDo
	                                  
	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize
	            
	            lHasNext	:= .F.
	        Else	            
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd 
	    	oJsonProd["hasNext"] 	:= lHasNext
	       
	    EndIf       
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= "Parametros de paginacao com valores Negativo"
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd 
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )	
    Self:SetResponse(cResponse)
Else	
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonProd) == "O"
	FreeObj(oJsonProd)
	oJsonProd := Nil
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{TESTE.doc} GET/TESTE
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas 
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Pedro Antonio Missaglia
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET saldoSeguranca WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE TESTE

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0     
Local nEntJson          := 0
Local nStart            := 0
Local lHasNext			:= .F.

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100

Self:SetContentType("application/json")

//PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "D MG 01 " USER 'admin' PASSWORD '1234'	
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" USER 'admin' PASSWORD ''

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
		GetSaldoSeg(cAlias)
	    If (cAlias)->(!EOF())
	
	         COUNT TO nRecord
	        (cAlias)->(DBGoTop()) 
	
	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1 
	        EndIf
	        oJsonProd 			:=  JsonObject():New()
	        
	        SX2->( DbSetOrder( 1 ))
	        If SX2->( DbSeek ( "SB1" ) ) 
	        	oJsonProd["branch"	]	:= SX2->X2_MODO
	        	oJsonProd["business"]	:= SX2->X2_MODOEMP
	        	oJsonProd["unit"	]	:= SX2->X2_MODOUN
	        Endif
	        While (cAlias)->(!EOF())
	            nCount++
	            
	
	            If (nCount >= nStart) 
	                
	                nEntJson++
	                aAdd( aJsonProd,  JsonObject():New() )                 
	               
	                aJsonProd[nEntJson]["code"				]	:= (cAlias)->cod 				
					aJsonProd[nEntJson]["description"		]	:= Alltrim((cAlias)->descr)				
					aJsonProd[nEntJson]["security"			]	:= (cAlias)->estseg
					aJsonProd[nEntJson]["quantity"			]	:= (cAlias)->quant
					aJsonProd[nEntJson]["price"				]	:= (cAlias)->Preco
					If nEntJson < Self:PageSize .And. nCount < nRecord
	                
	                Else
	                    Exit 
	                EndIf
	            
	            	               
	            EndIf   
	
	            If ( nEntJson == Self:PageSize )	            	
	                Exit
				EndIf
				
				(cAlias)->(DbSkip())	
	            
	        EndDo
	                                  
	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize
	            
	            lHasNext	:= .F.
	        Else	            
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd 
	    	oJsonProd["hasNext"] 	:= lHasNext
	       
	    EndIf       
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= "Parametros de paginacao com valores Negativo"
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd 
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonProd )	
    Self:SetResponse(cResponse)
Else	
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonProd) == "O"
	FreeObj(oJsonProd)
	oJsonProd := Nil
Endif

Return (lRet)

Static Function GetProd(cAliasQry)
    
	BeginSQL Alias cAliasQry
	
	SELECT 
		B1_COD PRODUTO, B1_DESC DESCRICAO, B1_UM UNIDADE, B1_RASTRO CONTROLE_LOTE,
		B1_LOCALIZ CONTROLE_ENDERECO, B2_LOCAL ARMAZEM, B2_QATU QUANTIDADE_ESTOQUE,
		B2_VATU1 VALOR_CUSTO

	FROM 
		%Table:SB1% SB1,
		%Table:SB2% SB2		
	WHERE 
		B1_COD = B2_COD
	EndSQL

Return

Static Function GetPurchase(cAliasQry)
    
	BeginSQL Alias cAliasQry
	
	SELECT 
		C7_PRODUTO Produto, C7_QUANT Quant, C7_PRECO Preco, C7_TOTAL Total, B1_CUSTD Custo_Normal, C7_DINICOM Data_Compra
	FROM 
		%Table:SC7% SC7, 
		%Table:SB1% SB1
	WHERE 
		B1_COD = C7_PRODUTO
	EndSQL

Return

Static Function GetTop3(cAliasQry)
    
	BeginSQL Alias cAliasQry
	
	SELECT 
		D2_COD Produto, SUM(D2_TOTAL) as Total, B2_QATU Quant, B1_DESC Descr, ROW_NUMBER() OVER (ORDER BY sum(D2_TOTAL) DESC) Position 
	FROM 
		%Table:SB2% SB2, 
		%Table:SD2% SD2,
		%Table:SB1% SB1
	WHERE 
		D2_COD = B2_COD
	AND 
		B1_COD = B2_COD
	GROUP BY 
		D2_COD, B2_QATU, B1_DESC
	ORDER BY 
		Total DESC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY	
	EndSQL

Return

Static Function GetLotValidity(cAliasQry)
    
	BeginSQL Alias cAliasQry
	
	SELECT 
		B8_PRODUTO AS Produto, B1_DESC AS Descr, B8_LOTECTL Lote, B8_SALDO Quant, 
		DATEDIFF(DAY, (CONVERT( varchar, getdate(), 112 )),B8_DTVALID ) AS DiffEmDias
	FROM 
		%Table:SB1% SB1,
		%Table:SB8% SB8		
	WHERE 
		DATEDIFF(DAY, (CONVERT( varchar, getdate(), 112 )),B8_DTVALID ) < 30 
	AND 
		B8_PRODUTO = B1_COD
	ORDER BY 
		DiffEmDias	
	EndSQL

Return


Static Function GetCompEstoque(cAliasQry)
    
	BeginSQL Alias cAliasQry
	
	SELECT 
		B1_DESC descr, B2_COD cod, B2_QATU Quant
	FROM 
		%Table:SB1% SB1,
		%Table:SB2% SB2		
	WHERE 
		B1_COD = B2_COD 
	EndSQL

Return

Static Function GetSaldoSeg(cAliasQry)
    
	BeginSQL Alias cAliasQry
	
	SELECT 
		B1_COD cod, B1_DESC descr, B1_ESTSEG estseg, B2_QATU quant, B1_CUSTD Preco
	FROM 
		%Table:SB1% SB1,
		%Table:SB2% SB2		
	WHERE 
		B1_COD = B2_COD
	AND 
		B2_QATU <= B1_ESTSEG 
	ORDER BY 
		B2_QATU	 
	EndSQL

Return