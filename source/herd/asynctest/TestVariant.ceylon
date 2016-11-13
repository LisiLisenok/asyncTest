import herd.asynctest.internal {
	typeName,
	stringify,
	sequenceHash
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
	variable Integer memoizedHash = 0;


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
	
	shared actual default Boolean equals( Object that ) {
		if ( is TestVariant that ) {
			return parameters == that.parameters && 
				arguments == that.arguments && variantName == that.variantName;
		}
		else {
			return false;
		}
	}
	
	shared actual default Integer hash {
		if ( memoizedHash == 0 ) {
			memoizedHash = 31 * sequenceHash( parameters, 31 ) + sequenceHash( arguments, 31 );
			memoizedHash = 31 * memoizedHash + variantName.hash;
		}
		return memoizedHash;
	}
	
}


"Test variant without any arguments."
since( "0.6.0" ) by( "Lis" )
object emptyTestVariant extends TestVariant( [], [] ) {
	shared actual String variantName = "";
	shared actual Boolean equals( Object that ) {
		if ( is TestVariant that ) {
			return that === this;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash => 37;	
}
