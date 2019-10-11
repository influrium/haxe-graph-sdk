package fb.graph;

class GraphEvent extends GraphNode
{
    /**
     * @var array Maps object key names to GraphNode types.
     */
    static var graphObjectMap = {
        cover: fb.graph.GraphCoverPhoto,
        place: fb.graph.GraphPage,
        picture: fb.graph.GraphPicture,
        parent_group: fb.graph.GraphGroup,
    };

    /**
     * Returns the `id` (The event ID) as string if present.
     */
    public function getId( ) : String return this.getField('id');

    /**
     * Returns the `cover` (Cover picture) as GraphCoverPhoto if present.
     */
    public function getCover( ) : GraphCoverPhoto return this.getField('cover');

    /**
     * Returns the `description` (Long-form description) as string if present.
     */
    public function getDescription( ) : String return this.getField('description');

    /**
     * Returns the `end_time` (End time, if one has been set) as DateTime if present.
     */
    public function getEndTime( ) : Date return this.getField('end_time');

    /**
     * Returns the `is_date_only` (Whether the event only has a date specified, but no time) as bool if present.
     */
    public function getIsDateOnly( ) : Bool return this.getField('is_date_only');

    /**
     * Returns the `name` (Event name) as string if present.
     */
    public function getName( ) : String return this.getField('name');

    /**
     * Returns the `owner` (The profile that created the event) as GraphNode if present.
     */
    public function getOwner( ) : GraphNode return this.getField('owner');

    /**
     * Returns the `parent_group` (The group the event belongs to) as GraphGroup if present.
     */
    public function getParentGroup( ) : GraphGroup return this.getField('parent_group');

    /**
     * Returns the `place` (Event Place information) as GraphPage if present.
     */
    public function getPlace( ) : GraphPage return this.getField('place');

    /**
     * Returns the `privacy` (Who can see the event) as string if present.
     */
    public function getPrivacy( ) : String return this.getField('privacy');

    /**
     * Returns the `start_time` (Start time) as DateTime if present.
     */
    public function getStartTime( ) : Date return this.getField('start_time');

    /**
     * Returns the `ticket_uri` (The link users can visit to buy a ticket to this event) as string if present.
     */
    public function getTicketUri( ) : String return this.getField('ticket_uri');

    /**
     * Returns the `timezone` (Timezone) as string if present.
     */
    public function getTimezone( ) : String return this.getField('timezone');

    /**
     * Returns the `updated_time` (Last update time) as DateTime if present.
     */
    public function getUpdatedTime( ) : Date return this.getField('updated_time');

    /**
     * Returns the `picture` (Event picture) as GraphPicture if present.
     */
    public function getPicture( ) : GraphPicture return this.getField('picture');

    /**
     * Returns the `attending_count` (Number of people attending the event) as int if present.
     */
    public function getAttendingCount( ) : Int return this.getField('attending_count');

    /**
     * Returns the `declined_count` (Number of people who declined the event) as int if present.
     */
    public function getDeclinedCount( ) : Int return this.getField('declined_count');

    /**
     * Returns the `maybe_count` (Number of people who maybe going to the event) as int if present.
     */
    public function getMaybeCount( ) : Int  return this.getField('maybe_count');

    /**
     * Returns the `noreply_count` (Number of people who did not reply to the event) as int if present.
     */
    public function getNoreplyCount( ) : Int return this.getField('noreply_count');

    /**
     * Returns the `invited_count` (Number of people invited to the event) as int if present.
     */
    public function getInvitedCount( ) : Int return this.getField('invited_count');
}
