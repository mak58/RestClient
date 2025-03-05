Two units from Delphi 10.2;

Rest.HttpClient is a unit containning a class that encapusulate an object to make a rest request; 
It's just need to create a record object TRequestParams and create the class. 
Soon, the methods like MapGet, MapPost, MapUpdate and MapDelete will be accessible;

Rest.HttpClient.Types is a unit containning three objects complex types.
> TRequestParams /// Input to Rest.HttpClient
> TResult; /// Base on TResult from C#
> IRestClient; /// Interface that implements on Rest.HttpClient;

Using these two Units, it is easy to make requests where the traffic is Json;
To expand to other data types, such as Files, simply inherit from Rest.HttpClient and add new methods.

The class Rest.HttpClient is used declaring a variable IRestClient in a target classe, and passing a new instance by a 
constructor method or a especial method that receives a IRestClient;
 
