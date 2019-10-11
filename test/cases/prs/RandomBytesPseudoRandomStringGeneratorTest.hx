package cases.prs;

import utest.Assert;

import fb.prs.RandomBytesPseudoRandomStringGenerator;


class RandomBytesPseudoRandomStringGeneratorTest extends utest.Test
{
    public function testCanGenerateRandomStringOfArbitraryLength( )
    {
        var csprng = new RandomBytesPseudoRandomStringGenerator();
        var randomString = csprng.getPseudoRandomString(10);

        Assert.match(~/^([0-9a-f]+)$/, randomString);
        Assert.equals(10, randomString.length);
    }
}