package cases;

import utest.Assert;

import fb.*;
import fb.auth.*;
import fb.error.*;
import fb.upload.*;
import fb.util.*;


class FacebookRequestTest extends utest.Test
{
    public function test_anEmptyRequestEntityCanInstantiate( )
    {
        var app = new FacebookApp('123', 'foo_secret');
        var request = new FacebookRequest(app);
        
        Assert.is(request, FacebookRequest);
    }

    public function test_aMissingAccessTokenWillThrow( )
    {
        Assert.raises(function(){
            var app = new FacebookApp('123', 'foo_secret');
            var request = new FacebookRequest(app);

            request.validateAccessToken();
        }, FacebookSDKException);
    }

    public function test_aMissingMethodWillThrow( )
    {
        Assert.raises(function(){
            var app = new FacebookApp('123', 'foo_secret');
            var request = new FacebookRequest(app);

            request.validateMethod();
        }, FacebookSDKException);
    }

    public function test_anInvalidMethodWillThrow( )
    {
        Assert.raises(function(){
            var app = new FacebookApp('123', 'foo_secret');
            var request = new FacebookRequest(app, 'foo_token', 'FOO');

            request.validateMethod();
        }, FacebookSDKException);
    }

    public function test_getHeadersWillAutoAppendETag( )
    {
        var app = new FacebookApp('123', 'foo_secret');
        var request = new FacebookRequest(app, null, 'GET', '/foo', new Params(), 'fooETag');

        var headers = request.getHeaders();

        var expectedHeaders = FacebookRequest.getDefaultHeaders();
        expectedHeaders.set('If-None-Match', 'fooETag');

        Assert.same(expectedHeaders, headers);
    }

    public function test_getParamsWillAutoAppendAccessTokenAndAppSecretProof( )
    {
        var app = new FacebookApp('123', 'foo_secret');
        var request = new FacebookRequest(app, 'foo_token', 'POST', '/foo', new Params(['foo' => 'bar']));

        var params = request.getParams();

        Assert.same(new Params([
            'foo' => 'bar',
            'access_token' => new AccessToken('foo_token'),
            'appsecret_proof' => 'df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
        ]), params);
    }

    public function test_anAccessTokenCanBeSetFromTheParams( )
    {
        var app = new FacebookApp('123', 'foo_secret');
        var request = new FacebookRequest(app, null, 'POST', '/me', new Params(['access_token' => 'bar_token']));

        var accessToken = request.accessToken;

        Assert.equals('bar_token', accessToken.toString());
    }

    public function test_accessTokenConflictsWillThrow( )
    {
        Assert.raises(function(){
            var app = new FacebookApp('123', 'foo_secret');
            new FacebookRequest(app, 'foo_token', 'POST', '/me', new Params(['access_token' => 'bar_token']));
        }, FacebookSDKException);
    }

    public function test_aProperUrlWillBeGenerated( )
    {
        var app = new FacebookApp('123', 'foo_secret');
        var getRequest = new FacebookRequest(app, 'foo_token', 'GET', '/foo', new Params(['foo' => 'bar']));

        var getUrl = getRequest.getUrl();
        // var expectedParams = 'foo=bar&access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9';
        var expectedParams = 'access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&foo=bar';

        var expectedUrl = '/' + Facebook.DEFAULT_GRAPH_VERSION + '/foo?' + expectedParams;

        Assert.equals(expectedUrl, getUrl);

        var postRequest = new FacebookRequest(app, 'foo_token', 'POST', '/bar', new Params(['foo' => 'bar']));

        var postUrl = postRequest.getUrl();
        var expectedUrl = '/' + Facebook.DEFAULT_GRAPH_VERSION + '/bar';

        Assert.equals(expectedUrl, postUrl);
    }

    public function test_authenticationParamsAreStrippedAndReapplied( )
    {
        var app = new FacebookApp('123', 'foo_secret');

        var request = new FacebookRequest(app, 'foo_token', 'GET', '/foo', new Params([
            'access_token' => 'foo_token',
            'appsecret_proof' => 'bar_app_secret',
            'bar' => 'baz',
        ]));

        var url = request.getUrl();
        
        var expectedParams = 'access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&bar=baz';
        var expectedUrl = '/' + Facebook.DEFAULT_GRAPH_VERSION + '/foo?' + expectedParams;
        Assert.equals(expectedUrl, url);

        var params = request.getParams();

        var expectedParams = new Params([
            'access_token' => new AccessToken('foo_token'),
            'appsecret_proof' => 'df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
            'bar' => 'baz',
        ]);
        Assert.same(expectedParams, params, true);
    }

    public function test_aFileCanBeAddedToParams( )
    {
        var myFile = new FacebookFile('test/files/foo.txt');
        var params = new Params([
            'name' => 'Foo Bar',
            'source' => myFile,
        ]);
        var app = new FacebookApp('123', 'foo_secret');
        var request = new FacebookRequest(app, 'foo_token', 'POST', '/foo/photos', params);

        var actualParams = request.getParams();

        Assert.isTrue(request.containsFileUploads());
        Assert.isFalse(request.containsVideoUploads());
        // Assert.isTrue(!isset(actualParams['source']));
        Assert.isNull(actualParams['source']);
        Assert.equals('Foo Bar', actualParams['name']);
    }

    public function test_aVideoCanBeAddedToParams( )
    {
        var myFile = new FacebookVideo('test/files/foo.txt');
        var params = new Params([
            'name' => 'Foo Bar',
            'source' => myFile,
        ]);
        var app = new FacebookApp('123', 'foo_secret');
        var request = new FacebookRequest(app, 'foo_token', 'POST', '/foo/videos', params);

        var actualParams = request.getParams();

        Assert.isTrue(request.containsFileUploads());
        Assert.isTrue(request.containsVideoUploads());
        // Assert.isTrue(!isset(actualParams['source']));
        Assert.isNull(actualParams['source']);
        Assert.equals('Foo Bar', actualParams['name']);
    }
}
