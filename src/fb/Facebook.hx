package fb;

import fb.util.Params;
import fb.error.*;
import fb.graph.*;
import fb.auth.*;
import fb.upload.*;
import fb.url.*;
import fb.prs.*;
import fb.persist.*;
import fb.httpclient.*;
import fb.helpers.*;

using fb.util.ObjectTools;

typedef FacebookOptions = {
    @:optional var app_id : String;
    @:optional var app_secret : String;
    @:optional var default_graph_version : GraphVersion;
    @:optional var default_access_token : AccessToken;
    @:optional var enable_beta_mode : Bool;
    @:optional var http_client_handler : Dynamic; // FacebookHttpClientInterface;
    @:optional var persistent_data_handler : Dynamic; // PersistentDataInterface;
    @:optional var pseudo_random_string_generator : Dynamic; // PseudoRandomStringGeneratorInterface;
    @:optional var url_detection_handler : Dynamic; // UrlDetectionInterface;
}


class Facebook
{
    /**
     * Version number of the Facebook PHP SDK.
     */
    inline public static var VERSION = '5.7.0';

    /**
     * Default Graph API version for requests.
     */
    inline public static var DEFAULT_GRAPH_VERSION : GraphVersion = new GraphVersion('v2.10');

    /**
     * The name of the environment variable that contains the app ID.
     */
    inline public static var APP_ID_ENV_NAME = 'FACEBOOK_APP_ID';

    /**
     * The name of the environment variable that contains the app secret.
     */
    inline public static var APP_SECRET_ENV_NAME = 'FACEBOOK_APP_SECRET';

    /**
     * The FacebookApp entity.
     */
    public var app (default, null) : FacebookApp;

    /**
     * The Facebook client service.
     */
    public var client (default, null) : FacebookClient;

    /**
     * The OAuth 2.0 client service.
     */
    public var oAuth2Client(get, null) : OAuth2Client;

    /**
     * The URL detection handler.
     */
    public var urlDetectionHandler (default, null) : Null<UrlDetectionInterface>;

    /**
     * The cryptographically secure pseudo-random string generator.
     */
    var pseudoRandomStringGenerator : Null<PseudoRandomStringGeneratorInterface>;

    /**
     * The default access token to use with requests.
     */
    public var defaultAccessToken (default, null) : Null<AccessToken>;

    /**
     * The default Graph version we want to use.
     */
    public var defaultGraphVersion (default, null) : GraphVersion;

    /**
     * The persistent data handler.
     */
    var persistentDataHandler : Null<PersistentDataInterface>;

    /**
     * Stores the last request made to Graph.
     */
    public var lastResponse (default, null) : FacebookResponse;
    // public var lastResponse (default, null) : FacebookBatchResponse;

    
    public function new( config : FacebookOptions )
    {
        config = {
            app_id: Sys.getEnv(APP_ID_ENV_NAME),
            app_secret: Sys.getEnv(APP_SECRET_ENV_NAME),
            default_graph_version: DEFAULT_GRAPH_VERSION,
            enable_beta_mode: false,
            http_client_handler: null,
            persistent_data_handler: null,
            pseudo_random_string_generator: null,
            url_detection_handler: null,
        }.merge(config);

        if (config.app_id == null)
            throw new FacebookSDKException('Required "app_id" key not supplied in config and could not find fallback environment variable "$APP_ID_ENV_NAME"');
        
        if (config.app_secret == null)
            throw new FacebookSDKException('Required "app_secret" key not supplied in config and could not find fallback environment variable "$APP_SECRET_ENV_NAME"');

        this.app = new FacebookApp(config.app_id, config.app_secret);

        this.client = new FacebookClient(HttpClientsFactory.createHttpClient(config.http_client_handler), config.enable_beta_mode);

        this.pseudoRandomStringGenerator = PseudoRandomStringGeneratorFactory.createPseudoRandomStringGenerator(config.pseudo_random_string_generator);

        this.urlDetectionHandler = config.url_detection_handler != null ? config.url_detection_handler : new FacebookUrlDetectionHandler();

        this.persistentDataHandler = PersistentDataFactory.createPersistentDataHandler(config.persistent_data_handler);

        if (config.default_access_token != null)
            setDefaultAccessToken(config.default_access_token);

        // @todo v6: Throw an InvalidArgumentException if "default_graph_version" is not set
        this.defaultGraphVersion = config.default_graph_version;
    }

    // Returns the OAuth 2.0 client service.
    public function get_oAuth2Client( ) : OAuth2Client
    {
        if (oAuth2Client == null)
            oAuth2Client = new OAuth2Client(this.app, this.client, this.defaultGraphVersion);
        
        return oAuth2Client;
    }

    // Sets the default access token to use with requests.
    public function setDefaultAccessToken( ?accessToken : AccessToken, ?accessTokenString : String ) : Void
    {
        if (accessToken != null)
        {
            this.defaultAccessToken = accessToken;
            return;
        }

        if (accessTokenString != null)
        {
            this.defaultAccessToken = new AccessToken(accessTokenString);
            return;
        }

        throw new InvalidArgumentException('The default access token must be of type "string" or fb.auth.AccessToken');
    }

    // Returns the redirect login helper.
    public function getRedirectLoginHelper( ) return new FacebookRedirectLoginHelper(oAuth2Client, persistentDataHandler, urlDetectionHandler, pseudoRandomStringGenerator);

    // Returns the JavaScript helper.
    public function getJavaScriptHelper( ) return new FacebookJavaScriptHelper(app, client, defaultGraphVersion);

    // Returns the canvas helper.
    public function getCanvasHelper( ) return new FacebookCanvasHelper(app, client, defaultGraphVersion);

    // Returns the page tab helper.
    public function getPageTabHelper( ) return new FacebookPageTabHelper(app, client, defaultGraphVersion);

    // Sends a GET request to Graph and returns the result.
    public function get( endpoint : String, ?accessToken : AccessToken, ?eTag : String, ?graphVersion : GraphVersion ) : FacebookResponse
    {
        return sendRequest(
            'GET',
            endpoint,
            {},
            accessToken,
            eTag,
            graphVersion
        );
    }

    // Sends a POST request to Graph and returns the result.
    public function post( endpoint : String, ?params : Dynamic, ?accessToken : AccessToken, ?eTag : String, ?graphVersion : GraphVersion ) : FacebookResponse
    {
        return sendRequest(
            'POST',
            endpoint,
            params,
            accessToken,
            eTag,
            graphVersion
        );
    }

    // Sends a DELETE request to Graph and returns the result.
    public function delete( endpoint : String, ?params : Dynamic, ?accessToken : AccessToken, ?eTag : String, ?graphVersion : GraphVersion ) : FacebookResponse
    {
        return sendRequest(
            'DELETE',
            endpoint,
            params,
            accessToken,
            eTag,
            graphVersion
        );
    }

    /**
     * Sends a request to Graph for the next page of results.
     * @param graphEdge The GraphEdge to paginate over.
     * @return Null<GraphEdge>
     */
    inline public function next( graphEdge : GraphEdge ) : GraphEdge return getPaginationResults(graphEdge, Next);

    /**
     * Sends a request to Graph for the previous page of results.
     * @param graphEdge The GraphEdge to paginate over.
     * @return Null<GraphEdge>
     */
    inline public function previous( graphEdge : GraphEdge ) : GraphEdge return getPaginationResults(graphEdge, Previous);

    /**
     * Sends a request to Graph for the next page of results.
     * @param graphEdge The GraphEdge to paginate over.
     * @param direction The direction of the pagination: next|previous.
     * @return Null<GraphEdge>
     */
    public function getPaginationResults( graphEdge : GraphEdge, direction : Pagination ) : Null<GraphEdge>
    {
        var paginationRequest : FacebookRequest = graphEdge.getPaginationRequest(direction);
        if (paginationRequest == null)
            return null;
        
        lastResponse = client.sendRequest(paginationRequest);

        // Keep the same GraphNode subclass
        var subClassName = graphEdge.subclassName;
        graphEdge = lastResponse.getGraphEdge(subClassName, false);
        return graphEdge.length > 0 ? graphEdge : null;
    }

    /**
     * Sends a request to Graph and returns the result.
     * @param method 
     * @param endpoint 
     * @param params 
     * @param accessToken 
     * @param eTag 
     * @param graphVersion 
     * @return FacebookResponse
     */
    public function sendRequest( method : String, endpoint : String, params : Dynamic, ?accessToken : AccessToken, ?eTag : String, ?graphVersion : GraphVersion ) : FacebookResponse
    {
        accessToken = accessToken != null ? accessToken : defaultAccessToken;
        graphVersion = graphVersion != null ? graphVersion : defaultGraphVersion;
        
        var request = request(method, endpoint, params, accessToken, eTag, graphVersion);

        lastResponse = client.sendRequest(request);

        return lastResponse;
    }

    /**
     * Sends a batched request to Graph and returns the result.
     * @param requests 
     * @param accessToken 
     * @param graphVersion 
     * @return FacebookBatchResponse
     */
    public function sendBatchRequest( requests : Array<FacebookRequest>, ?accessToken : AccessToken, ?graphVersion : GraphVersion ) : FacebookBatchResponse
    {
        accessToken = accessToken != null ? accessToken : defaultAccessToken;
        graphVersion = graphVersion != null ? graphVersion : defaultGraphVersion;

        var batchRequest = new FacebookBatchRequest(
            app,
            requests,
            accessToken,
            graphVersion
        );
        
        var batchResponse = client.sendBatchRequest(batchRequest);
        lastResponse = batchResponse;

        return batchResponse;
    }

    /**
     * Instantiates an empty FacebookBatchRequest entity.
     * @param accessToken  The top-level access token. Requests with no access token will fallback to this.
     * @param graphVersion The Graph API version to use.
     * @return FacebookBatchRequest
     */
    public function newBatchRequest( ?accessToken : AccessToken,  ?graphVersion : GraphVersion ) : FacebookBatchRequest
    {
        accessToken = accessToken != null ? accessToken : defaultAccessToken;
        graphVersion = graphVersion != null ? graphVersion : defaultGraphVersion;

        return new FacebookBatchRequest(
            app,
            [],
            accessToken,
            graphVersion
        );
    }

    /**
     * Instantiates a new FacebookRequest entity.
     * @param method 
     * @param endpoint 
     * @param params 
     * @param accessToken 
     * @param eTag 
     * @param graphVersion 
     * @return FacebookRequest
     */
    public function request( method : String, endpoint : String, ?params : Dynamic, ?accessToken : AccessToken, ?eTag : String, ?graphVersion : GraphVersion ) : FacebookRequest
    {
        accessToken = accessToken != null ? accessToken : defaultAccessToken;
        graphVersion = graphVersion != null ? graphVersion : defaultGraphVersion;

        return new FacebookRequest(
            app,
            accessToken,
            method,
            endpoint,
            params,
            eTag,
            graphVersion
        );
    }

    /**
     * Factory to create FacebookFile's.
     * @param pathToFile 
     * @return FacebookFile
     */
    public function fileToUpload( pathToFile : String ) return new FacebookFile(pathToFile);

    /**
     * Factory to create FacebookVideo's.
     * @param pathToFile 
     * @return FacebookVideo
     */
    public function videoToUpload( pathToFile : String ) return new FacebookVideo(pathToFile);

    /**
     * Upload a video in chunks.
     * @param target           The id of the target node before the /videos edge.
     * @param pathToFile       The full path to the file.
     * @param metadata         The metadata associated with the video file.
     * @param accessToken      Token The access token.
     * @param maxTransferTries The max times to retry a failed upload chunk.
     * @param graphVersion     The Graph API version to use.
     * @return Dynamic
     */
    public function uploadVideo( target : String, pathToFile : String, ?metadata : Params, ?accessToken : String,  ?maxTransferTries : Int = 5, ?graphVersion : GraphVersion ) : Dynamic
    {
        accessToken = accessToken != null ? accessToken : defaultAccessToken;
        graphVersion = graphVersion != null ? graphVersion : defaultGraphVersion;
        metadata = metadata != null ? metadata : new Params();

        var uploader = new FacebookResumableUploader(app, client, accessToken, graphVersion);

        var endpoint = '/$target/videos';
        var file = videoToUpload(pathToFile);
        var chunk = uploader.start(endpoint, file);

        do
        {
            chunk = maxTriesTransfer(uploader, endpoint, chunk, maxTransferTries);
        }
        while (!chunk.isLastChunk());

        return {
          video_id: chunk.videoId,
          success: uploader.finish(endpoint, Std.string(chunk.uploadSessionId), metadata),
        };
    }

    /**
     * Attempts to upload a chunk of a file in $retryCountdown tries.
     * @param uploader 
     * @param endpoint 
     * @param chunk 
     * @param retryCountdown 
     * @return FacebookTransferChunk
     */
    function maxTriesTransfer( uploader : FacebookResumableUploader, endpoint : String, chunk : FacebookTransferChunk, retryCountdown : Int ) : FacebookTransferChunk
    {
        var newChunk = uploader.transfer(endpoint, chunk, retryCountdown < 1);

        if (newChunk != chunk)
            return newChunk;

        retryCountdown--;

        // If transfer() returned the same chunk entity, the transfer failed but is resumable.
        return maxTriesTransfer(uploader, endpoint, chunk, retryCountdown);
    }
}