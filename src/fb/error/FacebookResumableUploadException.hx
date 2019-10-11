package fb.error;

class FacebookResumableUploadException extends FacebookSDKException
{
    public var startOffset (default, null) : Int;
    public var endOffset (default, null) : Int;

    public function setStartOffset( startOffset : Int ) : Void this.startOffset = startOffset;
    public function setEndOffset( endOffset : Int ) : Void this.endOffset = endOffset;
}
