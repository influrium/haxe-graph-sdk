package fb.helpers;

import fb.error.*;
import fb.util.UrlTools;
import fb.auth.*;
import fb.prs.*;
import fb.persist.*;
import fb.url.*;


class FacebookRedirectLoginHelper
{
    /**
     * The length of CSRF string to validate the login link.
     */
    inline public static var CSRF_LENGTH = 32;

    /**
     * The OAuth 2.0 client service.
     */
    var oAuth2Client : OAuth2Client;

    /**
     * The URL detection handler.
     */
    public var urlDetectionHandler (default, null) : UrlDetectionInterface;

    /**
     *  The persistent data handler.
     */
    public var persistentDataHandler (default, null) : PersistentDataInterface;

    /**
     * The cryptographically secure pseudo-random string generator.
     */
    public var pseudoRandomStringGenerator (default, null) : PseudoRandomStringGeneratorInterface;

    /**
     * @param OAuth2Client                              $oAuth2Client          The OAuth 2.0 client service.
     * @param PersistentDataInterface|null              $persistentDataHandler The persistent data handler.
     * @param UrlDetectionInterface|null                $urlHandler            The URL detection handler.
     * @param PseudoRandomStringGeneratorInterface|null $prsg                  The cryptographically secure pseudo-random string generator.
     */
    public function new( oAuth2Client : OAuth2Client, ?persistentDataHandler : PersistentDataInterface, ?urlHandler : UrlDetectionInterface, ?prsg : PseudoRandomStringGeneratorInterface )
    {
        this.oAuth2Client = oAuth2Client;
        this.persistentDataHandler = persistentDataHandler != null ? persistentDataHandler : new FacebookMemoryPersistentDataHandler();
        this.urlDetectionHandler = urlHandler != null ? urlHandler : new FacebookUrlDetectionHandler();
        this.pseudoRandomStringGenerator = PseudoRandomStringGeneratorFactory.createPseudoRandomStringGenerator(prsg);
    }

    /**
     * Stores CSRF state and returns a URL to which the user should be sent to in order to continue the login process with Facebook.
     *
     * @param string $redirectUrl The URL Facebook should redirect users to after login.
     * @param array  $scope       List of permissions to request during login.
     * @param array  $params      An array of parameters to generate URL.
     * @param string $separator   The separator to use in http_build_query().
     *
     * @return string
     */
    private function makeUrl( redirectUrl : String, scope : Array<String>, params : Dynamic<String>, separator : String = '&') : String
    {
        var state = this.persistentDataHandler.get('state');
        state = state != null ? state : this.pseudoRandomStringGenerator.getPseudoRandomString(CSRF_LENGTH);
        this.persistentDataHandler.set('state', state);

        return this.oAuth2Client.getAuthorizationUrl(redirectUrl, state, scope, params, separator);
    }

    /**
     * Returns the URL to send the user in order to login to Facebook.
     *
     * @param string $redirectUrl The URL Facebook should redirect users to after login.
     * @param array  $scope       List of permissions to request during login.
     * @param string $separator   The separator to use in http_build_query().
     *
     * @return string
     */
    public function getLoginUrl( redirectUrl : String, ?scope : Array<String>, separator : String = '&') : String
    {
        scope = scope != null ? scope : [];
        return this.makeUrl(redirectUrl, scope, {}, separator);
    }

    /**
     * Returns the URL to send the user in order to log out of Facebook.
     *
     * @param AccessToken|string $accessToken The access token that will be logged out.
     * @param string             $next        The url Facebook should redirect the user to after a successful logout.
     * @param string             $separator   The separator to use in http_build_query().
     *
     * @return string
     *
     * @throws FacebookSDKException
     */
    public function getLogoutUrl( accessToken : AccessToken, next : String, separator : String = '&') : String
    {
        if (accessToken.isAppAccessToken())
            throw new FacebookSDKException('Cannot generate a logout URL with an app access token.', 722);

        var params = {
            next: next,
            access_token: accessToken.getValue(),
        };

        return 'https://www.facebook.com/logout.php?' + UrlTools.http_build_query(params, separator);
    }

    /**
     * Returns the URL to send the user in order to login to Facebook with permission(s) to be re-asked.
     *
     * @param string $redirectUrl The URL Facebook should redirect users to after login.
     * @param array  $scope       List of permissions to request during login.
     * @param string $separator   The separator to use in http_build_query().
     *
     * @return string
     */
    public function getReRequestUrl( redirectUrl : String, ?scope : Array<String>, separator : String = '&' ) : String
    {
        var params = {
            auth_type: 'rerequest',
        };
        return this.makeUrl(redirectUrl, scope, params, separator);
    }

    /**
     * Returns the URL to send the user in order to login to Facebook with user to be re-authenticated.
     *
     * @param string $redirectUrl The URL Facebook should redirect users to after login.
     * @param array  $scope       List of permissions to request during login.
     * @param string $separator   The separator to use in http_build_query().
     *
     * @return string
     */
    public function getReAuthenticationUrl( redirectUrl : String, scope : Array<String>, separator : String = '&' ) : String
    {
        var params =  {
            auth_type: 'reauthenticate',
        };
        return this.makeUrl(redirectUrl, scope, params, separator);
    }

    /**
     * Takes a valid code from a login redirect, and returns an AccessToken entity.
     *
     * @param string|null $redirectUrl The redirect URL.
     *
     * @return AccessToken|null
     *
     * @throws FacebookSDKException
     */
    public function getAccessToken( ?redirectUrl : String ) : AccessToken
    {
        var code = this.getCode();
        if (code == null )
            return null;

        this.validateCsrf();
        this.resetCsrf();

        redirectUrl = redirectUrl != null ? redirectUrl : this.urlDetectionHandler.getCurrentUrl();

        // At minimum we need to remove the 'code', 'enforce_https' and 'state' params
        redirectUrl = FacebookUrlManipulator.removeParamsFromUrl(redirectUrl, ['code', 'enforce_https', 'state']);

        return this.oAuth2Client.getAccessTokenFromCode(code, redirectUrl);
    }

    /**
     * Validate the request against a cross-site request forgery.
     *
     * @throws FacebookSDKException
     */
    function validateCsrf( ) : Void
    {
        var state = this.getState();
        if (state == null)
            throw new FacebookSDKException('Cross-site request forgery validation failed. Required GET param "state" missing.');
        
        var savedState = this.persistentDataHandler.get('state');
        if (savedState == null)
            throw new FacebookSDKException('Cross-site request forgery validation failed. Required param "state" missing from persistent data.');

        if (savedState == state)
            return;

        throw new FacebookSDKException('Cross-site request forgery validation failed. The "state" param from the URL and session do not match.');
    }

    /**
     * Resets the CSRF so that it doesn't get reused.
     */
    private function resetCsrf( ) : Void
    {
        this.persistentDataHandler.set('state', null);
    }

    /**
     * Return the code.
     */
    function getCode( ) : String return this.getInput('code');

    /**
     * Return the state.
     */
    function getState( ) : String return this.getInput('state');

    /**
     * Return the error code.
     */
    public function getErrorCode( ) : String return this.getInput('error_code');

    /**
     * Returns the error.
     */
    public function getError( ) : String return this.getInput('error');

    /**
     * Returns the error reason.
     */
    public function getErrorReason( ) : String return this.getInput('error_reason');

    /**
     * Returns the error description.
     */
    public function getErrorDescription( ) : String return this.getInput('error_description');

    /**
     * Returns a value from a GET param.
     */
    private function getInput( key : String ) : String
    {
        // return isset($_GET[$key]) ? $_GET[$key] : null;
    #if neko
        return neko.Web.getParams().get(key);
    #else
        #error
    #end
        return null;
    }
}
