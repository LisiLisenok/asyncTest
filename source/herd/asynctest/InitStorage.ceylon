import java.util.concurrent.locks {

	ReentrantLock
}
import ceylon.collection {

	HashMap
}


"map of containers"
by( "Lis" )
interface InitStorage {
	
	"returns stored item"
	shared formal Item? retrieve<Item>( String name );
	
	"returns all items of given type"
	shared formal Item[] retrieveAll<Item>();
	
	"disposes all stored items"
	shared formal void dispose();
	
}


"empty container map"
class EmptyInitStorage() satisfies InitStorage
{
	shared actual Item? retrieve<Item>(String name) => null;
	shared actual Item[] retrieveAll<Item>() => [];
	shared actual void dispose() {}
}


"stores containers"
by( "Lis" )
class ContainerStorage() satisfies InitStorage
{
	"locks concurent access"
	ReentrantLock locker = ReentrantLock();
	
	"containers stored here"
	HashMap<String, Container<Anything>> containers = HashMap<String, Container<Anything>>(); 
	
	
	"returns item from container"
	Item? containerItem<Item>( Container<Anything> con )
		=> if ( is Item ret = con.item ) then ret else null;
	
	
	"`true` if storage is empty and `false` otherwise"
	shared Boolean empty => containers.empty;
	
	"stores item"
	shared void store( String name, Container<Anything> container ) {
		locker.lock();
		try {
			containers.put( name, container );
		}
		finally {
			locker.unlock();
		}
	}

	"returns stored item"
	shared actual Item? retrieve<Item>( String name ) {
		locker.lock();
		try {
			if ( is Container<Item> ret = containers.get( name ) ) {
				return ret.item;
			}
			else {
				return null;
			}
		}
		finally {
			locker.unlock();
		}
	}
	
	"returns all items of given type"
	shared actual Item[] retrieveAll<Item>() {
		locker.lock();
		try {
			return containers.items.map( containerItem<Item> ).coalesced.sequence();
		}
		finally {
			locker.unlock();
		}
	}
	
	"disposes all containers"
	shared actual void dispose() {
		locker.lock();
		try {
			for ( con in containers.items ) {
				con.dispose();
			}
			containers.clear();
		}
		finally {
			locker.unlock();
		}
	}
	
}
