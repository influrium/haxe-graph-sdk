package cases.upload;

import utest.Assert;

import fb.upload.FacebookFile;
import fb.error.FacebookSDKException;


class FacebookFileTest extends utest.Test
{
    var testFile = '';

    function setup( )
    {
        testFile = 'test/files/foo.txt';
    }

    public function test_canOpenAndReadAndCloseAFile( )
    {
        var file = new FacebookFile(testFile);
        var fileContents = file.getContents();

        Assert.equals('This is a text file used for testing. Let\'s dance.', fileContents);
    }

    public function test_partialFilesCanBeCreated( )
    {
        var file = new FacebookFile(testFile, 14, 5);
        var fileContents = file.getContents();

        Assert.equals('is a text file', fileContents);
    }
    
    public function testTryingToOpenAFileThatDoesntExistsThrows()
    {
        Assert.raises(function(){
            new FacebookFile('does_not_exist.file');
        }, FacebookSDKException);
    }
}