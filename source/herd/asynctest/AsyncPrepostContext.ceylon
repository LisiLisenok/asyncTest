import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import herd.asynctest.rule {

	SuiteRule,
	TestRule
}


"Allows pre- and post- test functions to interract with test executor.  
 
 Prepost function has to call [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]]
 when initialization or disposing is completed or errored, correspondently.  
 The test xecutor blocks execution thread until [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]] is called.
 
 See details about test initialization / disposing in [[module herd.asynctest]].
 "
see( `interface TestRule`, `interface SuiteRule` )
since( "0.6.0" ) by( "Lis" )
shared interface AsyncPrePostContext {
	
	"Initialization or disposing has been completed - proceed with the test."
	shared formal void proceed();
	
	"Aborts the test initialization or disposing."
	shared formal void abort( Throwable reason, String title = "" );
	
	"Currently tested function:  
	 `null` if context is submitted to [[SuiteRule]] or function annotated with
	 `ceylon.test.beforeTestRun` or `ceylon.test.afterTestRun`.  
	 non-null if context is submitted to [[TestRule]] or function annotated with
	 `ceylon.test.beforeTest` or `ceylon.test.afterTest`."
	shared formal FunctionDeclaration? testFunction;
}
