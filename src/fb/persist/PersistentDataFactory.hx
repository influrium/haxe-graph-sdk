package fb.persist;

import fb.error.*;


class PersistentDataFactory
{
    private function new( )
    {
        // a factory constructor should never be invoked
    }

    /**
     * PersistentData generation.
     * @param PersistentDataInterface|string|null $handler
     * @throws InvalidArgumentException If the persistent data handler isn't "session", "memory", or an instance of Facebook\PersistentData\PersistentDataInterface.
     * @return PersistentDataInterface
     */
    public static function createPersistentDataHandler( handler : Dynamic ) : PersistentDataInterface
    {
        if (handler == null)
            // return session_status() == PHP_SESSION_ACTIVE ? new FacebookSessionPersistentDataHandler() : new FacebookMemoryPersistentDataHandler();
            return new FacebookMemoryPersistentDataHandler();

        if (Std.is(handler, PersistentDataInterface) )
            return handler;

        if (Std.is(handler, String)) switch (cast(handler, String))
        {
            // case 'session': return new FacebookSessionPersistentDataHandler();
            case 'memory': return new FacebookMemoryPersistentDataHandler();
            default:
        }

        throw new InvalidArgumentException('The persistent data handler must be set to "session", "memory", or be an instance of fb.oersist.PersistentDataInterface');
        return null;
    }
}
