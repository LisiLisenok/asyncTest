import ceylon.language.meta.declaration {
	FunctionDeclaration,
	FunctionOrValueDeclaration
}
import ceylon.language.meta {
	type,
	optionalAnnotation
}
import herd.asynctest.internal {
	declarationVerifier,
	extractSourceValue
}


"Indicates that the test function has to be executed with variants provided by combinations
 of the test function agrument values.  
 [[DataSourceAnnotation]] annotation has to be applied to the each argument of the test function in order to
 specify a list of possible argument values.  
 [[combinator]] function is responsible to generate test variants and to provide [[TestVariantEnumerator]].
 "
tagged( "Applying combinatorial" )
see( `function combinatorial`, `class ParameterizedAnnotation`, `class DataSourceAnnotation`,
	`function permuting`, `function zipping`, `function mixing` )
since( "0.6.1" ) by( "Lis" )
shared final annotation class CombinatorialAnnotation (
	"Combinator function which has to return [[TestVariantEnumerator]] and takes `ArgumentVariants[]`
	 which is generated based on [[DataSourceAnnotation]] at each test function argument.  
	 > Each test function argument has to be marked with [[DataSourceAnnotation]]!"
	shared FunctionDeclaration combinator,
	"Maximum number of failed variants to stop testing. Unlimited if <= 0."
	shared Integer maxFailedVariants
)
		satisfies SequencedAnnotation<CombinatorialAnnotation, FunctionDeclaration> & TestVariantProvider
{
	
	"Asserts if argument list is empty."
	[Anything+] extractNonemptyArgumentList( FunctionOrValueDeclaration source, Object? instance ) {
		"Agrument list for combinatorial testing has to be nonempty."
		assert( nonempty ret = extractSourceValue<Anything[]>( source, instance ) );
		return ret;
	}
	
	
	"Extracts argument source if available."
	ArgumentVariants resolveArgumentSource (
		"Test function to extract source for." FunctionDeclaration testFunction,
		"Declaration to resolve argument source." FunctionOrValueDeclaration declaration,
		"Instance of the test class or `null` if not available." Object? instance
	) {
		if ( exists argProvider = optionalAnnotation( `DataSourceAnnotation`, declaration ) ) {
			return ArgumentVariants (
				testFunction, declaration,
				extractSourceValue<CombinatorialKind>( argProvider.kind, instance ),
				extractNonemptyArgumentList( argProvider.source, instance )
			);
		}
		else {
			throw AssertionError( "Argument ``declaration.name`` of test function ``testFunction.name`` doesn't have data source." );
		}
	}
	
	
	throws( `class AssertionError`, "At least one of the test function argument doesn't contain `argument` annotation 
	                                 or argument source function returns empty argument list." )
	shared actual TestVariantEnumerator variants( FunctionDeclaration testFunction, Object? instance ) {
		value params =
			if ( declarationVerifier.isAsyncDeclaration( testFunction ) )
			then testFunction.parameterDeclarations.rest
			else testFunction.parameterDeclarations;
		value args = [ for ( item in params ) resolveArgumentSource( testFunction, item, instance ) ];
		return TestVariantMaxFailureEnumerator (
			if ( !combinator.toplevel, exists instance ) 
			then combinator.memberApply<Nothing, TestVariantEnumerator, Nothing>( type( instance ) ).bind( instance ).apply( args )
			else combinator.apply<TestVariantEnumerator, Nothing>().apply( args ),
			maxFailedVariants
		);
	}
	
}


"Indicates the test has to be performed with combinatorial test variants.  
 See details in [[CombinatorialAnnotation]]."
tagged( "Applying combinatorial" )
see( `function permuting`, `function zipping`, `function mixing` )
since( "0.6.1" ) by( "Lis" )
shared annotation CombinatorialAnnotation combinatorial (
	"Combinator function which has to return [[TestVariantEnumerator]] and takes `ArgumentVariants[]`
	 which is generated based on [[DataSourceAnnotation]] at each test function argument.  
	 > Each test function argument has to be marked with [[DataSourceAnnotation]]!"
	FunctionDeclaration combinator,
	"Maximum number of failed variants to stop testing. Unlimited if <= 0."
	Integer maxFailedVariants = -1
) => CombinatorialAnnotation( combinator, maxFailedVariants );
