package fb.prs;

interface PseudoRandomStringGeneratorInterface
{
    /**
     * Get a cryptographically secure pseudo-random string of arbitrary length.
     * @see http://sockpuppet.org/blog/2014/02/25/safely-generate-random-numbers/
     * @param int $length The length of the string to return.
     * @return string
     * @throws \Facebook\Exceptions\FacebookSDKException|\InvalidArgumentException
     */
    public function getPseudoRandomString( length : Int ) : String;
}