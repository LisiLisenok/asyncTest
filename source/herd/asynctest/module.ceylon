"
 ## asyncTest
 
 is an extension to SDK `ceylon.test` module with following capabilities:
 * testing asynchronous multithread code
 * executing tests concurrently or sequentially
 * value- or type- parameterized testing
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
 3. [Test rules.](#rules)  
 4. [Instantiation the test container class.](#instantiation)  
 5. [Test groups and concurrent execution.](#groups) 
 6. [Value- and type- parameterized testing.](#parameterized)  
 7. [Matchers.](#matchers)  
 8. [Time out.](#timeout)  
 9. [Conditional execution.](#conditions)  
 10. [Reporting test results using charts.](#charts)  

 
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
 and `ceylon.test::afterTestRun`which may take only no arguments):  
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
 
 
 -------------------------------------------
 ### <a name=\"rules\"></a> Test rules
 
 Test rules provide more flexible way for test initialization / disposing and for modification the test behaviour.
 See details in [[package herd.asynctest.rule]]. 
 
 
 -------------------------------------------
 ### <a name=\"instantiation\"></a> Instantiation the test container class
 
 Sometimes instantiation and initialization of the test container class requires
 some complex logic or some asynchronous operations. If the class declaration is marked with [[factory]] annotation
 a given factory function is used to instantiate the class.  
 
 [[factory]] annotation takes two arguments: declaration of top-level factory function and declaration of top-level
 value or function returned stream of factory arguments. Additionally, the factory function may take [[AsyncFactoryContext]]
 as first argument or may not.  
 
 If factory function takes [[AsyncFactoryContext]] as first argument it is executed asynchronously and may
 fill the context with instantiated object using [[AsyncFactoryContext.fill]]
 or may report on error using [[AsyncFactoryContext.abort]]. Test executor blocks the current thread until
 one of [[AsyncFactoryContext.fill]] or [[AsyncFactoryContext.abort]] is called.  
 Otherwise factory function doesn't take [[AsyncFactoryContext]] as first argument. It is executed synchronously
 and has to return instantiated existed object or throw an error.  
 
 #### Example of synchronous instantiation:
 
 		[Integer] testUniverseSize = [1K];
 		StarshipTest createStarshipTest(Integer universeSize) => StarshipTest(universeSize);
 
 		factory(`function createStarshipTest`, `value testUniverseSize`)
 		class StarshipTest(Integer universeSize) {
 			...
 		} 		
 
 #### Example of asynchronous instantiation:
 
 		[Integer] testUniverseSize = [1K];
 		StarshipTest createStarshipTest(AsyncFactoryContext context, Integer universeSize) {
 			context.fill(StarshipTest(universeSize));
 		}
 
 		factory(`function createStarshipTest`, `value testUniverseSize`)
 		class StarshipTest(Integer universeSize) {
 			...
 		} 		
 
 
 > Pay attention:  
 > Asynchronous version has to call [[AsyncFactoryContext.fill]] or [[AsyncFactoryContext.abort]].  
 > Synchronous version has to return non-optional object or throw.  
 
 If no factory function is provided instantiation is done using metamodel staff calling class initializer with arguments
 provided with [[arguments]] annotation or without arguments if the annotation is missed.  
 
 > Just a one instance of the test class is used for the overall test runcycle. This opens way to have some test relations.
   Please, remember best-practices say the tests have to be independent.  
 
 
 -------------------------------------------
 ### <a name=\"groups\"></a> Test groups and concurrent execution
 
 Test functions are collected into groups, which are defined by:
 * `ClassDeclaration` for methods.
 * `Package` for top-level functions.
 
 The groups are always executed in sequential mode. By default test functions in each group are executed in
 sequential mode also. In order to execute functions within some group in concurrent mode
 mark a container (`ClassDeclaration`, `Package` or `Module`) with [[concurrent]] annotation.
 Thread pool with fixed number of threads eqauls to number of available processors (cores)
 is used to execute functions in concurrent mode.  
 
 > If the container (package for top-level functions or class for methods) contains initializers or cleaners marked
   with `ceylon.test::beforeTest` or `ceylon.test::afterTest` or have values marked with [[herd.asynctest.rule::testRule]]
   sequential order is applied nevetherless exists [[concurrent]] annotation or not.  
 >  
 > Functions annotated with `ceylon.test::beforeTestRun` or `ceylon.test::afterTestRun` are executed _once_ before / after
   all test executions and have no influence on the test functions execution order.  
 
 
 -------------------------------------------
 ### <a name=\"parameterized\"></a> Value- and type- parameterized testing
 
 In order to perform parameterized testing the test function has to be marked with annotation which supports
 [[TestVariantProvider]] interface. The interface has just a one function
 which provides an iterator of the test function parameters (generic type parameters and function arguments).  
 
 [[parameterized]] annotation satisfies [[TestVariantProvider]] interface and is intended to provide simple
 parameterized testing based on stream of function parameters.  
 The annotation is similar `ceylon.test::parameters` one but also provides generic type parameters.  
 
 [[parameterized]] annotation takes two arguments:
 1. Declaration of function or value which returns a stream of function parameters `{FunctionParameters*}`
    or such stream iterator - `Iterator<FunctionParameters>`.
 	[[FunctionParameters]] contains a list of generic type parameters and a list of function arguments.
 2. Number of failed variants to stop testing. Default is -1 which means no limit.
 
 The test will be performed using all parameters listed at the annotation
 a number of times equals to length of the given stream
 or while total number of failed variants not exceeds specified limit.
 Results of the each test call will be reported as separated test variant.  
 
 Example:
 
 		Value identity<Value>(Value argument) => argument;
 		
 		{FunctionParameters*} identityArgs => {
 			FunctionParameters([\`String\`], [\"stringIdentity\"]),
 			FunctionParameters([\`Integer\`], [1]),
 			FunctionParameters([\`Float\`], [1.0])
 		};
 		
 		shared test async
 		parameterized(\`value identityArgs\`)
 		void testIdentity<Value>(AsyncTestContext context, Value arg)
 			given Value satisfies Object
 		{
 			context.assertThat(identity<Value>(arg), EqualObjects<Value>(arg), \"\", true );
 			context.complete();
 		}
 
 In the above example the function `testIdentity` will be called 3 times:
 *		testIdentity<String>(context, \"stringIdentity\");
 *		testIdentity<Integer>(context, 1);
 *		testIdentity<Float>(context, 1.0);
 
 In order to run test with conventional (non-generic function) type parameters list has to be empty:
  		[Hobbit] who => [bilbo];
 		{FunctionParameters*} dwarves => {
 			FunctionParameters([], [fili]),
 			FunctionParameters([], [kili]),
 			FunctionParameters([], [balin],
 			FunctionParameters([], [dwalin]),
 			...
 		};
 		
 		arguments(`value who`)
 		class HobbitTester(Hobbit hobbit) {
 			shared test async
 			parameterized(`value dwarves`)
 			void thereAndBackAgain(AsyncTestContext context, Dwarf dwarf) {
 				context.assertTrue(hobbit.thereAndBackAgain(dwarf)...);
 				context.complete();
 			}
 		}
 		
 In this example class `HobbitTester` is instantiated once with argument provided by value `who` and
 method `thereAndBackAgain` is called multiply times according to size of dwarves stream.
 According to second argument of `parameterized` annotation the test will be stopped
 if two different invoking of `thereAndBackAgain` with two different arguments report failure.  

  
 > [[parameterized]] annotation may occur multiple times at a given test function.  
 
 > Note: `ceylon.test::parameters` and `ceylon.test.engine.spi::ArgumentListProvider` are not supported!  
 
 
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
 
 For a example, see `ceylon.test::ignore` annotation.
 
 
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
