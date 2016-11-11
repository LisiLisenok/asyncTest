import herd.asynctest {

	AsyncPrePostContext,
	AsyncTestContext
}


"Base interface for suite rule, which is initialized or disposed before or after execution of _all_ tests in the scope
 (package for top-level value or class for attribute).  
 
 Usage:
 Declare attribute or top-level value satisfies the interface and mark it with [[testRule]] annotation.  
 "
see( `function testRule`, `interface TestRule`, `interface TestStatement` )
tagged( "SuiteRule" ) since( "0.6.0" ) by( "Lis" )
shared interface SuiteRule
{
	"Initializer which is called _once_ before all tests within the scope
	 (package for top-level value or class for attribute) are started."
	shared formal void initialize (
		"Prepost context to report on test aborts or ask to procceed with the test as normal."
		AsyncPrePostContext context
	);
	
	"Cleaner which is called _once_ after all tests within the scope
	 (package for top-level value or class for attribute) are completed."
	shared formal void dispose (
		"Prepost context to report on test aborts or ask to procceed with the test as normal."
		AsyncPrePostContext context
	);
}


"Base interface for test rule, which is initialized or disposed before or after execution of _each_ test in the scope
 (package for top-level value or class for attribute).  
  
 Usage:
 Declare attribute or top-level value satisfies the interface and mark it with [[testRule]] annotation.
 "
tagged( "TestRule" ) see( `function testRule`, `interface SuiteRule`, `interface TestStatement` )
since( "0.6.0" ) by( "Lis" )
shared interface TestRule
{
	"Initializer which is called before _each_ test function within the scope
	 (package for top-level value or class for attribute) is executed."
	shared formal void before (
		"Prepost context to report on test aborts or ask to procceed with the test as normal."
		AsyncPrePostContext context
	);
	
	"Cleaner which is called after _each_ test function within the scope
	 (package for top-level value or class for attribute) is executed."
	shared formal void after (
		"Prepost context to report on test aborts or ask to procceed with the test as normal."
		AsyncPrePostContext context
	);
}


"Base interface for test statement, which is applied after execution of _each_ test in the scope
 (package for top-level value or class for attribute) and may report additional messages to the test results
 using [[AsyncTestContext]] submitted to [[apply]].  
  
 Usage:
 Declare attribute or top-level value satisfies the interface and mark it with [[testRule]] annotation.
 "
see( `function testRule`, `interface SuiteRule`, `interface TestRule` )
tagged( "Statement" ) since( "0.6.0" ) by( "Lis" )
shared interface TestStatement
{
	
	"Applies this statement using [[context]].  
	 The method is called by test executor for each attribute or top-level value annotated with [[testRule]]
	 after _each_ test function in the scope (package for top-level value or class for attribute) is executed.  
	 
	 [[AsyncTestContext.complete]] has to be called when application is completed."
	shared formal void apply (
		"Context to make additional reports on the test results."
		AsyncTestContext context
	);
	
}
