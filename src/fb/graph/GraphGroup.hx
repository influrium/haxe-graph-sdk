package fb.graph;

class GraphGroup extends GraphNode
{
    /**
     * @var array Maps object key names to GraphNode types.
     */
    static var graphObjectMap = {
        cover: fb.graph.GraphCoverPhoto,
        venue: fb.graph.GraphLocation,
    };

    /**
     * Returns the `id` (The Group ID) as string if present.
     */
    public function getId( ) : String return this.getField('id');

    /**
     * Returns the `cover` (The cover photo of the Group) as GraphCoverPhoto if present.
     */
    public function getCover( ) : GraphCoverPhoto return this.getField('cover');

    /**
     * Returns the `description` (A brief description of the Group) as string if present.
     */
    public function getDescription( ) : String return this.getField('description');

    /**
     * Returns the `email` (The email address to upload content to the Group. Only current members of the Group can use this) as string if present.
     */
    public function getEmail( ) : String return this.getField('email');

    /**
     * Returns the `icon` (The URL for the Group's icon) as string if present.
     */
    public function getIcon( ) : String return this.getField('icon');

    /**
     * Returns the `link` (The Group's website) as string if present.
     */
    public function getLink( ) : String return this.getField('link');

    /**
     * Returns the `name` (The name of the Group) as string if present.
     */
    public function getName( ) : String return this.getField('name');

    /**
     * Returns the `member_request_count` (Number of people asking to join the group.) as int if present.
     */
    public function getMemberRequestCount( ) : Int return this.getField('member_request_count');

    /**
     * Returns the `owner` (The profile that created this Group) as GraphNode if present.
     */
    public function getOwner( ) : GraphNode return this.getField('owner');

    /**
     * Returns the `parent` (The parent Group of this Group, if it exists) as GraphNode if present.
     */
    public function getParent( ) : GraphNode return this.getField('parent');

    /**
     * Returns the `privacy` (The privacy setting of the Group) as string if present.
     */
    public function getPrivacy( ) : String return this.getField('privacy');

    /**
     * Returns the `updated_time` (The last time the Group was updated (this includes changes in the Group's properties and changes in posts and comments if user can see them)) as \DateTime if present.
     */
    public function getUpdatedTime( ) : Date return this.getField('updated_time');

    /**
     * Returns the `venue` (The location for the Group) as GraphLocation if present.
     */
    public function getVenue( ) : GraphLocation return this.getField('venue');
}
