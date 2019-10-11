package fixtures;

import haxe.ds.StringMap;

import fb.http.GraphRawResponse;
import fb.httpclient.FacebookHttpClientInterface;


class MyFooBatchClientHandler implements FacebookHttpClientInterface
{
    public function new( )
    {

    }

    // public function send($url, $method, $body, array $headers, $timeOut)
    public function send( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int ) : GraphRawResponse
    {
        return new GraphRawResponse(
            '[{"code":"123","body":"Foo"},{"code":"1337","body":"Bar"}]',
            "HTTP/1.1 200 OK\r\nDate: Mon, 19 May 2014 18:37:17 GMT"
        );
    }
}