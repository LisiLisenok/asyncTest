import ceylon.language.meta.declaration {

	ClassDeclaration,
	Package,
	Module,
	FunctionOrValueDeclaration,
	FunctionDeclaration,
	ValueDeclaration
}
import ceylon.test.annotation {

	TestExecutorAnnotation
}
import ceylon.test {

	testExecutor
}
import ceylon.language.meta {

	type
}
import herd.asynctest.runner {

	RepeatStrategy,
	RepeatRunner
}


"The same as `testExecutor(`\`class AsyncTestExecutor\``)`"
since( "0.6.0" ) by( "Lis" )
shared annotation TestExecutorAnnotation async() => testExecutor(`class AsyncTestExecutor`);


"Calls [[source]] to get source value."
since( "0.6.0" ) by( "Lis" )
Result extractSourceValue<Result>( FunctionOrValueDeclaration source, Object? instance ) {
	switch ( source )
	case ( is FunctionDeclaration ) {
		return if ( !source.toplevel, exists instance ) 
			then source.memberApply<Nothing, Result, []>( type( instance ) ).bind( instance )()
			else source.apply<Result, []>()();
	}
	case ( is ValueDeclaration ) {
		return if ( !source.toplevel, exists instance ) 
			then source.memberApply<Nothing, Result>( type( instance ) ).bind( instance ).get()
			else source.apply<Result>().get();
	}
}


"Annotation class for [[arguments]]."
see( `function arguments` )
since( "0.5.0" ) by( "Lis" )
shared final annotation class ArgumentsAnnotation (
	"The source function or value declaration which has to take no arguments and has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	shared FunctionOrValueDeclaration source
)
		satisfies OptionalAnnotation<ArgumentsAnnotation, ClassDeclaration|FunctionDeclaration>
{
	
	"Calls [[source]] to get argument stream."
	shared Anything[] argumentList (
		"Instance of the test class or `null` if test is performed using top-level function." Object? instance
	) => extractSourceValue<Anything[]>( source, instance );
	
}


"Indicates that test container class or test prepost function have to be instantiated
 or called using arguments provided by this annotation, see [[ArgumentsAnnotation.argumentList]].  
 
 Example:
 		[Hobbit] who => [bilbo];
 		{[[], [Dwarf]]*} dwarves => {[[], [fili]], [[], [kili]], [[], [balin]], [[], [dwalin]]...};
 		
 		arguments(`value who`)
 		class HobbitTester(Hobbit hobbit) {
 			shared test async
 			parameterized(`value dwarves`)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 				context.complete();
 			}
 		}
 
 "
since( "0.5.0" ) by( "Lis" )
shared annotation ArgumentsAnnotation arguments (
	"The source function or value declaration which has to take no arguments and has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	FunctionOrValueDeclaration source
)
		=> ArgumentsAnnotation( source );



"Annotation class for [[parameterized]]."
since( "0.6.0" ) by( "Lis" )
see( `function parameterized`, `class TestVariant` )
shared final annotation class ParameterizedAnnotation (
	"The source function or value declaration which has to take no arguments and has to return a stream
	 of test variants: `{TestVariant*}`.  
	 The source may be either top-level or tested class shared member."
	shared FunctionOrValueDeclaration source,
	"Maximum number of failed variants before stop. Unlimited if <= 0."
	shared Integer maxFailedVariants
)
		satisfies SequencedAnnotation<ParameterizedAnnotation, FunctionDeclaration> & TestVariantProvider
{
	
	"Returns test variant enumerator based on test variants extracted from `source`."
	shared actual TestVariantEnumerator variants( Object? instance )
		=> TestVariantIterator (
			extractSourceValue<{TestVariant*}>( source, instance ).iterator().next,
			maxFailedVariants
		);
	
}


"Indicates that generic (with possibly empty generic parameter list) test function
 has to be executed with given test variants.  
 
 The annotation provides parameterized testing based on collection of test variants.
 It takes two arguments:  
 1. Declaration of function or value which returns a collection of test variants `{TestVariant*}`.
 2. Number of failed variants to stop testing. Default is -1 which means no limit.  
 
 The test will be performed using all test variants returned by the given stream
 or while total number of failed variants not exceeds specified limit. 
 
 > [[parameterized]] annotation may occur multiple times at a given test function.  
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
 			context.assertThat(identity<Value>(arg), EqualObjects<Value>(arg), \"\", true );
 			context.complete();
 		}
 
 In the above example the function `testIdentity` will be called 3 times:
 *		testIdentity<String>(context, \"stringIdentity\");
 *		testIdentity<Integer>(context, 1);
 *		testIdentity<Float>(context, 1.0);
 
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


"Annotation class for [[factory]]."
see( `function factory`, `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class FactoryAnnotation (
	"Function used to instantiate anotated class.  
	 Has to take no arguments or just a one argument of [[AsyncFactoryContext]] type.  
	 Has to return an instance of the looking class."
	shared FunctionDeclaration factoryFunction
)
		satisfies OptionalAnnotation<FactoryAnnotation, ClassDeclaration>
{}


"Indicates that class has to be instantiated using a given factory function.  
 [[factory]] annotation takes declaration of top-level factory function.  
 
 Factory function has to take no arguments or take first argument of [[AsyncFactoryContext]] type.  
 If factory function takes [[AsyncFactoryContext]] as first argument it is executed asynchronously and may
 fill the context with instantiated object using [[AsyncFactoryContext.fill]]
 or may report on error using [[AsyncFactoryContext.abort]]. Test executor blocks the current thread until
 one of [[AsyncFactoryContext.fill]] or [[AsyncFactoryContext.abort]] is called.  
 Otherwise factory function doesn't take [[AsyncFactoryContext]] as first argument. It is executed synchronously
 and has to return instantiated non-optional object or throw an error.  
 
 
 #### Example of synchronous instantiation:
 
 		StarshipTest createStarshipTest() => StarshipTest(universeSize);
 
 		factory(`function createStarshipTest`)
 		class StarshipTest(Integer universeSize) {
 			...
 		} 		
 
 #### Example of asynchronous instantiation:
 
 		StarshipTest createStarshipTest(AsyncFactoryContext context) {
 			context.fill(StarshipTest(universeSize));
 		}
 
 		factory(`function createStarshipTest`)
 		class StarshipTest(Integer universeSize) {
 			...
 		} 		
 
 
 > Pay attention:  
 > Asynchronous version has to call [[AsyncFactoryContext.fill]] or [[AsyncFactoryContext.abort]].  
 > Synchronous version has to return non-optional object or throw.  
 "
see( `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
shared annotation FactoryAnnotation factory (
	"Function used to instantiate anotated class.  
	 Has to take no arguments or just a one argument of [[AsyncFactoryContext]] type.  
	 Has to return an instance of the looking class."
	FunctionDeclaration factoryFunction
	
) => FactoryAnnotation( factoryFunction );


"Annotation class for [[concurrent]]."
see( `function concurrent` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class ConcurrentAnnotation()
	satisfies OptionalAnnotation<ConcurrentAnnotation, ClassDeclaration | Package | Module>
{}


"Indicates that all test suites (each suite contains all top-level test functions in the given package
 or all test methods of the given class) contained in the marked container have to be executed in concurrent mode.    
 The functions within each suite are executed sequentially in a one thread while the suites are executed concurrently
 using thread pool of number of available cores size.  
 
 > Thread pool with fixed number of threads equals to number of available processors (cores)
   is used to execute tests in concurrent mode."
since( "0.6.0" ) by( "Lis" )
shared annotation ConcurrentAnnotation concurrent() => ConcurrentAnnotation();


"Annotation class for [[timeout]]."
see( `function timeout` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class TimeoutAnnotation( "Timeout in milliseconds." shared Integer timeoutMilliseconds )
	satisfies OptionalAnnotation<TimeoutAnnotation, FunctionDeclaration | ValueDeclaration
		 | ClassDeclaration | Package | Module>
{}


"Indicates that if test function execution takes more than `timeoutMilliseconds` the test has to be interrupted.  
 The annotation is applied to any function called using [[AsyncTestExecutor]]: prepost functions, test rules,
 factory and test functions."
since( "0.6.0" ) by( "Lis" )
shared annotation TimeoutAnnotation timeout( "Timeout in milliseconds." Integer timeoutMilliseconds )
		=> TimeoutAnnotation( timeoutMilliseconds );


"Annotation class for [[retry]]."
see( `function retry` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class RetryAnnotation (
	"Repeat strategy source which has to take no arguments and has to return instance of [[RepeatStrategy]] type.
	 Either top-level function or value or test function container method or attribute."
	shared FunctionOrValueDeclaration source
)
		satisfies OptionalAnnotation<RetryAnnotation, Module | Package | ClassDeclaration | FunctionDeclaration>
{}


"Indicates that test function or all functions within test container have to be tested using the given
 `RepeatStrategy` (extracted from `source`).  
 
 > Overall execution cycle including `before`, `after` and `testRule` callbacks are repeated!  
 
 If you need to repeat just test function execution, look on [[RepeatRunner]].
 "
see( `class RepeatRunner`, `interface RepeatStrategy` )
since( "0.6.0" ) by( "Lis" )
shared annotation RetryAnnotation retry (
	"Repeat strategy source which has to take no arguments and has to return instance of [[RepeatStrategy]] type.
	 Either top-level function or value or test function container method or attribute."
	FunctionOrValueDeclaration source
)
		=> RetryAnnotation( source );
