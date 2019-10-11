package fb.graph;

class GraphUser extends GraphNode
{
    /**
     * Maps object key names to Graph object types.
     */
    static var graphObjectMap = {
        hometown: GraphPage,
        location: GraphPage,
        significant_other: GraphUser,
        picture:  GraphPicture,
    };

    /**
     * Returns the ID for the user as a string if present.
     */
    public function getId( ) : String return this.getField('id');

    /**
     * Returns the name for the user as a string if present.
     */
    public function getName( ) : String return this.getField('name');

    /**
     * Returns the first name for the user as a string if present.
     */
    public function getFirstName( ) : String return this.getField('first_name');

    /**
     * Returns the middle name for the user as a string if present.
     */
    public function getMiddleName( ) : String return this.getField('middle_name');

    /**
     * Returns the last name for the user as a string if present.
     */
    public function getLastName( ) : String return this.getField('last_name');

    /**
     * Returns the email for the user as a string if present.
     */
    public function getEmail( ) : String return this.getField('email');

    /**
     * Returns the gender for the user as a string if present.
     */
    public function getGender( ) : String return this.getField('gender');

    /**
     * Returns the Facebook URL for the user as a string if available.
     */
    public function getLink( ) : String return this.getField('link');

    /**
     * Returns the users birthday, if available.
     */
    public function getBirthday( ) : Birthday return this.getField('birthday');

    /**
     * Returns the current location of the user as a GraphPage.
     */
    public function getLocation( ) : GraphPage return this.getField('location');

    /**
     * Returns the current location of the user as a GraphPage.
     */
    public function getHometown( ) : GraphPage return this.getField('hometown');

    /**
     * Returns the current location of the user as a GraphUser.
     */
    public function getSignificantOther( ) : GraphUser return this.getField('significant_other');

    /**
     * Returns the picture of the user as a GraphPicture
     */
    public function getPicture( ) : GraphPicture return this.getField('picture');
}
