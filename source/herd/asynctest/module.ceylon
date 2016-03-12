"
 ### asyncTest
 
 is an extension to SDK `ceylon.test` module with following capabilities:
 * testing asynchronous multithread code
 * common initialization for a test suite
 * controlling test execution order
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
 * [[TestSuite]] interface the test suite class has to satisfy
   and [[TestInitContext]] interface used for test suite initialization.
 * [[TestMaintainer]] controls test execution order.
 * [[package herd.asynctest.chart]] which is intended to organize reporting with charts.
 * [[package herd.asynctest.match]] which contains match API.
 
 
 -------------------------------------------
 Basically:
 * If you would like to run test using [[AsyncTestExecutor]]: 
		1. Implement test function taking [[AsyncTestContext]] as first argument.
		2. Mark test function with `ceylon.test::test` annotation.
		3. Mark appropriate `function`, `class`, `package` or `module` with `testExecutor(`\`class AsyncTestExecutor\``)`.
 * If you need to run common initialization for a complex test:
		1. Implement [[TestSuite]].
		2. Implement test methods taking [[AsyncTestContext]] as first argument.
		3. Mark test methods with `ceylon.test::test` annotation.
		4. Mark appropriate `method`, `class`, `package` or `module` with `testExecutor(`\`class AsyncTestExecutor\``)`.
 * If you prefer to execute test functions in sequential mode rather then in default concurrent one:
   mark `class`, `package` or `module` with [[sequential]] annotation.
 * If you would like to sort an order the tests are executed in:
		1. Create your tests.
		2. Implement [[TestMaintainer]].
		3. Mark `package` or `module` with [[maintainer]] annotation specifying
		   declaration of your [[TestMaintainer]] implementation. 
 
 -------------------------------------------
 
 
 ### Test procedure   
 
 1. Declare test function, which accepts [[AsyncTestContext]] as the first argument:
 			test testExecutor(\`class AsyncTestExecutor\`) void doTesting(AsyncTestContext context) {...}
    The other arguments have to be in accordance with `ceylon.test::parameters` annotation
    or another annotation which supports `ceylon.test.engine.spi::ArgumentListProvider`.  
    Mark test function or upper level container with `ceylon.test::test` annotation.  
    Mark test function or upper level container with `testExecutor(`\`class AsyncTestExecutor\``)` annotation.
 2. Code test function according to [[AsyncTestContext]] specification:
 	* call [[AsyncTestContext.start]] before start testing
 	* perform testing and report failures or successes via [[AsyncTestContext]]
 	* call [[AsyncTestContext.complete]] to complete the testing
 3. Apply `ceylon.test::testExecutor` annotation at function, class, package or module level.
 4. Run test in IDE or command line using Ceylon test tool.
 
 
 >Test executor blocks the thread until [[AsyncTestContext.complete]] is called. It means test function
  has to notify completion to continue with other testing and to report results.  
 
 
 >If a number of test functions are declared within some class
  just a one instance of the class is used for the overall test runcycle.  
 
 
 ### Test suite
 
 Test suite can be used in order to organize test functions into a one suite and to perform common
 test initialization / disposing.    
 All test functions of the suite are to be declared within some class which satisfies [[TestSuite]] interface.  
 Just a one instance of test suite is used for the overall test runcycle.  
 Before executing any test [[TestSuite.initialize]] is called with initializer context of [[TestInitContext]].  
 Initializer has to call [[TestInitContext.proceed]] or [[TestInitContext.abort]] when initialization
 is completed or failured, correspondently.  
 When test is completed [[TestSuite.dispose]] is called.  
 
 
 >Executor blocks current thread until [[TestInitContext.proceed]] or [[TestInitContext.abort]] is called.  
 
 
 >If initialization is aborted using [[TestInitContext.abort]] corresponding tests
  are never executed but test aborts are reported.  
 
 
 >Use [[TestSuite]] for test initialization. `ceylon.test::beforeTest` and `ceylon.test::afterTest`
  don't work with [[AsyncTestExecutor]].  
 
 
 >Arguments of test suite class can be specified using [[arguments]] annotation.  
 
 
 Example:
 		// initialization parameters
 		[String, Integer] serverParameters => [\"host\", 123]; 
 		
 		// test suite is instantiated just once for the overall test runcycle
 		arguments(`value serverParameters`)
 		class TestServer(String host, Integer port) satisfies TestSuite {
 			
 			variable Server? server = null;
 			
 			// initializer - binds to server specified by host:port,
 			// if successfull proceeds with test or aborted if some error occured
 			shared actual void initialize(TestInitContext context) {
 				Server().bind(host, port).onComplete (
 					(Server createdServer) {
 						// storing server on context and notifying to continue with testing
 						server = createdServer; 
 						context.proceed();
 					},
 					(Throwable err) {
 						// abort initialization since server binding errored
 						context.abort(err, \"server \`\`host\`\`:\`\`port\`\` binding error\");
 					}
 				);
 			}
 		
 			
 			// test functions
 			test testExecutor(\`class AsyncTestExecutor\`)
 			void firstTest(AsyncTestContext context) {
 				assert (exists s = server);
 				...
 			}
 		
 			test testExecutor(\`class AsyncTestExecutor\`)
 			void secondTest(AsyncTestContext context) {
 				assert (exists s = server);
 				...
 			}
 		}
 
 ### Test Group
 
 Test functions are collected into groups, which are defined by:
 * `ClassDeclaration` for methods.
 * `Package` for top level functions.
 
 The groups are executed in sequential order. While functions in each group are executed concurrently using
 thread pool with fixed number of threads eqauls to number of available processors (cores).  
 In order to execute functions sequentially mark a container (`ClassDeclaration`, `Package` or `Module`)
 with [[sequential]] annotation.  
 
 
 >Test class can be instantiated with arguments using [[arguments]] annotation.
 
 
 ### Test maintainer
 
 Combines a number of test groups into a one assembly and indented to sort the test groups execution order
 (by default test groups are executed in alphabetical order). This can be used to execute more important tests before
 less important ones.    
 Maintainer has to satisfy [[TestMaintainer]] interface and can be specified using [[maintainer]] annotation
 at `package` or `module` level.
 
 Only one maintainer of a given type is instantiated for any number of [[maintainer]] annotation application.  
 In the below example only one instance of `MyMaintainer` is used to manage the overall test assembly:
 		maintainer( `class MyMaintainer`) package xxx
 		...
 		maintainer( `class MyMaintainer`) package yyy
 		...
 		maintainer( `class MyMaintainer`) package zzz
 		...
 
 >Test maintainer can be instantiated with arguments using [[arguments]] annotation.
 
 
 ### Conditional execution
 
 Test condition can be specified via custom annotation which satisfies `ceylon.test.engine.spi::TestCondition` interface.  
 Any number of test conditions can be specified at function, class, package or module level.  
 All conditions at every level are evaluated before test execution started
 and if some conditions are _not_ met (are unsuccessfull) the test is skipped and all rejection reasons are reported.
 
 
 ### Parameterized testing
 
 Can be performed using staff provided by `module ceylon.test`:
 `ceylon.test.engine.spi::ArgumentListProvider` or `ceylon.test::parameters`.  
 Just mark test function with `ceylon.test::parameters` annotation or another satisfied to
 `ceylon.test.engine.spi::ArgumentListProvider`.   
 See details in `ceylon.test` documentation.  
 
 
 ### Matchers
 
 Matchers are intended to organize complex test conditions into a one flexible expression.  
 Basically, matcher is a rule and verification method which identifies
 if submitted test value satisfies this rule or not.    
 
 Details of matching API are described in [[package herd.asynctest.match]].
 
 
 ### Reporting test results using charts
 
 Chart is simply a set of plots, where each plot is a sequence of 2D points.  
 Test results can be represented and reported with charts using staff provided by [[package herd.asynctest.chart]].
 
 --------------------------------------------
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
module herd.asynctest "0.5.1" {
	import java.base "8";
	shared import ceylon.test "1.2.2";
	import ceylon.collection "1.2.2";
	import ceylon.file "1.2.2";
	shared import ceylon.promise "1.2.2";
}
