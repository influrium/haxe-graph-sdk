package cases.helper;

import utest.Assert;

import fb.FacebookClient;
import fb.helpers.FacebookPageTabHelper;
import fb.FacebookApp;


class FacebookPageTabHelperTest extends utest.Test
{
    var rawSignedRequestAuthorized = '6Hi26ECjkj347belC0O8b8H5lwiIz5eA6V9VVjTg-HU=.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MzIxLCJvYXV0aF90b2tlbiI6ImZvb190b2tlbiIsInVzZXJfaWQiOiIxMjMiLCJwYWdlIjp7ImlkIjoiNDIiLCJsaWtlZCI6dHJ1ZSwiYWRtaW4iOmZhbHNlfX0=';

    public function testPageDataCanBeAccessed( )
    {
    #if neko
        untyped neko.Web.getParams = function() return ['signed_request' => this.rawSignedRequestAuthorized];
    #end

        var app = new FacebookApp('123', 'foo_app_secret');
        var helper = new FacebookPageTabHelper(app, new FacebookClient());

        Assert.isFalse(helper.isAdmin());
        Assert.equals('42', helper.getPageId());
        Assert.equals('42', helper.getPageData('id'));
        Assert.equals('default', helper.getPageData('foo', 'default'));
    }
}