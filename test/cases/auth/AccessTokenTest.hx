package cases.auth;

import utest.Assert;

import haxe.Unserializer;
import haxe.Serializer;

import fb.auth.AccessToken;


class AccessTokenTest extends utest.Test
{
    public function test_AnAccessTokenCanBeReturnedAsAString( )
    {
        var accessToken = new AccessToken('foo_token');

        Assert.equals('foo_token', accessToken.getValue());
        Assert.equals('foo_token', '$accessToken');
    }

    public function test_AnAppSecretProofWillBeProperlyGenerated()
    {
        var accessToken = new AccessToken('foo_token');

        var appSecretProof = accessToken.getAppSecretProof('shhhhh!is.my.secret');

        Assert.equals('796ba0d8a6b339e476a7b166a9e8ac0a395f7de736dc37de5f2f4397f5854eb8', appSecretProof);
    }

    public function test_AnAppAccessTokenCanBeDetected( )
    {
        var normalToken = new AccessToken('foo_token');
        var isNormalToken = normalToken.isAppAccessToken();

        Assert.isFalse(isNormalToken, 'Normal access token not expected to look like an app access token.');

        var appToken = new AccessToken('123|secret');
        var isAppToken = appToken.isAppAccessToken();

        Assert.isTrue(isAppToken, 'App access token expected to look like an app access token.');
    }

    public function test_ShortLivedAccessTokensCanBeDetected( )
    {
        var anHourAndAHalf = time() + (1.5 * 60);
        var accessToken = new AccessToken('foo_token', anHourAndAHalf);

        var isLongLived = accessToken.isLongLived();

        Assert.isFalse(isLongLived, 'Expected access token to be short lived.');
    }

    public function test_LongLivedAccessTokensCanBeDetected( )
    {
        var accessToken = new AccessToken('foo_token', this.aWeekFromNow());

        var isLongLived = accessToken.isLongLived();

        Assert.isTrue(isLongLived, 'Expected access token to be long lived.');
    }

    public function test_AnAppAccessTokenDoesNotExpire( )
    {
        var appToken = new AccessToken('123|secret');
        var hasExpired = appToken.isExpired();

        Assert.isFalse(hasExpired, 'App access token not expected to expire.');
    }

    public function test_AnAccessTokenCanExpire( )
    {
        var expireTime = time() - 100;
        var appToken = new AccessToken('foo_token', expireTime);
        var hasExpired = appToken.isExpired();

        Assert.isTrue(hasExpired, 'Expected 100 second old access token to be expired.');
    }

    public function test_AccessTokenCanBeSerialized( )
    {
        // var accessToken = new AccessToken('foo', time(), 'bar');
        var accessToken = new AccessToken('foo', time());

        var newAccessToken : AccessToken = Unserializer.run(Serializer.run(accessToken));

        Assert.equals('$accessToken', '$newAccessToken');
        Assert.same(accessToken.getExpiresAt(), newAccessToken.getExpiresAt());
    }

    //a week from now
    private function aWeekFromNow( )
    {
        return time() + (60 * 60 * 24 * 7);
    }

    inline static function time( ) return Date.now().getTime() / 1000;
}