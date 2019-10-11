package cases;

import fb.GraphVersion;
import fb.util.Params;
import fb.error.FacebookResponseException;
import fb.graph.GraphNode;
import fb.FacebookResponse;
import fb.FacebookApp;
import fb.FacebookRequest;
import utest.Assert;


class FacebookResponseTest extends utest.Test
{
    var request : FacebookRequest;

    function setup( )
    {
        var app = new FacebookApp('123', 'foo_secret');
        this.request = new FacebookRequest(
            app,
            'foo_token',
            'GET',
            '/me/photos?keep=me',
            new Params(['foo' => 'bar']),
            'foo_eTag',
            new GraphVersion('v1337')
        );
    }

    public function testAnETagCanBeProperlyAccessed()
    {
        var response = new FacebookResponse(this.request, '', 200, ['ETag' => 'foo_tag']);

        var eTag = response.getETag();

        Assert.equals('foo_tag', eTag);
    }

    public function testAProperAppSecretProofCanBeGenerated()
    {
        var response = new FacebookResponse(this.request);

        var appSecretProof = response.getAppSecretProof();

        Assert.equals('df4256903ba4e23636cc142117aa632133d75c642bd2a68955be1443bd14deb9', appSecretProof);
    }

    public function testASuccessfulJsonResponseWillBeDecodedToAGraphNode()
    {
        var graphResponseJson = '{"id":"123","name":"Foo"}';
        var response = new FacebookResponse(this.request, graphResponseJson, 200);

        var decodedResponse = response.decodedBody;
        var graphNode = response.getGraphNode();

        Assert.isFalse(response.isError(), 'Did not expect Response to return an error.');
        Assert.same({
            id: '123',
            name: 'Foo',
        }, decodedResponse, true);
        Assert.is(graphNode, GraphNode);
    }

    public function testASuccessfulJsonResponseWillBeDecodedToAGraphEdge()
    {
        var graphResponseJson = '{"data":[{"id":"123","name":"Foo"},{"id":"1337","name":"Bar"}]}';
        var response = new FacebookResponse(this.request, graphResponseJson, 200);

        var graphEdge = response.getGraphEdge();

        Assert.isFalse(response.isError(), 'Did not expect Response to return an error.');
        Assert.is(graphEdge.child(0), GraphNode);
        Assert.is(graphEdge.child(1), GraphNode);
    }

    public function testASuccessfulUrlEncodedKeyValuePairResponseWillBeDecoded()
    {
        var graphResponseKeyValuePairs = 'id=123&name=Foo';
        var response = new FacebookResponse(this.request, graphResponseKeyValuePairs, 200);

        var decodedResponse = response.decodedBody;

        Assert.isFalse(response.isError(), 'Did not expect Response to return an error.');
        Assert.same({
            id: '123',
            name: 'Foo',
        }, decodedResponse, true);
    }

    public function testErrorStatusCanBeCheckedWhenAnErrorResponseIsReturned()
    {
        var graphResponse = '{"error":{"message":"Foo error.","type":"OAuthException","code":190,"error_subcode":463}}';
        var response = new FacebookResponse(this.request, graphResponse, 401);

        var exception = response.getThrownException();

        Assert.isTrue(response.isError(), 'Expected Response to return an error.');
        Assert.is(exception, FacebookResponseException);
    }
}