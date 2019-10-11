package fb.upload;


class FacebookTransferChunk
{
    /**
     * The file to chunk during upload.
     */
    public var file (default, null) : FacebookFile;

    /**
     * The ID of the upload session.
     */
    public var uploadSessionId (default, null) : String;

    /**
     * Start byte position of the next file chunk.
     */
    public var startOffset (default, null) : Int;

    /**
     * End byte position of the next file chunk.
     */
    public var endOffset (default, null) : Int;

    /**
     * The ID of the video.
     */
    public var videoId (default, null) : String;

    /**
     * @param FacebookFile $file
     * @param int $uploadSessionId
     * @param int $videoId
     * @param int $startOffset
     * @param int $endOffset
     */
    public function new( file : FacebookFile, uploadSessionId : String, videoId : String, startOffset : Int, endOffset : Int )
    {
        this.file = file;
        this.uploadSessionId = uploadSessionId;
        this.videoId = videoId;
        this.startOffset = startOffset;
        this.endOffset = endOffset;
    }

    /**
     * Return a FacebookFile entity with partial content.
     * @return FacebookFile
     */
    public function getPartialFile( ) : FacebookFile
    {
        var maxLength : Int = endOffset - startOffset;
        file.close();
        return new FacebookFile(file.getFilePath(), maxLength, startOffset);
    }

    /**
     * Check whether is the last chunk
     * @return Bool
     */
    public function isLastChunk( ) : Bool
    {
        return startOffset == endOffset;
    }
}