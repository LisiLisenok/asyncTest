
"Executes test function in a single thread."
tagged( "Bench" )
see( `function benchmark`, `class EmptyParameterBench` )
since( "0.7.0" ) by( "Lis" )
shared final class SingleBench<Parameter> (
	"Bench title. Generally unique."
	String title,
	"Function to be tested."
	shared actual Anything(*Parameter) runIteration
)
	extends BaseBench<Parameter>( title )
	given Parameter satisfies Anything[]
{
	
	shared actual Boolean equals( Object other ) {
		if ( is SingleBench<Parameter> other ) {
			return title == other.title;
		}
		else {
			return false;
		}
	}
	
}
