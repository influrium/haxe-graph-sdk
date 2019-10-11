package fb.httpclient;

import fb.http.GraphRawResponse;
import fb.error.FacebookSDKException;

import necurl.Necurl;

import haxe.ds.IntMap;
import haxe.ds.StringMap;

using StringTools;


class FacebookCurlHttpClient implements FacebookHttpClientInterface
{
    /**
     * The client error message
     */
    var curlErrorMessage : String = '';

    /**
     * The curl client error code
     */
    var curlErrorCode : Int = 0;

    /**
     * The raw response from the server
     * string|boolean
     */
    var rawResponse : String;

    /**
     * Procedural curl as object
     * FacebookCurl
     */
    var facebookCurl : Necurl;

    /**
     * Procedural curl as object
     * @param facebookCurl 
     */
    public function new( ?facebookCurl : Necurl )
    {
        this.facebookCurl = facebookCurl != null ? facebookCurl : new Necurl();
    }

    /**
     * @inheritdoc
     */
    public function send( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int ) : GraphRawResponse
    {
        openConnection(url, method, body, headers, timeOut);
        sendRequest();

        var curlErrorCode = facebookCurl.errno();
        if (curlErrorCode > 0)
            throw new FacebookSDKException(facebookCurl.error(), curlErrorCode);

        // Separate the raw headers from the raw body
        var resp = extractResponseHeadersAndBody();

        closeConnection();

        return new GraphRawResponse(resp.headers, resp.body);
    }

    /**
     * Opens a new curl connection.
     *
     * @param string $url     The endpoint to send the request to.
     * @param string $method  The request method.
     * @param string $body    The body of the request.
     * @param array  $headers The request headers.
     * @param int    $timeOut The timeout in seconds for the request.
     */
    public function openConnection( url : String, method : String, body : String, headers : StringMap<String>, timeOut : Int )
    {
        var options : IntMap<Dynamic> = [
            CurlOpt.CUSTOMREQUEST => method,
            CurlOpt.URL => url,
            CurlOpt.CONNECTTIMEOUT => 10,
            CurlOpt.TIMEOUT => timeOut,
            CurlOpt.HEADER => true, // Enable header processing
            CurlOpt.SSL_VERIFYHOST => 2,
            CurlOpt.SSL_VERIFYPEER => true,
            // CurlOpt.CAINFO => __DIR__ . '/certs/DigiCertHighAssuranceEVRootCA.pem',
        ];

        if (method != "GET")
            options.set(CurlOpt.POSTFIELDS, body);

        // facebookCurl.init();
        // this.facebookCurl.setoptArray($options);
        for (key in options.keys())
            facebookCurl.setopt(key, options.get(key));

        for (h in compileRequestHeaders(headers))
            facebookCurl.setheader(h);
    }

    /**
     * Closes an existing curl connection
     */
    public function closeConnection( ) : Void facebookCurl.close();

    /**
     * Send the request and get the raw response from curl
     */
    public function sendRequest( ) : Void rawResponse = facebookCurl.exec();

    /**
     * Compiles the request headers into a curl-friendly format.
     * @param array $headers The request headers.
     * @return array
     */
    public function compileRequestHeaders( headers : StringMap<String> ) : Array<String>
    {
        var out = [];
        for (key in headers.keys())
        {
            var value = headers.get(key);
            out.push('$key: $value');
        }
        return out;
    }

    /**
     * Extracts the headers and the body into a two-part array
     */
    public function extractResponseHeadersAndBody( )
    {
        var parts = rawResponse.split("\r\n\r\n");
        var rawBody = parts.pop();
        var rawHeaders = parts.join("\r\n\r\n");

        return {
            headers: rawHeaders.trim(),
            body: rawBody.trim(),
        };
    }
}