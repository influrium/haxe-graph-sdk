package fb.helpers;

class FacebookCanvasHelper extends FacebookSignedRequestFromInputHelper
{
    /**
     * Returns the app data value.
     */
    public function getAppData( ) : Dynamic
    {
        return signedRequest != null ? signedRequest.get('app_data') : null;
    }

    /**
     * Get raw signed request from POST.
     */
    override public function getRawSignedRequest( ) : String
    {
        return getRawSignedRequestFromPost();
    }
}
