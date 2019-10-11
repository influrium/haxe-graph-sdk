package fb;

import haxe.ds.StringMap;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.crypto.Hmac;
import haxe.Json;
import fb.error.*;

using StringTools;


class SignedRequest
{
    /**
     * The FacebookApp entity.
     */
    var app : FacebookApp;

    /**
     * The raw encrypted signed request.
     */
    public var rawSignedRequest (default, null) : String;

    /**
     * The payload from the decrypted signed request.
     */
    public var payload (default, null) : StringMap<Dynamic>;

    /**
     * Instantiate a new SignedRequest entity.
     *
     * @param FacebookApp $facebookApp      The FacebookApp entity.
     * @param string|null $rawSignedRequest The raw signed request.
     */
    public function new( facebookApp : FacebookApp, ?rawSignedRequest : String )
    {
        this.app = facebookApp;

        if (rawSignedRequest == null)
            return;

        this.rawSignedRequest = rawSignedRequest;

        parse();
    }
    
    /**
     * Returns a property from the signed request data if available.
     */
    public function get<A>( key : String, ?def : A ) : A
    {
        var v = payload.get(key);
        return v != null ? v : def;
    }

    /**
     * Returns user_id from signed request data if available.
     */
    public function getUserId( ) : String return this.get('user_id');

    /**
     * Checks for OAuth data in the payload.
     */
    public function hasOAuthData( ) : Bool return this.get('oauth_token') != null || this.get('code') != null;

    /**
     * Creates a signed request from an array of data.
     */
    public function make( payload : StringMap<Dynamic> ) : String
    {
        var algorithm = payload.get('algorithm');
        if (algorithm == null)
            payload.set('algorithm', 'HMAC-SHA256');
        
        var issued_at = payload.get('issued_at');
        if (issued_at == null)
            payload.set('issued_at', Std.int(Date.now().getTime() / 1000.0));
        
        // var o = {}; for (k in payload.keys()) Reflect.setField(o, k, payload.get(k));
        var encodedPayload = this.base64UrlEncode(Json.stringify(payload));
        // expect - eyJvYXV0aF90b2tlbiI6ImZvb190b2tlbiIsImFsZ29yaXRobSI6IkhNQUMtU0hBMjU2IiwiaXNzdWVkX2F0IjozMjEsImNvZGUiOiJmb29fY29kZSIsInN0YXRlIjoiZm9vX3N0YXRlIiwidXNlcl9pZCI6MTIzLCJmb28iOiJiYXIifQ==
        // strmap - eyJjb2RlIjoiZm9vX2NvZGUiLCJ1c2VyX2lkIjoxMjMsImZvbyI6ImJhciIsInN0YXRlIjoiZm9vX3N0YXRlIiwib2F1dGhfdG9rZW4iOiJmb29fdG9rZW4iLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MzIxfQ==
        //          eyJjb2RlIjoiZm9vX2NvZGUiLCJ1c2VyX2lkIjoxMjMsImZvbyI6ImJhciIsInN0YXRlIjoiZm9vX3N0YXRlIiwib2F1dGhfdG9rZW4iOiJmb29fdG9rZW4iLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MzIxfQ==

        var hashedSig = this.hashSignature(encodedPayload);
        var encodedSig = this.base64UrlEncode(hashedSig);

        return encodedSig + '.' + encodedPayload;
    }

    /**
     * Validates and decodes a signed request and saves the payload to an array.
     */
    function parse( )
    {
        var parts = this.split();

        // Signature validation
        var sig = this.decodeSignature(parts.encodedSig);
        var hashedSig = this.hashSignature(parts.encodedPayload);

        this.validateSignature(hashedSig, sig);

        this.payload = this.decodePayload(parts.encodedPayload);

        // Payload validation
        this.validateAlgorithm();
    }

    /**
     * Splits a raw signed request into signature and payload.
     * @return array
     * @throws FacebookSDKException
     */
    function split( )
    {
        if ( this.rawSignedRequest.indexOf('.') < 0 )
            throw new FacebookSDKException('Malformed signed request.', 606);

        var parts = this.rawSignedRequest.split('.');
        return {
            encodedSig: parts.shift(),
            encodedPayload: parts.join('.'),
        };
    }

    /**
     * Decodes the raw signature from a signed request.
     * @param string $encodedSig
     * @return string
     * @throws FacebookSDKException
     */
    function decodeSignature( encodedSig : String ) : String
    {
        var sig = this.base64UrlDecode(encodedSig);

        if (sig == null)
            throw new FacebookSDKException('Signed request has malformed encoded signature data.', 607);

        return sig;
    }

    /**
     * Decodes the raw payload from a signed request.
     * @param string $encodedPayload
     * @return array
     * @throws FacebookSDKException
     */
    function decodePayload( encodedPayload : String ) : StringMap<Dynamic>
    {
        var payload = this.base64UrlDecode(encodedPayload);

        if (payload != null)
            payload = Json.parse(payload);
        
        var o = new StringMap();
        for (f in Reflect.fields(payload))
            o.set(f, Reflect.field(payload, f));

        // if (!is_array($payload)) throw new FacebookSDKException('Signed request has malformed encoded payload data.', 607);
        
        return o;
    }

    /**
     * Validates the algorithm used in a signed request.
     * @throws FacebookSDKException
     */
    function validateAlgorithm( )
    {
        if (this.get('algorithm') != 'HMAC-SHA256')
            throw new FacebookSDKException('Signed request is using the wrong algorithm.', 605);
    }

    /**
     * Hashes the signature used in a signed request.
     * @param string $encodedData
     * @return string
     * @throws FacebookSDKException
     */
    function hashSignature( encodedData : String ) : String
    {
        var hashedSig = (new Hmac(SHA256)).make(Bytes.ofString(app.secret), Bytes.ofString(encodedData)).toString();
        if (hashedSig == null)
            throw new FacebookSDKException('Unable to hash signature from encoded payload data.', 602);

        return hashedSig;
    }

    /**
     * Validates the signature used in a signed request.
     * @param string $hashedSig
     * @param string $sig
     * @throws FacebookSDKException
     */
    function validateSignature( hashedSig : String, sig : String )
    {
        // if (hash_equals(hashedSig, sig))
        if (hashedSig == sig)
            return;

        throw new FacebookSDKException('Signed request has an invalid signature.', 602);
    }

    /**
     * Base64 decoding which replaces characters:
     *   + instead of -
     *   / instead of _
     * @link http://en.wikipedia.org/wiki/Base64#URL_applications
     * @param string $input base64 url encoded input
     * @return string decoded string
     */
    public function base64UrlDecode( input : String ) : String
    {
        var urlDecodedBase64 = input.replace('-', '+').replace('_', '/');
        this.validateBase64(urlDecodedBase64);

        return Base64.decode(urlDecodedBase64).toString();
    }

    /**
     * Base64 encoding which replaces characters:
     *   + instead of -
     *   / instead of _
     * @link http://en.wikipedia.org/wiki/Base64#URL_applications
     * @param string $input string to encode
     * @return string base64 url encoded input
     */
    public function base64UrlEncode( input : String ) : String
    {
        return Base64.encode(Bytes.ofString(input)).replace('+', '-').replace('/', '_');
    }

    /**
     * Validates a base64 string.
     * @param string $input base64 value to validate
     * @throws FacebookSDKException
     */
    function validateBase64( input : String ) : Void
    {
        if (!erBase64.match(input))
            throw new FacebookSDKException('Signed request contains malformed base64 encoding.', 608);
    }

    static var erBase64 = ~/^[a-zA-Z0-9\/\r\n+]*={0,2}$/;
}
