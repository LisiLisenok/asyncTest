import herd.asynctest {

	async,
	concurrent
}


"Using matchers.  
 
 Annotated with `async` - all test functions of the package to be run using `AsyncTestExecutor`.  
 
 Annotated with `concurrent` - all test functions to be run in concurrent mode.
 Since functions are groupped in the classes then all functions within a particular class are executed concurrently,
 while classes are executed sequentially. 
 "
see( `package herd.asynctest.match` )
by( "Lis" )
async concurrent
shared package herd.examples.asynctest.matchers;
