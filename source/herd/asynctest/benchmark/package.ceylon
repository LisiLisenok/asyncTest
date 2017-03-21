
"
 Library to run benchmarks.  
 
 
 ### Terminology  
 
 * Benchmark is a set of benches with a unified test parameter type and a set of the parameter values.  
 * Bench is an executor of the function to be tested.  
 * Bench run statistic is number of operations per time unit, i.e. number of test function calls per time unit.  
 * Benchmark run result is collection of bench run statistic for all given benches and all given test parameter values.  
 
 
 ### Bench
 
 Bench is responsible for the test function execution and calculation performance statistic.  
 Each bench has to satisfy [[Bench]] interface.  
 Any particular bench may implement its own testing semantic and purposes.  
 
 [[SingleBench]] is intended to run test function in a single thread.  
 [[MultiBench]] is intended to run test function in a multithread environment.  
 
 
 ### Bench flow
 
 An object which provides more flexible execution control then just bench function.
 Has to satisfy [[BenchFlow]] interface.  
 Both [[SingleBench]] and [[MultiBench]] may take either bench function of an object satisfied [[BenchFlow]] interface.  
 
 There are some impementations of bench flow:
 * [[SelectiveFlow]] which reselects bench function each given number of iterations  
 * [[SequentialFlow]] which reselects bench function one by one from the given sequence
 * [[RandomFlow]] which randomly reselects bench function from the given list each given number of iterations
 * [[RandomDataFlow]] which randomly chooses bench function argument from the given list each given number of iterations
 
 
 ### Benchmark execution
 
 [[benchmark]] is intended to run benchmark. The function executes each given bench with each given parameter
 and returns results of benchmark test as instance of [[Result]].
 
 
 ### JIT optimization
 
 JIT optimization may eliminate some code at runtime if it finds that the result of the code execution is
 not used anywhere.  
 
 Mainly there are two eliminations:  
 1. Unused results of calculations  
 2. Constants  
 
 
 #### Black hole  
 
 In order to avoid unused results elimination results may be passed to black hole using [[pushToBlackHole]] function.  
 
 Suppose we would like to test plus operation:  
 	
 		void plusBenchmark() {
 			value x = 2;
 			value y = 3;
 			value z = x + y;
 		}
 
 This function call might be eliminated at all, since it results to nothing. To avoid this black hole might be used:
 	
 		void plusBenchmark() {
 			value x = 2;
 			value y = 3;
 			pushToBlackHole(x + y);
 		}
 
 All returned values are pushed to black hole by default. So, the above example might be replaced with:
 
 		Integer plusBenchmark() {
 			value x = 2;
 			value y = 3;
 			return x + y;
 		}
 
 
 #### Constants
 
 There are two constants `x` and `y` in the above examples. JIT may find that result of `+` operation is always
 the same and replace the last function with

 		Integer plusBenchmark() {
 			return 5;
 		}

 So, the plus operation will never be executed. In order to avoid this the parameters might be passed to function as arguments
 or declared outside the function scope as variables:  
 
 		variable Integer x = 2;
 		variable Integer y = 3;
 
 		Integer plusBenchmark() {
 			return x + y;
 		}
 
 > Note: returning value is prefer to direct pushing to black hole, since in this case time consumed by black hole is excluded
   from total time of the test function execution.  
 
 
 ### Writing benchmark result
 
 Benchmark run results may be writed to `AsyncTestContext` using a number of writers. See functions tagged as `Writer`.
 
 
 ### Example
 
 		Integer plusBenchmarkFunction(Integer x, Integer y) {
 			return x + y;
 		}
 		Integer minusBenchmarkFunction(Integer x, Integer y) {
 			return x - y;
 		}

 		shared test async void plusMinusBenchmark(AsyncTestContext context) {
 			writeRelativeToFastest (
 				context,
 				benchmark (
 					Options(NumberOfLoops(20000).or(ErrorCriterion(0.002)), NumberOfLoops(100).or(ErrorCriterion(0.002))),
 					[SingleBench(\"plus\", plusBenchmarkFunction),
 					SingleBench(\"minus\", minusBenchmarkFunction)],
 					[1, 1], [2, 3], [25, 34]
 				)
 			);
 			context.complete();
 		}
  
 
 "
since( "0.7.0" ) by( "Lis" )
shared package herd.asynctest.benchmark;
