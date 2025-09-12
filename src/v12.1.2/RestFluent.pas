unit RestFluent;

{  __   __
  |  | |  |________
  |  |_| |        _|______
  |      |__    _|       _|_____
  |   _   | |  | |__   __|      \
  |  | |  | |  |    |  | |  __   |
  |__| |__| |  |    |  | |  |_|  |
            |__|    |  | |       |
                    |__| |   ___/
    _       _        __  |  |
   /  /  / /_  /| /  /   |__|
  /_ /_ / /_  / |/  / Copyright (C) 2024 Márcio Koehler - v12.1.2
 }

interface

uses
  REST.Client, REST.Types,
  System.Generics.Collections;

type
  TKindAuth = (eDefault, eJWT, eBearer, eAuth, eBasic);

/// Output Response
  TResult = record
    IsSuccessful: Boolean;
    StatusCode: Integer;
    Data: string;
    Error: string;
  end;

  TAddParameter = record
    Name: string;
    Value: string;
    Kind: Byte;

    class function Create(const AName, AValue: string; AKind: Byte): TAddParameter; static;
  end;  

  /// <summary>
  ///  Event called when is used ExecuteAsync on RestClient instance. (v12.1.2)
  /// </summary>
  TOnRequestFinished = reference to procedure(const AResult: TResult);

  IRestFluent = interface
    ['{87CF502B-E37B-4C70-AEDB-0024B79BF18C}']
    function AddToken(const AToken: string; const AKind: TKindAuth): IRestFluent;
    function AddPayload(const AJson: string): IRestFluent;
    function AddSecureProtocols(const AValue: Integer): IRestFluent;
    function AddFile(const AFilePath, AContentType: string): IRestFluent;
    function SetHandle(AHandleRedirects, ASyncEvents: Boolean): IRestFluent;
    function SetAccept(const AAccept, ACharset: string): IRestFluent;
    function AddHeader(ASettings: TArray<string>): IRestFluent;
    function AddParams(const AName, AValue: string; AKind: Byte = 4): IRestFluent;

    function MapGet(const APath: string): TResult;
    function MapPost(const APath: string): TResult;
    function MapPut(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapDelete(const APath: string): TResult;

    function MapGetAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapPostAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapPutAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapDeleteAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
  end;

   TRestFluent = class(TInterfacedObject, IRestFluent)
   private
     RestClient: TRESTClient;
     RestResponse: TRESTResponse;
     FToken, FPayload: string;
     FFilePath, FContentType: string;
     FAccept, FCharset: string;
     FHandleRedirect, FSyncEvent: Boolean;
     FAsync: Boolean;
     FHeaderParams: TArray<string>;
     FListParams: TList<TAddParameter>;
     FOnFinished: TOnRequestFinished;
     RestClientInterface: IRestFluent;
     function ExecuteRequest(AMethod: TRESTRequestMethod;
       const AURL: string): TResult;
     function GetResultRequest(out AResult: TResult;
       ARestRequest: TRESTRequest): TResult;
     procedure ExecuteNewRequestSettings(out ARequest: TRESTRequest);
     procedure ExecuteExcept(out AResult: TResult; ARestRequest: TRESTRequest);
   public
    function AddToken(const AToken: string; const AKind: TKindAuth): IRestFluent;
    function AddPayload(const AJson: string): IRestFluent;
    function AddSecureProtocols(const AValue: Integer): IRestFluent;
    function AddFile(const AFilePath, AContentType: string): IRestFluent;
    function SetHandle(AHandleRedirects, ASyncEvents: Boolean): IRestFluent;
    function SetAccept(const AAccept, ACharset: string): IRestFluent;
    function AddHeader(ASettings: TArray<string>): IRestFluent;
    function AddParams(const AName, AValue: string; AKind: Byte = 4): IRestFluent;    

    function MapGet(const APath: string): TResult;
    function MapPost(const APath: string): TResult;
    function MapPut(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapDelete(const APath: string): TResult;

    function MapGetAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapPostAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapPutAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;
    function MapDeleteAsync(const APath: string; ACallback: TOnRequestFinished = nil): TResult;

    constructor Create();
    destructor Destroy();
   end;

  const
    LKindAuthName: array[TKindAuth] of string = ('', '', 'Bearer ', '', 'Basic ');

implementation

uses
  System.Net.HttpClient,
  System.SysUtils, System.StrUtils, System.Classes;

{ TRestFluent }

constructor TRestFluent.Create();
begin
  inherited;
  FToken := '';
  FAsync := False;
  FFilePath := '';
  FContentType := '';
  FHandleRedirect := True;
  FSyncEvent := False;
  FAccept := '';
  FCharset := '';
  FAccept := '';
  FCharset := '';

  RestClient :=  TRESTClient.Create(nil);
  RestClient.ResetToDefaults();
end;

destructor TRestFluent.Destroy();
begin
  FListParams.Free;
  inherited;
end;

function TRestFluent.AddToken(const AToken: string;
  const AKind: TKindAuth): IRestFluent;
begin
  if (AToken <> '') then
    FToken := Trim(LKindAuthName[AKind] + AToken);
  Result := Self;
end;

function TRestFluent.AddPayload(const AJson: string): IRestFluent;
begin
  FPayload := AJson;
  Result := Self;
end;

function TRestFluent.AddSecureProtocols(const AValue: Integer): IRestFluent;
begin
/// <summary>
/// <param name="AValue">
///  An integer that representants THTTPSecureProtocol index;
///  System.Net.HttpClient.THTTPSecureProtocol = (SSL2, SSL3, TLS1, TLS11, TLS12, TLS13);
/// </param>
/// </summary>
  RestClient.SecureProtocols := [THTTPSecureProtocol(AValue)];
  Result := Self;
end;

function TRestFluent.AddFile(const AFilePath, AContentType: string): IRestFluent;
begin
  FFilePath := AFilePath;
  FContentType := AContentType;
  Result := Self;
end;

function TRestFluent.SetAccept(const AAccept, ACharset: string): IRestFluent;
begin
/// <summary>
///  sRequestDefaultAccept = [ctAPPLICATION_JSON, ctTEXT_PLAIN, ctTEXT_HTML];
///  sRequestDefaultAcceptCharset = 'utf-8,
/// </summary>
  FAccept := AAccept;
  FCharset := ACharset;
  Result := Self;
end;

function TRestFluent.SetHandle(AHandleRedirects, ASyncEvents: Boolean): IRestFluent;
begin
/// <summary>
/// HandleRedirects is True default on unit REST.Client;
/// SynchronizedEvents is False;
/// </summary>
  FHandleRedirect := AHandleRedirects;
  FSyncEvent := ASyncEvents;
  Result := Self;
end;

function TRestFluent.AddHeader(ASettings: TArray<string>): IRestFluent;
begin
/// <summary>
/// Receive pairs of strings and add it to Header;
///  Suitable to x-api-key or cacheControl...
/// </summary>
  FHeaderParams := ASettings;
  Result := Self;
end;

function TRestFluent.AddParams(const AName, AValue: string;
  AKind: Byte = 4): IRestFluent;
begin
/// <summary>
/// AKind = [pkCOOKIE, pkGETorPOST, pkURLSEGMENT, pkHTTPHEADER, pkREQUESTBODY, pkFILE, pkQUERY];
/// default = pkREQUESTBODY;
/// </summary>
  if (not Assigned(FListParams)) then
    FListParams := TList<TAddParameter>.Create();

  FListParams.Add(TAddParameter.Create(AName, AValue, AKind));
  
  Result := Self;
end;

{Requests}

function TRestFluent.ExecuteRequest(AMethod: TRESTRequestMethod;
  const AURL: string): TResult;
var
  resultRequest: TResult;
  RestRequest: TRESTRequest;
begin
  try
    Self.ExecuteNewRequestSettings(RestRequest);
    RestClient.BaseURL := AURL;
    RestRequest.Method := AMethod;
    if (FAsync) then
    begin
      RestClientInterface := Self;
      RestRequest.ExecuteAsync(
        procedure
        begin
          Self.GetResultRequest(resultRequest, RestRequest);

          TThread.Queue(nil,
            procedure
            begin
              if Assigned(FOnFinished) then
              begin
                FOnFinished(resultRequest);
                RestClientInterface := nil;
              end;
            end);
        end,
        True,
        True);
      FAsync := False;
    end
    else
    begin
      RestRequest.Execute();

      Self.GetResultRequest(Result, RestRequest);
    end;
  except
    Self.ExecuteExcept(resultRequest, RestRequest);
    Result := resultRequest;
  end;
end;

procedure TRestFluent.ExecuteNewRequestSettings(out ARequest: TRESTRequest);
var
  Response: TRESTResponse;
  indexH, indexP: Byte;
begin
/// <summary>
///  For each request is created new instances of REQUEST and RESPONSE components.
///  The CLIENT stick with the same.
/// </summary>
  ARequest := TRESTRequest.Create(nil);
  Response := TRESTResponse.Create(nil);

  ARequest.ResetToDefaults();
  Response.ResetToDefaults();

  ARequest.Client := RestClient;
  ARequest.Response := Response;

  if (FToken <> '') then
    ARequest.AddAuthParameter('Authorization',
      FToken, pkHTTPHEADER,[poDoNotEncode]);

  if (Assigned(FListParams)) then
  begin
    for indexP := 0 to FListParams.Count -1 do
      ARequest.AddParameter(FListParams[indexP].Name,
        FListParams[indexP].Value, TRESTRequestParameterKind(FListParams[indexP].Kind));
    FListParams.Clear;
  end;

  if not (string.IsNullOrEmpty(FPayload)) then
    ARequest.AddBody(FPayload, TRESTContentType.ctAPPLICATION_JSON)
  else
    if (FFilePath <> '') and (FContentType <> '') then
      ARequest.AddFile('file', FFilePath, FContentType);

  RestClient.HandleRedirects := FHandleRedirect;
  ARequest.SynchronizedEvents := FSyncEvent;
  ARequest.Accept := FAccept;
  ARequest.AcceptCharset := FCharset;

  if (Length(FHeaderParams) >= 2) then
  begin    
    for indexH := 0 to High(FHeaderParams) do       
      if (indexH mod 2 = 0) then      
        ARequest.Params.AddHeader(FHeaderParams[indexH], FHeaderParams[indexH + 1]);
    FHeaderParams := nil;
  end;
end;

function TRestFluent.GetResultRequest(out AResult: TResult;
  ARestRequest: TRESTRequest): TResult;
begin
  case (ARestRequest.Response.StatusCode) of
    200, 400, 401 : AResult.Data := ARestRequest.Response.Content;
    500: AResult.Error := 'InternalServerError ' + ARestRequest.Response.Content;
  end;
  AResult.StatusCode := ARestRequest.Response.StatusCode;
  AResult.IsSuccessful := (ARestRequest.Response.StatusCode = 200);
end;

procedure TRestFluent.ExecuteExcept(out AResult: TResult; ARestRequest: TRESTRequest);
begin
  AResult.StatusCode := ARestRequest.Response.StatusCode;

  case (AResult.StatusCode) of
    0: AResult.Error := 'Error on HTTP connection. Verify your network';
  else
    AResult.Error := ARestRequest.Response.ErrorMessage;
  end;
end;

function TRestFluent.MapGet(const APath: string): TResult;
begin
  Result := Self.ExecuteRequest(TRESTRequestMethod.rmGET,
    APath);
end;

function TRestFluent.MapGetAsync(const APath: string;
  ACallback: TOnRequestFinished): TResult;
begin
  FAsync := True;

  if Assigned(ACallback) then
    FOnFinished := ACallback;

  Result := Self.ExecuteRequest(TRESTRequestMethod.rmGET,
    APath);
end;

function TRestFluent.MapPost(const APath: string): TResult;
begin
  Result := Self.ExecuteRequest(TRESTRequestMethod.rmPost,
    APath);
end;

function TRestFluent.MapPostAsync(const APath: string;
  ACallback: TOnRequestFinished): TResult;
begin
  FAsync := True;

  if Assigned(ACallback) then
    FOnFinished := ACallback;

  Result := Self.ExecuteRequest(TRESTRequestMethod.rmPost,
    APath);
end;

function TRestFluent.MapPut(const APath: string;
  ACallback: TOnRequestFinished): TResult;
begin
  Result := Self.ExecuteRequest(TRESTRequestMethod.rmPUT,
    APath);
end;

function TRestFluent.MapPutAsync(const APath: string;
  ACallback: TOnRequestFinished): TResult;
begin
  FAsync := True;

  if Assigned(ACallback) then
    FOnFinished := ACallback;

  Result := Self.ExecuteRequest(TRESTRequestMethod.rmPUT,
    APath);
end;

function TRestFluent.MapDelete(const APath: string): TResult;
begin
  Result := Self.ExecuteRequest(TRESTRequestMethod.rmDELETE,
    APath);
end;

function TRestFluent.MapDeleteAsync(const APath: string;
  ACallback: TOnRequestFinished): TResult;
begin
  FAsync := True;

  if Assigned(ACallback) then
    FOnFinished := ACallback;

  Result := Self.ExecuteRequest(TRESTRequestMethod.rmDELETE,
    APath);
end;

{ TAddParameter }

class function TAddParameter.Create(const AName, AValue: string;
  AKind: Byte): TAddParameter;
begin
  Result.Name  := AName;
  Result.Value := AValue;
  Result.Kind  := AKind;
end;

end.
