import ceylon.language.meta.declaration {

	FunctionDeclaration,
	Package,
	Module,
	ClassDeclaration
}


"Annotation class for [[init]]."
shared final annotation class InitAnnotation (
	"The function declaration called to init.  
	 The function has to take first argument of [[TestInitContext]] type
	 and other arguments as specified by [[ceylon.test::parameters]] annotation if marked with."
	shared FunctionDeclaration initializer 
)
		satisfies OptionalAnnotation<InitAnnotation, FunctionDeclaration | ClassDeclaration | Package | Module> 
{}


"Marks a test function (marked with [[ceylon.test::test]] also) with initializer.  
 The `initializer` function has to take first argument of [[TestInitContext]] type
 and other arguments as specified by [[ceylon.test::parameters]] annotation if marked with.  
 Initializer is called just a ones and all test functions marked with `init` annotation uses
 results of this initialization.  
 Annotation can be used at `class`, `package` or `module` level which forces to use this initializer
 for all functions of corresponding level. This behavior can be overriden by apply `init` directly to function.  
 "
see( `interface TestInitContext` )
shared annotation InitAnnotation init (
	"Function which performs initialization." FunctionDeclaration initializer
) => InitAnnotation( initializer );
