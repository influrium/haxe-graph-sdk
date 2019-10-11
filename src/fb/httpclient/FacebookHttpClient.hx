package fb.httpclient;

import sys.Http;
import haxe.ds.StringMap;

import fb.http.GraphRawResponse;
import fb.error.FacebookSDKException;


class FacebookHttpClient implements FacebookHttpClientInterface
{

    public function new( )
    {

    }

    /**
     * @inheritdoc
     */
    public function send( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int ) : GraphRawResponse
    {
        var output = new haxe.io.BytesOutput();
        var status = null;
        var http = new Http(url);
        http.onStatus = function( code : Int ) status = code;
        http.onError = function( msg : String ) throw new FacebookSDKException('$msg. Url: $url. Response:' + output.getBytes().toString());

        for (k in headers.keys())
            http.addHeader(k, headers.get(k));

        http.setPostData(body);

		http.customRequest(method == 'POST', output, null, method);

        var b = output.getBytes();
        
        return new GraphRawResponse(http.responseHeaders, b.toString(), status);
    }
}