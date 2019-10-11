package cases.auth;

import utest.Assert;

import fb.error.FacebookSDKException;
import fb.auth.AccessTokenMetadata;


class AccessTokenMetadataTest extends utest.Test
{

    var graphResponseData = {
        data: {
            app_id: '123',
            application: 'Foo App',
            error: {
                code: 190,
                message: 'Foo error message.',
                subcode: 463,
            },
            issued_at: 1422110200,
            expires_at: 1422115200,
            is_valid: false,
            metadata: {
                sso: 'iphone-sso',
                auth_type: 'rerequest',
                auth_nonce: 'no-replicatey',
            },
            scopes: ['public_profile', 'basic_info', 'user_friends'],
            profile_id: '1000',
            user_id: '1337',
        },
    };


    public function test_DatesGetCastToDateTime( )
    {
        var metadata = new AccessTokenMetadata(this.graphResponseData);

        var expires = metadata.getExpiresAt();
        var issuedAt = metadata.getIssuedAt();

        Assert.is(expires, Date);
        Assert.is(issuedAt, Date);
    }

    public function test_AllTheGettersReturnTheProperValue( )
    {
        var metadata = new AccessTokenMetadata(this.graphResponseData);

        Assert.equals('123', metadata.getAppId());
        Assert.equals('Foo App', metadata.getApplication());
        Assert.isTrue(metadata.isError(), 'Expected an error');
        Assert.equals(190, metadata.getErrorCode());
        Assert.equals('Foo error message.', metadata.getErrorMessage());
        Assert.equals(463, metadata.getErrorSubcode());
        Assert.isFalse(metadata.getIsValid(), 'Expected the access token to not be valid');
        Assert.equals('iphone-sso', metadata.getSso());
        Assert.equals('rerequest', metadata.getAuthType());
        Assert.equals('no-replicatey', metadata.getAuthNonce());
        Assert.equals('1000', metadata.getProfileId());
        Assert.same(['public_profile', 'basic_info', 'user_friends'], metadata.getScopes());
        Assert.equals('1337', metadata.getUserId());
    }

    public function test_InvalidMetadataWillThrow( )
    {
        Assert.raises(function(){
            new AccessTokenMetadata(['foo' => 'bar']);
        }, FacebookSDKException);
    }

    public function test_AnExpectedAppIdWillNotThrow( )
    {
        var metadata = new AccessTokenMetadata(this.graphResponseData);
        metadata.validateAppId('123');

        Assert.pass('expected AppId will not throw');
    }

    public function test_AnUnexpectedAppIdWillThrow( )
    {
        Assert.raises(function(){
            var metadata = new AccessTokenMetadata(this.graphResponseData);
            metadata.validateAppId('foo');
        }, FacebookSDKException);
    }

    public function test_AnExpectedUserIdWillNotThrow( )
    {
        var metadata = new AccessTokenMetadata(this.graphResponseData);
        metadata.validateUserId('1337');

        Assert.pass('expected UserId will not throw');
    }

    public function test_AnUnexpectedUserIdWillThrow( )
    {
        Assert.raises(function(){
            var metadata = new AccessTokenMetadata(this.graphResponseData);
            metadata.validateUserId('foo');
        }, FacebookSDKException);
    }

    public function test_AnActiveAccessTokenWillNotThrow( )
    {
        this.graphResponseData.data.expires_at = time() + 1000;

        var metadata = new AccessTokenMetadata(this.graphResponseData);
        metadata.validateExpiration();

        Assert.pass('active AccessToken will not throw');
    }

    public function test_AnExpiredAccessTokenWillThrow( )
    {
        Assert.raises(function(){
            this.graphResponseData.data.expires_at = time() - 1000;
            var metadata = new AccessTokenMetadata(this.graphResponseData);
            metadata.validateExpiration();
        }, FacebookSDKException);
    }

    inline static function time( ) : Int return Std.int(Date.now().getTime() / 1000.0);
}