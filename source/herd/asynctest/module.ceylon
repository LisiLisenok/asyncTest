"
 ## asyncTest
 
 is an extension to SDK `ceylon.test` module with following capabilities:  
 * testing asynchronous multithread code  
 * executing tests concurrently or sequentially  
 * value- and type- parameterized testing  
 * organizing complex test conditions into a one flexible expression with matchers  
 * initialization and disposing with either functions or test rules  
 * test execution control with test runners  
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
 * [[package herd.asynctest.runner]] provides a control over a test function execution.  
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
 5. [Test execution cycle.](#cycle)  
 6. [Value- and type- parameterized testing.](#parameterized)  
 7. [Test runners.](#runners)  
 8. [Matchers.](#matchers)  
 9. [Time out.](#timeout)
 10. [Retry test.](#retry)    
 11. [Conditional execution.](#conditions)  
 12. [Reporting test results using charts.](#charts)  

 
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
   is used for the overall test runcycle. This opens way to have some test interrelations. Please, remember
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
 
 > All `before` and `after` callbacks are called prepost functions below.

 Prepost functions may take arguments (excepting a top-level function marked with `ceylon.test::beforeTestRun`
 and `ceylon.test::afterTestRun` which may take only empty argument list):  
 * According to [[arguments]] annotation. In this case the functions are executed as synchronous and
   may asserting or throw exceptions.  
 * First argument of [[AsyncPrePostContext]] type and other arguments according to [[arguments]] annotation.
   To complete or abort initialization / disposing process [[AsyncPrePostContext.proceed]] 
   or [[AsyncPrePostContext.abort]] has to be called.   
 
 
 If prepost function reports on failure (throwing exception or calling [[AsyncPrePostContext.abort]] method)
 the test procedure for every test function in the scope
 (package for top-level and class for methods) is interrupted and failure is reported.  
 
 > All prepost functions are called disregard the failure reporting.  
 
 **Notes:**  
 * There is no specific order the prepost functions are executed in.  
 * If some initializer reports on failure the test is skipped.  
 * Every prepost function is always executed regardless failure reporting
   since a right to be disposed has to be provided for each.  
 * Top-level functions marked with `ceylon.test::beforeTestRun` or `ceylon.test::afterTestRun` have to take no arguments!
   While methods may take (see [below](#initargs)).  
 * Test executor blocks current thread until prepost function calls 
   [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]].  
 * Prepost methods have to be shared! Top-level prepost functions may not be shared.  
 * Inherited prepost methods are executed also.  
 
 
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
 
 
 #### <a name=\"initargs\"></a> Prepost function arguments  
 
 [[arguments]] annotation is intended to provide arguments for a `one-shot` function like test prepost functions are.  
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
 
 > Invoking order of prepost functions is shown in [Test execution cycle.](#cycle) section.  
 
   
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
   2. Test isolation. If test class has some mutable properties then a test may get mutated state from previous run
      but not purely initialized property! Always use test rules or `before` \\ `after` callbacks for such properties.  
 
 > From the other side having only one test class instance during overall test runcycle
   helps to orginaze initialization logic in manner more suitable for asynchronous code testing.  
 
 
 -------------------------------------------
 ### <a name=\"suites\"></a> Test suites and concurrent execution  
 
 Test functions are collected into suites, which are defined by:  
 * `ClassDeclaration` for methods.  
 * `Package` for top-level functions.  
 
 So, each suite contains all top-level test functions in a given package
 or all test methods of a given class.  
 
 > This is implicit suite organization!  
 
 All test and prepost functions within the given suite are always executed sequentially via a one
 thread (note: any test function is free to run any number of threads it needs).  
 
 By default the suites are executed sequentially also. In order to execute suites concurrently (each suite in separated thread)
 the suite or upper-level container is to be marked with [[concurrent]] annotation.  
 
 > Thread pool with fixed number of threads equals to number of available processors (cores)
   is used to execute tests in concurrent mode.  
 > If `package` or `module` is marked with [[concurrent]] all suites it contains are executed in concurrent mode.  
 
 For example:  
 * A package has three test classes.  
 * Two of them are annotated with [[concurrent]] and third is not annotated.  
 * Two marked suites are executed via thread pool. Each suite in separated thread if number of
   available cores admits. But all test functions in the given suite are executed sequentially via a one thread.  
 * After completion the test of the first two suites the third one is executed.  
 
 
 -------------------------------------------
 ### <a name=\"cycle\"></a> Test execution cycle  
 
 1. Test suite initialization:  
 	* Functions marked with `ceylon.test::beforeTestRun`.  
 	* `SuiteRule.initialize` of each suite rule marked with `testRule`.  
 2. Execution of test function for each variant:  
 	* Test execution inititalization:  
 		* Functions marked with `ceylon.test::beforeTest`.  
 		* `TestRule.before` of each test rule marked with `testRule`.  
 	* Test function invoking:  
 		* Test function invoking with arguments provided by current test variant.  
 		* `TestStatement` application.  
 	* Test execution disposing:  
 		* `TestRule.after` of each test rule marked with `testRule`.  
 		* Functions marked with `ceylon.test::afterTest`.  
 3. Test suite disposing:  
 	* `SuiteRule.dispose` of each suite rule marked with `testRule`.  
 	* Functions marked with `ceylon.test::afterTestRun`.  
 
 
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
 					// set `current` to test variant to be tested next
 				} else {
 					// set `current` to `finished`
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
 ### <a name=\"runners\"></a> Test runners  
 
 Test runners provide a way to control test function execution.  
 Simply, test runner takes a test function and invokes it.
 But it may, for example, execute it several times or execute simultaneously in several threads,
 or modify the function report or something else.  
 For the details, see [[package herd.asynctest.runner]].   
 
 
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
 
 [[timeout]] annotation is applicable to every function executed during the test: test function, `before` or `after` callbacks,
 test rule or factory.  
 
 Example, function `doMyTest` will be interrupted if not completed during 1 second:
 		timeout( 1K ) test async void doMyTest(...) {...}
  
 
 -------------------------------------------
 ### <a name=\"retry\"></a> Retry test  
 
 If overall test runcycle (i.e. before callbacks - test function - test statements - after callbacks)
 has to be retryed for each given test variant
 (see section [Value- and type- parameterized testing](#parameterized)) the [[retry]] annotation may be applied
 to the test function. The annotation forces test framework to retry the overall test execution cycle according to a given
 repeat strategy.    
 
 
 -------------------------------------------
 ### <a name=\"conditions\"></a> Conditional execution  
 
 Test conditions can be specified via custom annotation which satisfies `ceylon.test.engine.spi::TestCondition` interface.  
 Any number of test conditions can be specified at function, class, package or module level.  
 All conditions at every level are evaluated before test execution started
 and if some conditions are _not_ met (are unsuccessfull) the test is skipped and all rejection reasons are reported.  
 
 For an example, see `ceylon.test::ignore` annotation.
 
 > Conditions are evaluation up to the first unsatisfied condition.
   So, there is no guarantee for a condition to be evaluated.  
  
 
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
	shared import ceylon.test "1.3.1";
	import ceylon.collection "1.3.1";
	shared import ceylon.file "1.3.1";
}
