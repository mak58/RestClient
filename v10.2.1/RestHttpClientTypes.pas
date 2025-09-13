unit RestHttpClientTypes;

interface

uses System.Net.HttpClient;

type

/// Input Request
  TRequestParams = record
    payload: string;
    Token: string;
    KindToken: string; {'bearer', 'basic'}
    Method: string;
    BaseUrl: string;
    ContentType: string;
    Uri: string;
    Timeout: Integer;
    Charset: string;
    Accept: string;
    HandleRedirects: boolean;
    SynchronizedEvents: boolean;
    SecureProtocols: THTTPSecureProtocols; {[THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS11]}
    Headerkey1: string; {'apiKey'}
    Headerkey2: string; {sAPIKey}
    HeaderValue1: string; {'Cache-Control'}
    HeaderValue2: string; {'no-cache'}
  end;

/// Output Response
  TResult = record
    IsSuccessful: Boolean;
    StatusCode: Integer;
    Data: string;
    Error: string;
  end;

/// <summary>
///   Interface to use in Rest Request Classes;
/// </summary>

  IRestClient = interface
  ['{72AC0083-83E6-4D56-AEC3-8424CF8FC3A6}']
  function MapGet(const payload: string = ''): TResult;
  function MapPost(const payload: string): TResult; overload;
  function MapPut(const payload: string): TResult;
  function MapDelete(): TResult;
  end;


implementation

end.
