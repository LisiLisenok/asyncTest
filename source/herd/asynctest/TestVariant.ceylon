import herd.asynctest.internal {
	typeName,
	stringify
}
import ceylon.language.meta.model {
	Type
}


"Represents test variant, i.e. test function generic type parameters and arguments."
see( `interface TestVariantEnumerator`, `interface TestVariantProvider` )
since( "0.6.0" ) by( "Lis" )
shared class TestVariant (	
	"Generic type parameters."
	shared Type<Anything>[] parameters,
	"Function arguments."
	shared Anything[] arguments
) {

	variable String? memoizedName = null;

	String buildName() {
		StringBuilder builder = StringBuilder();
		
		// add type parameters
		variable Integer size = parameters.size;
		if ( size > 0 ) {
			size --;
			builder.append( "<" );
			for( arg in parameters.indexed ) {
				builder.append( typeName( arg.item ) );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( ">" );
		}
		
		// add function arguments
		size = arguments.size - 1;
		if ( size > -1 ) {
			builder.append( "(" );
			for( arg in arguments.indexed ) {
				builder.append( stringify( arg.item ) );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( ")" );
		}
		return builder.string;
	}
	
	"Returns a name of the variant.  
	 By default name is <'type argument list'>('function argument list')"
	shared default String variantName {
		if ( exists m = memoizedName ) {
			return m;
		}
		else {
			String ret = buildName();
			memoizedName = ret;
			return ret;
		}
	}
}


"Test variant without any arguments."
since( "0.6.0" ) by( "Lis" )
object emptyTestVariant extends TestVariant( [], [] ) {
	shared actual String variantName = "";
}
