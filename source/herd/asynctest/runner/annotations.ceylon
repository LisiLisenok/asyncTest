import ceylon.language.meta.declaration {
	FunctionOrValueDeclaration,
	FunctionDeclaration,
	ClassDeclaration,
	Module,
	Package
}


"Indicates that the test function has to be run with the given runner.  
 The runner has to satisfy [[AsyncTestRunner]] interface.  
 
 If class or top-level container is marked with the annotation each test function of the container
 is executed with the given runner.
 "
see( `function runWith`, `package herd.asynctest.runner`, `interface AsyncTestRunner` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class RunWithAnnotation (
	"Runner source. Top-level function or value or method or attribute of a test function container.
	 The source has to return an instance implementing [[AsyncTestRunner]] interface."
	shared FunctionOrValueDeclaration runner
)
		satisfies OptionalAnnotation<RunWithAnnotation, FunctionDeclaration | ClassDeclaration | Package | Module>
{}


"Provides test runner for the annotated test function. See details in [[RunWithAnnotation]]."
since( "0.6.0" ) by( "Lis" )
see( `package herd.asynctest.runner`, `interface AsyncTestRunner` )
shared annotation RunWithAnnotation runWith (
	"Runner source. Top-level function or value or method or attribute of a test function container.
	 The source has to return an instance implementing [[AsyncTestRunner]] interface."
	FunctionOrValueDeclaration runner
)
		=> RunWithAnnotation( runner );
