package cases.graph;

import utest.Assert;

import fb.FacebookRequest;
import fb.FacebookApp;
import fb.GraphVersion;
import fb.graph.GraphEdge;
import fb.graph.GraphNode;
import fb.error.FacebookSDKException;
import fb.util.Params;

using StringTools;

class GraphEdgeTest extends utest.Test
{
    var request : FacebookRequest;

    var pagination = {
        next: 'https://graph.facebook.com/v7.12/998899/photos?pretty=0&limit=25&after=foo_after_cursor',
        previous: 'https://graph.facebook.com/v7.12/998899/photos?pretty=0&limit=25&before=foo_before_cursor',
    };

    function setup( )
    {
        var app = new FacebookApp('123', 'foo_app_secret');
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

    public function testNonGetRequestsWillThrow( )
    {
        Assert.raises(function (){
            this.request.setMethod('POST');
            var graphEdge = new GraphEdge(this.request);
            graphEdge.validateForPagination();
        }, FacebookSDKException);
    }

    public function testCanReturnGraphGeneratedPaginationEndpoints()
    {
        var graphEdge = new GraphEdge(
            this.request,
            [],
            {paging: this.pagination}
        );
        var nextPage = graphEdge.getPaginationUrl(Next);
        var prevPage = graphEdge.getPaginationUrl(Previous);

        Assert.equals('/998899/photos?pretty=0&limit=25&after=foo_after_cursor', nextPage);
        Assert.equals('/998899/photos?pretty=0&limit=25&before=foo_before_cursor', prevPage);
    }

    public function testCanInstantiateNewPaginationRequest()
    {
        var graphEdge = new GraphEdge(
            this.request,
            [],
            {paging: this.pagination},
            '/1234567890/likes'
        );
        var nextPage = graphEdge.getNextPageRequest();
        var prevPage = graphEdge.getPreviousPageRequest();

        Assert.is(nextPage, FacebookRequest);
        Assert.is(prevPage, FacebookRequest);
        Assert.notEquals(this.request, nextPage);
        Assert.notEquals(this.request, prevPage);
        Assert.equals('/v1337/998899/photos?access_token=foo_token&after=foo_after_cursor&appsecret_proof=857d5f035a894f16b4180f19966e055cdeab92d4d53017b13dccd6d43b6497af&foo=bar&limit=25&pretty=0', nextPage.getUrl());
        Assert.equals('/v1337/998899/photos?access_token=foo_token&appsecret_proof=857d5f035a894f16b4180f19966e055cdeab92d4d53017b13dccd6d43b6497af&before=foo_before_cursor&foo=bar&limit=25&pretty=0', prevPage.getUrl());

/*
        expected
        "/v1337/998899/photos?access_token=foo_token&appsecret_proof=857d5f035a894f16b4180f19966e055cdeab92d4d53017b13dccd6d43b6497af&before=foo_before_cursor&foo=bar&limit=25&pretty=0"
        but it is
        "/v1337/998899/photos?limit=25&appsecret_proof=857d5f035a894f16b4180f19966e055cdeab92d4d53017b13dccd6d43b6497af&pretty=0&access_token=foo_token&before=foo_before_cursor&foo=bar"
*/
    }

    public function testCanMapOverNodes( )
    {
        var graphEdge = new GraphEdge(
            this.request,
            [
                new GraphNode(['name' => 'dummy']),
                new GraphNode(['name' => 'dummy']),
            ],
            {paging: this.pagination},
            '/1234567890/likes'
        );

        var graphEdge = graphEdge.map(function ( key : String, node : GraphNode ) {
            node.set('name', cast(node.get('name'), String).replace('dummy', 'foo'));
            return node;
        });

        var graphEdgeToCompare = new GraphEdge(
            this.request,
            [
                new GraphNode(['name' => 'foo']),
                new GraphNode(['name' => 'foo'])
            ],
            {paging: this.pagination},
            '/1234567890/likes'
        );

        Assert.same(graphEdgeToCompare, graphEdge, true);
    }
}