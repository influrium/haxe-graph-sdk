package fb.auth;

import haxe.io.Bytes;
import haxe.crypto.Hmac;

typedef AccessTokenData = {
    var value : String;
    @:optional var expiresAt : Date;
}

abstract AccessToken(AccessTokenData) //from String to String
{
    inline public function new( token : String, expiresAt : Float = .0 )
    {
        this = {
            value: token,
            expiresAt: expiresAt > 0 ? Date.fromTime(expiresAt * 1000.0) : null,
        };
    }
    @:from static public function fromString( s : String ) : AccessToken
    {
        return new AccessToken(s);
    }
    @:to public function toString( ) : String
    {
        return this.value;
    }

    inline public function getValue( ) : String return this.value;
    inline public function getExpiresAt( ) : Date return this.expiresAt;

    /**
     * Generate an app secret proof to sign a request to Graph.
     * @param appSecret 
     * @return String
     */
    inline public function getAppSecretProof( appSecret : String ) : String
    {
        // return hash_hmac('sha256', value, appSecret);
        return (new Hmac(SHA256)).make(Bytes.ofString(appSecret), Bytes.ofString(this.value)).toHex(); // toString();
    }

    /**
     * Determines whether or not this is an app access token.
     * @return Bool
     */
    inline public function isAppAccessToken( ) : Bool
    {
        // return strpos($this->value, '|') != false;
        return this.value.indexOf('|') > -1;
    }

    /**
     * Determines whether or not this is a long-lived token.
     * @return Bool
     */
    inline public function isLongLived( ) : Bool
    {
        return this.expiresAt != null ? (this.expiresAt.getTime() > Date.now().getTime() + (60 * 60 * 2) * 1000.0) : isAppAccessToken();
    }
// 1571082000, 1570484792000
    /**
     * Checks the expiration of the access token.
     * @return Null<Bool>
     */
    inline public function isExpired() : Null<Bool>
    {
        return this.expiresAt != null ? (this.expiresAt.getTime() < Date.now().getTime()) : (isAppAccessToken() ? false : null);
    }
}


class AccessTokenOrig
{
    /**
     * The access token value.
     */
    public var value(default, null) : String;

    /**
     * Date when token expires.
     */
    public var expiresAt(default, null) : Null<Date>;


    /**
     * Create a new access token entity.
     * @param accessToken 
     * @param expiresAt 
     */
    public function new( accessToken : String, expiresAt : Int = 0 )
    {
        this.value = accessToken;
        if( expiresAt > 0 )
            setExpiresAtFromTimeStamp(expiresAt);
    }

    /**
     * Generate an app secret proof to sign a request to Graph.
     * @param appSecret 
     * @return String
     */
    public function getAppSecretProof( appSecret : String ) : String
    {
        // return hash_hmac('sha256', value, appSecret);
        var hmac = new Hmac(SHA256);
        return hmac.make(Bytes.ofString(appSecret), Bytes.ofString(value)).toString();
    }

    /**
     * Determines whether or not this is an app access token.
     * @return Bool
     */
    public function isAppAccessToken( ) : Bool
    {
        // return strpos($this->value, '|') != false;
        return value.indexOf('|') > -1;
    }

    /**
     * Determines whether or not this is a long-lived token.
     * @return Bool
     */
    public function isLongLived( ) : Bool
    {
        if (expiresAt != null)
            return expiresAt.getTime() > Date.now().getTime() + (60 * 60 * 2);

        if (isAppAccessToken())
            return true;

        return false;
    }

    /**
     * Checks the expiration of the access token.
     * @return Null<Bool>
     */
    public function isExpired() : Null<Bool>
    {
        if (expiresAt != null)
            return expiresAt.getTime() < Date.now().getTime();

        if (isAppAccessToken())
            return false;

        return null;
    }

    /**
     * Returns the access token as a string.
     * @return String
     */
    public function toString( ) : String
    {
        return value;
    }

    /**
     * Setter for expires_at.
     * @param timeStamp 
     */
    function setExpiresAtFromTimeStamp( timeStamp : Float ) : Void
    {
        expiresAt = Date.fromTime(timeStamp);
    }
}
