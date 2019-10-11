package cases;

import fb.util.Params;
import fb.graph.GraphNode;
import utest.Assert;

import fb.*;
import fb.httpclient.*;
import fb.error.*;
import fb.upload.*;
import fb.graphnodes.*;

import fixtures.*;


class FacebookClientTest extends utest.Test
{
    public static var testFacebookApp : FacebookApp;
    public static var testFacebookClient : FacebookClient;

    var fbApp : FacebookApp;
    var fbClient : FacebookClient;

    function setup( )
    {
        fbApp = new FacebookApp('id', 'shhhh!');
        fbClient = new FacebookClient(new MyFooClientHandler());
    }

    public function test_aCustomHttpClientCanBeInjected( )
    {
        var handler = new MyFooClientHandler();
        var client = new FacebookClient(handler);
        var httpHandler = client.httpClientHandler;

        Assert.is(httpHandler, MyFooClientHandler);
    }

    public function test_theHttpClientWillFallbackToDefault( )
    {
        var client = new FacebookClient();
        var httpHandler = client.httpClientHandler;
#if necurl
        if ( necurl.Necurl.loaded )
        {
            Assert.is(httpHandler, fb.httpclient.FacebookCurlHttpClient);
        }
        else
#end
        {
            Assert.is(httpHandler, FacebookHttpClient);
        }
    }

    public function test_betaModeCanBeDisabledOrEnabledViaConstructor( )
    {
        var client = new FacebookClient(null, false);
        var url = client.getBaseGraphUrl();
        Assert.equals(FacebookClient.BASE_GRAPH_URL, url);

        var client = new FacebookClient(null, true);
        url = client.getBaseGraphUrl();
        Assert.equals(FacebookClient.BASE_GRAPH_URL_BETA, url);
    }

    public function test_betaModeCanBeDisabledOrEnabledViaMethod( )
    {
        var client = new FacebookClient();
        client.enableBetaMode = false;
        var url = client.getBaseGraphUrl();
        Assert.equals(FacebookClient.BASE_GRAPH_URL, url);

        client.enableBetaMode = true;
        var url = client.getBaseGraphUrl();
        Assert.equals(FacebookClient.BASE_GRAPH_URL_BETA, url);
    }

    public function test_graphVideoUrlCanBeSet( )
    {
        var client = new FacebookClient();
        client.enableBetaMode = false;
        var url = client.getBaseGraphUrl(true);
        Assert.equals(FacebookClient.BASE_GRAPH_VIDEO_URL, url);

        client.enableBetaMode = true;
        var url = client.getBaseGraphUrl(true);
        Assert.equals(FacebookClient.BASE_GRAPH_VIDEO_URL_BETA, url);
    }

    public function test_aFacebookRequestEntityCanBeUsedToSendARequestToGraph( )
    {
        var fbRequest = new FacebookRequest(fbApp, 'token', 'GET', '/foo');
        var response = fbClient.sendRequest(fbRequest);

        Assert.is(response, FacebookResponse);
        Assert.equals(200, response.httpStatusCode);
        Assert.equals('{"data":[{"id":"123","name":"Foo"},{"id":"1337","name":"Bar"}]}', response.body);
    }

    public function test_aFacebookBatchRequestEntityCanBeUsedToSendABatchRequestToGraph( )
    {
        var fbRequests = [
            new FacebookRequest(fbApp, 'token', 'GET', '/foo'),
            new FacebookRequest(fbApp, 'token', 'POST', '/bar'),
        ];
        var fbBatchRequest = new FacebookBatchRequest(fbApp, fbRequests);
        var fbBatchClient = new FacebookClient(new MyFooBatchClientHandler());

        var response = fbBatchClient.sendBatchRequest(fbBatchRequest);

        Assert.is(response, FacebookBatchResponse);
        Assert.equals('GET', response.responses.get('0').request.method);
        Assert.equals('POST', response.responses.get('1').request.method);
    }

    public function test_aFacebookBatchRequestWillProperlyBatchFiles( )
    {
        var fbRequests = [
            new FacebookRequest(fbApp, 'token', 'POST', '/photo', new Params([
                'message' => 'foobar',
                'source'  => new FacebookFile('test/files/foo.txt'),
            ])),
            new FacebookRequest(fbApp, 'token', 'POST', '/video', new Params([
                'message' => 'foobar',
                'source'  => new FacebookVideo('test/files/foo.txt'),
            ])),
        ];
        var fbBatchRequest = new FacebookBatchRequest(fbApp, fbRequests);
        fbBatchRequest.prepareRequestsForBatch();

        var rm = fbClient.prepareRequestMessage(fbBatchRequest);

        Assert.equals(FacebookClient.BASE_GRAPH_VIDEO_URL + '/' + Facebook.DEFAULT_GRAPH_VERSION, rm.url);
        Assert.equals('POST', rm.method);

        Assert.stringContains('multipart/form-data; boundary=', rm.headers.get('Content-Type'));
        Assert.stringContains('Content-Disposition: form-data; name="batch"', rm.body);
        Assert.stringContains('Content-Disposition: form-data; name="include_headers"', rm.body);
        Assert.stringContains('"name":"0","attached_files":', rm.body);
        Assert.stringContains('"name":"1","attached_files":', rm.body);
        Assert.stringContains('"; filename="foo.txt"', rm.body);
    }

    public function test_aRequestOfParamsWillBeUrlEncoded( )
    {
        var fbRequest = new FacebookRequest(fbApp, 'token', 'POST', '/foo', new Params(['foo' => 'bar']));
        var response = fbClient.sendRequest(fbRequest);

        var headersSent = response.request.getHeaders();

        Assert.equals('application/x-www-form-urlencoded', headersSent.get('Content-Type'));
    }

    public function test_aRequestWithFilesWillBeMultipart( )
    {
        var myFile = new FacebookFile('test/files/foo.txt');
        var fbRequest = new FacebookRequest(fbApp, 'token', 'POST', '/foo', new Params(['file' => myFile]));
        var response = fbClient.sendRequest(fbRequest);

        var headersSent = response.request.getHeaders();

        Assert.stringContains('multipart/form-data; boundary=', headersSent.get('Content-Type'));
    }

    public function test_aFacebookRequestValidatesTheAccessTokenWhenOneIsNotProvided( )
    {
        Assert.raises(function()
        {
            var fbRequest = new FacebookRequest(fbApp, null, 'GET', '/foo');
            fbClient.sendRequest(fbRequest);
        },
        FacebookSDKException);
    }

    /**
     * @group integration
     */
    public function no_net_test_canCreateATestUserAndGetTheProfileAndThenDeleteTheTestUser()
    {
        initializeTestApp();

        // Create a test user
        var testUserPath = '/' + FacebookTestCredentials.appId + '/accounts/test-users';
        var params = new Params([
            'installed' => true,
            'name' => 'Foo Phpunit User',
            'locale' => 'en_US',
            'permissions' => ['read_stream', 'user_photos'].join(','),
        ]);

        var request = new FacebookRequest(
            testFacebookApp,
            testFacebookApp.getAccessToken(),
            'POST',
            testUserPath,
            params
        );
        var response = testFacebookClient.sendRequest(request).getGraphNode();

        var testUserId = response.getField('id');
        var testUserAccessToken = response.getField('access_token');

        // Get the test user's profile
        var request = new FacebookRequest(
            testFacebookApp,
            testUserAccessToken,
            'GET',
            '/me'
        );
        var graphNode = testFacebookClient.sendRequest(request).getGraphNode();

        Assert.is(graphNode, GraphNode);
        Assert.notNull(graphNode.getField('id'));
        Assert.equals('Foo Phpunit User', graphNode.getField('name'));

        // Delete test user
        var request = new FacebookRequest(
            testFacebookApp,
            testFacebookApp.getAccessToken(),
            'DELETE',
            '/$testUserId'
        );
        var graphNode = testFacebookClient.sendRequest(request).getGraphNode();

        Assert.isTrue(graphNode.getField('success'));
    }

    public function initializeTestApp( )
    {
        if (FacebookTestCredentials.appId == null || FacebookTestCredentials.appId.length < 1 ||
            FacebookTestCredentials.appSecret == null || FacebookTestCredentials.appSecret.length < 1)
            throw new FacebookSDKException('You must fill out FacebookTestCredentials');

        testFacebookApp = new FacebookApp(FacebookTestCredentials.appId, FacebookTestCredentials.appSecret);

        // Use default client
        var client = null;

        // Uncomment to enable curl implementation.
        // var client = new FacebookCurlHttpClient();

        // Uncomment to enable stream wrapper implementation.
        // var client = new FacebookStreamHttpClient();

        // Uncomment to enable Guzzle implementation.
        // var client = new FacebookGuzzleHttpClient();

        testFacebookClient = new FacebookClient(client);
    }
}