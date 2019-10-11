package fb.prs;

import sys.FileSystem;
import fb.error.*;


class PseudoRandomStringGeneratorFactory
{
    private function new( )
    {
        // a factory constructor should never be invoked
    }

    /**
     * Pseudo random string generator creation.
     * @param PseudoRandomStringGeneratorInterface|string|null $generator
     * @throws InvalidArgumentException If the pseudo random string generator must be set to "random_bytes", "mcrypt", "openssl", or "urandom", or be an instance of Facebook\PseudoRandomString\PseudoRandomStringGeneratorInterface.
     * @return PseudoRandomStringGeneratorInterface
     */
    public static function createPseudoRandomStringGenerator( generator : Dynamic ) : PseudoRandomStringGeneratorInterface
    {
        if (generator == null)
            return detectDefaultPseudoRandomStringGenerator();

        if (Std.is(generator, PseudoRandomStringGeneratorInterface))
            return cast(generator, PseudoRandomStringGeneratorInterface);
        
        if (Std.is(generator, String)) switch (cast(generator, String))
        {
            case 'random_bytes': return new RandomBytesPseudoRandomStringGenerator();
            // case 'mcrypt': return new McryptPseudoRandomStringGenerator();
            // case 'openssl': return new OpenSslPseudoRandomStringGenerator();
            case 'urandom': return new UrandomPseudoRandomStringGenerator();
            default:
        }

        throw new InvalidArgumentException('The pseudo random string generator must be set to "random_bytes", "mcrypt", "openssl", or "urandom", or be an instance of fb.prs.PseudoRandomStringGeneratorInterface');
        return null;
    }

    /**
     * Detects which pseudo-random string generator to use.
     * @throws FacebookSDKException If unable to detect a cryptographically secure pseudo-random string generator.
     * @return PseudoRandomStringGeneratorInterface
     */
    private static function detectDefaultPseudoRandomStringGenerator( ) : PseudoRandomStringGeneratorInterface
    {
/*
        // Check for PHP 7's CSPRNG first to keep mcrypt deprecation messages from appearing in PHP 7.1.
        if (function_exists('random_bytes'))
            return new RandomBytesPseudoRandomStringGenerator();

        // Since openssl_random_pseudo_bytes() can sometimes return non-cryptographically
        // secure pseudo-random strings (in rare cases), we check for mcrypt_create_iv() next.
        if (function_exists('mcrypt_create_iv'))
            return new McryptPseudoRandomStringGenerator();

        if (function_exists('openssl_random_pseudo_bytes'))
            return new OpenSslPseudoRandomStringGenerator();

        if (!ini_get('open_basedir') && is_readable('/dev/urandom'))
            return new UrandomPseudoRandomStringGenerator();
*/
        if (FileSystem.exists('/dev/urandom') && !FileSystem.isDirectory('/dev/urandom'))
            return new UrandomPseudoRandomStringGenerator();

        // if (function_exists('random_bytes'))
            return new RandomBytesPseudoRandomStringGenerator();
        
        throw new FacebookSDKException('Unable to detect a cryptographically secure pseudo-random string generator.');
        return null;
    }
}