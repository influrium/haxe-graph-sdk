package fb.graph;

import fb.url.FacebookUrlManipulator;
import fb.error.FacebookSDKException;
import haxe.ds.StringMap;


class GraphEdge extends Collection
{
    /**
     * The original request that generated this data.
     */
    var request : FacebookRequest;

    /**
     * An array of Graph meta data like pagination, etc.
     */
    public var metaData (default, null) : Dynamic = {};

    /**
     * The parent Graph edge endpoint that generated the list.
     */
    public var parentEdgeEndpoint (default, null) : Null<String>;

    /**
     * The subclass of the child GraphNode's.
     */
    public var subclassName (default, null) : Null<Class<GraphNode>>;

    /**
     * Init this collection of GraphNode's.
     *
     * @param FacebookRequest $request            The original request that generated this data.
     * @param array           $data               An array of GraphNode's.
     * @param array           $metaData           An array of Graph meta data like pagination, etc.
     * @param string|null     $parentEdgeEndpoint The parent Graph edge endpoint that generated the list.
     * @param string|null     $subclassName       The subclass of the child GraphNode's.
     */
    public function new( request : FacebookRequest, ?data : Dynamic, ?metaData : {}, ?parentEdgeEndpoint : String, ?subclassName : Class<GraphNode> )
    {
        this.request = request;
        this.metaData = metaData;
        this.parentEdgeEndpoint = parentEdgeEndpoint;
        this.subclassName = subclassName;

        super(data);
    }

    /**
     * Returns the next cursor if it exists.
     */
    public function getNextCursor( ) : Null<String>
    {
        return getCursor(After);
    }

    /**
     * Returns the previous cursor if it exists.
     */
    public function getPreviousCursor( ) : Null<String>
    {
        return getCursor(Before);
    }

    /**
     * Returns the cursor for a specific direction if it exists.
     * @param string $direction The direction of the page: after|before
     */
    public function getCursor( direction : Cursor ) : Null<String>
    {
        return Reflect.field(metaData.paging.cursors, direction);
    }

    /**
     * Generates a pagination URL based on a cursor.
     * @param string $direction The direction of the page: next|previous
     */
    public function getPaginationUrl( direction : Pagination ) : Null<String>
    {
        validateForPagination();

        // Do we have a paging URL?
        var pageUrl = Reflect.field(metaData.paging, direction);
        if (pageUrl == null)
            return null;
        
        return FacebookUrlManipulator.baseGraphUrlEndpoint(pageUrl);
    }

    /**
     * Validates whether or not we can paginate on this request.
     */
    public function validateForPagination( ) : Void
    {
        if (request.method != 'GET')
            throw new FacebookSDKException('You can only paginate on a GET request.', 720);
    }

    /**
     * Gets the request object needed to make a next|previous page request.
     * @param string $direction The direction of the page: next|previous
     * @return Null<FacebookRequest>
     */
    public function getPaginationRequest( direction : Pagination ) : Null<FacebookRequest>
    {
        var pageUrl = getPaginationUrl(direction);
        if (pageUrl == null)
            return null;
        
        var newRequest = Reflect.copy(request);
        newRequest.setEndpoint(pageUrl);
        return newRequest;
    }

    /**
     * Gets the request object needed to make a "next" page request.
     * @return Null<FacebookRequest>
     */
    public function getNextPageRequest( ) : Null<FacebookRequest>
    {
        return getPaginationRequest(Next);
    }

    /**
     * Gets the request object needed to make a "previous" page request.
     * @return Null<FacebookRequest>
     */
    public function getPreviousPageRequest( ) : Null<FacebookRequest>
    {
        return getPaginationRequest(Previous);
    }

    /**
     * The total number of results according to Graph if it exists.
     * This will be returned if the summary=true modifier is present in the request.
     * @return Null<Int>
     */
    public function getTotalCount( ) : Null<Int>
    {
        return metaData.summary.total_count;
    }

    /**
     * @inheritDoc
     */
    public function map( callback : String->Dynamic->Dynamic )
    {
        return new GraphEdge(
            this.request,
            [for (k=>v in items.keyValueIterator()) k=>callback(k, v)],
            // array_map($callback, this.items, array_keys(this.items)),
            this.metaData,
            this.parentEdgeEndpoint,
            this.subclassName
        );
    }

}