
"Executes test function in a single thread.  
 Test function takes no argument - the same as to `SingleBench<[]>`."
tagged( "Bench" )
see( `function benchmark`, `class SingleBench` )
since( "0.7.0" ) by( "Lis" )
shared final class EmptyParameterBench (
	"Bench title. Generally unique."
	String title,
	"Function to be tested."
	shared actual Anything() bench
)
		extends BaseBench<[]>( title )
{
	
	shared actual Boolean equals( Object other ) {
		if ( is EmptyParameterBench other ) {
			return title == other.title;
		}
		else {
			return false;
		}
	}
	
}
