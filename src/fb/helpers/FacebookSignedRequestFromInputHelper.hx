package fb.helpers;

import fb.auth.*;


class FacebookSignedRequestFromInputHelper
{
    /**
     * The SignedRequest entity.
     */
    public var signedRequest (default, null) : SignedRequest;

    /**
     * The FacebookApp entity.
     */
    var app : FacebookApp;

    /**
     * The OAuth 2.0 client service.
     */
    var oAuth2Client : OAuth2Client;

    /**
     * Initialize the helper and process available signed request data.
     *
     * @param FacebookApp    $app          The FacebookApp entity.
     * @param FacebookClient $client       The client to make HTTP requests.
     * @param string|null    $graphVersion The version of Graph to use.
     */
    public function new( app : FacebookApp, client : FacebookClient, ?graphVersion : GraphVersion )
    {
        this.app = app;
        var gv : GraphVersion = graphVersion != null ? graphVersion : Facebook.DEFAULT_GRAPH_VERSION;
        this.oAuth2Client = new OAuth2Client(this.app, client, gv);

        instantiateSignedRequest();
    }

    /**
     * Instantiates a new SignedRequest entity.
     */
    public function instantiateSignedRequest( ?rawSignedRequest : String ) : Void
    {
        rawSignedRequest = rawSignedRequest != null ? rawSignedRequest : getRawSignedRequest();

        if (rawSignedRequest == null)
            return;

        this.signedRequest = new SignedRequest(this.app, rawSignedRequest);
    }

    /**
     * Returns an AccessToken entity from the signed request.
     */
    public function getAccessToken( ) : Null<AccessToken>
    {
        if (this.signedRequest != null && this.signedRequest.hasOAuthData())
        {
            var code = this.signedRequest.get('code');
            var accessToken = this.signedRequest.get('oauth_token');

            if (code != null && accessToken == null)
                return this.oAuth2Client.getAccessTokenFromCode(code);

            var expiresAt = this.signedRequest.get('expires', 0);

            return new AccessToken(accessToken, expiresAt);
        }

        return null;
    }

    /**
     * Returns the user_id if available.
     */
    public function getUserId( ) : Null<String>
    {
        return this.signedRequest != null ? this.signedRequest.getUserId() : null;
    }

    /**
     * Get raw signed request from input.
     */
    public function getRawSignedRequest( ) : Null<String>
    {
        throw "Not implemented";
        return null;
    }

    /**
     * Get raw signed request from POST input.
     */
    public function getRawSignedRequestFromPost( ) : Null<String>
    {
        var key = 'signed_request';
        var v : String = null;
    #if neko
        v = neko.Web.getParams().get(key);
    #end
        return v;
    }

    /**
     * Get raw signed request from cookie set from the Javascript SDK.
     */
    public function getRawSignedRequestFromCookie( ) : String
    {
        var key : String = 'fbsr_' + this.app.id;
        var v = null;
    #if neko
        v = neko.Web.getCookies().get(key);
    #end
        return v;
    }
}
