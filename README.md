#### asyncTest
is an extension of SDK `ceylon.test` with following capabilities:
* testing asynchronous multithread code
* reporting several failures for a one particular test execution (test function)
* mark each failure with `String` title
* instantiating private classes and invoking private functions of tested module without additional dependecies in

The extension is based on:
* `AsyncTestContext` interface which test function has to operate with (basically, reports on fails to).
* `AsyncTestExecutor` class which satisfies `ceylon.test.engine.spi::TestExecutor` and used by `ceylon.test` module
  to execute test functions.
 
 
#### test procedure:
1. Declare test function, which accepts `AsyncTestContext` as the first argument:

         test void doTesting(AsyncTestContext context) {...}
       
  The other arguments have to be in accordance with `ceylon.test::parameters` annotation.  
  Mark test function with `ceylon.test::test` annotation.
2. Code test function according to `AsyncTestContext` specification:
  * call `AsyncTestContext.start` before start testing
  * perform testing and report on fails via `AsyncTestContext`
  * call `AsyncTestContext.complete` to complete the testing
3. Apply `ceylon.test::testExecutor` annotation:
	* at module level to execute using `AsyncTestExecutor` every functions / classes
	  marked with `test` annotation in the given module
	
            testExecutor(`class AsyncTestExecutor`)   
            native("jvm")   
            module mymodule "1.0.0"
	* at function level to execute using `AsyncTestExecutor` the given function only
	
            testExecutor(`class AsyncTestExecutor`)  
            test void doTesting(AsyncTestContext context) {...}  
    
4. Run test in IDE or command line.

 
#### instantiating private classes
`loadAndInstantiate` function is doing that.
 
#### invoking private functions
`loadTopLevelFunction` function is doing that.

#### see also
[examples](examples/herd/examples/asynctest)  
[Ceylon API docs](http://lisilisenok.github.io/asyncTest/)  
 
