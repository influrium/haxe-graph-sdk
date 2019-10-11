package fb.graph;

class GraphLocation extends GraphNode
{
    /**
     * Returns the street component of the location
     */
    public function getStreet( ) : String return this.getField('street');

    /**
     * Returns the city component of the location
     */
    public function getCity( ) : String return this.getField('city');

    /**
     * Returns the state component of the location
     */
    public function getState( ) : String return this.getField('state');

    /**
     * Returns the country component of the location
     */
    public function getCountry( ) : String return this.getField('country');

    /**
     * Returns the zipcode component of the location
     */
    public function getZip( ) : String return this.getField('zip');

    /**
     * Returns the latitude component of the location
     */
    public function getLatitude( ) : Float return this.getField('latitude');

    /**
     * Returns the street component of the location
     */
    public function getLongitude( ) : Float return this.getField('longitude');
}
