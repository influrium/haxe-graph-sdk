package cases;

import fb.util.Params;
import fb.error.InvalidArgumentException;
import utest.Assert;

import haxe.Json;
import haxe.ds.StringMap;

import fb.Facebook;
import fb.upload.FacebookFile;
import fb.error.FacebookSDKException;
import fb.GraphVersion;
import fb.FacebookBatchRequest;
import fb.FacebookApp;
import fb.FacebookRequest;
import fb.auth.AccessToken;


class FacebookBatchRequestTest extends utest.Test
{
    var app : FacebookApp;

    function setup( )
    {
        this.app = new FacebookApp('123', 'foo_secret');
    }

    public function test_ABatchRequestWillInstantiateWithTheProperProperties( )
    {
        var batchRequest = new FacebookBatchRequest(this.app, [], 'foo_token', new GraphVersion('v0.1337'));
        
        Assert.same(this.app, batchRequest.app);
        Assert.equals('foo_token', batchRequest.accessToken.toString());
        Assert.equals('POST', batchRequest.method);
        Assert.equals('', batchRequest.endpoint);
        Assert.equals('v0.1337', batchRequest.graphVersion);
    }

    public function test_EmptyRequestWillFallbackToBatchDefaults( )
    {
        var request = new FacebookRequest();

        this.createBatchRequest().addFallbackDefaults(request);

        this.assertRequestContainsAppAndToken(request, this.app, 'foo_token');
    }

    public function test_RequestWithTokenOnlyWillFallbackToBatchDefaults( )
    {
        var request = new FacebookRequest(null, 'bar_token');

        this.createBatchRequest().addFallbackDefaults(request);

        this.assertRequestContainsAppAndToken(request, this.app, 'bar_token');
    }

    public function test_RequestWithAppOnlyWillFallbackToBatchDefaults( )
    {
        var customApp = new FacebookApp('1337', 'bar_secret');
        var request = new FacebookRequest(customApp);

        this.createBatchRequest().addFallbackDefaults(request);

        this.assertRequestContainsAppAndToken(request, customApp, 'foo_token');
    }

    public function test_WillThrowWhenNoThereIsNoAppFallback( )
    {
        Assert.raises(function(){
            var batchRequest = new FacebookBatchRequest();
            batchRequest.addFallbackDefaults(new FacebookRequest(null, 'foo_token'));
        }, FacebookSDKException);
    }

    public function test_WillThrowWhenNoThereIsNoAccessTokenFallback( )
    {
        Assert.raises(function(){
            var request = new FacebookBatchRequest();
            request.addFallbackDefaults(new FacebookRequest(this.app));
        }, FacebookSDKException);
    }

    public function test_AddingRequestsWillBeFormattedInAnArrayProperly( )
    {
        var requests = [
            '' => new FacebookRequest(null, null, 'GET', '/foo'),
            'my-second-request' => new FacebookRequest(null, null, 'POST', '/bar', new Params(['foo' => 'bar'])),
            'my-third-request' => new FacebookRequest(null, null, 'DELETE', '/baz')
        ];

        var batchRequest = this.createBatchRequest();
        for (name in requests.keys())
            batchRequest.addRequest(requests.get(name), name);
/*
        batchRequest.addRequest(requests[''], '');
        batchRequest.addRequest(requests['my-second-request'], 'my-second-request');
        batchRequest.addRequest(requests['my-third-request'], 'my-third-request');
*/
        var formattedRequests = batchRequest.requests;

        this.assertRequestsMatch(requests, formattedRequests);
    }

    public function test_ANumericArrayOfRequestsCanBeAdded( )
    {
        var requests = [
            new FacebookRequest(null, null, 'GET', '/foo'),
            new FacebookRequest(null, null, 'POST', '/bar', new Params(['foo' => 'bar'])),
            new FacebookRequest(null, null, 'DELETE', '/baz'),
        ];

        var formattedRequests = this.createBatchRequestWithRequests(requests).requests;

        this.assertRequestsMatch(requests, formattedRequests);
    }

    public function test_AnAssociativeArrayOfRequestsCanBeAdded( )
    {
        /*
        var requests = [
            'req-one' => new FacebookRequest(null, null, 'GET', '/foo'),
            'req-two' => new FacebookRequest(null, null, 'POST', '/bar', new Params(['foo' => 'bar'])),
            'req-three' => new FacebookRequest(null, null, 'DELETE', '/baz'),
        ];
        */
        
        var requests = [
            new FacebookRequest(null, null, 'GET', '/foo'),
            new FacebookRequest(null, null, 'POST', '/bar', new Params(['foo' => 'bar'])),
            new FacebookRequest(null, null, 'DELETE', '/baz'),
        ];

        var formattedRequests = this.createBatchRequestWithRequests(requests).requests;

        this.assertRequestsMatch(requests, formattedRequests);
    }

    public function test_RequestsCanBeInjectedIntoConstructor( )
    {
        var requests = [
            new FacebookRequest(null, null, 'GET', '/foo'),
            new FacebookRequest(null, null, 'POST', '/bar', new Params(['foo' => 'bar'])),
            new FacebookRequest(null, null, 'DELETE', '/baz'),
        ];

        var batchRequest = new FacebookBatchRequest(this.app, requests, 'foo_token');
        var formattedRequests = batchRequest.requests;

        this.assertRequestsMatch(requests, formattedRequests);
    }

    public function test_AZeroRequestCountWithThrow( )
    {
        Assert.raises(function(){
            var batchRequest = new FacebookBatchRequest(this.app, [], 'foo_token');

            batchRequest.validateBatchRequestCount();
        }, FacebookSDKException);
    }

    public function test_MoreThanFiftyRequestsWillThrow( )
    {
        Assert.raises(function(){
            var batchRequest = this.createBatchRequest();

            this.createAndAppendRequestsTo(batchRequest, 51);
            batchRequest.validateBatchRequestCount();
        }, FacebookSDKException);
    }

    public function test_LessOrEqualThanFiftyRequestsWillNotThrow( )
    {
        var batchRequest = this.createBatchRequest();

        this.createAndAppendRequestsTo(batchRequest, 50);
        batchRequest.validateBatchRequestCount();
        Assert.pass();
    }

    public function test_BatchRequestEntitiesProperlyGetConvertedToAnArray( )
    {
        for (requestsAndExpectedResponses in requestsAndExpectedResponsesProvider())
        {
            // request, expectedArray @dataProvider requestsAndExpectedResponsesProvider
            var request = requestsAndExpectedResponses[0];
            var expectedArray = requestsAndExpectedResponses[1];

            var batchRequest = this.createBatchRequest();
            batchRequest.addRequest(request, 'foo_name');

            var requests = batchRequest.requests;
            var batchRequestArray = batchRequest.requestEntityToBatchArray(requests[0].request, requests[0].name);

            Assert.same(expectedArray, batchRequestArray, true);
        }
/*
    '/v2.10/foo?foo=bar&access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9'
    '/v2.10/foo?appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&access_token=foo_token&foo=bar'
*/
    }

    public function requestsAndExpectedResponsesProvider( ) : Array<Array<Dynamic>>
    {
        var headers = this.defaultHeaders();
        var apiVersion = Facebook.DEFAULT_GRAPH_VERSION;

        return [
            [
                new FacebookRequest(null, null, 'GET', '/foo', new Params(['foo' => 'bar'])),
                ({
                    headers: headers,
                    method: 'GET',
                    relative_url: '/$apiVersion/foo?access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&foo=bar',
                    name: 'foo_name',
                } : BatchData),
            ],
            [
                new FacebookRequest(null, null, 'POST', '/bar', new Params(['bar' => 'baz'])),
                ({
                    headers: headers,
                    method: 'POST',
                    relative_url: '/$apiVersion/bar',
                    body: 'access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&bar=baz',
                    name: 'foo_name',
                } : BatchData),
            ],
            [
                new FacebookRequest(null, null, 'DELETE', '/bar'),
                ({
                    headers: headers,
                    method: 'DELETE',
                    relative_url: '/$apiVersion/bar?access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
                    name: 'foo_name',
                } : BatchData),
            ],
        ];
    }

    public function test_BatchRequestsWithFilesGetConvertedToAnArray( )
    {
        var request = new FacebookRequest(null, null, 'POST', '/bar', new Params([
            'message' => 'foobar',
            'source' => new FacebookFile('test/files/foo.txt'),
        ]));

        var batchRequest = this.createBatchRequest();
        batchRequest.addRequest(request, 'foo_name');

        var requests = batchRequest.requests;

        var attachedFiles = requests[0].attached_files;

        var batchRequestArray = batchRequest.requestEntityToBatchArray(
            requests[0].request,
            requests[0].name,
            attachedFiles
        );

        Assert.same({
            headers: this.defaultHeaders(),
            method: 'POST',
            relative_url: '/' + Facebook.DEFAULT_GRAPH_VERSION + '/bar',
            body: 'access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&message=foobar',
            name: 'foo_name',
            attached_files: attachedFiles,
        }, batchRequestArray, true);
    }

    public function test_BatchRequestsWithOptionsGetConvertedToAnArray( )
    {
        var request = new FacebookRequest(null, null, 'GET', '/bar');
        var batchRequest = this.createBatchRequest();
        batchRequest.addRequest(request, {
            name: 'foo_name',
            omit_response_on_success: false,
        });

        var requests : Array<BatchRequest> = batchRequest.requests;

        var options : Dynamic = requests[0].options;
        options.name = requests[0].name;

        var batchRequestArray = batchRequest.requestEntityToBatchArray(requests[0].request, options);

        Assert.same({
            headers: this.defaultHeaders(),
            method: 'GET',
            relative_url: '/' + Facebook.DEFAULT_GRAPH_VERSION + '/bar?access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
            name: 'foo_name',
            omit_response_on_success: false,
        }, batchRequestArray, true);
    }

    public function test_PreppingABatchRequestProperlySetsThePostParams( )
    {
        var batchRequest = this.createBatchRequest();
        batchRequest.addRequest(new FacebookRequest(null, 'bar_token', 'GET', '/foo'), 'foo_name');
        batchRequest.addRequest(new FacebookRequest(null, null, 'POST', '/bar', new Params(['foo' => 'bar'])));
        batchRequest.prepareRequestsForBatch();

        var params : Params = batchRequest.getParams();

        var expectedHeaders = Json.stringify(this.defaultHeaders());
        var version = Facebook.DEFAULT_GRAPH_VERSION;

        var relative_url_1 : String = '/$version/foo?access_token=bar_token&appsecret_proof=2ceec40b7b9fd7d38fff1767b766bcc6b1f9feb378febac4612c156e6a8354bd';
        var relative_url_2 : String = '/$version/bar';
        var body_2 : String = 'access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&foo=bar';

        var expectedBatchParams : Params = new Params([
            'batch' =>
                '[{"name":"foo_name","headers":$expectedHeaders,"method":"GET","relative_url":"$relative_url_1"}'+
                ',{"body":"$body_2","headers":$expectedHeaders,"method":"POST","relative_url":"$relative_url_2"}]',
            'include_headers' => true,
            'access_token' => new AccessToken('foo_token'),
            'appsecret_proof' => 'df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
        ]);
        Assert.same(expectedBatchParams, params, true);
    }

    public function test_PreppingABatchRequestProperlyMovesTheFiles()
    {
        var batchRequest = this.createBatchRequest();
        batchRequest.addRequest(new FacebookRequest(null, 'bar_token', 'GET', '/foo'), 'foo_name');
        batchRequest.addRequest(new FacebookRequest(null, null, 'POST', '/me/photos', new Params([
            'message' => 'foobar',
            'source' => new FacebookFile('test/files/foo.txt'),
        ])));
        batchRequest.prepareRequestsForBatch();

        var params = batchRequest.getParams();
        var files = batchRequest.files;

        var attachedFiles = [for(k in files.keys()) k].join(',');

        var expectedHeaders : String = Json.stringify(this.defaultHeaders());
        var version = Facebook.DEFAULT_GRAPH_VERSION;

        var relative_url_1 : String = '/$version/foo?access_token=bar_token&appsecret_proof=2ceec40b7b9fd7d38fff1767b766bcc6b1f9feb378febac4612c156e6a8354bd';
        var relative_url_2 : String = '/$version/me/photos';
        var body_2 : String = 'access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9&message=foobar';

        var expectedBatchParams = new Params([
            'batch' => 
                '[{"name":"foo_name","headers":$expectedHeaders,"method":"GET","relative_url":"$relative_url_1"}'+
                ',{"body":"$body_2","attached_files":"$attachedFiles","headers":$expectedHeaders,"method":"POST","relative_url":"$relative_url_2"}]',
            'include_headers' => true,
            'access_token' => new AccessToken('foo_token'),
            'appsecret_proof' => 'df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
        ]);
        Assert.same(expectedBatchParams, params, true);
    }

    public function test_PreppingABatchRequestWithOptionsProperlySetsThePostParams()
    {
        var batchRequest = this.createBatchRequest();
        batchRequest.addRequest(new FacebookRequest(null, null, 'GET', '/foo'), {
            name: 'foo_name',
            omit_response_on_success: false,
        });

        batchRequest.prepareRequestsForBatch();
        var params = batchRequest.getParams();

        var expectedHeaders = Json.stringify(this.defaultHeaders());
        var version = Facebook.DEFAULT_GRAPH_VERSION;

        var relative_url_1 : String = '/$version/foo?access_token=foo_token&appsecret_proof=df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9';

        var expectedBatchParams = new Params([
            'batch' => '[{"name":"foo_name","headers":$expectedHeaders,"method":"GET","omit_response_on_success":false,"relative_url":"$relative_url_1"}]',
            'include_headers' => true,
            'access_token' => new AccessToken('foo_token'),
            'appsecret_proof' => 'df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9',
        ]);
        Assert.same(expectedBatchParams, params, true);
    }

    function assertRequestContainsAppAndToken( request : FacebookRequest, expectedApp : FacebookApp, expectedToken : AccessToken )
    {
        var app = request.app;
        var token = request.accessToken;

        Assert.same(expectedApp, app);
        Assert.same(expectedToken, token);
    }

    function defaultHeaders( )
    {
        var headers = [];
        var dh = FacebookRequest.getDefaultHeaders();
        for (name in dh.keys())
        {
            var value = dh.get(name);
            headers.push('$name: $value');
        }
        return headers;
    }

    function createAndAppendRequestsTo( batchRequest : FacebookBatchRequest, number : Int ) : Void
    {
        for (i in 0...number)
            batchRequest.addRequest(new FacebookRequest());
    }

    function createBatchRequest( )
    {
        return new FacebookBatchRequest(this.app, [], 'foo_token');
    }

    function createBatchRequestWithRequests( requests : Array<FacebookRequest> ) : FacebookBatchRequest
    {
        var batchRequest = this.createBatchRequest();
        batchRequest.add(requests);
        return batchRequest;
    }

    function assertRequestsMatch( ?requests : Array<FacebookRequest>, ?requestsMap : StringMap<FacebookRequest>, formattedRequests : Array<BatchRequest> )
    {
        var expectedRequests : Array<BatchRequest> = [];

        if (requests != null) for (i in 0...requests.length)
        {
            var request = requests[i];
            expectedRequests.push({
                name: Std.string(i),
                request: request,
                attached_files: null,
                options:  {},
            });
        }

        if (requestsMap != null) for (name in requestsMap.keys())
        {
            var request = requestsMap.get(name);
            expectedRequests.push({
                name: name,
                request: request,
                attached_files: null,
                options:  {},
            });
        }

        // trace(expectedRequests);
        // trace(formattedRequests);
        Assert.same(expectedRequests, formattedRequests, true);
    }
/*
    public function test_AnInvalidTypeGivenToAddWillThrow( )
    {
        Assert.raises(function(){
            var request = new FacebookBatchRequest();
            request.add('foo');
        }, InvalidArgumentException);
    }
*/
}