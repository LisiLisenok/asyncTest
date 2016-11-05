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


"The same as `testExecutor(`\`class AsyncTestExecutor\``)`"
since( "0.6.0" ) by( "Lis" )
shared annotation TestExecutorAnnotation async() => testExecutor(`class AsyncTestExecutor`);


"Calls [[source]] to get argument stream."
since( "0.6.0" ) by( "Lis" )
Anything[] extractArgumentList( FunctionOrValueDeclaration source ) {
	switch ( source )
	case ( is FunctionDeclaration ) {
		return source.apply<Anything[], []>()();
	}
	case ( is ValueDeclaration ) {
		return source.apply<Anything[]>().get();
	}
}



"Annotation class for [[arguments]]."
see( `function arguments` )
since( "0.5.0" ) by( "Lis" )
shared final annotation class ArgumentsAnnotation (
	"The source function or value declaration. Which has to take no arguments and has to return a stream of values."
	shared FunctionOrValueDeclaration source
)
		satisfies OptionalAnnotation<ArgumentsAnnotation, ClassDeclaration|FunctionDeclaration>
{
	
	"Calls [[source]] to get argument stream."
	shared Anything[] argumentList() => extractArgumentList( source );
	
}


"Indicates that test container class or test initializer or cleaner function have to be instantiated
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
	"The source function or value declaration. Which has to take no arguments and has to return a stream of values."
	FunctionOrValueDeclaration source
)
		=> ArgumentsAnnotation( source );



"Annotation class for [[parameterized]]."
since( "0.6.0" ) by( "Lis" )
see( `function parameterized`, `class TestVariant` )
shared final annotation class ParameterizedAnnotation (
	"The source function or value declaration. Which has to take no arguments and has to return a stream
	 of test variants: `{TestVariant*}`."
	shared FunctionOrValueDeclaration source,
	"Maximum number of failed variants before stop. Unlimited if <= 0."
	shared Integer maxFailedVariants
)
		satisfies SequencedAnnotation<ParameterizedAnnotation, FunctionDeclaration> & TestVariantProvider
{
	
	"Calls [[source]] to get type parameters and a function arguments stream."
	Iterator<TestVariant> arguments() {
		switch ( source )
		case ( is FunctionDeclaration ) {
			return source.apply<{TestVariant*},[]>()().iterator();
		}
		case ( is ValueDeclaration ) {
			return source.apply<{TestVariant*}>().get().iterator();
		}
	}
	
	"Returns test variant enumerator based on test variants extracted from `source`."
	shared actual TestVariantEnumerator variants()
			=> TestVariantIterator( arguments().next, maxFailedVariants );
	
}


"Indicates that generic test function has to be called with given type parameters and arguments.  
 
 [[parameterized]] annotation takes two arguments:
 1. Declaration of function or value which returns a stream of test variants `{TestVariant*}`.
    Each [[TestVariant]] contains a list of generic type parameters and a list of function arguments.
 2. Number of failed variants to stop testing. Default is -1 which means no limit.
 
 The test function will be called a number of times equals to length of returned stream.
 Results of the each test call will be reported as separate test variant.   
 
 Example:
 
 		Value identity<Value>(Value argument) => argument;
 		
 		{TestVariant*} identityArgs => {
 			TestVariant([\`String\`], [\"stringIdentity\"]),
 			TestVariant([\`Integer\`], [1]),
 			TestVariant([\`Float\`], [1.0])
 		};
 		
 		shared test async
 		parameterized(\`value identityArgs\`)
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
 			parameterized(`value dwarves`)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 				context.complete();
 			}
 		}
 		
 In this example class `HobbitTester` is instantiated once with argument provided by value `who` and
 method `thereAndBackAgain` is called multiply times according to size of dwarves stream.  
 "
see( `class TestVariant` )
since( "0.6.0" ) by( "Lis" )
shared annotation ParameterizedAnnotation parameterized (
	"The source function or value declaration. Which has to take no arguments and has to return
	 a stream of test variants: `{TestVariant*}`."
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
	 Has to take arguments according to [[arguments]] or first argument of
	 [[AsyncFactoryContext]] type followed with arguments returned by [[arguments]].
	 "
	shared FunctionDeclaration factoryFunction,
	"The source of factory function arguments function or value declaration.
	 Which has to take no arguments and has to return a stream of values."
	shared FunctionOrValueDeclaration arguments
)
		satisfies OptionalAnnotation<FactoryAnnotation, ClassDeclaration>
{
	
	"Calls [[arguments]] to get argument stream."
	shared Anything[] argumentList() => extractArgumentList( arguments );
	
}


"Indicates that class has to be instantiated using a given factory function.
 [[factoryFunction]] has to take arguments according to [[arguments]] or first argument of
 [[AsyncFactoryContext]] type followed with arguments returned by [[arguments]].
 If [[factoryFunction]] takes [[AsyncFactoryContext]] as first argument itis executed
 asynchronously and has to pass instantiated object according to [[AsyncFactoryContext]] contract.
 Otherwise it is execute synchronously and has to return instantiated object or throw if some error has been occurred.
 "
see( `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
shared annotation FactoryAnnotation factory (
	"Function used to instantiate anotated class.  
	 Has to take arguments according to [[arguments]] or first argument of
	 [[AsyncFactoryContext]] type followed with arguments returned by [[arguments]].
	 "
	FunctionDeclaration factoryFunction,
	"The source of factory function arguments function or value declaration.
	 Which has to take no arguments and has to return a stream of values."
	FunctionOrValueDeclaration arguments
	
) => FactoryAnnotation( factoryFunction, arguments );


"Annotation class for [[concurrent]]."
see( `function concurrent` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class ConcurrentAnnotation()
	satisfies OptionalAnnotation<ConcurrentAnnotation, ClassDeclaration | Package | Module>
{}


"Indicates that all test functions of the marked container have to be run in conccurent mode."
since( "0.6.0" ) by( "Lis" )
shared annotation ConcurrentAnnotation concurrent() => ConcurrentAnnotation();


"Annotation class for [[timeout]]."
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
