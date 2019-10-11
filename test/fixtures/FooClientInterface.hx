package fixtures;

import haxe.ds.StringMap;
import fb.http.GraphRawResponse;
import fb.httpclient.FacebookHttpClientInterface;

class FooClientInterface implements FacebookHttpClientInterface
{
    public function new( )
    {

    }
    
    public function send( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int ) : GraphRawResponse
    {
        return new GraphRawResponse(
            '{"data":[{"id":"123","name":"Foo"},{"id":"1337","name":"Bar"}]}',
            "HTTP/1.1 1337 OK\r\nDate: Mon, 19 May 2014 18:37:17 GMT"
        );
    }
}
