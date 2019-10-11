package fb.prs;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;

import fb.error.*;

using fb.prs.PseudoRandomStringGeneratorTrait;


class RandomBytesPseudoRandomStringGenerator implements PseudoRandomStringGeneratorInterface
{
    /**
     * @const string The error message when generating the string fails.
     */
    inline public static var ERROR_MESSAGE = 'Unable to generate a cryptographically secure pseudo-random string from random_bytes(). ';

    /**
     * @throws FacebookSDKException
     */
    public function new( )
    {
        /*
        if (!function_exists('random_bytes'))
            throw new FacebookSDKException(ERROR_MESSAGE + 'The function random_bytes() does not exist.');
        */
    }

    /**
     * @inheritdoc
     */
    public function getPseudoRandomString( length : Int )
    {
        length.validateLength();

        return random_bytes(length).binToHex(length);
    }

    function random_bytes( len : Int ) : Bytes
    {  
        var buf = new BytesBuffer();
        for (i in 0...len)
            buf.addByte(Std.int(Math.random() * 255));
        return buf.getBytes();
    }
}
