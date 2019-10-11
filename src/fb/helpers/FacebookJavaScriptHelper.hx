package fb.helpers;

class FacebookJavaScriptHelper extends FacebookSignedRequestFromInputHelper
{
    /**
     * Get raw signed request from the cookie.
     */
    override public function getRawSignedRequest( ) : String
    {
        return getRawSignedRequestFromCookie();
    }
}
