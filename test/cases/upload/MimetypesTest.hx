package cases.upload;

import utest.Assert;

import fb.upload.Mimetypes;


class MimetypesTest extends utest.Test
{
    /**
     * Taken from Guzzle
     *
     * @see https://github.com/guzzle/guzzle/blob/master/tests/MimetypesTest.php
     */
    public function testGetsFromExtension()
    {
        Assert.equals('text/plain', Mimetypes.fromExtension('txt'));
    }

    public function testGetsFromFilename()
    {
        Assert.equals('text/plain', Mimetypes.fromFilename('test/files/foo.txt'));
    }

    public function testGetsFromCaseInsensitiveFilename()
    {
        Assert.equals('text/plain', Mimetypes.fromFilename('test/files/foo.txt'.toUpperCase()));
    }

    public function testReturnsNullWhenNoMatchFound( )
    {
        Assert.isNull(Mimetypes.fromExtension('foobar'));
    }
}