package fb.graph;

class GraphAlbum extends GraphNode
{
    /**
     * @var array Maps object key names to Graph object types.
     */
    static var graphObjectMap = {
        from: fb.graph.GraphUser,
        place: fb.graph.GraphPage,
    };

    /**
     * Returns the ID for the album.
     */
    public function getId( ) : String return this.getField('id');

    /**
     * Returns whether the viewer can upload photos to this album.
     */
    public function getCanUpload( ) : Bool return this.getField('can_upload');

    /**
     * Returns the number of photos in this album.
     */
    public function getCount( ) : Int return this.getField('count');

    /**
     * Returns the ID of the album's cover photo.
     */
    public function getCoverPhoto( ) : String return this.getField('cover_photo');

    /**
     * Returns the time the album was initially created.
     */
    public function getCreatedTime( ) : Date return this.getField('created_time');

    /**
     * Returns the time the album was updated.
     */
    public function getUpdatedTime( ) : Date return this.getField('updated_time');

    /**
     * Returns the description of the album.
     */
    public function getDescription( ) : String return this.getField('description');

    /**
     * Returns profile that created the album.
     */
    public function getFrom( ) : GraphUser return this.getField('from');

    /**
     * Returns profile that created the album.
     */
    public function getPlace( ) : GraphPage return this.getField('place');

    /**
     * Returns a link to this album on Facebook.
     */
    public function getLink( ) : String return this.getField('link');

    /**
     * Returns the textual location of the album.
     */
    public function getLocation( ) : String return this.getField('location');

    /**
     * Returns the title of the album.
     */
    public function getName( ) : String return this.getField('name');

    /**
     * Returns the privacy settings for the album.
     */
    public function getPrivacy( ) : String return this.getField('privacy');

    /**
     * Returns the type of the album.
     * enum{ profile, mobile, wall, normal, album }
     */
    public function getType( ) : String return this.getField('type');
}
