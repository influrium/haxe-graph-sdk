package fb.graph;

class GraphPage extends GraphNode
{
    /**
     * Maps object key names to Graph object types.
     */
    static var graphObjectMap = {
        best_page: fb.graph.GraphPage,
        global_brand_parent_page: fb.graph.GraphPage,
        location: fb.graph.GraphLocation,
        cover: fb.graph.GraphCoverPhoto,
        picture: fb.graph.GraphPicture,
    };

    /**
     * Returns the ID for the user's page as a string if present.
     */
    public function getId( ) : String return this.getField('id');

    /**
     * Returns the Category for the user's page as a string if present.
     */
    public function getCategory( ) : String return this.getField('category');

    /**
     * Returns the Name of the user's page as a string if present.
     */
    public function getName( ) : String return this.getField('name');

    /**
     * Returns the best available Page on Facebook.
     */
    public function getBestPage( ) : GraphPage return this.getField('best_page');

    /**
     * Returns the brand's global (parent) Page.
     */
    public function getGlobalBrandParentPage( ) : GraphPage return this.getField('global_brand_parent_page');

    /**
     * Returns the location of this place.
     */
    public function getLocation( ) : GraphLocation return this.getField('location');

    /**
     * Returns CoverPhoto of the Page.
     */
    public function getCover( ) : GraphCoverPhoto return this.getField('cover');

    /**
     * Returns Picture of the Page.
     */
    public function getPicture( ) : GraphPicture return this.getField('picture');

    /**
     * Returns the page access token for the admin user.
     * Only available in the `/me/accounts` context.
     */
    public function getAccessToken( ) : String return this.getField('access_token');

    /**
     * Returns the roles of the page admin user.
     * Only available in the `/me/accounts` context.
     */
    public function getPerms( ) : Array<String> return this.getField('perms');

    /**
     * Returns the `fan_count` (Number of people who likes to page) as int if present.
     */
    public function getFanCount( ) : Int return this.getField('fan_count');
}
