package fb.graph;

class GraphCoverPhoto extends GraphNode
{
    /**
     * Returns the id of cover if it exists
     */
    public function getId( ) : Int return this.getField('id');
    
    /**
     * Returns the source of cover if it exists
     */
    public function getSource( ) : String return this.getField('source');

    /**
     * Returns the offset_x of cover if it exists
     */
    public function getOffsetX( ) : Int return this.getField('offset_x');

    /**
     * Returns the offset_y of cover if it exists
     */
    public function getOffsetY( ) : Int return this.getField('offset_y');
}
