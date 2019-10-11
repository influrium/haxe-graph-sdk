package cases.prs;

import utest.Assert;

import sys.FileSystem;

import fb.prs.UrandomPseudoRandomStringGenerator;


class UrandomPseudoRandomStringGeneratorTest extends utest.Test
{
    public function testCanGenerateRandomStringOfArbitraryLength( )
    {
        if (!FileSystem.exists('/dev/urandom') || FileSystem.isDirectory('/dev/urandom'))
        {
            Assert.pass('/dev/urandom not found or is not readable.');
            return;
        }

        var prsg = new UrandomPseudoRandomStringGenerator();
        var randomString = prsg.getPseudoRandomString(10);
        
        Assert.match(~/^([0-9a-f]+)$/, randomString);
        Assert.equals(10, randomString.length);
    }
}