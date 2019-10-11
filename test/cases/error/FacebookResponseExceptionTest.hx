package cases.error;

import utest.Assert;

import haxe.Json;

import fb.error.*;
import fb.FacebookApp;
import fb.FacebookRequest;
import fb.FacebookResponse;


class FacebookResponseExceptionTest extends utest.Test
{
    var request : FacebookRequest;

    function setup( )
    {
        this.request = new FacebookRequest(new FacebookApp('123', 'foo'));
    }

    public function testAuthenticationExceptions( )
    {
        var params = {
            error: {
                code: 100,
                message: 'errmsg',
                error_subcode: 0,
                type: 'exception',
            },
        };

        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(100, exception.code);
        Assert.equals(0, exception.getSubErrorCode());
        Assert.equals('exception', exception.getErrorType());
        Assert.equals('errmsg', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(401, exception.getHttpStatusCode());

        params.error.code = 102;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(102, exception.code);

        params.error.code = 190;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(190, exception.code);

        params.error.type = 'OAuthException';
        params.error.code = 0;
        params.error.error_subcode = 458;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(458, exception.getSubErrorCode());

        params.error.error_subcode = 460;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(460, exception.getSubErrorCode());

        params.error.error_subcode = 463;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(463, exception.getSubErrorCode());

        params.error.error_subcode = 467;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(467, exception.getSubErrorCode());

        params.error.error_subcode = 0;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(0, exception.getSubErrorCode());
    }

    public function testServerExceptions( )
    {
        var params = {
            error:{
                code: 1,
                message: 'errmsg',
                error_subcode: 0,
                type: 'exception'
            }
        };

        var response = new FacebookResponse(this.request, Json.stringify(params), 500);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookServerException);
        Assert.equals(1, exception.code);
        Assert.equals(0, exception.getSubErrorCode());
        Assert.equals('exception', exception.getErrorType());
        Assert.equals('errmsg', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(500, exception.getHttpStatusCode());

        params.error.code = 2;
        var response = new FacebookResponse(this.request, Json.stringify(params), 500);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookServerException);
        Assert.equals(2, exception.code);
    }

    public function testThrottleExceptions()
    {
        var params = {
            error: {
                code: 4,
                message: 'errmsg',
                error_subcode: 0,
                type: 'exception'
            },
        };
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookThrottleException);
        Assert.equals(4, exception.code);
        Assert.equals(0, exception.getSubErrorCode());
        Assert.equals('exception', exception.getErrorType());
        Assert.equals('errmsg', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(401, exception.getHttpStatusCode());

        params.error.code = 17;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookThrottleException);
        Assert.equals(17, exception.code);

        params.error.code = 341;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookThrottleException);
        Assert.equals(341, exception.code);
    }

    public function testUserIssueExceptions( )
    {
        var params = {
            error: {
                code: 230,
                message: 'errmsg',
                error_subcode: 459,
                type: 'exception'
            },
        };

        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(230, exception.code);
        Assert.equals(459, exception.getSubErrorCode());
        Assert.equals('exception', exception.getErrorType());
        Assert.equals('errmsg', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(401, exception.getHttpStatusCode());

        params.error.error_subcode = 464;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthenticationException);
        Assert.equals(464, exception.getSubErrorCode());
    }

    public function testAuthorizationExceptions()
    {
        var params = {
            error: {
                code: 10,
                message: 'errmsg',
                error_subcode: 0,
                type: 'exception'
            },
        };

        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthorizationException);
        Assert.equals(10, exception.code);
        Assert.equals(0, exception.getSubErrorCode());
        Assert.equals('exception', exception.getErrorType());
        Assert.equals('errmsg', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(401, exception.getHttpStatusCode());

        params.error.code = 200;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthorizationException);
        Assert.equals(200, exception.code);

        params.error.code = 250;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthorizationException);
        Assert.equals(250, exception.code);

        params.error.code = 299;
        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookAuthorizationException);
        Assert.equals(299, exception.code);
    }

    public function testClientExceptions()
    {
        var params = {
            error: {
                code: 506,
                message: 'errmsg',
                error_subcode: 0,
                type: 'exception'
            },
        };

        var response = new FacebookResponse(this.request, Json.stringify(params), 401);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookClientException);
        Assert.equals(506, exception.code);
        Assert.equals(0, exception.getSubErrorCode());
        Assert.equals('exception', exception.getErrorType());
        Assert.equals('errmsg', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(401, exception.getHttpStatusCode());
    }

    public function testOtherException()
    {
        var params = {
            error: {
                code: 42,
                message: 'ship love',
                error_subcode: 0,
                type: 'feature'
            },
        };

        var response = new FacebookResponse(this.request, Json.stringify(params), 200);
        var exception = FacebookResponseException.create(response);
        Assert.is(exception.previous, FacebookOtherException);
        Assert.equals(42, exception.code);
        Assert.equals(0, exception.getSubErrorCode());
        Assert.equals('feature', exception.getErrorType());
        Assert.equals('ship love', exception.message);
        Assert.equals(Json.stringify(params), exception.getRawResponse());
        Assert.equals(200, exception.getHttpStatusCode());
    }
}