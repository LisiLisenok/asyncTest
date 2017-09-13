import herd.asynctest.internal {
	extractSourceValue
}
import ceylon.language.meta.declaration {
	FunctionOrValueDeclaration,
	FunctionDeclaration
}


"Indicates that generic (with possibly empty generic parameter list) test function
 has to be executed with given test variants.  
 
 The annotation provides parameterized testing based on collection of test variants.
 It takes two arguments:  
 1. Declaration of function or value which returns a collection of test variants `{TestVariant*}`.  
 2. Number of failed variants to stop testing. Default is -1 which means no limit.  
 
 The test will be performed using all test variants returned by the given stream
 or while total number of failed variants not exceeds specified limit.  
 
 > `parameterized` annotation may occur multiple times at a given test function.  
 > The variants source may be either top-level or tested class shared member.  
 
 
 #### Example:
 
 		Value identity<Value>(Value argument) => argument;
 		
 		{TestVariant*} identityArgs => {
 			TestVariant([`String`], [\"stringIdentity\"]),
 			TestVariant([`Integer`], [1]),
 			TestVariant([`Float`], [1.0])
 		};
 		
 		shared test async
 		parameterized(`value identityArgs`)
 		void testIdentity<Value>(AsyncTestContext context, Value arg)
 			given Value satisfies Object
 		{
 			context.assertThat(identity<Value>(arg), EqualObjects<Value>(arg), \"\", true);
 			context.complete();
 		}
 
 In the above example the function `testIdentity` will be called 3 times:  
 * `testIdentity<String>(context, \"stringIdentity\");`  
 * `testIdentity<Integer>(context, 1);`  
 * `testIdentity<Float>(context, 1.0);`  
 
 In order to run test with conventional (non-generic function) type parameters list has to be empty:  
  		[Hobbit] who => [bilbo];
 		{TestVariant*} dwarves => {
 			TestVariant([], [fili]),
 			TestVariant([], [kili]),
 			TestVariant([], [balin],
 			TestVariant([], [dwalin]),
 			...
 		};
 		
 		arguments(`value who`)
 		class HobbitTester(Hobbit hobbit) {
 			shared test async
 			parameterized(`value dwarves`, 2)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 				context.complete();
 			}
 		}
 		
 In this example class `HobbitTester` is instantiated once with argument provided by value `who` and
 method `thereAndBackAgain` is called multiply times according to size of `dwarves` stream.  
 According to second argument of `parameterized` annotation the test will be stopped
 if two different invoking of `thereAndBackAgain` with two different arguments report failure.  
 "
tagged( "varianted" )
see( `function parameterized`, `class TestVariant`, `class CombinatorialAnnotation` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class ParameterizedAnnotation (
	"The source function or value declaration which has to return a stream
	 of test variants: `{TestVariant*}`.  
	 The source may be either top-level or tested class shared member."
	shared FunctionOrValueDeclaration source,
	"Maximum number of failed variants to stop testing. Unlimited if <= 0."
	shared Integer maxFailedVariants
)
		satisfies SequencedAnnotation<ParameterizedAnnotation, FunctionDeclaration> & TestVariantProvider
{
	
	"Returns test variant enumerator based on test variants extracted from `source`."
	shared actual TestVariantEnumerator variants( FunctionDeclaration testFunction, Object? instance)
			=> TestVariantIterator (
				extractSourceValue<{TestVariant*}>( source, instance ).iterator().next,
				maxFailedVariants
			);
	
}


"Provides parameters for the parameterized testing. See [[ParameterizedAnnotation]] for the details."
tagged( "varianted" )
see( `class TestVariant` )
since( "0.6.0" ) by( "Lis" )
shared annotation ParameterizedAnnotation parameterized (
	"The source function or value declaration which has to take no arguments and has to return
	 a stream of test variants: `{TestVariant*}`.  
	 The source may be either top-level or tested class shared member."
	FunctionOrValueDeclaration source,
	"Maximum number of failed variants before stop. Unlimited if <= 0."
	Integer maxFailedVariants = -1
)
		=> ParameterizedAnnotation( source, maxFailedVariants );
