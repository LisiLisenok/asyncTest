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
{
	shared actual String string => "init annotation with '``initializer.qualifiedName``' initializer";
}


"Marks a test function (marked with [[ceylon.test::test]] also) with initializer.  
 
 Initializer function has to take first argument of [[TestInitContext]] type.
 If initializer takes more arguments it has to be marked with [[ceylon.test::parameters]] annotation
 or another annotation which supports [[ceylon.test.engine.spi::ArgumentProvider]].    
 
 [[AsyncTestExecutor]] invokes initializers just a once for a test run before test execution started.
 "
see( `interface TestInitContext` )
shared annotation InitAnnotation init (
	"Function which performs initialization." FunctionDeclaration initializer
) => InitAnnotation( initializer );


"Annotation class for [[alone]]."
shared final annotation class AloneAnnotation (
)
		satisfies OptionalAnnotation<AloneAnnotation, FunctionDeclaration | ClassDeclaration | Package | Module> 
{
	shared actual String string => "alone annotation";
}


"Requires the test function to be executed alone rather than concurrently.  
 By default all tests are executed concurrently using fixed size thread pool with number of threads equals to
 number of available processor (cores).  
 
 Test functions marked with `alone` annotation are executed sequentially one-by-one on the <i>main</i> thread
 and after all concurrent tests are completed.
 
 >To run sequentially all functions contained in package or module just mark package or module with `alone` annotation.
 "
shared annotation AloneAnnotation alone() => AloneAnnotation();
