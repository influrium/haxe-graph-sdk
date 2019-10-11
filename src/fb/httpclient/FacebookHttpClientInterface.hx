package fb.httpclient;

import haxe.ds.StringMap;

import fb.http.GraphRawResponse;


interface FacebookHttpClientInterface
{
    /**
     * Sends a request to the server and returns the raw response.
     * @param url     The endpoint to send the request to.
     * @param method  The request method.
     * @param body    The body of the request.
     * @param headers The request headers.
     * @param timeOut The timeout in seconds for the request.
     * @return GraphRawResponse
     */
    public function send( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int ) : GraphRawResponse;
}