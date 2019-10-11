package cases.upload;

import fb.error.FacebookResponseException;
import fb.util.Params;
import fb.GraphVersion;
import utest.Assert;

import fb.FacebookApp;
import fb.FacebookClient;
import fb.upload.FacebookFile;
import fb.upload.FacebookTransferChunk;
import fb.upload.FacebookResumableUploader;
import fixtures.FakeGraphApiForResumableUpload;


class FacebookResumableUploaderTest extends utest.Test
{
    var fbApp : FacebookApp;
    var client : FacebookClient;
    var graphApi : FakeGraphApiForResumableUpload;
    var file : FacebookFile;

    function setup( )
    {
        this.fbApp = new FacebookApp('app_id', 'app_secret');
        this.graphApi = new FakeGraphApiForResumableUpload();
        this.client = new FacebookClient(this.graphApi);
        this.file = new FacebookFile('test/files/foo.txt');
    }

    public function test_resumableUploadCanStartTransferAndFinish( )
    {
        setup();

        var uploader = new FacebookResumableUploader(this.fbApp, this.client, 'access_token', new GraphVersion('v2.4'));
        var endpoint = '/me/videos';
        var chunk = uploader.start(endpoint, this.file);
        Assert.is(chunk, FacebookTransferChunk);
        Assert.equals('42', chunk.uploadSessionId);
        Assert.equals('1337', chunk.videoId);

        var newChunk = uploader.transfer(endpoint, chunk);
        Assert.equals(20, newChunk.startOffset);
        // this.assertNotSame
        Assert.notEquals(newChunk, chunk);

        var finalResponse = uploader.finish(endpoint, chunk.uploadSessionId, new Params());
        Assert.isTrue(finalResponse);
    }

    public function test_startWillLetErrorResponsesThrow( )
    {
        Assert.raises(function( ){
            this.graphApi.failOnStart();
            var uploader = new FacebookResumableUploader(this.fbApp, this.client, 'access_token', new GraphVersion('v2.4'));

            uploader.start('/me/videos', this.file);
        }, FacebookResponseException);
    }

    public function test_failedResumableTransferWillNotThrowAndReturnSameChunk( )
    {
        this.graphApi.failOnTransfer();
        var uploader = new FacebookResumableUploader(this.fbApp, this.client, 'access_token', new GraphVersion('v2.4'));

        var chunk : FacebookTransferChunk = new FacebookTransferChunk(this.file, '1', '2', 3, 4);
        var newChunk : FacebookTransferChunk = uploader.transfer('/me/videos', chunk);
        Assert.same(chunk, newChunk, false);
    }

    public function test_failedResumableTransferWillNotThrowAndReturnNewChunk( )
    {
        this.graphApi.failOnTransferAndUploadNewChunk();
        var uploader = new FacebookResumableUploader(this.fbApp, this.client, 'access_token', new GraphVersion('v2.4'));

        var chunk = new FacebookTransferChunk(this.file, '1', '2', 3, 4);
        var newChunk = uploader.transfer('/me/videos', chunk);
        Assert.equals(40, newChunk.startOffset);
        Assert.equals(50, newChunk.endOffset);
    }
}