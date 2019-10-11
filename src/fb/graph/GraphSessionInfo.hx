package fb.graph;

class GraphSessionInfo extends GraphNode
{
    /**
     * Returns the application id the token was issued for.
     */
    public function getAppId( ) : String return this.getField('app_id');

    /**
     * Returns the application name the token was issued for.
     */
    public function getApplication( ) : String return this.getField('application');

    /**
     * Returns the date & time that the token expires.
     */
    public function getExpiresAt( ) : Date return this.getField('expires_at');

    /**
     * Returns whether the token is valid.
     */
    public function getIsValid( ) : Bool return this.getField('is_valid');

    /**
     * Returns the date & time the token was issued at.
     */
    public function getIssuedAt( ) : Date return this.getField('issued_at');

    /**
     * Returns the scope permissions associated with the token.
     */
    public function getScopes( ) : Array<String> return this.getField('scopes');

    /**
     * Returns the login id of the user associated with the token.
     */
    public function getUserId( ) : String return this.getField('user_id');
}
