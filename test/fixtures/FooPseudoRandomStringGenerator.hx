package fixtures;

import fb.prs.PseudoRandomStringGeneratorInterface;

class FooPseudoRandomStringGenerator implements PseudoRandomStringGeneratorInterface
{
    public function new( )
    {

    }
    
    public function getPseudoRandomString( length : Int ) : String
    {
        return 'csprs123';
    }
}