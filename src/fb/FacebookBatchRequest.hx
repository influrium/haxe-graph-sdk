package fb;

import haxe.CallStack;
import fb.util.Params;
import fb.util.MiscTools;
import haxe.Json;
import fb.error.FacebookSDKException;
import fb.auth.AccessToken;
import fb.upload.FacebookFile;
import fb.util.ObjectTools;

typedef BatchRequest = {
    var name : String;
    var request : FacebookRequest;
    var options : Dynamic;
    var attached_files : Null<String>;
};

typedef BatchData = {
    var name : String;
    var headers : Array<String>;
    var method : String;
    var relative_url : String;
    @:optional var body : String;
    @:optional var attached_files : String;
}

class FacebookBatchRequest extends FacebookRequest // implements IteratorAggregate, ArrayAccess
{
    /**
     * An array of FacebookRequest entities to send.
     */
    public var requests (default, null) : Array<BatchRequest> = [];

    /**
     * An array of files to upload.
     */
    var attachedFiles : Array<FacebookFile>;


    public function new( ?app : FacebookApp, ?requests : Array<FacebookRequest>, ?accessToken : AccessToken, ?graphVersion : GraphVersion )
    {
        super(app, accessToken, 'POST', '', new Params(), null, graphVersion);

        add(requests);
    }

    /**
     * Adds a new requests to the array.
     * @param requests 
     * @return FacebookBatchRequest
     */
    public function add( requests : Array<FacebookRequest> ) : FacebookBatchRequest
    {
        if (requests != null) for( i in 0...requests.length )
            addRequest(requests[i], {name: Std.string(i)});

        return this;
    }

    /**
     * Adds a new request to the array.
     * @param request FacebookRequest
     * @param options Object of batch request options e.g. 'name', 'omit_response_on_success'. If a string is given, it is the value of the 'name' option.
     * @return FacebookBatchRequest
     */
    public function addRequest( request : FacebookRequest, ?options : Dynamic ) : FacebookBatchRequest
    {
        if (options == null)
            options = {};
        
        else if (Std.is(options, String))
            options = {name: cast(options, String)};

        addFallbackDefaults(request);

        // File uploads
        var attachedFiles = extractFileAttachments(request);

        var name = options.name != null ? options.name : null;
        Reflect.deleteField(options, 'name'); // options.name = null;
        
        var requestToAdd = {
            name: name,
            request: request,
            options: options,
            attached_files: attachedFiles,
        };

        requests.push(requestToAdd);

        return this;
    }

    /**
     * Ensures that the FacebookApp and access token fall back when missing.
     * @param request 
     */
    public function addFallbackDefaults( request : FacebookRequest ) : Void
    {
        if (request.app == null )
        {
            if (this.app == null)
                throw new FacebookSDKException('Missing FacebookApp on FacebookRequest and no fallback detected on FacebookBatchRequest.');
            
            request.app = app;
        }

        if (request.accessToken == null)
        {
            if (this.accessToken == null)
                throw new FacebookSDKException('Missing access token on FacebookRequest and no fallback detected on FacebookBatchRequest.');
            
            request.accessToken = accessToken;
        }
    }

    /**
     * Extracts the files from a request.
     * @param request 
     * @return Null<String>
     */
    public function extractFileAttachments( request : FacebookRequest ) : Null<String>
    {
        if (!request.containsFileUploads())
            return null;

        var fileNames = [];
        for (file in request.files)
        {
            var fileName = MiscTools.uniqid();
            addFile(fileName, file);
            fileNames.push(fileName);
        }

        request.resetFiles();

        // @TODO: Does Graph support multiple uploads on one endpoint?
        return fileNames.join(',');
    }

    /**
     * Prepares the requests to be sent as a batch request.
     */
    public function prepareRequestsForBatch( ) : Void
    {
        validateBatchRequestCount();
        var params = new Params([
            'batch' => convertRequestsToJson(),
            'include_headers' => true,
        ]);
        setParams(params);
    }

    /**
     * Converts the requests into a JSON(P) string.
     * @return String
     */
    public function convertRequestsToJson( ) : String
    {
        var requests = [];
        for( request in this.requests )
        {
            var options : Dynamic = {};

            if (request.name != null)
                options.name = request.name;

            options = ObjectTools.append(options, request.options);

            requests.push(requestEntityToBatchArray(request.request, options, request.attached_files));
        }

        return Json.stringify(requests);
    }

    /**
     * Validate the request count before sending them as a batch.
     */
    public function validateBatchRequestCount( ) : Void
    {
        var batchCount = this.requests.length;
        if (batchCount == 0)
            throw new FacebookSDKException('There are no batch requests to send.');
        
        else if (batchCount > 50)
            // Per: https://developers.facebook.com/docs/graph-api/making-multiple-requests#limits
            throw new FacebookSDKException('You cannot send more than 50 batch requests at a time.');
    }

    /**
     * Converts a Request entity into an array that is batch-friendly.
     *
     * @param FacebookRequest   $request       The request entity to convert.
     * @param string|null|array $options       Array of batch request options e.g. 'name', 'omit_response_on_success'.
     *                                         If a string is given, it is the value of the 'name' option.
     * @param string|null       $attachedFiles Names of files associated with the request.
     *
     * @return array
     */
    /**
     * Converts a Request entity into an array that is batch-friendly.
     * @param request       The request entity to convert.
     * @param options       Array of batch request options e.g. 'name', 'omit_response_on_success'.
     * @param attachedFiles Names of files associated with the request.
     * @return Array
     */
    public function requestEntityToBatchArray( request : FacebookRequest, ?options : Dynamic, ?attachedFiles : String ) : BatchData
    {
        if (options == null)
            options = {};
        else if (Std.is(options, String))
            options = {name: cast(options, String)};

        var compiledHeaders = [];
        var headers = request.getHeaders();
        for (name in headers.keys())
        {
            var value = headers.get(name);
            compiledHeaders.push('$name: $value');
        }

        var batch : BatchData = {
            name: options.name,
            headers: compiledHeaders,
            method: request.method,
            relative_url: request.getUrl(),
        };

        if (batch.name == null)
            Reflect.deleteField(batch, 'name');

        // Since file uploads are moved to the root request of a batch request,
        // the child requests will always be URL-encoded.
        var body = request.getUrlEncodedBody().getBody();
        if (body != null && body.length > 0)
            batch.body = body;
        
        batch = ObjectTools.append(batch, options);

        if (attachedFiles != null)
            batch.attached_files = attachedFiles;
        
        return batch;
    }

/*
    /**
     * Get an iterator for the items.
     * @return ArrayIterator
     * /
    public function getIterator( )
    {
        return new ArrayIterator($this->requests);
    }
    public function offsetSet( offset, value)
    {
        add(value, offset);
    }
    public function offsetExists($offset)
    {
        return isset($this->requests[$offset]);
    }
    public function offsetUnset($offset)
    {
        unset($this->requests[$offset]);
    }
    public function offsetGet($offset)
    {
        return isset($this->requests[$offset]) ? $this->requests[$offset] : null;
    }
*/
}