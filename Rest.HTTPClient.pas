unit Rest.HTTPClient;
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
  /_ /_ / /_  / |/  /
 }
interface

uses
  REST.Client, REST.Types, System.Json, REST.Json, System.SysUtils, System.StrUtils,
  Rest.HttpClient.Types;

type

  /// <summary>
  ///  Copyright (C) 2024 Márcio Koehler
  ///
  ///  This class was performed to work using Dependency Injection;
  ///  The class that want to use this service, will have to create a variable from type IRestClient and inject the THttpClientAPI in ctor or other deffered method;
  ///
  /// <param name="TRequestParams">
  ///  THttpClientAPI waits a record as parameter to create the service. (TRequestParams = record(Rest.HttpClient.Types) and passing by Ctor)
  ///  Inform the requested parameters in the creation time.
  /// </param>
  ///
  ///  There's a method called SetBaseAddressUri() that allows to pass main data like URL, URI, Token, TypeToken;
  ///
  /// <returns>
  ///  Returns a TResult record from Rest.HttpClient.Types;
  /// </returns>
  ///  The GET, POST, UPDATE, DELETE methods returns a JsonString.
  /// </summary>

  THttpClientAPI = class(TInterfacedObject, IRestClient)
  private
   RestClient: TRESTClient;
   RestRequest: TRESTRequest;
   RestResponse: TRESTResponse;
   procedure ExecuteRequest(var ARequest: TResult);
  public
    RequestParams: TRequestParams;

   procedure SetBaseAddressUri(newBaseAddress, newUri: string; const newToken: string = ''; const newKindToken: string = '');
   function MapGet(const payload: string = ''): TResult; virtual;
   function MapPost(const payload: string): TResult; virtual;
   function MapPut(const payload: string): TResult; virtual;
   function MapDelete(): TResult; virtual;

   constructor Create(const ARequestParams: TRequestParams); virtual;
   destructor Destroy; override;
  end;

implementation

{ THttpClient }

constructor THttpClientAPI.Create(const ARequestParams: TRequestParams);
begin
  RestRequest := TRESTRequest.Create(nil);
  RestClient :=  TRESTClient.Create(nil);
  RestResponse := TRESTResponse.Create(nil);

  RestRequest.Client := RestClient;
  RestRequest.Response := RestResponse;

  RestRequest.ResetToDefaults;
  RestClient.ResetToDefaults;
  RestResponse.ResetToDefaults;

  if (ARequestParams.SecureProtocols <> []) then
    RestClient.SecureProtocols := ARequestParams.SecureProtocols;

  if (ARequestParams.HandleRedirects) then
    RestClient.HandleRedirects := True;

  if (RestRequest.SynchronizedEvents) then
    RestRequest.SynchronizedEvents := True;

  RestRequest.Accept := IfThen(ARequestParams.Accept <> '', ARequestParams.Accept ,'text/plain');
  RestRequest.AcceptCharset := IfThen(ARequestParams.Charset <> '', ARequestParams.Charset ,'UTF-8');

  RestClient.BaseURL := ARequestParams.BaseUrl;
  RestRequest.Resource := ARequestParams.Uri;

  RestClient.ContentType := IfThen(ARequestParams.ContentType <> '',
    ARequestParams.ContentType,
    'application/json');

  RestRequest.AddAuthParameter('Authorization',
    IfThen(ARequestParams.KindToken <> ' ',
    ARequestParams.KindToken, 'Bearer') + '' + ARequestParams.Token, pkHTTPHEADER,[poDoNotEncode]);

  if (ARequestParams.HeaderKey1 <> '') and (ARequestParams.HeaderValue1 <> '') then
    RestRequest.Params.AddHeader(ARequestParams.HeaderKey1, ARequestParams.HeaderValue1);

  if (ARequestParams.HeaderKey2 <> '') and (ARequestParams.HeaderValue2 <> '' ) then
    RestRequest.Params.AddHeader(ARequestParams.HeaderKey2, ARequestParams.HeaderValue2);

  if (ARequestParams.Timeout = 0) then
    RestRequest.Timeout := 30000;
end;

destructor THttpClientAPI.Destroy;
begin
  RestRequest.Free();
  RestClient.Free();
  RestResponse.Free();
end;

procedure THttpClientAPI.ExecuteRequest(var ARequest: TResult);
begin
  try
    RestRequest.Execute();

    ARequest.StatusCode := RestRequest.Response.StatusCode;

    case (RestRequest.Response.StatusCode) of
      200, 400, 401 : ARequest.Data := RestResponse.Content;

      500: ARequest.Data := IntToStr(RestRequest.Response.StatusCode) + ' InternalServerError';
    end;

    ARequest.IsSuccessful := (RestRequest.Response.StatusCode = 200);
  except
    ARequest.StatusCode := RestRequest.Response.StatusCode;

    case (ARequest.StatusCode) of
      0: ARequest.Error := 'Error - Houve um erro na conexão HTTP. Verifique sua rede de internet';
    else
      ARequest.Error := RestRequest.Response.ErrorMessage;
    end;
  end;
end;

procedure THttpClientAPI.SetBaseAddressUri(newBaseAddress, newUri: string; const newToken: string = ''; const newKindToken: string = '');
/// <summary>
///  there are two possibilities:
///  (1) Create the THttpClientAPI class by defining BaseAddress and URI.
///  (2) Updating ou passing the BaseAddress, URI or a new token and a new type' by this method.
///  If it is necessary to make more than one request, this can be done in the same instance just by configuring the BaseAddress and URI using this method.
/// </summary>
var
  kindToken: string;
begin
  RestRequest.Resource := EmptyStr;

  if not (string.IsNullOrEmpty(newBaseAddress)) then
    RestClient.BaseURL := newBaseAddress;

  if not (string.IsNullOrEmpty(newUri)) then
    RestRequest.Resource := newUri;

  if not (string.IsNullOrEmpty(newToken)) then
  begin
    if not (string.IsNullOrEmpty(newKindToken)) then
      kindToken := Trim(newKindToken)
    else
      kindToken := 'Bearer';

    RestRequest.AddAuthParameter('Authorization', kindToken + ' ' + newToken, pkHTTPHEADER,[poDoNotEncode]);
  end;
end;

function THttpClientAPI.MapGet(const payload: string = ''): TResult;
begin
  RestRequest.Method := TRESTRequestMethod.rmGET;

  if not (string.IsNullOrEmpty(payload)) then
    RestRequest.AddBody(payload, TRESTContentType.ctAPPLICATION_JSON);

  Self.ExecuteRequest(Result);
end;

function THttpClientAPI.MapPost(const payload: string): TResult;
begin
  RestRequest.Method := TRESTRequestMethod.rmPost;

  RestRequest.ClearBody();

  RestRequest.AddBody(payload, TRESTContentType.ctAPPLICATION_JSON);

  Self.ExecuteRequest(Result);
end;

function THttpClientAPI.MapPut(const payload: string): TResult;
begin
  RestRequest.Method := TRESTRequestMethod.rmPUT;

  RestRequest.ClearBody();

  RestRequest.AddBody(payload, TRESTContentType.ctAPPLICATION_JSON);

  Self.ExecuteRequest(Result);
end;

function THttpClientAPI.MapDelete(): TResult;
begin
  RestRequest.Method := TRESTRequestMethod.rmDELETE;

  Self.ExecuteRequest(Result);
end;

end.
