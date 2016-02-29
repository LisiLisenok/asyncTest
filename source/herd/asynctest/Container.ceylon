

"Represents an item can be stored on [[TestInitContext]].  
 Container is disposed when test run is finished."
see( `interface TestInitContext` )
by( "Lis" )
class Container<out Item> (
	"Item this container contains." Item initial,
	"Dispose the container. To be called when test run is finished." void disposeItem()
 ) {
 	
 	variable Item? itemSotre = initial;
 	
 	
 	shared Item? item => itemSotre;
 	
 	shared void dispose() {
 		itemSotre = null;
 		disposeItem();
 	}
 	
 }
