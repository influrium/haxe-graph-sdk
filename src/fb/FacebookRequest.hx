package fb;

import haxe.CallStack;
import fb.http.RequestBodyUrlEncoded;
import haxe.ds.StringMap;

import fb.auth.AccessToken;
import fb.error.FacebookSDKException;
import fb.http.RequestBodyMultipart;
import fb.upload.FacebookFile;
import fb.upload.FacebookVideo;
import fb.url.FacebookUrlManipulator;

// using fb.util.ObjectTools;
using fb.util.Params;


class FacebookRequest
{
    /**
     * FacebookApp The Facebook app entity.
     */
    public var app : FacebookApp;

    /**
     * The access token to use for this request.
     */
    public var accessToken : AccessToken;

    /**
     * The HTTP method for this request.
     */
    public var method (default, null) : String;

    /**
     * The Graph endpoint for this request.
     */
    public var endpoint (default, null) : String;

    /**
     * The headers to send with this request.
     */
    var headers : StringMap<String> = new StringMap();

    /**
     * The parameters to send with this request.
     */
    var params : Params = new Params();

    /**
     * The files to send with this request.
     */
    public var files (default, null) : StringMap<FacebookFile> = new StringMap();

    /**
     * ETag to send with this request.
     */
    public var eTag (default, null) : String;

    /**
     * Graph version to use for this request.
     */
    public var graphVersion (default, null) : GraphVersion;

    public function new( ?app : FacebookApp, ?accessToken : AccessToken, ?method : String, ?endpoint : String, ?params : Params, ?eTag : String, ?graphVersion : GraphVersion ) : Void
    {
        this.app = app;
        this.accessToken = accessToken;
        setMethod(method);
        setEndpoint(endpoint);
        setParams(params);
        this.eTag = eTag;

        this.graphVersion = (graphVersion != null ? graphVersion : fb.Facebook.DEFAULT_GRAPH_VERSION);
    }

    /**
     * Sets the access token with one harvested from a URL or POST params.
     * @param accessToken 
     */
    public function setAccessTokenFromParams( accessToken : AccessToken ) : Void
    {
        if (this.accessToken == null)
            this.accessToken = accessToken;
        
        else if (this.accessToken.toString() != accessToken.toString())
        {
            throw new FacebookSDKException('Access token mismatch. The access token provided in the FacebookRequest and the one provided in the URL or POST params do not match.');
        }
            
    }

    /**
     * Return the access token for this request as an AccessToken entity.
     * @return AccessToken
     */
    public function getAccessTokenEntity( ) : AccessToken
    {
        return accessToken != null ? new AccessToken(accessToken) : null;
    }

    /**
     * Generate an app secret proof to sign this request.
     * @return Null<String>
     */
    public function getAppSecretProof( ) : Null<String>
    {
        var accessTokenEntity = getAccessTokenEntity();
        if ( accessTokenEntity == null )
            return null;

        return accessTokenEntity.getAppSecretProof(app.secret);
    }

    /**
     * Validate that an access token exists for this request.
     */
    public function validateAccessToken( ) : Void
    {
        if (this.accessToken == null)
            throw new FacebookSDKException('You must provide an access token.');
    }

    /**
     * Set the HTTP method for this request.
     * @param method 
     */
    public function setMethod( method : String ) : Void
    {
        if (method == null)
            return;
        
        this.method = method.toUpperCase();
    }

    /**
     * Validate that the HTTP method is set.
     */
    public function validateMethod( ) : Void
    {
        if (method == null)
            throw new FacebookSDKException('HTTP method not specified.');

        
        if (['GET', 'POST', 'DELETE'].indexOf(method) < 0)
            throw new FacebookSDKException('Invalid HTTP method specified.');
    }

    /**
     * Set the endpoint for this request.
     * @param endpoint 
     * @return FacebookRequest
     */
    public function setEndpoint( endpoint : String ) : FacebookRequest
    {
        // Harvest the access token from the endpoint to keep things in sync
        var params = FacebookUrlManipulator.getParamsAsObject(endpoint);
        if (params['access_token'] != null)
            setAccessTokenFromParams(params['access_token']);
        
        // Clean the token & app secret proof from the endpoint.
        var filterParams = ['access_token', 'appsecret_proof'];
        this.endpoint = FacebookUrlManipulator.removeParamsFromUrl(endpoint, filterParams);

        return this;
    }

    /**
     * Generate and return the headers for this request.
     * @return Dynamic<String>
     */
    public function getHeaders( ) : StringMap<String>
    {
        var headers = getDefaultHeaders();

        if (eTag != null)
            headers.set('If-None-Match', eTag);
        
        for (key in this.headers.keys())
            headers.set(key, this.headers.get(key));
        
        return headers;
    }

    /**
     * Set the headers for this request.
     * @param headers 
     */
    public function setHeaders( headers : StringMap<String> ) : Void
    {
        for (key in headers.keys())
            this.headers.set(key, headers.get(key));
    }

    /**
     * Set the params for this request.
     * @param params 
     * @return FacebookRequest
     */
    public function setParams( params : Params ) : FacebookRequest
    {
        if (params == null)
            params = new Params();

        if (params.has('access_token') && params['access_token'] != null)
        {
            var v : Dynamic = params['access_token'];
            var at : AccessToken = Std.is(v, String) ? new AccessToken(v) : v;
            setAccessTokenFromParams(at);
        }
            

        // Don't let these buggers slip in.
        params.del('access_token');
        params.del('appsecret_proof');

        // TODO: Refactor code above with this
        //params = sanitizeAuthenticationParams(params);
        params = sanitizeFileParams(params);
        dangerouslySetParams(params);
        return this;
    }

    /**
     * Set the params for this request without filtering them first.
     * @param params 
     * @return FacebookRequest
     */
    public function dangerouslySetParams( params : Params ) : FacebookRequest
    {
        this.params.append(params);
        return this;
    }

    /**
     * Iterate over the params and pull out the file uploads.
     * @param params 
     * @return Dynamic<String>
     */
    public function sanitizeFileParams( params : Params ) : Params
    {
        for (k in params.keys())
        {
            var v = params[k];
            if (Std.is(v, FacebookFile))
            {
                addFile(k, cast(v, FacebookFile));
                params.del(k);
            }
        }
        return params;
    }

    /**
     * Add a file to be uploaded.
     * @param key 
     * @param file 
     */
    public function addFile( key : String, file : FacebookFile ) : Void files.set(key, file);

    /**
     * Removes all the files from the upload queue.
     */
    public function resetFiles( ) : Void files = new StringMap();

    /**
     * Let's us know if there is a file upload with this request.
     * @return Bool return files.keys().hasNext()
     */
    public function containsFileUploads( ) : Bool return files != null && files.keys().hasNext();

    /**
     * Let's us know if there is a video upload with this request.
     * @return Bool
     */
    public function containsVideoUploads( ) : Bool
    {
        for (file in files)
            if (Std.is(file, FacebookVideo))
                return true;
        return false;
    }

    /**
     * Returns the body of the request as multipart/form-data.
     * @return RequestBodyMultipart
     */
    public function getMultipartBody( ) : RequestBodyMultipart return new RequestBodyMultipart(getPostParams(), files);

    /**
     * Returns the body of the request as URL-encoded.
     * @return RequestBodyUrlEncoded
     */
    public function getUrlEncodedBody( ) : RequestBodyUrlEncoded return new RequestBodyUrlEncoded(getPostParams());
    
    /**
     * Generate and return the params for this request.
     * @return Dynamic<String>
     */
    public function getParams( ) : Params
    {
        var params = this.params.clone();
        var accessToken = this.accessToken;
        if (accessToken != null)
        {
            params['access_token'] = accessToken;
            params['appsecret_proof'] = getAppSecretProof();
        }

        return params;
    }

    /**
     * Only return params on POST requests.
     * @return Dynamic<String>
     */
    public function getPostParams( ) : Params return this.method == 'POST' ? getParams() : new Params();

    /**
     * Generate and return the URL for this request.
     * @return String
     */
    public function getUrl( ) : String
    {
        validateMethod();

        var graphVersion : String = FacebookUrlManipulator.forceSlashPrefix(this.graphVersion.toString());
        var endpoint : String = FacebookUrlManipulator.forceSlashPrefix(this.endpoint);
        
        var url = graphVersion + endpoint;

        return this.method != 'POST' ? FacebookUrlManipulator.appendParamsToUrl(url, getParams()) : url;
    }

    /**
     * Return the default headers that every request should use.
     * @return Dynamic<String>
     */
    public static function getDefaultHeaders( ) : StringMap<String>
    {
        return [
            'User-Agent' => 'fb-haxe-${Facebook.VERSION}',
            'Accept-Encoding' => '*',
        ];
    }
}