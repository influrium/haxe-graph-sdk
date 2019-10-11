package cases.auth;

import utest.Assert;

import haxe.ds.StringMap;

import fixtures.FooFacebookClientForOAuth2Test;

import fb.GraphVersion;
import fb.FacebookApp;
import fb.Facebook;
import fb.auth.OAuth2Client;
import fb.auth.AccessTokenMetadata;
import fb.auth.AccessToken;
import fb.util.Params;


class OAuth2ClientTest extends utest.Test
{
    /**
     * The foo Graph version
     */
    inline static var TESTING_GRAPH_VERSION = new GraphVersion('v1337');

    var client : FooFacebookClientForOAuth2Test;

    var oauth : OAuth2Client;

    function setup( )
    {
        var app = new FacebookApp('123', 'foo_secret');

        this.client = new FooFacebookClientForOAuth2Test();
        this.oauth = new OAuth2Client(app, this.client, TESTING_GRAPH_VERSION);
    }

    public function testCanGetMetadataFromAnAccessToken( )
    {
        this.client.setMetadataResponse();

        var metadata = this.oauth.debugToken('baz_token');

        Assert.is(metadata, AccessTokenMetadata);
        Assert.equals('444', metadata.getUserId());

        var expectedParams = new Params([
            'input_token' => 'baz_token',
            'access_token' => new AccessToken('123|foo_secret'),
            'appsecret_proof' => 'de753c58fd58b03afca2340bbaeb4ecf987b5de4c09e39a63c944dd25efbc234',
        ]);

        var request = this.oauth.lastRequest;
        Assert.equals('GET', request.method);
        Assert.equals('/debug_token', request.endpoint);
        Assert.same(expectedParams, request.getParams(), true);
        Assert.equals(TESTING_GRAPH_VERSION, request.graphVersion);
    }

    public function testCanBuildAuthorizationUrl( )
    {
        var scope = ['email', 'base_foo'];
        var authUrl = this.oauth.getAuthorizationUrl('https://foo.bar', 'foo_state', scope, {foo: 'bar'}, '*');

        Assert.stringContains('*', authUrl);

        var expectedUrl = 'https://www.facebook.com/' + TESTING_GRAPH_VERSION + '/dialog/oauth?';
        Assert.isTrue(authUrl.indexOf(expectedUrl) == 0, 'Unexpected base authorization URL returned from getAuthorizationUrl().');

        var params : StringMap<Dynamic> = [
            'client_id' => '123',
            'redirect_uri' => 'https://foo.bar',
            'state' => 'foo_state',
            'sdk' => 'haxe-sdk-' + Facebook.VERSION,
            'scope' => scope.join(','),
            'foo' => 'bar',
        ];
        for (key in params.keys())
        {
            var value = params.get(key);
            Assert.stringContains(key + '=' + StringTools.urlEncode(value), authUrl); //, 'Key: $key Value: $value Url: $authUrl');
        }
    }

    public function testCanGetAccessTokenFromCode( )
    {
        this.client.setAccessTokenResponse();

        var accessToken = this.oauth.getAccessTokenFromCode('bar_code', 'foo_uri');

        // Assert.is(accessToken, AccessToken);
        Assert.equals('my_access_token', accessToken.getValue());

        var expectedParams = new Params([
            'code' => 'bar_code',
            'redirect_uri' => 'foo_uri',
            'client_id' => '123',
            'client_secret' => 'foo_secret',
            'access_token' => new AccessToken('123|foo_secret'),
            'appsecret_proof' => 'de753c58fd58b03afca2340bbaeb4ecf987b5de4c09e39a63c944dd25efbc234',
        ]);

        var request = this.oauth.lastRequest;
        Assert.equals('GET', request.method);
        Assert.equals('/oauth/access_token', request.endpoint);
        Assert.same(expectedParams, request.getParams(), true);
        Assert.equals(TESTING_GRAPH_VERSION, request.graphVersion);
    }

    public function testCanGetLongLivedAccessToken( )
    {
        this.client.setAccessTokenResponse();

        var accessToken = this.oauth.getLongLivedAccessToken('short_token');

        Assert.equals('my_access_token', accessToken.getValue());

        var expectedParams = new Params([
            'grant_type' => 'fb_exchange_token',
            'fb_exchange_token' => 'short_token',
            'client_id' => '123',
            'client_secret' => 'foo_secret',
            'access_token' => new AccessToken('123|foo_secret'),
            'appsecret_proof' => 'de753c58fd58b03afca2340bbaeb4ecf987b5de4c09e39a63c944dd25efbc234',
        ]);

        var request = this.oauth.lastRequest;
        Assert.same(expectedParams, request.getParams(), true);
    }

    public function testCanGetCodeFromLongLivedAccessToken( )
    {
        this.client.setCodeResponse();

        var code = this.oauth.getCodeFromLongLivedAccessToken('long_token', 'foo_uri');

        Assert.equals('my_neat_code', code);

        var expectedParams = new Params([
            'access_token' => new AccessToken('long_token'),
            'redirect_uri' => 'foo_uri',
            'client_id' => '123',
            'client_secret' => 'foo_secret',
            'appsecret_proof' => '7e91300ea91be4166282611d4fc700b473466f3ea2981dafbf492fc096995bf1',
        ]);

        var request = this.oauth.lastRequest;
        Assert.same(expectedParams, request.getParams(), true);
        Assert.equals('/oauth/client_code', request.endpoint);
    }
}