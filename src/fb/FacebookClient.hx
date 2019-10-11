package fb;

import fb.http.RequestBodyUrlEncoded;
import fb.http.RequestBodyMultipart;
import fb.http.RequestBodyInterface;

import fb.httpclient.FacebookHttpClientInterface;
import fb.httpclient.FacebookHttpClient;

#if necurl
import fb.httpclient.FacebookCurlHttpClient;
#end


class FacebookClient
{
    /**
     * Production Graph API URL.
     */
    inline public static var BASE_GRAPH_URL = 'https://graph.facebook.com';

    /**
     * Graph API URL for video uploads.
     */
    inline public static var BASE_GRAPH_VIDEO_URL = 'https://graph-video.facebook.com';

    /**
     * Beta Graph API URL.
     */
    inline public static var BASE_GRAPH_URL_BETA = 'https://graph.beta.facebook.com';

    /**
     * Beta Graph API URL for video uploads.
     */
    inline public static var BASE_GRAPH_VIDEO_URL_BETA = 'https://graph-video.beta.facebook.com';

    /**
     * The timeout in seconds for a normal request.
     */
    inline public static var DEFAULT_REQUEST_TIMEOUT = 60;

    /**
     * The timeout in seconds for a request that contains file uploads.
     */
    inline public static var DEFAULT_FILE_UPLOAD_REQUEST_TIMEOUT = 3600;

    /**
     * The timeout in seconds for a request that contains video uploads.
     */
    inline public static var DEFAULT_VIDEO_UPLOAD_REQUEST_TIMEOUT = 7200;

    /**
     * The number of calls that have been made to Graph.
     */
    public static var requestCount = 0;

    /**
     * Toggle to use Graph beta url.
     */
    public var enableBetaMode = false;

    /**
     * HTTP client handler.
     */
    public var httpClientHandler : FacebookHttpClientInterface;


    public function new( ?httpClientHandler : FacebookHttpClientInterface, ?enableBeta : Bool = false )
    {
        this.httpClientHandler = httpClientHandler != null ? httpClientHandler : detectHttpClientHandler();
        this.enableBetaMode = enableBeta;
    }

    /**
     * Detects which HTTP client handler to use.
     * @return FacebookHttpClientInterface
     */
    public function detectHttpClientHandler( ) : FacebookHttpClientInterface
    {
#if necurl
        return necurl.Necurl.loaded ? new FacebookCurlHttpClient() : new FacebookHttpClient();
#else
        return  new FacebookHttpClient();
#end
    }

    /**
     * Returns the base Graph URL.
     * @param postToVideoUrl Post to the video API if videos are being uploaded.
     * @return String
     */
    public function getBaseGraphUrl( postToVideoUrl : Bool = false ) : String
    {
        if (postToVideoUrl)
            return enableBetaMode ? BASE_GRAPH_VIDEO_URL_BETA : BASE_GRAPH_VIDEO_URL;

        return enableBetaMode ? BASE_GRAPH_URL_BETA : BASE_GRAPH_URL;
    }

    /**
     * Prepares the request for sending to the client handler.
     * @param request 
     */
    public function prepareRequestMessage( request : FacebookRequest )
    {
        var postToVideoUrl = request.containsVideoUploads();
        var url = getBaseGraphUrl(postToVideoUrl) + request.getUrl();

        var requestBody : RequestBodyInterface = null;
        // If we're sending files they should be sent as multipart/form-data
        if (request.containsFileUploads())
        {
            var rb : RequestBodyMultipart = request.getMultipartBody();
            requestBody = rb;
            request.setHeaders([
                'Content-Type' => 'multipart/form-data; boundary=' + rb.boundary,
            ]);
        }
        else
        {
            var rb : RequestBodyUrlEncoded = request.getUrlEncodedBody();
            requestBody = rb;
            request.setHeaders([
                'Content-Type' => 'application/x-www-form-urlencoded',
            ]);
        }

        return {
            url: url,
            method: request.method,
            headers: request.getHeaders(),
            body: requestBody.getBody(),
        };
    }

    /**
     * Makes the request to Graph and returns the result.
     * @param request 
     * @return FacebookResponse
     */
    public function sendRequest( request : FacebookRequest ) : FacebookResponse
    {
        if (Type.getClass(request) == FacebookRequest)
            request.validateAccessToken();

        var rm = prepareRequestMessage(request);

        // Since file uploads can take a while, we need to give more time for uploads
        var timeOut = if (request.containsFileUploads()) DEFAULT_FILE_UPLOAD_REQUEST_TIMEOUT;
        else if (request.containsVideoUploads()) DEFAULT_VIDEO_UPLOAD_REQUEST_TIMEOUT;
        else DEFAULT_REQUEST_TIMEOUT;

        // Should throw `FacebookSDKException` exception on HTTP client error.
        // Don't catch to allow it to bubble up.
        var rawResponse = httpClientHandler.send(rm.url, rm.method, rm.body, rm.headers, timeOut);

        requestCount++;

        var returnResponse = new FacebookResponse(
            request,
            rawResponse.body,
            rawResponse.httpResponseCode,
            rawResponse.headers
        );
        
        if (returnResponse.isError())
            throw returnResponse.getThrownException();

        return returnResponse;
    }

    /**
     * Makes a batched request to Graph and returns the result.
     * @param request 
     * @return FacebookBatchResponse
     */
    public function sendBatchRequest( request : FacebookBatchRequest ) : FacebookBatchResponse
    {
        request.prepareRequestsForBatch();
        var facebookResponse : FacebookResponse = sendRequest(request);
        
        return new FacebookBatchResponse(request, facebookResponse);
    }
}