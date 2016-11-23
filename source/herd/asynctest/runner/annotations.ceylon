import ceylon.language.meta.declaration {
	FunctionOrValueDeclaration,
	FunctionDeclaration,
	ClassDeclaration,
	Module,
	Package
}


"Annotation class for [[runWith]]."
see( `function runWith` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class RunWithAnnotation( shared FunctionOrValueDeclaration runner )
		satisfies OptionalAnnotation<RunWithAnnotation, FunctionDeclaration | ClassDeclaration | Package | Module>
{}


"Indicates that the test function has to be run with the given runner.  
 The runner has to satisfy [[AsyncTestRunner]] interface.  
 
 If class or top-level container is marked with the annotation each test function of the container
 is executed with the given runner.
 "
since( "0.6.0" ) by( "Lis" )
see( `package herd.asynctest.runner`, `interface AsyncTestRunner` )
shared annotation RunWithAnnotation runWith (
	"Runner source. Top-level function or value or test function container method or attribute.
	 Which has to return an instance of [[AsyncTestRunner]] interface."
	FunctionOrValueDeclaration runner
)
		=> RunWithAnnotation( runner );
