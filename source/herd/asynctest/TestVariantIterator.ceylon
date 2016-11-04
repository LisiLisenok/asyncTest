import ceylon.test {
	TestState
}


"Iterates variants by arguments list."
since( "0.6.0" ) by( "Lis" )
class TestVariantIterator (
	Iterator<FunctionParameters> argsIterator,
	Integer maxFailedVariants
)
		satisfies Iterator<TestVariant>
{
	variable Integer variantsFailed = 0;
	
	void completed( TestVariantResult result ) {
		if ( result.overallState > TestState.success ) {
			variantsFailed ++;
		}
	}
	
	
	"`TestVariant` which uses given type parameters and function arguments."
	class TypedTestVariant (
		shared actual FunctionParameters parameters
	)
			satisfies TestVariant
	{
		shared actual void completed( TestVariantResult result ) => outer.completed( result );
	}
	
	
	shared actual TestVariant|Finished next() {
		if ( maxFailedVariants < 1 || maxFailedVariants > variantsFailed ) {
			if ( is FunctionParameters nn = argsIterator.next() ) {
				return TypedTestVariant( nn );
			}
		}
		return finished;
	}
	
}

