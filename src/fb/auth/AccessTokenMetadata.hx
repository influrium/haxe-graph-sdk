package fb.auth;

import fb.error.FacebookSDKException;

/**
 * Class AccessTokenMetadata
 * Represents metadata from an access token.
 * @see     https://developers.facebook.com/docs/graph-api/reference/debug_token
 */
class AccessTokenMetadata
{
    /**
     * The access token metadata.
     */
    var metadata : Dynamic<String> = {};

    /**
     * Properties that should be cast as DateTime objects.
     */
    static var dateProperties = ['expires_at', 'issued_at'];

    public function new( metadata : Dynamic )
    {
        if (metadata.data == null )
            throw new FacebookSDKException('Unexpected debug token response data.', 401);

        this.metadata = metadata.data;

        castTimestampsToDateTime();
    }

    /**
     * Returns a value from the metadata.
     * @param string $field   The property to retrieve.
     * @param mixed  $default The default to return if the property doesn't exist.
     * @return mixed
     */
    public function getField<A>( field : String, ?def : A ) : A
    {
        return Reflect.hasField(metadata, field) ? Reflect.field(metadata, field) : def;
    }

    /**
     * Returns a value from the metadata.
     * @param string $field   The property to retrieve.
     * @param mixed  $default The default to return if the property doesn't exist.
     * @return mixed
     * @deprecated 5.0.0 getProperty() has been renamed to getField()
     * @todo v6: Remove this method
     */
    public function getProperty<A>( field : String, ?def : A ) : A
    {
        return this.getField(field, def);
    }

    /**
     * Returns a value from a child property in the metadata.
     * @param string $parentField The parent property.
     * @param string $field       The property to retrieve.
     * @param mixed  $default     The default to return if the property doesn't exist.
     * @return mixed
     */
    public function getChildProperty<A>( parentField : String, field : String, ?def : A ) : A
    {
        if (!Reflect.hasField(metadata, parentField))
            return def;
        
        var parent = Reflect.field(metadata, parentField);
        if (!Reflect.hasField(parent, field))
            return def;

        return Reflect.field(parent, field);
    }

    /**
     * Returns a value from the error metadata.
     * @param string $field   The property to retrieve.
     * @param mixed  $default The default to return if the property doesn't exist.
     * @return mixed
     */
    public function getErrorProperty<A>( field : String, ?def : A ) : A
    {
        return getChildProperty('error', field, def);
    }

    /**
     * Returns a value from the "metadata" metadata. *Brain explodes*
     * @param string $field   The property to retrieve.
     * @param mixed  $default The default to return if the property doesn't exist.
     * @return mixed
     */
    public function getMetadataProperty<A>( field, ?def : A ) : A
    {
        return getChildProperty('metadata', field, def);
    }

    /**
     * The ID of the application this access token is for.
     * @return Null<String>
     */
    public function getAppId( ) : Null<String>
    {
        return getField('app_id');
    }

    /**
     * Name of the application this access token is for.
     * @return Null<String>
     */
    public function getApplication( ) : Null<String>
    {
        return getField('application');
    }

    /**
     * Any error that a request to the graph api would return due to the access token.
     * @return Bool
     */
    public function isError( ) : Bool
    {
        return getField('error') != null;
    }

    /**
     * The error code for the error.
     * @return Null<Int>
     */
    public function getErrorCode( ) : Null<Int>
    {
        return getErrorProperty('code');
    }

    /**
     * The error message for the error.
     * @return Null<String>
     */
    public function getErrorMessage( ) : Null<String>
    {
        return getErrorProperty('message');
    }

    /**
     * The error subcode for the error.
     * @return Null<Int>
     */
    public function getErrorSubcode( ) : Null<Int>
    {
        return getErrorProperty('subcode');
    }

    /**
     * DateTime when this access token expires.
     * @return Null<Date>
     */
    public function getExpiresAt( ) : Null<Date>
    {
        return getField('expires_at');
    }

    /**
     * Whether the access token is still valid or not.
     * @return Null<Bool>
     */
    public function getIsValid( ) : Null<Bool>
    {
        return getField('is_valid');
    }

    /**
     * DateTime when this access token was issued.
     * Note that the issued_at field is not returned for short-lived access tokens.
     * @see https://developers.facebook.com/docs/facebook-login/access-tokens#debug
     * @return Null<Date>
     */
    public function getIssuedAt( ) : Null<Date>
    {
        return getField('issued_at');
    }

    /**
     * General metadata associated with the access token.
     * Can contain data like 'sso', 'auth_type', 'auth_nonce'.
     * @return Null<Dynamic<String>>
     */
    public function getMetadata( ) : Null<Dynamic<String>>
    {
        return getField('metadata');
    }

    /**
     * The 'sso' child property from the 'metadata' parent property.
     * @return Null<String>
     */
    public function getSso( ) : Null<String>
    {
        return getMetadataProperty('sso');
    }

    /**
     * The 'auth_type' child property from the 'metadata' parent property.
     * @return Null<String>
     */
    public function getAuthType( ) : Null<String>
    {
        return getMetadataProperty('auth_type');
    }

    /**
     * The 'auth_nonce' child property from the 'metadata' parent property.
     * @return Null<String>
     */
    public function getAuthNonce( ) : Null<String>
    {
        return getMetadataProperty('auth_nonce');
    }

    /**
     * For impersonated access tokens, the ID of the page this token contains.
     * @return Null<String>
     */
    public function getProfileId( ) : Null<String>
    {
        return getField('profile_id');
    }

    /**
     * List of permissions that the user has granted for the app in this access token.
     * @return array
     */
    public function getScopes( ) : Array<Dynamic>
    {
        return getField('scopes');
    }

    /**
     * The ID of the user this access token is for.
     * @return Null<String>
     */
    public function getUserId( ) : Null<String>
    {
        return getField('user_id');
    }

    /**
     * Ensures the app ID from the access token metadata is what we expect.
     * @param string $appId
     * @throws FacebookSDKException
     */
    public function validateAppId( appId : String ) : Void
    {
        if (getAppId() != appId)
            throw new FacebookSDKException('Access token metadata contains unexpected app ID.', 401);
    }

    /**
     * Ensures the user ID from the access token metadata is what we expect.
     * @param string userId
     * @throws FacebookSDKException
     */
    public function validateUserId( userId : String ) : Void
    {
        if (getUserId() != userId)
            throw new FacebookSDKException('Access token metadata contains unexpected user ID.', 401);
    }

    /**
     * Ensures the access token has not expired yet.
     * @throws FacebookSDKException
     */
    public function validateExpiration( )
    {
        var expire : Date = getExpiresAt();
        if (expire == null || !Std.is(expire, Date))
            return;
        
        if (expire.getTime() < Date.now().getTime())
            throw new FacebookSDKException('Inspection of access token metadata shows that the access token has expired.', 401);
    }

    /**
     * Converts a unix timestamp into a DateTime entity.
     * @param Int timestamp
     * @return DateTime
     */
    function convertTimestampToDateTime( timestamp : Int ) : Date
    {
        return Date.fromTime(timestamp * 1000.0);
    }

    /**
     * Casts the unix timestamps as DateTime entities.
     */
    function castTimestampsToDateTime( )
    {
        for (key in dateProperties) if (Reflect.hasField(metadata, key))
        {
            var v = Reflect.field(metadata, key);
            if( v > 0 )
                Reflect.setField(metadata, key, convertTimestampToDateTime(v));
        }
    }
}