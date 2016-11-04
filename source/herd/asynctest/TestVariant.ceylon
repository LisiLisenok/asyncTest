import herd.asynctest.internal {
	typeName,
	stringify
}


"Represents test variant:  
 * Provides test function generic type parameters and arguments.  
 * Takes results of the test variant run.  
 "
since( "0.6.0" ) by( "Lis" )
shared interface TestVariant {

	"Test function parameters - generic type parameters and function arguments."
	shared formal FunctionParameters parameters;
	
	"Notified when test is completed."
	shared formal void completed( "Results of the test variant run." TestVariantResult result );

	"Returns a name of the variant.  
	 By default name is <'type argument list'>('function argument list')"
	shared default String variantName() {
		StringBuilder builder = StringBuilder();
		
		// add type parameters
		variable Integer size = parameters.generic.size;
		if ( size > 0 ) {
			size --;
			builder.append( "<" );
			for( arg in parameters.generic.indexed ) {
				builder.append( typeName( arg.item ) );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( ">" );
		}
		
		// add function arguments
		size = parameters.arguments.size - 1;
		if ( size > -1 ) {
			builder.append( "(" );
			for( arg in parameters.arguments.indexed ) {
				builder.append( stringify( arg.item ) );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( ")" );
		}
		return builder.string;
	}
}


"Test variant without any arguments."
since( "0.6.0" ) by( "Lis" )
object emptyTestVariant satisfies TestVariant {
	shared actual FunctionParameters parameters = FunctionParameters( [],[] );
	shared actual void completed(TestVariantResult result) {}
}
