import ceylon.language.meta.declaration {

	ClassDeclaration,
	Package,
	Module,
	FunctionOrValueDeclaration,
	FunctionDeclaration,
	ValueDeclaration
}


"Annotation class for [[sequential]]."
by( "Lis" )
shared final annotation class SequentialAnnotation()
		satisfies OptionalAnnotation<SequentialAnnotation, ClassDeclaration | Package | Module>
{}


"Indicates that all test functions of the marked container to be run in sequential mode."
by( "Lis" )
shared annotation SequentialAnnotation sequential() => SequentialAnnotation();


"Annotation class for [[maintainer]]."
see( `interface  TestMaintainer` )
by( "Lis" )
shared final annotation class MaintainerAnnotation (
	"Declaration of a maintainer which has to have empty initializer list
	 and has to satisfy [[TestMaintainer]] interface."
	shared ClassDeclaration maintainerDeclaration
)
		satisfies OptionalAnnotation<MaintainerAnnotation, Module | Package>
{}


"Identifies maintainer for the all test groups within annotated `module`.  
 Test groups are:
 * All test functions of `ClassDeclaration`.
 * All toplevel test functions of a `package`.
 
 Maintainer has to satisfy [[TestMaintainer]] interface.  
 "
see( `interface  TestMaintainer`, `function arguments` )
by( "Lis" )
shared annotation MaintainerAnnotation maintainer (
	"Declaration of a maintainer which has to have empty initializer list
	 and has to satisfy [[TestMaintainer]] interface."
	ClassDeclaration maintainerDeclaration
) => MaintainerAnnotation( maintainerDeclaration );


"Annotation class for [[arguments]]."
by( "Lis" )
shared final annotation class ArgumentsAnnotation (
	"The source function or value declaration. Which has to take no arguments and return a stream of values."
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
 		{[Dwarf]*} dwarves => {[fili], [kili], [balin], [dwalin]...};
 		
 		arguments(`value who`)
 		class HobbitTester(Hobbit hobbit) {
 			shared test testExecutor(`class AsyncTestExecutor`)
 			parameters(`value dwarves`)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 			}
 		}
 
 "
see( `function maintainer`, `interface TestMaintainer` )
by( "Lis" )
shared annotation ArgumentsAnnotation arguments (
	"The source function or value declaration. Which has to take no arguments and return a stream of values."
	FunctionOrValueDeclaration source
)
		=> ArgumentsAnnotation( source );
