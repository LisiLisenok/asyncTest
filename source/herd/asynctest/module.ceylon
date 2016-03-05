"
 ### asyncTest
 
 is an extension to SDK `ceylon.test` module with following capabilities:
 * testing asynchronous multithread code
 * common initialization for a set of test functions
 * storing initialized values on test context and retrieving them during test execution
 * executing tests concurrently or sequentially
 * parameterized testing
 * conditional test execution
 * organizing complex test conditions into a one flexible expression with matchers
 * multi-reporting: several failures or successes can be reported for a one particular test execution (test function),
   each report is represented as test variant and might be marked with `String` title
 * reporting test results using charts (or graphs)
 
 
 The extension is based on:
 * [[AsyncTestContext]] interface which test function has to operate with (basically, reports on fails to).
 * [[AsyncTestExecutor]] class which satisfies `ceylon.test.engine.spi::TestExecutor` and used by `ceylon.test` module
   to execute test functions.
 * [[TestInitContext]] interface and [[init]] annotation which can be used for common initialization of test set.
 * [[package herd.asynctest.chart]] which is intended to organize reporting with charts
 
 
 ### Test procedure   
 
 1. Declare test function, which accepts [[AsyncTestContext]] as the first argument:
 			test testExecutor(\`class AsyncTestExecutor\`) void doTesting(AsyncTestContext context) {...}
    The other arguments have to be in accordance with `ceylon.test::parameters` annotation
    or another annotation which supports `ceylon.test.engine.spi::ArgumentListProvider`.  
    Mark test function or upper level container with `ceylon.test::test` annotation.  
    Mark test function or upper level container with `testExecutor(\`class AsyncTestExecutor\`)` annotation.
 2. Code test function according to [[AsyncTestContext]] specification:
 	* call [[AsyncTestContext.start]] before start testing
 	* perform testing and report failures or successes via [[AsyncTestContext]]
 	* call [[AsyncTestContext.complete]] to complete the testing
 3. Apply `ceylon.test::testExecutor` annotation at function, class, package or module level.
 4. Run test in IDE or command line using Ceylon test tool.
 
 >Test executor blocks the thread until [[AsyncTestContext.complete]] is called. It means test function
  has to call completion to continue with other testing and to report results.
 
 
 >If test function is marked with testExecutor(\`class AsyncTestExecutor\`) but doesn't take `AsyncTestContext`
  as first argument it is executed using `ceylon.test.engine::DefaultTestExecutor`.
  At the same time the function is executed concurrently if <i>not</i> marked with [[alone]] annotation,
  see [Concurrent or sequential test execution section](#concurrent-or-sequential-test-execution) for details.
 
 
 ### Initialization
 
 Common asynchronous initialization for a set of test functions can be performed
 by marking these functions with [[init]] annotation. Argument of this annotation is declaration of initializer function,
 which is called just once for all tests.    
 
 Initializer function has to take first argument of [[TestInitContext]] type.
 If initializer takes more arguments it has to be marked with `ceylon.test::parameters` annotation
 or another annotation which supports `ceylon.test.engine.spi::ArgumentProvider`.    
 
 When initialization is completed [[TestInitContext.proceed]] has to be called.  
 If some error has occured and test has to be aborted, [[TestInitContext.abort]] can be called.  
 
 Initializer can store some values on context using [[TestInitContext.put]] method. These values can be retrieved lately
 by test functions using [[AsyncTestContext.get]] or [[AsyncTestContext.getAll]].  
 Alternatively [[init]] annotation can be used at `class`, `package` or `module` level to apply initialization to all
 test functions of corresponding container.  
 
 
 >Initializer may not be marked with [[init]] annotation! Test function, class, package or module should be marked.  
 
 
 >Executor blocks current thread until [[TestInitContext.proceed]] or [[TestInitContext.abort]] called.  
 
 
 >Just a one initializer is called for a given function selecting that from internal level (function) to external one (module).
  So if function and package (or module) are both marked with [[init]] only initializer from function annotation
  is used for the given test function initialization.
 
 >If initialization is aborted using [[TestInitContext.abort]] tests initialized with the given initializer
  are never executed but test abort is reported.
 
 
 >`init` and `ceylon.test::beforeTest` are different. First one is called just once for the overall test run, while
  second is called before each test function invoking.
 
 
 Example:
 		// initialization parameters
 		[String, Integer] serverParameters => [\"host\", 123]; 
 		
 		// initializer - binds to server specified by host:port,
 		// if successfull proceeds with test or aborted if some error occured
 		parameters(`value serverParameters`)
 		void setupServer(TestInitContext context, String host, Integer port) {
 			Server server = Server();
 			server.bind(host, port).onComplete (
 				(Server server) {
 					// storing server on context and notifying to continue with testing
 					context.put(\"\`\`host\`\`:\`\`port\`\`\", server, server.close); 
 					context.proceed();
 				},
 				(Throwable err) {
 					// abort initialization since server binding errored
 					context.abort(err, \"server \`\`host\`\`:\`\`port\`\` binding error\");
 				}
 			);
 		}
 		
 		// test functions, setupServer is called just once - neveretheless the actual number of test functions 
 		test testExecutor(\`class AsyncTestExecutor\`) init(`function setupServer`)
 		void firstTest AsyncTestContext context) {
 			String serverName = serverParameters.host + \":\`\`port\`\`\";
 			assert ( exists server = context.get<Server>(\"serverName\") );
 			...
 		}
 		
 		test testExecutor(\`class AsyncTestExecutor\`) init(`function setupServer`)
 		void secondTest(AsyncTestContext context) {
 			String serverName = serverParameters.host + \":\`\`port\`\`\";
 			assert ( exists server = context.get<Server>(\"serverName\") );
 			...
 		}
 
 
 ### Conditional execution
 
 Test condition can be specified via custom annotation which satisfies `ceylon.test.engine.spi::TestCondition` interface.  
 Any number of test conditions can be specified at function, class, package or module level.  
 All conditions at every level are evaluated before test execution started
 and if some conditions are <i>not</i> met (are unsuccessfull) the test is skipped and all rejection reasons are reported.
 
 
 ### Parameterized testing
 
 Can be performed using staff provided by `module ceylon.test`:
 `ceylon.test.engine.spi::ArgumentListProvider` or `ceylon.test::parameters`.  
 See details in corresponding documentation.  
 
 
 ### Concurrent or sequential test execution
 
 Test function can be executed:
 * concurrently using fixed size thread pool with number of threads equals to number of available processors (cores)
 * sequentially one-by-one on the <i>main</i> thread
 
 >Test executor runs all concurrently executed tests firstly and than runs sequential tests.
 
 In order to run test sequentially mark test function with [[alone]] annotation.
 If this annotation is omitted test function is executed concurrently.
 
 >To run sequentially all functions contained in package or module just mark package or module with `alone` annotation. 
 
 Example:  
 			testExecutor(\`class AsyncTestExecutor\`)
 			test void doTestOne(AsyncTestContext context) {...}
 			
 			testExecutor(\`class AsyncTestExecutor\`)
 			test void doTestOther(AsyncTestContext context) {...}
 			
 			testExecutor(\`class AsyncTestExecutor\`)
 			alone test void doTestAlone(AsyncTestContext context) {...}
 
 In the above example, `doTestOne` and `doTestOther` are executed concurrently,
 while `doTestAlone` is executed just after both `doTestOne` and `doTestOther` are completed.
 
 
 ### Matchers
 
 Matchers are intended to organize complex test conditions into a one flexible expression.  
 Basically, matcher is a rule and verification method which identifies
 if submitted test value satisfies this rule or not.    
 
 Details of matching API are described in [[package herd.asynctest.match]].
 
 
 ### Reporting test results using charts
 
 Chart is simply a set of plots, where each plot is a sequence of 2D points.  
 Test results can be represented and reported with charts using staff provided by [[package herd.asynctest.chart]].
 
 "
license (
	"
	 The MIT License (MIT)
	 
	 Permission is hereby granted, free of charge, to any person obtaining a copy
	 of this software and associated documentation files (the \"Software\"), to deal
	 in the Software without restriction, including without limitation the rights
	 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the Software is
	 furnished to do so, subject to the following conditions:
	 
	 The above copyright notice and this permission notice shall be included in all
	 copies or substantial portions of the Software.
	 
	 THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	 SOFTWARE."
)
by( "Lis" )
native( "jvm" )
module herd.asynctest "0.4.0" {
	import java.base "8";
	shared import ceylon.test "1.2.1";
	import ceylon.collection "1.2.1";
	import ceylon.file "1.2.1";
}
