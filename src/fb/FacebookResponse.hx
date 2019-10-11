package fb;

import haxe.CallStack;
import haxe.Json;
import haxe.ds.StringMap;

import fb.error.*;
import fb.graph.*;
import fb.util.UrlTools;


class FacebookResponse
{
    /**
     * The HTTP status code response from Graph.
     */
    public var httpStatusCode (default, null) : Int;

    /**
     * The headers returned from Graph.
     */
    public var headers (default, null) : StringMap<String>;

    /**
     * The raw body of the response from Graph.
     */
    public var body (default, null) : String;

    /**
     * The decoded body of the Graph response.
     */
    public var decodedBody (default, null) : Dynamic;

    /**
     * The original request that returned this response.
     */
    public var request (default, null) : FacebookRequest;

    /**
     * The exception thrown by this request.
     */
    var thrownException : FacebookResponseException;

    /**
     * Creates a new Response entity.
     *
     * @param FacebookRequest $request
     * @param string|null     $body
     * @param int|null        $httpStatusCode
     * @param array|null      $headers
     */
    public function new( request : FacebookRequest, ?body : String, ?httpStatusCode : Int, ?headers : StringMap<String> )
    {
        this.request = request;
        this.body = body;
        this.httpStatusCode = httpStatusCode;
        this.headers = headers;

        decodeBody();
    }

    /**
     * Return the FacebookApp entity used for this response.
     * @return FacebookApp
     */
    public function getApp( ) : FacebookApp return request.app;

    /**
     * Return the access token that was used for this response.
     * @return Null<String>
     */
    public function getAccessToken( ) : Null<String> return request.accessToken;

    /**
     * Get the app secret proof that was used for this response.
     * @return Null<String>
     */
    public function getAppSecretProof( ) : Null<String> return request.getAppSecretProof();

    /**
     * Get the ETag associated with the response.
     * @return Null<String>
     */
    public function getETag( ) : Null<String> return headers.get('ETag');

    /**
     * Get the version of Graph that returned this response.
     * @return Null<String>
     */
    public function getGraphVersion( ) : Null<String> return headers.get('Facebook-API-Version');

    /**
     * Returns true if Graph returned an error message.
     * @return Bool
     */
    public function isError( ) : Bool return Reflect.hasField(decodedBody, 'error');

    /**
     * Throws the exception.
     * @throws FacebookSDKException
     */
    public function throwException( ) : Void throw thrownException;

    /**
     * Instantiates an exception to be thrown later.
     */
    public function makeException( ) : Void thrownException = FacebookResponseException.create(this);

    /**
     * Returns the exception that was thrown for this request.
     * @return Null<FacebookResponseException>
     */
    public function getThrownException( ) : Null<FacebookResponseException> return thrownException;

    /**
     * Convert the raw response into an array if possible.
     *
     * Graph will return 2 types of responses:
     * - JSON(P)
     *    Most responses from Graph are JSON(P)
     * - application/x-www-form-urlencoded key/value pairs
     *    Happens on the `/oauth/access_token` endpoint when exchanging
     *    a short-lived access token for a long-lived access token
     * - And sometimes nothing :/ but that'd be a bug.
     */
    public function decodeBody( ) : Void
    {
        if (body == null)
        {
            decodedBody = {};
            return;
        }

        try decodedBody = Json.parse(body) catch(e:Dynamic) { /*trace(e, body);*/ };

        if (decodedBody == null)
            decodedBody = UrlTools.queryparse(body);
        
        else if (Std.is(decodedBody, Bool))
            // Backwards compatibility for Graph < 2.1.
            // Mimics 2.1 responses.
            // @TODO Remove this after Graph 2.0 is no longer supported
            decodedBody = {success: decodedBody};
        
        else if (Std.is(decodedBody, Int))
            decodedBody = {id: decodedBody};


        if (!Std.is(decodedBody, Dynamic))
            decodedBody = {};
        
        if (isError())
            makeException();
    }

    /**
     * Instantiate a new GraphObject from response.
     * @param subclassName The GraphNode subclass to cast to.
     * @return GraphObject
     * @deprecated 5.0.0 getGraphObject() has been renamed to getGraphNode()
     * @todo v6: Remove this method
     * TODO: [v6] Remove this method
     */
    inline public function getGraphObject( ?subclassName : Class<GraphNode> ) : GraphObject  return cast(getGraphNode(subclassName), GraphObject);

    /**
     * Instantiate a new GraphNode from response.
     * @param subclassName 
     * @return GraphNode
     */
    inline public function getGraphNode( ?subclassName : Class<GraphNode> ) : GraphNode return (new GraphNodeFactory(this)).makeGraphNode(subclassName);

    /**
     * Convenience method for creating a GraphAlbum collection.
     * @return GraphAlbum
     */
    inline public function getGraphAlbum( ) : GraphAlbum return (new GraphNodeFactory(this)).makeGraphAlbum();

    /**
     * Convenience method for creating a GraphPage collection.
     * @return GraphPage
     */
    inline public function getGraphPage( ) : GraphPage return (new GraphNodeFactory(this)).makeGraphPage();

    /**
     * Convenience method for creating a GraphSessionInfo collection.
     * @return GraphSessionInfo
     */
    inline public function getGraphSessionInfo( ) : GraphSessionInfo return (new GraphNodeFactory(this)).makeGraphSessionInfo();

    /**
     * Convenience method for creating a GraphUser collection.
     * @return GraphUser
     */
    inline public function getGraphUser( ) : GraphUser return (new GraphNodeFactory(this)).makeGraphUser();

    /**
     * Convenience method for creating a GraphEvent collection.
     * @return GraphEvent
     */
    inline public function getGraphEvent( ) : GraphEvent return (new GraphNodeFactory(this)).makeGraphEvent();

    /**
     * Convenience method for creating a GraphGroup collection.
     * @return \Facebook\GraphNodes\GraphGroup
     */
    inline public function getGraphGroup( ) : GraphGroup return (new GraphNodeFactory(this)).makeGraphGroup();

    /**
     * Instantiate a new GraphList from response.
     * @param subclassName The GraphNode subclass to cast list items to.
     * @param auto_prefix  Toggle to auto-prefix the subclass name.
     * @return GraphList
     * @deprecated 5.0.0 getGraphList() has been renamed to getGraphEdge()
     * @todo v6: Remove this method
     * TODO: [v6] Remove this method
     */
    inline public function getGraphList( ?subclassName : Class<GraphNode>, ?auto_prefix : Bool = true ) : GraphList return cast(getGraphEdge(subclassName, auto_prefix), GraphList);
    
    /**
     * Instantiate a new GraphEdge from response.
     * @param subclassName The GraphNode subclass to cast list items to.
     * @param auto_prefix  Toggle to auto-prefix the subclass name.
     * @return GraphEdge
     */
    inline public function getGraphEdge( ?subclassName : Class<GraphNode>, ?auto_prefix : Bool = true ) : GraphEdge return (new GraphNodeFactory(this)).makeGraphEdge(subclassName, auto_prefix);
}