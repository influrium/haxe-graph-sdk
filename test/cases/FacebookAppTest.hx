package cases;

import utest.Assert;

import haxe.Serializer;
import haxe.Unserializer;

import fb.FacebookApp;
import fb.auth.AccessToken;


class FacebookAppTest extends utest.Test
{
    var app : FacebookApp;

    public function setup( ) : Void
    {
        app = new FacebookApp('id', 'secret');
    }

    public function test_getId( )
    {
        Assert.equals('id', app.id);
    }

    public function test_getSecret( )
    {
        Assert.equals('secret', app.secret);
    }

    public function test_anAppAccessTokenCanBeGenerated( )
    {
        var accessToken = app.getAccessToken();

        // Assert.is(accessToken, AccessToken);
        Assert.equals('id|secret', '$accessToken');
    }

    public function test_serialization( )
    {
        var newApp : FacebookApp = Unserializer.run(Serializer.run(app));

        Assert.is(newApp, FacebookApp);
        Assert.equals('id', newApp.id);
        Assert.equals('secret', newApp.secret);
    }

    /**
     * @expectedException \Facebook\Exceptions\FacebookSDKException
     */
/*
    public function test_overflowIntegersWillThrow( )
    {
        new FacebookApp(PHP_INT_MAX + 1, "foo");
    }
*/
    public function test_unserializedIdsWillBeString( )
    {
        var newApp = Unserializer.run(Serializer.run(new FacebookApp('1', "foo")));

        Assert.equals('1', newApp.id);
    }
}