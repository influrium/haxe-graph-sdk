package fb.http;

import haxe.ds.StringMap;

using StringTools;


class GraphRawResponse
{
    /**
     * The response headers in the form of an associative array.
     */
    public var headers (default, null) : StringMap<String>;

    /**
     * The raw response body.
     */
    public var body (default, null) : String;

    /**
     * The HTTP status response code.
     */
    public var httpResponseCode (default, null) : Int;

    /**
     * Creates a new GraphRawResponse entity.
     * @param headers        The headers as a raw string or array.
     * @param body           The raw response body.
     * @param httpStatusCode The HTTP response code (if sending headers as parsed array).
     */
    public function new( ?headers : StringMap<String>, body : String, ?httpStatusCode : Int = null, ?headersString : String )
    {
        this.headers = headers != null ? headers : new StringMap();
        this.httpResponseCode = httpStatusCode;
        this.body = body;
        
        if( headersString != null )
            setHeadersFromString(headersString);
    }

    /**
     * Sets the HTTP response code from a raw header.
     * @param rawResponseHeader 
     */
    public function setHttpResponseCodeFromHeader( rawResponseHeader : String ) : Void
    {
        // https://tools.ietf.org/html/rfc7230#section-3.1.2
        httpResponseCode = Std.parseInt(rawResponseHeader.split(' ')[1]);
    }

    /**
     * Parse the raw headers and set as an array.
     * @param rawHeaders The raw headers from the response.
     */
    function setHeadersFromString( rawHeaders : String ) : Void
    {
        // Normalize line breaks
        rawHeaders = rawHeaders.replace("\r\n", "\n");

        // There will be multiple headers if a 301 was followed or a proxy was followed, etc
        var headerCollection = rawHeaders.trim().split("\n\n");

        // We just want the last response (at the end)
        var rawHeader = headerCollection.pop();

        var headerComponents = rawHeader.split("\n");
        for (line in headerComponents)
        {
            if (line.indexOf(':') < 0)
                setHttpResponseCodeFromHeader(line);
            else
            {
                var kv = line.split(': ');
                var k = kv.shift();
                var v = kv.join(': ');
                headers.set(k, v);
            }
        }
    }
}