package fb.graph;

/**
 * Birthday object to handle various Graph return formats
 * @package Facebook
 */
class Birthday
{
    var date : Date;

    public var hasDate (default, null) : Bool = false;

    public var hasYear (default, null) : Bool = false;

    /**
     * Parses Graph birthday format to set indication flags, possible values:
     *  MM/DD/YYYY
     *  MM/DD
     *  YYYY
     * @link https://developers.facebook.com/docs/graph-api/reference/user
     */
    public function new( date : String )
    {
        var parts = date.split('/');

        hasYear = parts.length == 3 || parts.length == 1;
        hasDate = parts.length == 3 || parts.length == 2;

        this.date = Date.fromString(date);
    }
}
