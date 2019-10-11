package fb.upload;

import haxe.CallStack;
import haxe.io.Path;
import sys.io.FileInput;
import sys.io.File;
import sys.FileSystem;
import fb.error.FacebookSDKException;


class FacebookFile
{
    /**
     * The path to the file on the system.
     */
    var path : Path;

    /**
     * The maximum bytes to read. Defaults to -1 (read all the remaining buffer).
     */
    var maxLength : Int;

    /**
     * Seek to the specified offset before reading. If this number is negative, no seeking will occur and reading will start from the current position.
     */
    var offset : Int;

    /**
     * The stream pointing to the file.
     */
    var stream : FileInput;


    public function new( filePath : String, maxLength : Int = -1, offset : Int = -1 )
    {
        this.path = new Path(filePath);
        this.maxLength = maxLength;
        this.offset = offset;

        open();
    }

    /**
     * Opens a stream for the file.
     */
    public function open( ) : Void
    {
        var p = path.toString();

        // TODO: add ability to read remote file
        if (isRemoteFile(p))
            throw new FacebookSDKException('Failed to create FacebookFile entity. Unable to read remote resource: [$p].');

        if (!FileSystem.exists(p) || FileSystem.isDirectory(p))
            throw new FacebookSDKException('Failed to create FacebookFile entity. Unable to read resource: [$p].');

        try
        {
            stream = File.read(p, true);
        }
        catch( e : Dynamic )
        {
            throw new FacebookSDKException('Failed to create FacebookFile entity. Unable to read resource: [$p].\nMessage: $e');
        }
    }

    /**
     * Stops the file stream.
     */
    public function close( ) : Void
    {
        if (stream != null)
        {
            stream.close();
            stream = null;
        }
    }

    /**
     * Return the contents of the file.
     * @return String
     */
    public function getContents( ) : String
    {
        if (offset > 0)
            stream.seek(offset, SeekBegin);
        
        return maxLength > 0 ? stream.readString(maxLength) : stream.readAll().toString();
    }

    /**
     * Return the name of the file.
     * @return String
     */
    public function getFileName( ) : String return '${path.file}.${path.ext}';

    /**
     * Return the path of the file.
     * @return String
     */
    public function getFilePath( ) : String return path.toString();

    /**
     * Return the size of the file.
     * @return Int
     */
    public function getSize( ) : Int return FileSystem.stat(path.toString()).size;

    /**
     * Return the mimetype of the file.
     *
     * @return string
     */
    public function getMimetype()
    {
        var mime = Mimetypes.fromExtension(path.ext);
        return mime != null ? mime : 'text/plain';
    }

    /**
     * Returns true if the path to the file is remote.
     * @param pathToFile 
     * @return Bool
     */
    function isRemoteFile( pathToFile : String ) : Bool return erRemoteFile.match(pathToFile);
    static var erRemoteFile = ~/^(https?|ftp):\/\/.*/;
}