package fixtures;

import fb.helpers.FacebookSignedRequestFromInputHelper;


class FooSignedRequestHelper extends FacebookSignedRequestFromInputHelper
{
    override public function getRawSignedRequest( )
    {
        return null;
    }
}