# 🌐 Delphi REST HTTP Client (Delphi 10.2+)

This project provides a clean and extensible way to make RESTful HTTP requests using **Delphi 10.2**, inspired by the simplicity and structure of **C#'s `TResult` and HTTP client models**.

---

## 📦 Project Structure - Version 1.0 (2024)

This solution is organized into **two main units**:

### 🔹 `Rest.HttpClient`

Note: I had to remove the dot (.) from the unit names to ensure compatibility with Delphi 12.


This unit contains a class that encapsulates an internal HTTP component, exposing high-level REST methods such as:

- `MapGet`
- `MapPost`
- `MapUpdate`
- `MapDelete`

Usage requires only the creation of a `TRequestParams` record and the instantiation of the class.  
The design promotes simplicity, type safety, and clear separation of concerns.

### 🔹 `Rest.HttpClient.Types`

This unit defines all the types used in the REST client layer, including:

- `TRequestParams` → A structured input record for passing request parameters to the client  
- `TResult<T>` → A generic result wrapper based on the `TResult` concept from C#  
- `IRestClient` → Interface used to decouple implementation from usage

---

## 🧰 How to Use

```delphi
uses
  Rest.HttpClient.Types, Rest.HttpClient;

var
  RestClient: IRestClient;
  Params: TRequestParams;
  ResultData: TResult<string>;
begin
  Params := TRequestParams.Create('https://api.example.com/data');
  RestClient := TRestHttpClient.Create;

  ResultData := RestClient.MapGet<string>(Params);

  if ResultData.Success then
    ShowMessage(ResultData.Data)
  else
    ShowMessage(ResultData.ErrorMessage);
end;

 
