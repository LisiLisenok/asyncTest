import ceylon.language.meta.declaration {

	ClassDeclaration,
	Package,
	Module,
	FunctionOrValueDeclaration,
	FunctionDeclaration,
	ValueDeclaration
}
import ceylon.language.meta.model {

	Type
}


"Annotation class for [[sequential]]."
since( "0.3.0" )
by( "Lis" )
shared final annotation class SequentialAnnotation()
		satisfies OptionalAnnotation<SequentialAnnotation, ClassDeclaration | Package | Module>
{}


"Indicates that all test functions of the marked container to be run in sequential mode."
since( "0.3.0" )
by( "Lis" )
shared annotation SequentialAnnotation sequential() => SequentialAnnotation();



"Annotation class for [[arguments]]."
since( "0.5.0" )
by( "Lis" )
shared final annotation class ArgumentsAnnotation (
	"The source function or value declaration. Which has to take no arguments and has to return a stream of values."
	shared FunctionOrValueDeclaration source
)
		satisfies OptionalAnnotation<ArgumentsAnnotation, ClassDeclaration>
{
	
	"Calls [[source]] to get arguments stream."
	shared {Anything*} arguments() {
		switch ( source )
		case ( is FunctionDeclaration ) {
			return source.apply<{Anything*},[]>()();
		}
		case ( is ValueDeclaration ) {
			return source.apply<{Anything*}>().get();
		}
	}
	
}


"Indicates that test container or test maintainer class has to be instantiated using arguments provided
 by this annotation, see [[ArgumentsAnnotation.arguments]].  
 
 Example:
 		[Hobbit] who => [bilbo];
 		{[[], [Dwarf]]*} dwarves => {[[], [fili]], [[], [kili]], [[], [balin]], [[], [dwalin]]...};
 		
 		arguments(`value who`)
 		class HobbitTester(Hobbit hobbit) {
 			shared test testExecutor(`class AsyncTestExecutor`)
 			parameterized(`value dwarves`)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 				context.complete();
 			}
 		}
 
 "
since( "0.5.0" )
by( "Lis" )
shared annotation ArgumentsAnnotation arguments (
	"The source function or value declaration. Which has to take no arguments and has to return a stream of values."
	FunctionOrValueDeclaration source
)
		=> ArgumentsAnnotation( source );



"Annotation class for [[parameterized]]."
since( "0.6.0" )
by( "Lis" )
shared final annotation class ParameterizedAnnotation (
	"The source function or value declaration. Which has to take no arguments and has to return a stream of tuples
	 contained a lis of type parameters and a list of function arguments: `{[Type<Anything>[], Anything[]]*}`."
	shared FunctionOrValueDeclaration source
)
		satisfies SequencedAnnotation<ParameterizedAnnotation, FunctionDeclaration>
{
	
	"Calls [[source]] to get type parameters and a function arguments stream."
	shared {[Type<Anything>[], Anything[]]*} arguments() {
		switch ( source )
		case ( is FunctionDeclaration ) {
			return source.apply<{[Type<Anything>[], Anything[]]*},[]>()();
		}
		case ( is ValueDeclaration ) {
			return source.apply<{[Type<Anything>[], Anything[]]*}>().get();
		}
	}
	
}


"Indicates that generic test function has to be called with given type parameters and arguments.  
 
 Argument of [[parameterized]] annotation has to return a stream of tupples:
 		{[Type<Anything>[], Anything[]]*}
 Each tupple has two fields. First one is a list of generic type parameters and second one is a list of function arguments.
 
 The test function will be called a number of times equals to length of returned stream.
 Results of the each test call will be reported as separated test variant.   
 
 Example:
 
 		Value identity<Value>(Value argument) => argument;
 		
 		{[Type<Anything>[], Anything[]]*} identityArgs => {
 			[[\`String\`], [\"stringIdentity\"]],
 			[[\`Integer\`], [1]],
 			[[\`Float\`], [1.0]]
 		};
 		
 		shared test testExecutor(\`class AsyncTestExecutor\`)
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
 		{[[], [Dwarf]]*} dwarves => {[[], [fili]], [[], [kili]], [[], [balin]], [[], [dwalin]]...};
 		
 		arguments(`value who`)
 		class HobbitTester(Hobbit hobbit) {
 			shared test testExecutor(`class AsyncTestExecutor`)
 			parameterized(`value dwarves`)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 				context.complete();
 			}
 		}
 		
 In this example class `HobbitTester` is instantiated once with argument provided by value `who` and
 method `thereAndBackAgain` is called multiply times according to size of dwarves stream.  
 
 "
since( "0.6.0" )
by( "Lis" )
shared annotation ParameterizedAnnotation parameterized (
	"The source function or value declaration. Which has to take no arguments and has to return a stream of tuples
	 contained a list of type parameters and a list of arguments: `{[Type<Anything>[], Anything[]]*}`."
	FunctionOrValueDeclaration source
)
		=> ParameterizedAnnotation( source );

