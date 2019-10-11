package cases;

import utest.Assert;

import fb.GraphVersion;
import fb.FacebookApp;
import fb.FacebookBatchResponse;
import fb.FacebookBatchRequest;
import fb.FacebookRequest;
import fb.FacebookResponse;
import fb.graph.GraphNode;
import fb.util.Params;


class FacebookBatchResponseTest extends utest.Test
{
    var app : FacebookApp;
    var request : FacebookRequest;

    function setup( )
    {
        this.app = new FacebookApp('123', 'foo_secret');
        this.request = new FacebookRequest(
            this.app,
            'foo_token',
            'POST',
            '/',
            new Params(['batch' => 'foo']),
            'foo_eTag',
            new GraphVersion('v1337')
        );
    }

    public function testASuccessfulJsonBatchResponseWillBeDecoded( )
    {
        var graphResponseJson = '[';
        // Single Graph object.
        graphResponseJson += '{"code":200,"headers":[{"name":"Connection","value":"close"},{"name":"Last-Modified","value":"2013-12-24T00:34:20+0000"},{"name":"Facebook-API-Version","value":"v2.0"},{"name":"ETag","value":"\\"fooTag\\""},{"name":"Content-Type","value":"text\\/javascript; charset=UTF-8"},{"name":"Pragma","value":"no-cache"},{"name":"Access-Control-Allow-Origin","value":"*"},{"name":"Cache-Control","value":"private, no-cache, no-store, must-revalidate"},{"name":"Expires","value":"Sat, 01 Jan 2000 00:00:00 GMT"}],"body":"{\\"id\\":\\"123\\",\\"name\\":\\"Foo McBar\\",\\"updated_time\\":\\"2013-12-24T00:34:20+0000\\",\\"verified\\":true}"}';
        // Paginated list of Graph objects.
        graphResponseJson += ',{"code":200,"headers":[{"name":"Connection","value":"close"},{"name":"Facebook-API-Version","value":"v1.0"},{"name":"ETag","value":"\\"barTag\\""},{"name":"Content-Type","value":"text\\/javascript; charset=UTF-8"},{"name":"Pragma","value":"no-cache"},{"name":"Access-Control-Allow-Origin","value":"*"},{"name":"Cache-Control","value":"private, no-cache, no-store, must-revalidate"},{"name":"Expires","value":"Sat, 01 Jan 2000 00:00:00 GMT"}],"body":"{\\"data\\":[{\\"id\\":\\"1337\\",\\"story\\":\\"Foo story.\\"},{\\"id\\":\\"1338\\",\\"story\\":\\"Bar story.\\"}],\\"paging\\":{\\"previous\\":\\"previous_url\\",\\"next\\":\\"next_url\\"}}"}';
        // After POST operation.
        graphResponseJson += ',{"code":200,"headers":[{"name":"Connection","value":"close"},{"name":"Expires","value":"Sat, 01 Jan 2000 00:00:00 GMT"},{"name":"Cache-Control","value":"private, no-cache, no-store, must-revalidate"},{"name":"Access-Control-Allow-Origin","value":"*"},{"name":"Pragma","value":"no-cache"},{"name":"Content-Type","value":"text\\/javascript; charset=UTF-8"},{"name":"Facebook-API-Version","value":"v2.0"}],"body":"{\\"id\\":\\"123_1337\\"}"}';
        // After DELETE operation.
        graphResponseJson += ',{"code":200,"headers":[{"name":"Connection","value":"close"},{"name":"Expires","value":"Sat, 01 Jan 2000 00:00:00 GMT"},{"name":"Cache-Control","value":"private, no-cache, no-store, must-revalidate"},{"name":"Access-Control-Allow-Origin","value":"*"},{"name":"Pragma","value":"no-cache"},{"name":"Content-Type","value":"text\\/javascript; charset=UTF-8"},{"name":"Facebook-API-Version","value":"v2.0"}],"body":"true"}';
        graphResponseJson += ']';

        var response = new FacebookResponse(this.request, graphResponseJson, 200);
        var batchRequest = new FacebookBatchRequest(this.app, [
            new FacebookRequest(this.app, 'token'),
            new FacebookRequest(this.app, 'token'),
            new FacebookRequest(this.app, 'token'),
            new FacebookRequest(this.app, 'token'),
        ]);
        var batchResponse = new FacebookBatchResponse(batchRequest, response);

        var decodedResponses = batchResponse.responses;

        // Single Graph object.
        Assert.isFalse(decodedResponses.get('0').isError(), 'Did not expect Response to return an error for single Graph object.');
        Assert.is(decodedResponses.get('0').getGraphNode(), GraphNode);

        // Paginated list of Graph objects.
        Assert.isFalse(decodedResponses.get('1').isError(), 'Did not expect Response to return an error for paginated list of Graph objects.');

        var graphEdge = decodedResponses.get('1').getGraphEdge();
        Assert.is(graphEdge.child(0), GraphNode);
        Assert.is(graphEdge.child(1), GraphNode);
    }

    public function testABatchResponseCanBeIteratedOver()
    {
        var graphResponseJson = '[';
        graphResponseJson += '{"code":200,"headers":[],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ',{"code":200,"headers":[],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ',{"code":200,"headers":[],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ']';

        var response = new FacebookResponse(this.request, graphResponseJson, 200);
/*
        var batchRequest = new FacebookBatchRequest(this.app, [
            'req_one' => new FacebookRequest(this.app, 'token'),
            'req_two' => new FacebookRequest(this.app, 'token'),
            'req_three' => new FacebookRequest(this.app, 'token'),
        ]);
*/
        var batchRequest = new FacebookBatchRequest(this.app, [
            new FacebookRequest(this.app, 'token'),
            new FacebookRequest(this.app, 'token'),
            new FacebookRequest(this.app, 'token'),
        ]);
        var batchResponse = new FacebookBatchResponse(batchRequest, response);

        // Assert.is(batchResponse, IteratorAggregate);

        for (key in batchResponse.responses.keys())
        {
            var responseEntity = batchResponse.responses.get(key);

            // Assert.allows(['req_one', 'req_two', 'req_three'], key);
            Assert.allows(['0', '1', '2'], key);
            Assert.is(responseEntity, FacebookResponse);
        }
    }

    public function testTheOriginalRequestCanBeObtainedForEachRequest()
    {
        var graphResponseJson = '[';
        graphResponseJson += '{"code":200,"headers":[],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ',{"code":200,"headers":[],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ',{"code":200,"headers":[],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ']';

        var response = new FacebookResponse(this.request, graphResponseJson, 200);

        var requests = [
            new FacebookRequest(this.app, 'foo_token_one', 'GET', '/me'),
            new FacebookRequest(this.app, 'foo_token_two', 'POST', '/you'),
            new FacebookRequest(this.app, 'foo_token_three', 'DELETE', '/123456'),
        ];

        var batchRequest = new FacebookBatchRequest(this.app, requests);
        var batchResponse = new FacebookBatchResponse(batchRequest, response);

        Assert.is(batchResponse.responses.get('0'), FacebookResponse);
        Assert.is(batchResponse.responses.get('0').request, FacebookRequest);
        
        Assert.equals('foo_token_one', batchResponse.responses.get('0').getAccessToken().toString());
        Assert.equals('foo_token_two', batchResponse.responses.get('1').getAccessToken().toString());
        Assert.equals('foo_token_three', batchResponse.responses.get('2').getAccessToken().toString());
    }

    public function testHeadersFromBatchRequestCanBeAccessed()
    {
        var graphResponseJson = '[';
        graphResponseJson += '{"code":200,"headers":[{"name":"Facebook-API-Version","value":"v2.0"},{"name":"ETag","value":"\\"fooTag\\""}],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ',{"code":200,"headers":[{"name":"Facebook-API-Version","value":"v2.5"},{"name":"ETag","value":"\\"barTag\\""}],"body":"{\\"foo\\":\\"bar\\"}"}';
        graphResponseJson += ']';

        var response = new FacebookResponse(this.request, graphResponseJson, 200);

        var requests = [
            new FacebookRequest(this.app, 'foo_token_one', 'GET', '/me'),
            new FacebookRequest(this.app, 'foo_token_two', 'GET', '/you'),
        ];

        var batchRequest = new FacebookBatchRequest(this.app, requests);
        var batchResponse = new FacebookBatchResponse(batchRequest, response);

        Assert.equals('v2.0', batchResponse.responses.get('0').getGraphVersion());
        Assert.equals('"fooTag"', batchResponse.responses.get('0').getETag());

        Assert.equals('v2.5', batchResponse.responses.get('1').getGraphVersion());
        Assert.equals('"barTag"', batchResponse.responses.get('1').getETag());

        Assert.same([
          'Facebook-API-Version' => 'v2.5',
          'ETag' => '"barTag"',
        ], batchResponse.responses.get('1').headers);
    }
}