package fixtures;

import fb.prs.PseudoRandomStringGeneratorInterface;


class FooBarPseudoRandomStringGenerator implements PseudoRandomStringGeneratorInterface
{
    public function new( )
    {
        
    }

    public function getPseudoRandomString( length : Int ) : String
    {
        return 'csprs123';
    }
}
