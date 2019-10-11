import haxe.io.Path;
import sys.FileSystem;
import utest.Runner;
import utest.ui.Report;

import cases.*;
import cases.auth.*;
import cases.error.*;
import cases.graph.*;
import cases.helper.*;
import cases.http.*;
import cases.prs.*;
import cases.upload.*;


class Main
{
    public static function main( ) : Void
    {
        //the long way
        var runner = new Runner();

        runner.addCase(new FacebookTest());
        runner.addCase(new FacebookAppTest());
        runner.addCase(new FacebookClientTest());

        runner.addCase(new FacebookRequestTest());
        runner.addCase(new FacebookResponseTest());

        runner.addCase(new FacebookBatchRequestTest());

        runner.addCase(new FacebookBatchResponseTest());

        runner.addCase(new SignedRequestTest());

        // Auth
        runner.addCase(new AccessTokenTest());
        runner.addCase(new AccessTokenMetadataTest());
        runner.addCase(new OAuth2ClientTest());

        // Error
        runner.addCase(new FacebookResponseExceptionTest());

        // Helper
        runner.addCase(new FacebookSignedRequestFromInputHelperTest());
        runner.addCase(new FacebookCanvasHelperTest());
        runner.addCase(new FacebookPageTabHelperTest());
        runner.addCase(new FacebookJavaScriptHelperTest());
        runner.addCase(new FacebookRedirectLoginHelperTest());

        // Http
        runner.addCase(new GraphRawResponseTest());

        runner.addCase(new RequestUrlEncodedTest());
        runner.addCase(new RequestBodyMultipartTest());

        // PRS
        runner.addCase(new UrandomPseudoRandomStringGeneratorTest());
        runner.addCase(new RandomBytesPseudoRandomStringGeneratorTest());

        // Upload
        runner.addCase(new FacebookFileTest());
        runner.addCase(new MimetypesTest());
        runner.addCase(new FacebookResumableUploaderTest());

        // Graph
        runner.addCase(new CollectionTest());
        runner.addCase(new GraphEdgeTest());
        // runner.addCase(new GraphNodeTest());

        Report.create(runner);
        runner.run();
    }
}