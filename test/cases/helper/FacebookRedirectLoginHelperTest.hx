package cases.helper;

import fb.prs.PseudoRandomStringGeneratorInterface;
import haxe.ds.StringMap;
import utest.Assert;

import fixtures.*;

import StringTools;

import fb.GraphVersion;
import fb.Facebook;
import fb.FacebookApp;
import fb.FacebookClient;
import fb.helpers.FacebookRedirectLoginHelper;
import fb.persist.FacebookMemoryPersistentDataHandler;


class FacebookRedirectLoginHelperTest extends utest.Test
{
    var persistentDataHandler : FacebookMemoryPersistentDataHandler;
    var redirectLoginHelper : FacebookRedirectLoginHelper;

    inline static var REDIRECT_URL = 'http://invalid.zzz';
    inline static var FOO_CODE = "foo_code";
    inline static var FOO_ENFORCE_HTTPS = "foo_enforce_https";
    inline static var FOO_STATE = "foo_state";
    inline static var FOO_PARAM = "some_param=blah";

    function setup( )
    {
        this.persistentDataHandler = new FacebookMemoryPersistentDataHandler();

        var app = new FacebookApp('123', 'foo_app_secret');
        var oAuth2Client = new FooRedirectLoginOAuth2Client(app, new FacebookClient(), new GraphVersion('v1337'));
        this.redirectLoginHelper = new FacebookRedirectLoginHelper(oAuth2Client, this.persistentDataHandler);
    }

    public function testLoginURL( )
    {
        var scope = ['foo', 'bar'];
        var loginUrl = this.redirectLoginHelper.getLoginUrl(REDIRECT_URL, scope);

        var expectedUrl = 'https://www.facebook.com/v1337/dialog/oauth?';
        Assert.isTrue(loginUrl.indexOf(expectedUrl) == 0, 'Unexpected base login URL returned from getLoginUrl().');

        var params : StringMap<Dynamic> = [
            'client_id' => '123',
            'redirect_uri' => REDIRECT_URL,
            'state' => this.persistentDataHandler.get('state'),
            'sdk' => 'haxe-sdk-' + Facebook.VERSION,
            'scope' => scope.join(','),
        ];
        for (key in params.keys())
        {
            var value = params.get(key);
            Assert.stringContains(key + '=' + StringTools.urlEncode(value), loginUrl);
        }
    }

    public function testLogoutURL()
    {
        var logoutUrl = this.redirectLoginHelper.getLogoutUrl('foo_token', REDIRECT_URL);
        var expectedUrl = 'https://www.facebook.com/logout.php?';
        Assert.isTrue(logoutUrl.indexOf(expectedUrl) == 0, 'Unexpected base logout URL returned from getLogoutUrl().');

        var params = [
            'next' => REDIRECT_URL,
            'access_token' => 'foo_token',
        ];
        for (key in params.keys())
        {
            var value = params.get(key);
            Assert.isTrue(logoutUrl.indexOf(key + '=' + StringTools.urlEncode(value)) != -1);
        }
    }

    public function testAnAccessTokenCanBeObtainedFromRedirect()
    {
        this.persistentDataHandler.set('state', FOO_STATE);
    #if neko
        untyped neko.Web.getParams = function() return [
            'code' => FOO_CODE, // _GET
            'enforce_https' => FOO_ENFORCE_HTTPS, // _GET
            'state' => FOO_STATE, // _GET
        ];
    #end


        var fullUrl = REDIRECT_URL + '?state=' + FOO_STATE + '&enforce_https=' + FOO_ENFORCE_HTTPS + '&code=' + FOO_CODE + '&' + FOO_PARAM;

        var accessToken = this.redirectLoginHelper.getAccessToken(fullUrl);

        // 'code', 'enforce_https' and 'state' should be stripped from the URL
        var expectedUrl = REDIRECT_URL + '?' + FOO_PARAM;
        var expectedString = 'foo_token_from_code|' + FOO_CODE + '|' + expectedUrl;

        Assert.equals(expectedString, accessToken.getValue());
    }

    public function testACustomCsprsgCanBeInjected()
    {
        var app = new FacebookApp('123', 'foo_app_secret');
        var accessTokenClient = new FooRedirectLoginOAuth2Client(app, new FacebookClient(), new GraphVersion('v1337'));
        var fooPrsg = new FooPseudoRandomStringGenerator();
        var helper = new FacebookRedirectLoginHelper(accessTokenClient, this.persistentDataHandler, null, fooPrsg);

        var loginUrl = helper.getLoginUrl(REDIRECT_URL);

        Assert.stringContains('state=csprs123', loginUrl);
    }

    public function testThePseudoRandomStringGeneratorWillAutoDetectCsprsg()
    {
        Assert.is(this.redirectLoginHelper.pseudoRandomStringGenerator, PseudoRandomStringGeneratorInterface);
    }
}