package fb.graph;

class GraphAchievement extends GraphNode
{
    /**
     * Maps object key names to Graph object types.
     */
    static var graphObjectMap = {
        from: fb.graph.GraphUser,
        application: fb.graph.GraphApplication,
    };

    /**
     * Returns the ID for the achievement.
     */
    public function getId( ) : String return this.getField('id');

    /**
     * Returns the user who achieved this.
     */
    public function getFrom( ) : GraphUser return this.getField('from');

    /**
     * Returns the time at which this was achieved.
     */
    public function getPublishTime( ) : Date return this.getField('publish_time');

    /**
     * Returns the app in which the user achieved this.
     *
     * @return GraphApplication|null
     */
    public function getApplication( ) : GraphApplication return this.getField('application');

    /**
     * Returns information about the achievement type this instance is connected with.
     */
    public function getData( ) : Dynamic return this.getField('data');

    /**
     * Returns the type of achievement.
     * @see https://developers.facebook.com/docs/graph-api/reference/achievement
     */
    public function getType( ) : String return 'game.achievement';

    /**
     * Indicates whether gaining the achievement published a feed story for the user.
     */
    public function isNoFeedStory( ) : Bool return this.getField('no_feed_story');
}
