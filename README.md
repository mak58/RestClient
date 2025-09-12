# REST Feature 

Este projeto contém uma **feature REST** que permite executar requisições REST de forma **simples, fluida e desacoplada**.  

---

## Versões

- **v10.2.1** – versão inicial da feature  (Classe THttpRestAPI)
- **v12.1.1** – melhorias de estabilidade e suporte ampliado (classes TRestHttp e TRestClientBuilder) 
- **v12.1.2** – adição do suporte a execução **assíncrona**;

---
## Exemplo de uso – v10.2.1 (10/2024)

> Compatível com versão 10.2+.

> Fontes utilizados em produção em projeto de 22 anos com exe em Delphi 7 e requisição dentro de dll em Delphi 10.2;

> Identificado uma falha ao adiconar Bearer token, corrigido na versão v12.1.1;

> Criado para realizar uma chamada somente, porém tendo a possibilidade de alterar URL/URI e token através do método SetBaseAddressUri e realizar novamente passando Json pelo MapGet, mapPost e MapPut;

    uses RestHTTPClient, RestHttpClientTypes;

    procedure TEasyStoreMain.TestApi();
    var
    IRest: IRestClient;
    LParams: TRequestParams;
    LResponse: TResult;
    begin
      LParams.BaseUrl := 'http://localhost:5000/';
  
      IRest := THttpClientAPI.Create(LParams);
      LResponse := IRest.MapGet();
  
      ShowMessage(LResponse.Data);
    end;

> Não é necessário liberar a memória do objeto IRest, pois a Interface irá liberar ao sair do escopo. (Reference counting Interface)    
    
## Exemplo de uso – v12.1.1 (08/2025)

> O recurso utiliza o **Builder Pattern** para criação do cliente REST, oferecendo suporte a chamadas **síncronas**.

> Necessário somente adicionar a unit "RestClientBuilder" à Unit que utilizará a funcionalidade Rest.

> Mantido internamente as units da versão anterior (RestHTTPClient, RestHttpClientTypes) com a correção ao usar Berar Token;

> Remoção do record de parâmetros de entrada para métodos encadeados e a dependência a unit de Types;

### 🔹 Modo Síncrono
Neste modo, o *builder* devolve uma **interface**.  
A chamada é executada de forma síncrona e o retorno é imediato.

    uses RestClientBuilder;

    var client := TRestClientBuilder.Create(URL_WHATS)
                     .KindToken(Bearer)   
                     .Token(TOKEN)
                     .Build();

    var response := client.MapPost(LBody.ToJSON);

> Liberação de memória do objeto client é gerenciado pela Interface, sendo liberado automaticamente;
 
> Corrigido teste pelo nome do kindToken no create da TRestHttp dando a possibilidade de usar Bearer;

> Removido método SetBaseAddressUri da IRestClient Interface e mantido como método adicional ao uso Síncrono;

> Método TRestClientBuilder.Build() devolve os metodos da IRestClient Interface;

## Exemplo de uso – v12.1.2 (09/2025)

> Introdução do uso assíncrono com a possibilidade de passar um callback lidando com a resposta no estilo async/Wait do .net;

> Além de permitir o uso Assíncrono, foi permitido o uso de multiplas sessões de requests na mesma instância do client;

> Removido classe Builder (TRestClientBuilder) para esta versão;

> Mantido os types auxiliares à classe TRestFluent (antiga TRestHttp) na mesma unit;

### 🔹 Modo Síncrono e Assíncrono

> Declaração somente da unit RestFluent;

> Criação da interface IRestFluent;

> Chamada encadeada para método Post;

    uses RestFluent;

    var client := TRestFluent.Create();
  
    var return := client.AddToken(TOKEN, eBearer) /// Type inference to TResult
      .AddPayload(LBody2.ToJSON)
      .MapPost(ULR_WHATS);

> Possibilidade de realizar multiplas requisições com o mesmo client;

    uses RestFluent;

    const ULR_WHATS = 'https://graph.facebook.com/v23.0/775317196378409/messages';

    var client := TRestFluent.Create();

    // First request

    var return := client.AddToken(TOKEN, eBearer) /// Type inference to TResult(Unit RestFluent) 
      .AddPayload(LBody2.ToJSON)
      .MapPost(ULR_WHATS);

    // Second request

     client.AddToken(TOKEN, eBearer)
        .AddPayload(LBody.ToJSON)
        .MapPostAsync(ULR_WHATS,
           procedure(const R: TResult)
           begin
             ShowMessage('Status: ' + IntToStr(R.StatusCode) + 'Data: ' + R.Data);
           end);  

> Não é necessário liberar a memória do objeto IRest, pois a Interface irá liberar ao sair do escopo. (Reference counting Interface)

> Metodos de adição de File e configuração de Header que podem ser mencionados ao realizar a requisição;
   
    AddSecureProtocols(const AValue: Integer) // Index to THTTPSecureProtocol = (SSL2, SSL3, TLS1, TLS11, TLS12, TLS13);

    AddFile(const AFilePath, AFileType: string) // File path and Type (.pdf, image/jpeg, audio/mpeg);

    SetHandle(AHandleRedirects, ASyncEvents: Boolean) // Define values not default;

    SetAccept(const AAccept, ACharset: string) // Define values not default;
    
    AddHeader(['x-api-key','Hello World']) // Suitable to x-api-key or cacheControl...

    AddParams(const AName, AValue: string; AKind: Byte = 4) // Params to Body

> Adicionado arquivo boss.json para instalação via gerenciador de pacotes;

    
 
