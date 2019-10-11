package fixtures;


import fb.FacebookClient;
import fb.FacebookResponse;
import fb.FacebookRequest;

class FooFacebookClientForOAuth2Test extends FacebookClient
{
    var response = '';

    public function setMetadataResponse( )
    {
        response = '{"data":{"user_id":"444"}}';
    }

    public function setAccessTokenResponse( )
    {
        response = '{"access_token":"my_access_token","expires":"1422115200"}';
    }

    public function setCodeResponse( )
    {
        response = '{"code":"my_neat_code"}';
    }

    override public function sendRequest( request : FacebookRequest ) : FacebookResponse
    {
        return new FacebookResponse(
            request,
            response,
            200
        );
    }
}