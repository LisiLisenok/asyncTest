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
 Annotation can be used at `function`, `class`, `package` or `module` level which forces to use specified initializer
 for all functions of corresponding level.  
 
 >Initializer may not be marked with [[init]] annotation! Test function, class, package or module should be marked.  
 
 >Executor blocks current thread until [[TestInitContext.proceed]] or [[TestInitContext.abort]] called.  
 
 >If initialization is aborted using [[TestInitContext.abort]] tests initialized with the given initializer
  are never executed but abort is reported.
  
 >Initializer arguments may be provided using [[ceylon.test::parameters]] annotation or another annotation
  which satisfied [[ceylon.test.engine.spi::ArgumentProvider]]
 
 >[[init]] and [[ceylon.test::beforeTest]] are diffrent. First one is called just once for the overall test run, while
  second is called  before each test function invoking. 
 "
see( `interface TestInitContext` )
shared annotation InitAnnotation init (
	"Function which performs initialization." FunctionDeclaration initializer
) => InitAnnotation( initializer );


"Annotation class for [[alone]]."
shared final annotation class AloneAnnotation (
)
		satisfies OptionalAnnotation<AloneAnnotation, FunctionDeclaration | ClassDeclaration | Package | Module> 
{}


"Requires the test function to be executed alone rather than concurrently.  
 By default all tests are executed concurrently using fixed size thread pool with number of threads equals to
 number of available processor (cores).  
 Test functions marked with `alone` annotation are executed sequentialy one-by-one on the <i>main</i> thread
 and after all concurrent tests are completed.
 "
shared annotation AloneAnnotation alone() => AloneAnnotation();
