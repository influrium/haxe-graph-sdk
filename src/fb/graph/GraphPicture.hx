package fb.graph;

class GraphPicture extends GraphNode
{
    /**
     * Returns true if user picture is silhouette.
     */
    public function isSilhouette( ) : Bool return this.getField('is_silhouette');

    /**
     * Returns the url of user picture if it exists
     */
    public function getUrl( ) : String return this.getField('url');

    /**
     * Returns the width of user picture if it exists
     */
    public function getWidth( ) : Int return this.getField('width');

    /**
     * Returns the height of user picture if it exists
     */
    public function getHeight( ) : Int return this.getField('height');
}
