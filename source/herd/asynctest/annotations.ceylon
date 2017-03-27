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
import herd.asynctest.runner {

	RepeatStrategy,
	RepeatRunner
}


"The same as `\`testExecutor(`class AsyncTestExecutor`)`\`."
see( `class AsyncTestExecutor` )
since( "0.6.0" ) by( "Lis" )
shared annotation TestExecutorAnnotation async() => testExecutor( `class AsyncTestExecutor` );


"Indicates that test container class or test prepost function have to be instantiated
 or called using arguments provided by this annotation, see [[ArgumentsAnnotation]].  
 
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
 
 > Source function may also be marked with `arguments` annotation.  
 
 "
see( `function arguments` )
since( "0.5.0" ) by( "Lis" )
shared final annotation class ArgumentsAnnotation (
	"The source function or value declaration which has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	shared FunctionOrValueDeclaration source
)
		satisfies OptionalAnnotation<ArgumentsAnnotation, ClassDeclaration|FunctionDeclaration>
{}


"Provides arguments for a one-shot functions. See [[ArgumentsAnnotation]] for details."
since( "0.5.0" ) by( "Lis" )
shared annotation ArgumentsAnnotation arguments (
	"The source function or value declaration which has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	FunctionOrValueDeclaration source
)
		=> ArgumentsAnnotation( source );


"Indicates that class has to be instantiated using a given factory function.  
 [[factory]] annotation takes declaration of top-level factory function.  
 
 #### Factory function arguments    
 * The first argument of [[AsyncFactoryContext]] type and the other arguments according to [[arguments]] annotation
   (or no more arguments if [[arguments]] annotation is omitted):  
   The function is executed asynchronously and may fill the context with instantiated object using [[AsyncFactoryContext.fill]]
   or may report on error using [[AsyncFactoryContext.abort]]. Test executor blocks the current thread until
   one of [[AsyncFactoryContext.fill]] or [[AsyncFactoryContext.abort]] is called.  
 * If no arguments or function takes arguments according to [[arguments]] annotation:  
   The function is executed synchronously and has to return instantiated non-optional object or throw an error.  
 
 
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
see( `function factory`, `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class FactoryAnnotation (
	"Function used to instantiate anotated class.  
	 Has to return an instance of the looking class."
	shared FunctionDeclaration factoryFunction
)
		satisfies OptionalAnnotation<FactoryAnnotation, ClassDeclaration>
{}


"Provides factory function for an object instantiation. See [[FactoryAnnotation]] for the details."
see( `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
shared annotation FactoryAnnotation factory (
	"Function used to instantiate anotated class.  
	 See [[FactoryAnnotation]] for the requirements to the factory function arguments.  
	 Has to return an instance of the looking class."
	FunctionDeclaration factoryFunction
	
) => FactoryAnnotation( factoryFunction );


"Indicates that all test suites (each suite contains all top-level test functions in the given package
 or all test methods of the given class) contained in the marked container have to be executed in concurrent mode.    
 The functions within each suite are executed sequentially in a one thread while the suites are executed concurrently
 using thread pool of number of available cores size.  
 
 > Thread pool with fixed number of threads equals to number of available processors (cores)
   is used to execute tests in concurrent mode."
see( `function concurrent` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class ConcurrentAnnotation()
	satisfies OptionalAnnotation<ConcurrentAnnotation, ClassDeclaration | Package | Module>
{}


"Indicates that all test suites contained in the marked container have to be executed in concurrent mode."
since( "0.6.0" ) by( "Lis" )
shared annotation ConcurrentAnnotation concurrent() => ConcurrentAnnotation();


"Indicates that if test function execution takes more than `timeoutMilliseconds` the test has to be interrupted.  
 The annotation is applied to any function called using [[AsyncTestExecutor]]: prepost functions, test rules,
 factory and test functions."
see( `function timeout` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class TimeoutAnnotation( "Timeout in milliseconds." shared Integer timeoutMilliseconds )
	satisfies OptionalAnnotation<TimeoutAnnotation, FunctionDeclaration | ValueDeclaration
		 | ClassDeclaration | Package | Module>
{}


"Indicates that if test function execution takes more than `timeoutMilliseconds` the test has to be interrupted."
since( "0.6.0" ) by( "Lis" )
shared annotation TimeoutAnnotation timeout( "Timeout in milliseconds." Integer timeoutMilliseconds )
		=> TimeoutAnnotation( timeoutMilliseconds );


"Indicates that execution of a test function or all test functions within annotated test container
 have to be retryed using the given `RepeatStrategy` (extracted from `source`).  
 
 > Overall execution cycle including `before`, `after` and `testRule` callbacks are repeated!  
 
 If you need to repeat just test function execution, look on [[RepeatRunner]].
 "
see( `function retry`, `class RepeatRunner`, `interface RepeatStrategy` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class RetryAnnotation (
	"Repeat strategy source which has to take no arguments and has to return instance of [[RepeatStrategy]] type.
	 Either top-level function or value or test function container method or attribute."
	shared FunctionOrValueDeclaration source
)
		satisfies OptionalAnnotation<RetryAnnotation, Module | Package | ClassDeclaration | FunctionDeclaration>
{}


"Provides retry trategy for the tet function execution. See details in [[RetryAnnotation]]."
see( `class RepeatRunner`, `interface RepeatStrategy` )
since( "0.6.0" ) by( "Lis" )
shared annotation RetryAnnotation retry (
	"Repeat strategy source which has to take no arguments and has to return instance of [[RepeatStrategy]] type.
	 Either top-level function or value or test function container method or attribute."
	FunctionOrValueDeclaration source
)
		=> RetryAnnotation( source );
