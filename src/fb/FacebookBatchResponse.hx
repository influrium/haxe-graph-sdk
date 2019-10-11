package fb;

import haxe.ds.StringMap;

class FacebookBatchResponse extends FacebookResponse //implements IteratorAggregate, ArrayAccess
{
    /**
     * The original entity that made the batch request.
     */
    var batchRequest : FacebookBatchRequest;

    /**
     * An array of FacebookResponse entities.
     */
    public var responses (default, null) : StringMap<FacebookResponse> = new StringMap();

    public function new( batchRequest : FacebookBatchRequest, response : FacebookResponse )
    {
        this.batchRequest = batchRequest;

        var request = response.request;
        var body = response.body;
        var httpStatusCode = response.httpStatusCode;
        var headers = response.headers;

        super(request, body, httpStatusCode, headers);

        setResponses(response.decodedBody);
    }

    /**
     * The main batch response will be an array of requests so we need to iterate over all the responses.
     * @param responses 
     */
    public function setResponses( responses : Array<Dynamic> ) : Void
    {
        this.responses = new StringMap();
        for (i in 0...responses.length)
        {
            var graphResponse = responses[i];
            addResponse(i, graphResponse);
        }
    }

    /**
     * Add a response to the list.
     *
     * @param int        $key
     * @param array|null $response
     */
    public function addResponse( key : Int, response : Dynamic ) : Void
    {
        var req = batchRequest.requests[key];

        var originalRequestName = req.name != null ? Std.string(req.name) : Std.string(key);
        var originalRequest = req.request != null ? req.request : null;

        var httpResponseBody = response.body != null ? response.body : null;
        var httpResponseCode = response.code != null ? response.code : null;

        // @TODO TODO: With PHP 5.5 support, this becomes array_column($response['headers'], 'value', 'name')
        var httpResponseHeaders = response.headers != null ? normalizeBatchHeaders(response.headers) : new StringMap();
        
        this.responses.set(originalRequestName, new FacebookResponse(
            originalRequest,
            httpResponseBody,
            httpResponseCode,
            httpResponseHeaders
        ));
    }

    /**
     * Converts the batch header array into a standard format.
     * @param array $batchHeaders
     * @return array
     */
    function normalizeBatchHeaders( batchHeaders : Array<{name:String,value:String}> ) : StringMap<String>
    {
        var headers = new StringMap();
        for( header in batchHeaders )
            headers.set(header.name, header.value);
        
        return headers;
    }

/*
    public function getIterator()
    {
        return new ArrayIterator($this->responses);
    }
    public function offsetSet($offset, $value)
    {
        $this->addResponse($offset, $value);
    }
    public function offsetExists($offset)
    {
        return isset($this->responses[$offset]);
    }
    public function offsetUnset($offset)
    {
        unset($this->responses[$offset]);
    }
    public function offsetGet($offset)
    {
        return isset($this->responses[$offset]) ? $this->responses[$offset] : null;
    }
*/
}