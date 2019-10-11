package fixtures;

import fb.auth.AccessToken;
import fb.auth.OAuth2Client;

class FooRedirectLoginOAuth2Client extends OAuth2Client
{
    override public function getAccessTokenFromCode( code : String, redirectUri : String = '' ) : AccessToken
    {
        return new AccessToken('foo_token_from_code|' + code + '|' + redirectUri);
    }
}