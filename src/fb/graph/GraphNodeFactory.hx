package fb.graph;

import fb.util.ObjectTools;
import haxe.ds.StringMap;
import fb.error.*;

/**
 * Class GraphNodeFactory
 *
 * ## Assumptions ##
 * GraphEdge - is ALWAYS a numeric array
 * GraphEdge - is ALWAYS an array of GraphNode types
 * GraphNode - is ALWAYS an associative array
 * GraphNode - MAY contain GraphNode's "recurrable"
 * GraphNode - MAY contain GraphEdge's "recurrable"
 * GraphNode - MAY contain DateTime's "primitives"
 * GraphNode - MAY contain string's "primitives"
 */
class GraphNodeFactory
{
    /**
     * The base graph object class.
     */
    inline public static var BASE_GRAPH_NODE_CLASS = fb.graph.GraphNode;
    /**
     * The base graph edge class.
     */
    inline public static var BASE_GRAPH_EDGE_CLASS = fb.graph.GraphEdge;
    /**
     * The graph object prefix.
     */
    // inline public static var BASE_GRAPH_OBJECT_PREFIX = 'fb.graph.';

    /**
     * The response entity from Graph.
     */
    var response : FacebookResponse;
    /**
     * The decoded body of the FacebookResponse entity from Graph.
     */
    var decodedBody : Dynamic;

    /**
     * Init this Graph object.
     * @param FacebookResponse $response The response entity from Graph.
     */
    public function new( response : FacebookResponse )
    {
        this.response = response;
        this.decodedBody = response.decodedBody;
    }

    /**
     * Tries to convert a FacebookResponse entity into a GraphNode.
     * @param string|null $subclassName The GraphNode sub class to cast to.
     * @return GraphNode
     */
    public function makeGraphNode<A>( ?subclassName : Class<GraphNode> ) : A
    {
        validateResponseAsArray();
        validateResponseCastableAsGraphNode();

        return castAsGraphNodeOrGraphEdge(decodedBody, subclassName);
    }

    /**
     * Convenience method for creating a GraphAchievement collection.
     * @return GraphAchievement
     */
    public function makeGraphAchievement( ) : GraphAchievement
    {
        return makeGraphNode(GraphAchievement);
    }

    /**
     * Convenience method for creating a GraphAlbum collection.
     * @return GraphAlbum
     */
    public function makeGraphAlbum( ) : GraphAlbum
    {
        return makeGraphNode(GraphAlbum);
    }

    /**
     * Convenience method for creating a GraphPage collection.
     * @return GraphPage
     */
    public function makeGraphPage( ) : GraphPage
    {
        return makeGraphNode(GraphPage);
    }

    /**
     * Convenience method for creating a GraphSessionInfo collection.
     * @return GraphSessionInfo
     */
    public function makeGraphSessionInfo( ) : GraphSessionInfo
    {
        return makeGraphNode(GraphSessionInfo);
    }

    /**
     * Convenience method for creating a GraphUser collection.
     * @return GraphUser
     */
    public function makeGraphUser( ) : GraphUser
    {
        return makeGraphNode(GraphUser);
    }

    /**
     * Convenience method for creating a GraphEvent collection.
     * @return GraphEvent
     */
    public function makeGraphEvent( ) : GraphEvent
    {
        return makeGraphNode(GraphEvent);
    }

    /**
     * Convenience method for creating a GraphGroup collection.
     * @return GraphGroup
     */
    public function makeGraphGroup( ) : GraphGroup
    {
        return makeGraphNode(GraphGroup);
    }

    /**
     * Tries to convert a FacebookResponse entity into a GraphEdge.
     * @param string|null $subclassName The GraphNode sub class to cast the list items to.
     * @param boolean     $auto_prefix  Toggle to auto-prefix the subclass name.
     * @return GraphEdge
     */
    public function makeGraphEdge( ?subclassName : Class<GraphNode>, auto_prefix : Bool = true ) : GraphEdge
    {
        validateResponseAsArray();
        validateResponseCastableAsGraphEdge();

        // if (subclassName != null && auto_prefix) subclassName = BASE_GRAPH_OBJECT_PREFIX + subclassName;
        return castAsGraphNodeOrGraphEdge(decodedBody, subclassName);
    }

    /**
     * Validates the decoded body.
     * @throws FacebookSDKException
     */
    public function validateResponseAsArray( ) : Void
    {
        if (!Std.is(decodedBody, Dynamic))
            throw new FacebookSDKException('Unable to get response from Graph as array.', 620);
    }

    /**
     * Validates that the return data can be cast as a GraphNode.
     */
    public function validateResponseCastableAsGraphNode( ) : Void
    {
        if (decodedBody.data != null && isCastableAsGraphEdge(decodedBody.data))
            throw new FacebookSDKException('Unable to convert response from Graph to a GraphNode because the response looks like a GraphEdge. Try using GraphNodeFactory.makeGraphEdge() instead.', 620);
    }

    /**
     * Validates that the return data can be cast as a GraphEdge.
     */
    public function validateResponseCastableAsGraphEdge( )
    {
        if ( !(decodedBody.data != null && isCastableAsGraphEdge(decodedBody.data)) )
            throw new FacebookSDKException('Unable to convert response from Graph to a GraphEdge because the response does not look like a GraphEdge. Try using GraphNodeFactory::makeGraphNode() instead.', 620);
    }

    /**
     * Safely instantiates a GraphNode of $subclassName.
     * @param array       $data         The array of data to iterate over.
     * @param string|null $subclassName The subclass to cast this collection to.
     * @return GraphNode
     */
    public function safelyMakeGraphNode( data : Dynamic, ?subCls : Class<GraphNode> ) : Dynamic
    {
        subCls = subCls != null ? subCls : BASE_GRAPH_NODE_CLASS;
        validateSubclass(subCls);

        // Remember the parent node ID
        var parentNodeId = data.id != null ? data.id : null;

        var graphObjectMap : Dynamic<Class<GraphNode>> = Reflect.field(subCls, 'graphObjectMap');
        // var graphObjectMap = subclassName.getObjectMap();

        var items = new StringMap();
        for (k in Reflect.fields(data))
        {
            var v = Reflect.field(data, k);

            // Array means could be recurable
            if (Std.is(v, Array))
            {
                // Detect any smart-casting from the $graphObjectMap array.
                // This is always empty on the GraphNode collection,
                // but subclasses can define their own array of smart-casting types.
                var objectSubClass : Class<GraphNode> = Reflect.field(graphObjectMap, k);

                // Could be a GraphEdge or GraphNode
                var g = castAsGraphNodeOrGraphEdge(v, objectSubClass, k, parentNodeId);
                items.set(k, g);
            }
            else
                items.set(k, v);
        }

        var inst = Type.createInstance(subCls, [items]);

        return inst;
    }

    /**
     * Takes an array of values and determines how to cast each node.
     * @param array       $data         The array of data to iterate over.
     * @param string|null $subclassName The subclass to cast this collection to.
     * @param string|null $parentKey    The key of this data (Graph edge).
     * @param string|null $parentNodeId The parent Graph node ID.
     * @return GraphNode|GraphEdge
     */
    public function castAsGraphNodeOrGraphEdge( data : Dynamic, ?subclassName : Class<GraphNode>, ?parentKey : String, ?parentNodeId : String ) : Dynamic
    {
        if (data.data != null)
        {
            // Create GraphEdge
            if (isCastableAsGraphEdge(data.data))
                return safelyMakeGraphEdge(data, subclassName, parentKey, parentNodeId);
            
            // Sometimes Graph is a weirdo and returns a GraphNode under the "data" key
            var outerData = Reflect.copy(data);
            Reflect.deleteField(outerData, 'data');
            
            data = ObjectTools.append(data.data, outerData);
        }
        // Create GraphNode
        return safelyMakeGraphNode(data, subclassName);
    }

    /**
     * Return an array of GraphNode's.
     * @param array       $data         The array of data to iterate over.
     * @param string|null $subclassName The GraphNode subclass to cast each item in the list to.
     * @param string|null $parentKey    The key of this data (Graph edge).
     * @param string|null $parentNodeId The parent Graph node ID.
     * @return GraphEdge
     */
    public function safelyMakeGraphEdge( data : Dynamic, ?subCls : Class<GraphNode>, ?parentKey : String, ?parentNodeId : String ) : GraphEdge
    {
        if (data.data == null)
            throw new FacebookSDKException('Cannot cast data to GraphEdge. Expected a "data" key.', 620);

        var dataList = [];
        var nodesData : Array<Dynamic> = data.data;
        for (graphNodeData in nodesData)
            dataList.push(safelyMakeGraphNode(graphNodeData, subCls));

        var metaData = getMetaData(data);
        
        // We'll need to make an edge endpoint for this in case it's a GraphEdge (for cursor pagination)
        var parentGraphEdgeEndpoint = parentNodeId != null && parentKey != null ? '/' + parentNodeId + '/' + parentKey : null;

        return Type.createInstance(BASE_GRAPH_EDGE_CLASS, [response.request, dataList, metaData, parentGraphEdgeEndpoint, subCls]);
    }

    /**
     * Get the meta data from a list in a Graph response.
     * @param data The Graph response.
     */
    public function getMetaData( data : Dynamic ) : Dynamic
    {
        Reflect.deleteField(data, 'data');
        return data;
    }

    /**
     * Determines whether or not the data should be cast as a GraphEdge.
     * @param data
     * @return Bool
     */
    public static function isCastableAsGraphEdge( data : Dynamic ) : Bool
    {
        return Std.is(data, Array);
        // Checks for a sequential numeric array which would be a GraphEdge
        // return Reflect.fields(data) ==  array_keys($data) === range(0, count($data) - 1);
    }

    /**
     * Ensures that the subclass in question is valid.
     * @param string $subclassName The GraphNode subclass to validate.
     */
    public static function validateSubclass( subclassName : Class<GraphNode> ) : Void
    {
        if (subclassName == BASE_GRAPH_NODE_CLASS || is_subclass_of(subclassName, BASE_GRAPH_NODE_CLASS))
            return;

        throw new FacebookSDKException('The given subclass "$subclassName" is not valid. Cannot cast to an object that is not a GraphNode subclass.', 620);
    }

    static function is_subclass_of( subCls : Class<Dynamic>, cls : Class<GraphNode> ) : Bool
    {
        if (subCls == cls)
            return true;
        
        while ((subCls = Type.getSuperClass(subCls)) != null)
        {
            if( subCls == cls )
                return true;
        }
        return false;
    }
}