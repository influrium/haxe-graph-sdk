package fb;

import haxe.Serializer;
import haxe.Unserializer;

import fb.auth.AccessToken;


class FacebookApp
{
    /**
     * The app ID.
     */
    public var id(default, null) : String;

    /**
     * The app secret.
     */
    public var secret(default, null) : String;

    public function new( id : String, secret : String )
    {
        this.id = id;
        this.secret = secret;
    }

    /**
     * Returns an app access token.
     * @return AccessToken
     */
    public function getAccessToken() : AccessToken
    {
        return new AccessToken('$id|$secret');
    }

    /**
     * Serializes the FacebookApp entity as a string.
     * @return String
     */
    public function serialize( ) : String
    {
        return [id, secret].join('|');
    }

    /**
     * Unserializes a string as a FacebookApp entity.
     * @param serialized 
     * @return FacebookApp
     */
    public static function unserialize( serialized : String ) : FacebookApp
    {
        var ar : Array<String> = serialized.split('|');

        return new FacebookApp(ar[0], ar[1]);
    }

    /**
     * Serializes the FacebookApp entity as a string.
     * @param s 
     */
    @:keep function hxSerialize( s : Serializer )
    {
        s.serialize([id, secret]);
    }

    /**
     * Unserializes a string as a FacebookApp entity.
     * @param u 
     */
    @:keep function hxUnserialize( u : Unserializer ) : Void
    {
        var v : Array<String> = u.unserialize();
        id = v[0];
        secret = v[1];
    }
}