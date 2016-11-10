"
 ## asyncTest
 
 is an extension to SDK `ceylon.test` module with following capabilities:
 * testing asynchronous multithread code
 * executing tests concurrently or sequentially
 * value- and type- parameterized testing
 * organizing complex test conditions into a one flexible expression with matchers
 * initialization and disposing
 * conditional test execution
 * multi-reporting: several failures or successes can be reported for a one particular test execution (test function),
   each report is represented as test variant and might be marked with \`String\` title
 * reporting test results using charts (or plots)
 
 
 The extension is based on:
 * [[AsyncTestExecutor]] class which satisfies `ceylon.test.engine.spi::TestExecutor` and used by `ceylon.test` module
   to execute test functions.
 * [[AsyncPrePostContext]] interface used for test initialization.
 * [[AsyncTestContext]] interface which test function has to operate with (basically, reports on fails to).
 * [[package herd.asynctest.rule]] which contains rules used for test initialization / disposing
   and for modification of the test behaviour.
 * [[package herd.asynctest.match]] which contains match API.
 * [[package herd.asynctest.chart]] which is intended to organize reporting with charts.
 
 It is recommended to read documentation on `module ceylon.test` before starting with **asyncTest**.
 
 The source code and examples are available at [GitHub](https://github.com/LisiLisenok/asyncTest)
 
 
 -------------------------------------------
 ### Content  
 
 1. [Test procedure.](#procedure)   
 2. [Test initialization and disposing.](#initialization)   
 3. [Instantiation the test container class.](#instantiation)  
 4. [Test suites and concurrent execution.](#suites) 
 5. [Value- and type- parameterized testing.](#parameterized)  
 6. [Matchers.](#matchers)  
 7. [Time out.](#timeout)  
 8. [Conditional execution.](#conditions)  
 9. [Reporting test results using charts.](#charts)  

 
 -------------------------------------------
 ### <a name=\"procedure\"></a> Test procedure   
 
 1. Declare test function, which accepts [[AsyncTestContext]] as the first argument:
 			test async void doTesting(AsyncTestContext context) {...}
    Mark test function or upper level container with `ceylon.test::test` annotation.  
    Mark test function or upper level container with [[async]] annotation.
 2. Code test function according to [[AsyncTestContext]] specification:
 	* perform testing and report failures or successes via [[AsyncTestContext]]
 	* call [[AsyncTestContext.complete]] to complete the testing.
 3. Run test in IDE or command line using Ceylon test tool.
 
 
 #### Notes
 
 > Both modules ceylon.test and herd.asynctest have to be imported to run testing.  
   
 > Test executor blocks the thread until [[AsyncTestContext.complete]] is called. It means test function
   has to notify completion to continue with other testing and to report results.  
   
 > [[async]] annotation is almost the same as `\`testExecutor(`class AsyncTestExecutor`)`\` annotation.  
 
 
 #### Test functions
 
 Any function or method marked with `test` and `async` annotation.  
 
 > If function (or upper-level container) is not marked with `async` annotation
   it is executed with default `ceylon.test` executor.  
 
 The function arguments:
 * If no arguments or function takes arguments according to [[parameterized]] annotation
   then the function is executed in synchronous mode and may report on failures using assertions or throwing some exception.
 * If function takes the first argument of [[AsyncTestContext]] type and the other arguments according
   to [[parameterized]] annotation then it is executed asynchronously and may report failures, successes and completion
   using [[AsyncTestContext]].
   
 > If a number of test functions are declared within some class just a one instance of the class
   is used for the overall test runcycle. This opens way to have some test relations. Please, remember
   best-practices say the tests have to be independent.  
   
 
 -------------------------------------------
 ### <a name=\"initialization\"></a> Test initialization and disposing
 
 Top-level functions or methods marked with `ceylon.test::beforeTestRun` are executed _once_
 before starting all tests in its scope (package for top-level and class for methods).  
 
 Top-level functions or methods marked with `ceylon.test::beforeTest` are executed _each_ time
 before executing _each_ test in its scope (package for top-level and class for methods).  
 
 Top-level functions or methods marked with `ceylon.test::afterTestRun` are executed _once_
 after completing all tests in its scope (package for top-level and class for methods).  
 
 Top-level functions or methods marked with `ceylon.test::afterTest` are executed _each_ time
 after _each_ test in its scope is completed.   
 

 Test initializers and cleaners may take arguments (excepting a top-level function marked with `ceylon.test::beforeTestRun`
 and `ceylon.test::afterTestRun` which may take only no arguments):  
 * According to [[arguments]] annotation. In this case the functions are executed as synchronous and
   may asserting or throw exceptions.  
 * First argument of [[AsyncPrePostContext]] type and other arguments according to [[arguments]] annotation.
   To complete or abort initialization / cleaning [[AsyncPrePostContext.proceed]] 
   or [[AsyncPrePostContext.abort]] has to be called.   
 
 
 If test initializer or cleaner reports on failure (throwing exception or calling [[AsyncPrePostContext.abort]] method)
 the test procedure for every test function in the scope
 (package for top-level and class for methods) is interrupted and failure is reported.  
 All initializers and cleaners are called disregard the failure reporting.  
 
 > If some initializer reports on failure the test is skipped but cleaners are executed.  
  
 > Top-level functions marked with `ceylon.test::beforeTestRun` or `ceylon.test::afterTestRun` have to take no arguments!
   While methods may take.  
 
 > Test executor blocks current thread until initializer or cleaner calls 
   [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]].  
 
 > Both initializer and cleaner methods have to be shared! Top-level functions may not be shared.  
 
 > Inherited initializer or cleaner methods are executed also.  
 
 
 #### Test initialization and disposing example
 		
 		class StarshipTest() {
			
 			// called just a once before all tests ae executed
 			shared beforeTestRun void createUniverse(AsyncPrePostContext context) { 
 				...
 				context.proceed();
 			}
 			
 			// called just a once after all tests are completed
 			shared afterTestRun void destroyUniverse(AsyncPrePostContext context) {
 				...
 				context.proceed();
 			} 
			
 			// called before each test function is executed
 			shared beforeTest void init() => starship.chargePhasers();
 			
 			// called after each test function is completed
 			shared afterTest void dispose() => starship.shutdownSystems();
			
 			test async testPhasersAiming() { ... }
 			test async testPhasersFire(AsynctestContext context) { ... context.complete(); }
		}
 
 
 #### Initializer or cleaner arguments
 
 [[arguments]] annotation is intended to provide arguments for a `one-shot` function like test initializers are.  
 The annotation takes a one argument - declaration of top-level function or value which returns a tupple with
 invoked function arguments: 
 
  		[Integer] testUniverseSize = [1K];
  		
  		arguments(`value testUniverseSize`)
 		beforeTestRun void initializeStarshipTestSync(Integer universeSize) { ... }
 
  		arguments(`value testUniverseSize`)
 		beforeTestRun void initializeStarshipTestAsync(AsyncPrePostContext context, Integer universeSize) { ... }

 In the above example both functions `initializeStarshipTestSync` and `initializeStarshipTestAsync`
 will be called with argument provided by `testUniverseSize`. So, for both sync and async versions arguments
 provider has to return the same arguments list. But async version will additionally be provided
 with `AsyncPrePostContext` which has to be the first argument.  
 
 > [[arguments]] annotation is applicable for test container class also.  
 
 > [[arguments]] annotation is not applicable to test functions. [[parameterized]] annotation is aimed
   to perform parameterized testing, see section [Value- and type- parameterized testing](#parameterized) below.  
 
 
 #### Test rules
 
 Test rules provide more flexible way for test initialization / disposing and for modification the test behaviour.
 See details in [[package herd.asynctest.rule]].  
 
 > Test rules are executed after functions marked with `ceylon.test::beforeTestRun`, `ceylon.test::afterTestRun`,
   `ceylon.test::beforeTest` or `ceylon.test::afterTest` annotations.  
 
 
 -------------------------------------------
 ### <a name=\"instantiation\"></a> Instantiation the test container class
 
 Sometimes instantiation and initialization of the test container class requires
 some complex logic or some asynchronous operations.
 If the class declaration is marked with [[factory]] annotation
 a given factory function is used to instantiate the class.  
  
 If no factory function is provided instantiation is done using metamodel staff calling class initializer with arguments
 provided with [[arguments]] annotation or without arguments if the annotation is missed.  
 
 > Just a one instance of the test class is used for the overall test runcycle it may cause several misalignments:
   1. Test interrelation. Please, remember best-practices say the tests have to be independent.  
   2. Test isolation. If test class has some mutable properties then a test may get mutation state from previous run
      but not purely initialized property! Always use test rules or initializers for such properties.  
 
 
 -------------------------------------------
 ### <a name=\"suites\"></a> Test suites and concurrent execution
 
 Test functions are collected into suites, which are defined by:
 * `ClassDeclaration` for methods.
 * `Package` for top-level functions.
 
 The suites are always executed in sequential mode. By default test functions in each suite are executed in
 sequential mode also. In order to execute functions within some suite in concurrent mode
 mark a container (`ClassDeclaration`, `Package` or `Module`) with [[concurrent]] annotation.
 Thread pool with fixed number of threads eqauls to number of available processors (cores)
 is used to execute functions in concurrent mode.  
 
 > If the container (package for top-level functions or class for methods) contains initializers or cleaners marked
   with `ceylon.test::beforeTest` or `ceylon.test::afterTest` or contains values marked with [[herd.asynctest.rule::testRule]]
   sequential order is applied nevetherless exists [[concurrent]] annotation or not.  
 
 > Functions annotated with `ceylon.test::beforeTestRun` or `ceylon.test::afterTestRun` are executed _once_ before / after
   execution of all test functions within correponding container and have no influence on execution mode.  
 
 
 -------------------------------------------
 ### <a name=\"parameterized\"></a> Value- and type- parameterized testing
 
 In order to perform parameterized testing the test function has to be marked with annotation which supports
 [[TestVariantProvider]] interface. The interface has just a one method - `variants()`
 which has to provide [[TestVariantEnumerator]]. The enumerator produces a stream
 of the [[TestVariant]]'s and is iterated just a once.
 The test will be performed using all variants the enumerator produces.  
 
 > The enumerator may return test variants lazily, dynamicaly or even non-determenisticaly.  
 > Each [[TestVariant]] contains a list of generic type parameters and a list of function arguments.  

  
 [[parameterized]] annotation satisfies [[TestVariantProvider]] interface and
 provides parameterized testing based on collection of test variants.  
 
 
 **Custom parameterization:**  
 
 1. Implement [[TestVariantEnumerator]] interface:
 		class MyTestVariantEnumerator(...) satisfies TestVariantEnumerator {
 			shared actual TestVariant|Finished current => ...;
 
 			shared actual void moveNext(TestVariantResult result) {
 				if (testToBeCompleted) {
 					// set `current` to `finished`
 				} else {
 					// set `current` to test variant to be tested next
 				}
 			}
 		}
 		
 2. Make an annotation which satisfies [[TestVariantProvider]] interface:
 		shared final annotation class MyParameterizedAnnotation(...)
 			satisfies SequencedAnnotation<MyParameterizedAnnotation, FunctionDeclaration>&TestVariantProvider
 		{
 			shared actual TestVariantEnumerator variants() => MyTestVariantEnumerator(...);
 		}
 		
 		shared annotation MyParameterizedAnnotation myParameterized(...) => MyParameterizedAnnotation(...);
 		
 
 3. Mark test function with created annotation:
 		myParameterized(...) void myTest(...) {...}
 
 
 -------------------------------------------
 ### <a name=\"matchers\"></a> Matchers
 
 Matchers are intended to organize complex test conditions into a one flexible expression.  
 Each matcher is represented as requirements specification and verification method which identifies
 if submitted test value satisfies this specification or not. Matchers may be combined using logical operators.  
 
 Details of matching API are described in [[package herd.asynctest.match]].
 
 
 -------------------------------------------
 ### <a name=\"timeout\"></a> Time out
 
 [[timeout]] annotation indicates that if test has not been completed during some time it has to be interrupted.  
 Annotation applied at class, package or module level acts for each function within the scope. Lower-level declaration
 overrides definitions of upper-level. So, if both function and class annotated with [[timeout]] the function annotation
 is applied.  
 
 [[timeout]] annotation is applicable to every function executed during test: test function, initialization, disposing,
 rule or factory.  
 
 Example, function `doMyTest` will be interrupted if not completed during 1 second:
 		timeout( 1K ) test async void doMyTest(...) {...}
 
 
 -------------------------------------------
 ### <a name=\"conditions\"></a> Conditional execution
 
 Test conditions can be specified via custom annotation which satisfies `ceylon.test.engine.spi::TestCondition` interface.  
 Any number of test conditions can be specified at function, class, package or module level.  
 All conditions at every level are evaluated before test execution started
 and if some conditions are _not_ met (are unsuccessfull) the test is skipped and all rejection reasons are reported.  
 
 For an example, see `ceylon.test::ignore` annotation.
 
 
 -------------------------------------------
 ### <a name=\"charts\"></a> Reporting test results using charts
 
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
module herd.asynctest "0.6.0" {
	import java.base "8";
	shared import ceylon.test "1.3.0";
	import ceylon.collection "1.3.0";
	shared import ceylon.file "1.3.0";
	shared import ceylon.promise "1.3.0";
}
