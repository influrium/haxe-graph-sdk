package fixtures;

import fb.FacebookResponse;
import haxe.Json;
import fb.FacebookRequest;
import fb.FacebookClient;

class FooSignedRequestHelperFacebookClient extends FacebookClient
{
    override public function sendRequest( request : FacebookRequest )
    {
        var params = request.getParams();
        var rawResponse = Json.stringify({
            access_token: 'foo_access_token_from:' + params['code'],
        });

        return new FacebookResponse(request, rawResponse, 200);
    }
}