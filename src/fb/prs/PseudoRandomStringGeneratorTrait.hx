package fb.prs;

import fb.error.*;


class PseudoRandomStringGeneratorTrait
{
    /**
     * Validates the length argument of a random string.
     * @param int $length The length to validate.
     * @throws \InvalidArgumentException
     */
    public static function validateLength( length : Int ) : Void
    {
        if (length == null)
            throw new InvalidArgumentException('getPseudoRandomString() expects an integer for the string length');

        if (length < 1)
            throw new InvalidArgumentException('getPseudoRandomString() expects a length greater than 1');
    }

    /**
     * Converts binary data to hexadecimal of arbitrary length.
     * @param string $binaryData The binary data to convert to hex.
     * @param int    $length     The length of the string to return.
     * @return string
     */
    public static function binToHex( binaryData : haxe.io.Bytes, length : Int ) : String
    {
        return binaryData.toHex().substr(0, length);
    }
}
