package cases.helper;

import fb.auth.AccessToken;
import fb.FacebookApp;
import utest.Assert;

import fixtures.*;


class FacebookSignedRequestFromInputHelperTest extends utest.Test
{
    var helper : FooSignedRequestHelper;

    var rawSignedRequestAuthorizedWithAccessToken = 'vdZXlVEQ5NTRRTFvJ7Jeo_kP4SKnBDvbNP0fEYKS0Sg=.eyJvYXV0aF90b2tlbiI6ImZvb190b2tlbiIsImFsZ29yaXRobSI6IkhNQUMtU0hBMjU2IiwiaXNzdWVkX2F0IjoxNDAyNTUxMDMxLCJ1c2VyX2lkIjoiMTIzIn0=';
    var rawSignedRequestAuthorizedWithCode = 'oBtmZlsFguNQvGRETDYQQu1-PhwcArgbBBEK4urbpRA=.eyJjb2RlIjoiZm9vX2NvZGUiLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTQwNjMxMDc1MiwidXNlcl9pZCI6IjEyMyJ9';
    var rawSignedRequestUnauthorized = 'KPlyhz-whtYAhHWr15N5TkbS_avz-2rUJFpFkfXKC88=.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTQwMjU1MTA4Nn0=';

    function setup( )
    {
        var app = new FacebookApp('123', 'foo_app_secret');
        this.helper = new FooSignedRequestHelper(app, new FooSignedRequestHelperFacebookClient());
    }

    public function testSignedRequestDataCanBeRetrievedFromPostData( )
    {
    #if neko
        untyped neko.Web.getParams = function() return ['signed_request' => 'foo_signed_request'];
    #end

        var rawSignedRequest = this.helper.getRawSignedRequestFromPost();

        Assert.equals('foo_signed_request', rawSignedRequest);
    }

    public function testSignedRequestDataCanBeRetrievedFromCookieData( )
    {
    #if neko
        untyped neko.Web.getCookies = function() return ['fbsr_123' => 'foo_signed_request'];
    #end

        var rawSignedRequest = this.helper.getRawSignedRequestFromCookie();

        Assert.equals('foo_signed_request', rawSignedRequest);
    }

    public function testAccessTokenWillBeNullWhenAUserHasNotYetAuthorizedTheApp()
    {
        this.helper.instantiateSignedRequest(this.rawSignedRequestUnauthorized);

        var accessToken = this.helper.getAccessToken();

        Assert.isNull(accessToken);
    }

    public function testAnAccessTokenCanBeInstantiatedWhenRedirectReturnsAnAccessToken()
    {
        this.helper.instantiateSignedRequest(this.rawSignedRequestAuthorizedWithAccessToken);
        
        var accessToken = this.helper.getAccessToken();

        // Assert.is(accessToken, AccessToken);
        Assert.equals('foo_token', accessToken.getValue());
    }

    public function testAnAccessTokenCanBeInstantiatedWhenRedirectReturnsACode()
    {
        this.helper.instantiateSignedRequest(this.rawSignedRequestAuthorizedWithCode);

        var accessToken = this.helper.getAccessToken();
        trace(Type.typeof(accessToken));

        // Assert.is(accessToken, AccessToken);
        Assert.equals('foo_access_token_from:foo_code', accessToken.getValue());
    }
}