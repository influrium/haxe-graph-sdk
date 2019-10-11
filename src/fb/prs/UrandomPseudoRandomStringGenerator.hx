package fb.prs;

import sys.FileSystem;
import sys.io.File;
import fb.error.*;

using fb.prs.PseudoRandomStringGeneratorTrait;


class UrandomPseudoRandomStringGenerator implements PseudoRandomStringGeneratorInterface
{
    /**
     * @const string The error message when generating the string fails.
     */
    inline static var ERROR_MESSAGE = 'Unable to generate a cryptographically secure pseudo-random string from /dev/urandom. ';

    public function new( )
    {
        // if (ini_get('open_basedir')) throw new FacebookSDKException(ERROR_MESSAGE + 'There is an open_basedir constraint that prevents access to /dev/urandom.');

        if (!FileSystem.exists('/dev/urandom') || FileSystem.isDirectory('/dev/urandom'))
            throw new FacebookSDKException(ERROR_MESSAGE+'Unable to read from /dev/urandom.');
    }

    /**
     * @inheritdoc
     */
    public function getPseudoRandomString( length : Int ) : String
    {
        length.validateLength();

        var stream = File.read('/dev/urandom', true);
        if (stream == null || stream.read(1) == null)
            throw new FacebookSDKException(ERROR_MESSAGE+'Unable to open stream to /dev/urandom.');
        
        /*
        if (!defined('HHVM_VERSION'))
            stream_set_read_buffer(stream, 0);
        */

        var bytes : haxe.io.Bytes = stream.read(length);
        stream.close();

        if (bytes == null)
            throw new FacebookSDKException(ERROR_MESSAGE+'Stream to /dev/urandom returned no data.');

        return bytes.binToHex(length);
    }
}
