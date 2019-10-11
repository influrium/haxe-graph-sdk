package cases;

import utest.Assert;

import haxe.ds.StringMap;
import sys.FileSystem;

import fb.Facebook;
import fb.FacebookRequest;
import fb.FacebookResponse;
import fb.FacebookBatchRequest;
import fb.FacebookClient;
import fb.GraphVersion;

import fb.prs.*;
import fb.auth.AccessToken;
import fb.httpclient.FacebookHttpClient;
import fb.persist.FacebookMemoryPersistentDataHandler;
import fb.url.FacebookUrlDetectionHandler;
import fb.util.ObjectTools;
import fb.error.*;
import fb.graph.*;

import fixtures.*;


class FacebookTest extends utest.Test
{
    var config : FacebookOptions = {
        app_id: '1337',
        app_secret: 'foo_secret',
    };

    public function test_instantiatingWithoutAppIdThrows( )
    {
        Assert.raises(function( ){
            // unset value so there is no fallback to test expected Exception
            Sys.putEnv(Facebook.APP_ID_ENV_NAME, '');
            var config = {
                app_secret: 'foo_secret',
            };
            new Facebook(config);
        }, FacebookSDKException);
    }

    public function test_instantiatingWithoutAppSecretThrows( )
    {
        Assert.raises(function( ){
            // unset value so there is no fallback to test expected Exception
            Sys.putEnv(Facebook.APP_SECRET_ENV_NAME, '');
            var config = {
                app_id: 'foo_id',
            };
            new Facebook(config);
        }, FacebookSDKException);
    }

    public function test_settingAnInvalidHttpClientHandlerThrows( )
    {
        Assert.raises(function( ){
            var config = ObjectTools.merge(this.config, {
                http_client_handler: 'foo_handler',
            });
            new Facebook(config);
        }, InvalidArgumentException);
    }

#if necurl
    public function test_curlHttpClientHandlerCanBeForced( )
    {
        if (!extension_loaded('curl'))
        {
            markTestSkipped('cURL must be installed to test cURL client handler.');
        }
        var config = ObjectTools.merge(this.config, {
            http_client_handler: 'curl',
        });
        var f = new Facebook(config);
        Assert.is(f.client.httpClientHandler, fb.HttpClient.FacebookCurlHttpClient);
    }
#end

    public function test_httpClientHandlerCanBeForced( )
    {
        var config = ObjectTools.merge(this.config, {
            http_client_handler: 'stream',
        });
        var f = new Facebook(config);
        Assert.is(f.client.httpClientHandler, FacebookHttpClient);
    }

    public function test_settingAnInvalidPersistentDataHandlerThrows( )
    {
        Assert.raises(function( ){
            var config = ObjectTools.merge(this.config, {
                persistent_data_handler: 'foo_handler',
            });
            new Facebook(config);
        }, InvalidArgumentException);
    }

    public function test_persistentDataHandlerCanBeForced( )
    {
        var config = ObjectTools.merge(this.config, {
            persistent_data_handler: 'memory',
        });
        var f = new Facebook(config);
        Assert.is(f.getRedirectLoginHelper().persistentDataHandler, FacebookMemoryPersistentDataHandler);
    }

    public function test_theUrlHandlerWillDefaultToTheFacebookImplementation( )
    {
        var f = new Facebook(this.config);
        Assert.is(f.urlDetectionHandler, FacebookUrlDetectionHandler);
    }

    public function test_anAccessTokenCanBeSetAsAString( )
    {
        var f = new Facebook(this.config);
        f.setDefaultAccessToken('foo_token');
        var accessToken : AccessToken = f.defaultAccessToken;

        // Assert.is(accessToken, AccessToken);
        Assert.equals('foo_token', '$accessToken');
    }

    public function test_anAccessTokenCanBeSetAsAnAccessTokenEntity( )
    {
        var f = new Facebook(this.config);
        f.setDefaultAccessToken(new AccessToken('bar_token'));
        var accessToken : AccessToken = f.defaultAccessToken;

        // Assert.is(accessToken, AccessToken);
        Assert.equals('bar_token', '$accessToken');
    }

    public function test_settingAnInvalidPseudoRandomStringGeneratorThrows( )
    {
        Assert.raises(function( ){
            var config = ObjectTools.merge(this.config, {
                pseudo_random_string_generator: 'foo_generator',
            });
            new Facebook(config);
        }, InvalidArgumentException);
    }

    public function test_randomBytesCsprgCanBeForced( )
    {
        var config = ObjectTools.merge(this.config, {
            persistent_data_handler: 'memory', // To keep session errors from happening
            pseudo_random_string_generator: 'random_bytes'
        });
        var f = new Facebook(config);

        Assert.is(f.getRedirectLoginHelper().pseudoRandomStringGenerator, RandomBytesPseudoRandomStringGenerator);
    }

    public function test_urandomCsprgCanBeForced( )
    {
        if (!FileSystem.exists('/dev/urandom') || FileSystem.isDirectory('/dev/urandom'))
        {
            Assert.isTrue(true);
            return; // this.markTestSkipped('/dev/urandom not found or is not readable.');
        }

        var config = ObjectTools.merge(this.config, {
            persistent_data_handler: 'memory', // To keep session errors from happening
            pseudo_random_string_generator: 'urandom'
        });
        var f = new Facebook(config);

        Assert.is(f.getRedirectLoginHelper().pseudoRandomStringGenerator, UrandomPseudoRandomStringGenerator);
    }

    public function test_creatingANewRequestWillDefaultToTheProperConfig( )
    {
        var config = ObjectTools.merge(this.config, {
            default_access_token: new AccessToken('foo_token'),
            enable_beta_mode: true,
            default_graph_version: new GraphVersion('v1337'),
        });
        var f = new Facebook(config);

        var request = f.request('FOO_VERB', '/foo');

        Assert.equals('1337', request.app.id);
        Assert.equals('foo_secret', request.app.secret);
        Assert.equals('foo_token', '${request.accessToken}');
        Assert.equals('v1337', request.graphVersion);
        Assert.equals(FacebookClient.BASE_GRAPH_URL_BETA, f.client.getBaseGraphUrl());
    }

    public function test_creatingANewBatchRequestWillDefaultToTheProperConfig( )
    {
        var config = ObjectTools.merge(this.config, {
            default_access_token: new AccessToken('foo_token'),
            enable_beta_mode: true,
            default_graph_version: new GraphVersion('v1337'),
        });
        var f = new Facebook(config);

        var batchRequest = f.newBatchRequest();

        Assert.equals('1337', batchRequest.app.id);
        Assert.equals('foo_secret', batchRequest.app.secret);
        Assert.equals('foo_token', '${batchRequest.accessToken}');
        Assert.equals('v1337', batchRequest.graphVersion);
        Assert.equals(FacebookClient.BASE_GRAPH_URL_BETA, f.client.getBaseGraphUrl());
        Assert.is(batchRequest, FacebookBatchRequest);
        Assert.equals(0, batchRequest.requests.length);
    }

    public function test_canInjectCustomHandlers( )
    {
        var config = ObjectTools.merge(this.config, {
            http_client_handler: new FooClientInterface(),
            persistent_data_handler: new FooPersistentDataInterface(),
            url_detection_handler: new FooUrlDetectionInterface(),
            pseudo_random_string_generator: new FooBarPseudoRandomStringGenerator(),
        });
        var f = new Facebook(config);
        
        Assert.is(f.client.httpClientHandler, FooClientInterface);
        Assert.is(f.getRedirectLoginHelper().persistentDataHandler, FooPersistentDataInterface);
        Assert.is(f.getRedirectLoginHelper().urlDetectionHandler, FooUrlDetectionInterface);
        Assert.is(f.getRedirectLoginHelper().pseudoRandomStringGenerator, FooBarPseudoRandomStringGenerator);
    }

    public function test_paginationReturnsProperResponse( )
    {
        var config = ObjectTools.merge(this.config, {
            http_client_handler: new FooClientInterface(),
        });
        var f = new Facebook(config);

        var request = new FacebookRequest(f.app, new AccessToken('foo_token'), 'GET');
        var graphEdge = new GraphEdge(
            request,
            new StringMap(),
            {
                paging: {
                    cursors: {
                        after: 'bar_after_cursor',
                        before: 'bar_before_cursor',
                    },
                    previous: 'previous_url',
                    next: 'next_url',
                }
            },
            '/1337/photos',
            GraphUser
        );

        var nextPage : GraphEdge = f.next(graphEdge);

        Assert.is(nextPage, GraphEdge);
        Assert.is(nextPage.all().get('0'), GraphUser);
        Assert.equals('Foo', nextPage.all().get('0').getName());

        var lastResponse = f.lastResponse;
        Assert.is(lastResponse, FacebookResponse);
        Assert.equals(1337, lastResponse.httpStatusCode);
    }

    public function test_canGetSuccessfulTransferWithMaxTries( )
    {
        var config = ObjectTools.merge(this.config, {
            http_client_handler: new FakeGraphApiForResumableUpload(),
        });
        var f = new Facebook(config);

        var response = f.uploadVideo('me', 'test/files/foo.txt', 'foo-token', 3);
        Assert.same({video_id: '1337', success: true,}, response);
    }

    public function off_test_maxingOutRetriesWillThrow( )
    {
        Assert.raises(function( ){
            var client = new FakeGraphApiForResumableUpload();
            client.failOnTransfer();

            var config = ObjectTools.merge(this.config, {
                http_client_handler: client,
            });
            var f = new Facebook(config);

            f.uploadVideo('4', 'test/files/foo.txt', 'foo-token', 3);
        }, FacebookResponseException);
    }

/*
    public function off_test_settingAnAccessThatIsNotStringOrAccessTokenThrows( )
    {
        Assert.raises(function( ){
            var config : FacebookOptions = ObjectTools.merge(this.config, {
                default_access_token: 123,
            });
            new Facebook(config);
        }, InvalidArgumentException);
    }
    public function ofF_test_settingAnInvalidUrlHandlerThrows( )
    {
        Assert.raises(function( ){
            var config = ObjectTools.merge(this.config, {
                url_detection_handler: 'foo_handler',
            });
            new Facebook(config);
        }, InvalidArgumentException);
    }
*/
}