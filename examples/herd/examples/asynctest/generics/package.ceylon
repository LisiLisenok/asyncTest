import herd.asynctest {

	async,
	concurrent
}

"
 Type parameterized test.  
 
 Annotated with `async` - all test functions of the package to be run using `AsyncTestExecutor`.  
 "
by( "Lis" )
async concurrent
shared package herd.examples.asynctest.generics;
