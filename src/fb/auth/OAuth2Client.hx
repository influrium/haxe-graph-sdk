package fb.auth;

import fb.util.ObjectTools;
import fb.util.UrlTools;
import fb.util.Params;
import fb.error.FacebookSDKException;
import fb.Facebook;
import fb.FacebookApp;
import fb.FacebookClient;
import fb.FacebookRequest;
import fb.auth.AccessTokenMetadata;


class OAuth2Client
{
    /**
     * The base authorization URL.
     */
    inline public static var BASE_AUTHORIZATION_URL = 'https://www.facebook.com';

    /**
     * The FacebookApp entity.
     */
    var app : FacebookApp;

    /**
     * The Facebook client.
     */
    var client : FacebookClient;

    /**
     * The version of the Graph API to use.
     */
    var graphVersion : GraphVersion;

    /**
     * The last request sent to Graph.
     */
    public var lastRequest(default, null) : Null<FacebookRequest>;


    public function new( app : FacebookApp, client : FacebookClient, ?graphVersion : GraphVersion )
    {
        this.app = app;
        this.client = client;
        this.graphVersion = graphVersion != null ? graphVersion : Facebook.DEFAULT_GRAPH_VERSION;
    }

    /**
     * Get the metadata associated with the access token.
     * @param accessToken       The access token to debug.
     * @param accessTokenString The access token to debug.
     * @return AccessTokenMetadata
     */
    public function debugToken( accessToken : AccessToken ) : AccessTokenMetadata
    {
        var token : String = accessToken;
        if (token == null)
            throw "AccessToken is NULL";

        var params = new Params([
            'input_token' => token,
        ]);

        lastRequest = new FacebookRequest(
            app,
            app.getAccessToken(),
            'GET',
            '/debug_token',
            params,
            null,
            graphVersion
        );

        var response = client.sendRequest(lastRequest);
        var metadata = response.decodedBody;
        return new AccessTokenMetadata(metadata);
    }

    /**
     * Generates an authorization URL to begin the process of authenticating a user.
     * @param redirectUrl The callback URL to redirect to.
     * @param state       The CSPRNG-generated CSRF value.
     * @param scope       An array of permissions to request.
     * @param params      An object of parameters to generate URL.
     * @param separator   The separator to use in http_build_query().
     * @return string
     */
    public function getAuthorizationUrl( redirectUrl : String, state : String, scope : Array<String>, params : Dynamic<String>, separator : String = '&' ) : String
    {
        params.client_id = app.id;
        params.state = state;
        params.response_type = 'code';
        params.sdk = 'haxe-sdk-${Facebook.VERSION}';
        params.redirect_uri = redirectUrl;
        params.scope = scope.join(',');

        return '$BASE_AUTHORIZATION_URL/$graphVersion/dialog/oauth?' + UrlTools.http_build_query(params, separator);
    }

    /**
     * Get a valid access token from a code.
     * @param code
     * @param redirectUri
     * @return AccessToken
     * @throws FacebookSDKException
     */
    public function getAccessTokenFromCode( code : String, redirectUri : String = '' ) : AccessToken
    {
        var params = new Params([
            'code' => code,
            'redirect_uri' => redirectUri,
        ]);

        return requestAnAccessToken(params);
    }

    /**
     * Exchanges a short-lived access token with a long-lived access token.
     * @param accessToken 
     * @param accessTokenString 
     * @return AccessToken
     */
    public function getLongLivedAccessToken( accessToken : AccessToken ) : AccessToken
    {
        var token : String = accessToken;
        if (token == null)
            throw "AccessToken is NULL";

        var params = new Params([
            'grant_type' => 'fb_exchange_token',
            'fb_exchange_token' => token,
        ]);

        return requestAnAccessToken(params);
    }

    /**
     * Get a valid code from an access token.
     * @param accessToken 
     * @param accessTokenString 
     * @param redirectUri 
     * @return String
     */
    public function getCodeFromLongLivedAccessToken( ?accessToken : AccessToken, redirectUri : String = '' ) : String
    {
        var params = new Params([
            'redirect_uri' => redirectUri,
        ]);
        var response = sendRequestWithClientParams('/oauth/client_code', params, accessToken);
        var data = response.decodedBody;

        if (data.code == null)
            throw new FacebookSDKException('Code was not returned from Graph.', 401);

        return data.code;
    }

    /**
     * Send a request to the OAuth endpoint.
     * @param params 
     * @return AccessToken
     */
    function requestAnAccessToken( params : Params ) : AccessToken
    {
        var response = sendRequestWithClientParams('/oauth/access_token', params);
        var data = response.decodedBody;

        if (data.access_token == null)
            throw new FacebookSDKException('Access token was not returned from Graph.', 401);

        // Graph returns two different key names for expiration time on the same endpoint.
        // Doh! :/
        var expiresAt : Float = 0.0;
        if (data.expires != null)
        {
            // For exchanging a short lived token with a long lived token.
            // The expiration time in seconds will be returned as "expires".
            expiresAt = Date.now().getTime() + data.expires;
        }
        else if (data.expires_in != null)
        {
            // For exchanging a code for a short lived access token.
            // The expiration time in seconds will be returned as "expires_in".
            // See: https://developers.facebook.com/docs/facebook-login/access-tokens#long-via-code
            expiresAt = Date.now().getTime() + data.expires_in;
        }

        return new AccessToken(data.access_token, expiresAt);
    }

    /**
     * Send a request to Graph with an app access token.
     * @param endpoint 
     * @param params 
     * @param accessToken 
     * @return FacebookResponse
     */
    function sendRequestWithClientParams( endpoint : String, params : Params, ?accessToken : AccessToken ) : FacebookResponse
    {
        params.append(getClientParams());

        if (accessToken == null)
            accessToken = app.getAccessToken();
        
        lastRequest = new FacebookRequest(
            app,
            accessToken,
            'GET',
            endpoint,
            params,
            null,
            graphVersion
        );

        return client.sendRequest(lastRequest);
    }

    /**
     * Returns the client_* params for OAuth requests.
     */
    function getClientParams( ) : Params
    {
        return new Params([
            'client_id' => app.id,
            'client_secret' => app.secret,
        ]);
    }
}
