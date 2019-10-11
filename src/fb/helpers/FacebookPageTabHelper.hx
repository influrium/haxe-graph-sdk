package fb.helpers;

class FacebookPageTabHelper extends FacebookCanvasHelper
{
    var pageData : Dynamic;

    /**
     * Initialize the helper and process available signed request data.
     *
     * @param FacebookApp    $app          The FacebookApp entity.
     * @param FacebookClient $client       The client to make HTTP requests.
     * @param string|null    $graphVersion The version of Graph to use.
     */
    public function new( app : FacebookApp, client : FacebookClient, ?graphVersion = null)
    {
        super(app, client, graphVersion);

        if (this.signedRequest == null)
            return;

        pageData = signedRequest.get('page');
    }

    /**
     * Returns a value from the page data.
     */
    public function getPageData<A>( key : String, ?def : A ) : A
    {
        return Reflect.hasField(pageData, key) ? Reflect.field(pageData, key) : def;
    }

    /**
     * Returns true if the user is an admin.
     */
    public function isAdmin( ) : Bool
    {
        return getPageData('admin') == true;
    }

    /**
     * Returns the page id if available.
     */
    public function getPageId( ) : String
    {
        return getPageData('id');
    }
}
