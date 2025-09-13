unit RestClientBuilder;

interface

uses
  RestHTTPClient, RestHttpClientTypes;

type
  TKindAuth =  (default, JWT, Bearer, Auth);

  TRestClientBuilder = class
  private
    FBaseUrl: string;
    FKindAuth: TKindAuth;
    FToken: string;
    FTimeout: Integer;
    FBody: string;
    FUri: string;
  public
    constructor Create(const ABaseUrl: string);

    function KindAuth(const AKind: TKindAuth): TRestClientBuilder;
    function Token(const AValue: string): TRestClientBuilder;
    function Timeout(const AValue: Integer): TRestClientBuilder;
    function Body(const AValue: string): TRestClientBuilder;
    function Uri(const AValue: string): TRestClientBuilder;
    function Build(): IRestClient;
  end;

implementation

const
  LKindAuthName: array[TKindAuth] of string = ('', '', 'Bearer ', '');

{ TRestClientBuilder }

constructor TRestClientBuilder.Create(const ABaseUrl: string);
begin
  FBaseUrl := ABaseUrl;
  FToken := '';
  FTimeout := 3000;
  FBody := '';
  FUri := '';
end;

function TRestClientBuilder.KindAuth(
  const AKind: TKindAuth): TRestClientBuilder;
begin
  FKindAuth := AKind;
  Result := Self;
end;

function TRestClientBuilder.Token(const AValue: string): TRestClientBuilder;
var
  KindName: string;
begin
  FToken :=  AValue;
  Result := Self;
end;

function TRestClientBuilder.Timeout(const AValue: Integer): TRestClientBuilder;
begin
  FTimeout := AValue;
  Result := Self;
end;

function TRestClientBuilder.Body(const AValue: string): TRestClientBuilder;
begin
  FBody := AValue;
  Result := Self;
end;

function TRestClientBuilder.Uri(const AValue: string): TRestClientBuilder;
begin
  FUri := AValue;
  Result := Self;
end;

function TRestClientBuilder.Build(): IRestClient;
begin
  var inputParams: TRequestParams;

  inputParams.BaseUrl := FBaseUrl;
  inputParams.KindToken := LKindAuthName[FKindAuth] + ' ';
  inputParams.Token := FToken;
  inputParams.Uri := FUri;
  inputParams.Timeout := FTimeout;
  Result := TRestHttp.Create(inputParams);
end;
end.
