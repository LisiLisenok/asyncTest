#### asyncTest
 is an extension of SDK `ceylon.test` with following capabilities:
 * testing asynchronous multithread code
 * common initialization for a set of test functions
 * reporting several failures for a one particular test execution (test function)
 * marking each failure with `String` title
 * instantiating private classes and invoking private functions of tested module without additional dependecies in
 
 The extension is based on:
 * `AsyncTestContext` interface which test function has to operate with (basically, reports on fails to).
 * `AsyncTestExecutor` class which satisfies `ceylon.test.engine.spi::TestExecutor` and used by `ceylon.test` module
   to execute test functions.
 * `TestInitContext` interface and `init` annotation, which can be used for common initialization of test set.
 
 
#### test procedure:
1. Declare test function, which accepts `AsyncTestContext` as the first argument:

         test void doTesting(AsyncTestContext context) {...}
       
  The other arguments have to be in accordance with `ceylon.test::parameters` annotation
  or other satisfied `ceylon.test.engine.spi::ArgumentProvider`.  
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
	
            test testExecutor(`class AsyncTestExecutor`)  
            void doTesting(AsyncTestContext context) {...}  
    
4. Run test in IDE or command line.

#### initialization
Common asynchronous initialization for a set of test functions can be performed
by marking these functions with `init` annotation. Argument of this annotation is initializer function,
which is called just once for all tests.    
Initializer has to take first argument of `TestInitContext` type
and other arguments as specified by `ceylon.test::parameters` annotation if marked with.    
When initialization is completed `TestInitContext.proceed` has to be called.  
If some error has occured and test has to be aborted, `TestInitContext.abort` can be called.  
Initializer can store some values on context using `TestInitContext.put` method. These values can be retrieved lately
by test functions using `AsyncTestContext.get` or `AsyncTestContext.getAll`.  
Alternatively `init` annotation can be used at `class`, `package` or `module` level to apply initializer to all
test functions of corresponding container.  
> Initializer may not be marked with `init` annotation! Test function, package or module should be marked.
 
Example:

 		// initialization parameters
 		[String, Integer] serverParameters => ["host", 123]; 
 		
 		// initializer - binds to server specified by host:port,
 		// if successful proceeds with test or aborted if some error occured
 		parameters(`value serverParameters`)
 		void setupServer(TestInitContext context, String host, Integer port) {
 			Server server = Server();
 			server.bind(host, port).onComplete (
 				(Server server) {
 					// storing server on context and notifying to continue with testing
 					context.put("``host``:``port``", server, server.close); 
 					context.proceed();
 				},
 				(Throwable err) {
 					// abort initialization since server binding errored
 					context.abort(err, "server ``host``:``port`` binding error");
 				}
 			);
 		}
 		
 		// test functions, setupServer is called just once - nevertheless the actual number of test functions 
 		test init(`function setupServer`) void firstTest AsyncTestContext context) {
 			String serverName = serverParameters.host + ":``port``";
 			assert ( exists server = context.get<Server>("serverName") );
 			...
 		}
 		test init(`function setupServer`) void secondTest(AsyncTestContext context) {
 			String serverName = serverParameters.host + ":``port``";
 			assert ( exists server = context.get<Server>("serverName") );
 			...
 		}


#### instantiating private classes
`loadAndInstantiate` function is doing that.
 
#### invoking private functions
`loadTopLevelFunction` function is doing that.

#### see also
[examples](examples/herd/examples/asynctest)  
[Ceylon API docs](https://modules.ceylon-lang.org/repo/1/herd/asynctest/0.1.0/module-doc/api/index.html)  
