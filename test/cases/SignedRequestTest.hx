package cases;

import utest.Assert;

import haxe.ds.StringMap;

import fb.FacebookApp;
import fb.SignedRequest;
import fb.error.FacebookSDKException;


class SignedRequestTest extends utest.Test
{
    var app : FacebookApp;

    // var rawSignature = 'U0_O1MqqNKUt32633zAkdd2Ce-jGVgRgJeRauyx_zC8=';
    // {"oauth_token":"foo_token","algorithm":"HMAC-SHA256","issued_at":321,"code":"foo_code","state":"foo_state","user_id":123,"foo":"bar"}
    // var rawPayload = 'eyJvYXV0aF90b2tlbiI6ImZvb190b2tlbiIsImFsZ29yaXRobSI6IkhNQUMtU0hBMjU2IiwiaXNzdWVkX2F0IjozMjEsImNvZGUiOiJmb29fY29kZSIsInN0YXRlIjoiZm9vX3N0YXRlIiwidXNlcl9pZCI6MTIzLCJmb28iOiJiYXIifQ==';
    
    var rawSignature = 'A-3yR0SwrngdJDiulSAA4o7OF6YB3tarHeTiRDj738Q=';
    // {"code":"foo_code","user_id":123,"foo":"bar","state":"foo_state","oauth_token":"foo_token","algorithm":"HMAC-SHA256","issued_at":321}
    var rawPayload = 'eyJjb2RlIjoiZm9vX2NvZGUiLCJ1c2VyX2lkIjoxMjMsImZvbyI6ImJhciIsInN0YXRlIjoiZm9vX3N0YXRlIiwib2F1dGhfdG9rZW4iOiJmb29fdG9rZW4iLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MzIxfQ==';

    var payloadData : StringMap<Dynamic> = [
        'oauth_token' => 'foo_token',
        'algorithm' => 'HMAC-SHA256',
        'issued_at' => 321,
        'code' => 'foo_code',
        'state' => 'foo_state',
        'user_id' => 123,
        'foo' => 'bar',
    ];

    function setup( )
    {
        this.app = new FacebookApp('123', 'foo_app_secret');
    }

    public function testAValidSignedRequestCanBeCreated( )
    {
        var sr = new SignedRequest(this.app);
        var rawSignedRequest = sr.make(this.payloadData);

        var srTwo = new SignedRequest(this.app, rawSignedRequest);
        var payload = srTwo.payload;

        var expectedRawSignedRequest = this.rawSignature + '.' + this.rawPayload;
        Assert.equals(expectedRawSignedRequest, rawSignedRequest);
        Assert.same(this.payloadData, payload, true);
    }

    public function testInvalidSignedRequestsWillFailFormattingValidation( )
    {
        Assert.raises(function(){
            new SignedRequest(this.app, 'invalid_signed_request');
        }, FacebookSDKException);
    }

    public function testBase64EncodingIsUrlSafe( )
    {
        var sr = new SignedRequest(this.app);
        var encodedData = sr.base64UrlEncode('aijkoprstADIJKLOPQTUVX1256!)]-:;"<>?.|~');

        Assert.equals('YWlqa29wcnN0QURJSktMT1BRVFVWWDEyNTYhKV0tOjsiPD4_Lnx-', encodedData);
    }

    public function testAUrlSafeBase64EncodedStringCanBeDecoded( )
    {
        var sr = new SignedRequest(this.app);
        var decodedData = sr.base64UrlDecode('YWlqa29wcnN0QURJSktMT1BRVFVWWDEyNTYhKV0tOjsiPD4/Lnx+');

        Assert.equals('aijkoprstADIJKLOPQTUVX1256!)]-:;"<>?.|~', decodedData);
    }

    public function testAnImproperlyEncodedSignatureWillThrowAnException( )
    {
        Assert.raises(function(){
            new SignedRequest(this.app, 'foo_sig.' + this.rawPayload);
        }, FacebookSDKException);
    }

    public function testAnImproperlyEncodedPayloadWillThrowAnException( )
    {
        Assert.raises(function(){
            new SignedRequest(this.app, this.rawSignature + '.foo_payload');
        }, FacebookSDKException);
    }

    public function testNonApprovedAlgorithmsWillThrowAnException( )
    {
        Assert.raises(function(){
            var signedRequestData = this.payloadData.copy();
            signedRequestData.set('algorithm', 'FOO-ALGORITHM');

            var sr = new SignedRequest(this.app);
            var rawSignedRequest = sr.make(signedRequestData);

            new SignedRequest(this.app, rawSignedRequest);
        }, FacebookSDKException);
    }

    public function testAsRawSignedRequestCanBeValidatedAndDecoded( )
    {
        var rawSignedRequest = this.rawSignature + '.' + this.rawPayload;
        var sr = new SignedRequest(this.app, rawSignedRequest);

        Assert.same(this.payloadData, sr.payload, true);
    }

    public function testARawSignedRequestCanBeValidatedAndDecoded( )
    {
        var rawSignedRequest = this.rawSignature + '.' + this.rawPayload;
        var sr = new SignedRequest(this.app, rawSignedRequest);

        Assert.same(sr.payload, this.payloadData, true);
        Assert.equals(sr.rawSignedRequest, rawSignedRequest);
        Assert.equals(123, sr.getUserId());
        Assert.isTrue(sr.hasOAuthData());
    }
}