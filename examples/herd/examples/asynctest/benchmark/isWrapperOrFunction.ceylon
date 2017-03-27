import herd.asynctest {
	AsyncTestContext,
	async
}
import ceylon.test {
	test
}
import herd.asynctest.benchmark {
	benchmark,
	writeRelativeToFastest,
	SingleBench,
	TimeUnit,
	Options,
	NumberOfLoops,
	CPUClock,
	WallClock
}


"Wrapper to test narrow SingleArgumentWrapper<Nothing> to SingleArgumentWrapper<Something>.  
 Supposes the function has just a one argument."
class SingleArgumentWrapper<in T> (
	shared Anything(T) func
){}

"Wrapper to test narrow MultipleArgumentWrapper<Nothing> to MultipleArgumentWrapper<[Something...]>.  
 The function may have multiple arguments."
class MultipleArgumentWrapper<in T> (
	shared Anything(*T) func
)
	given T satisfies Anything[]
{}

"Test function to narrow Anything(Nothing) to."
void integerArgumentFunction(Integer i) {}

"Test function to narrow Anything(Nothing) to."
void floatArgumentFunction(Float i) {}


"Narrows `SingleArgumentWrapper<Nothing>` to `SingleArgumentWrapper<Integer>`."
Boolean narrowSingleWrapperToInteger(SingleArgumentWrapper<Nothing> i)() {
	if (is SingleArgumentWrapper<Integer> i) {return true;}
	else {return false;}
}

"Narrows `MultipleArgumentWrapper<Nothing>` to `MultipleArgumentWrapper<[Integer]>`."
Boolean narrowMultipleWrapperToInteger(MultipleArgumentWrapper<Nothing> i)() {
	if (is MultipleArgumentWrapper<[Integer]> i) {return true;}
	else {return false;}
}

"Narrows `Anything(Nothing)` to `Anything(Integer)`."
Boolean narrowFunctionToInteger(Anything(Nothing) f)() {
	if (is Anything(Integer) f) {return true;}
	else {return false;}
}


"Executes benchmark tests for:
 * [[narrowSingleWrapperToInteger]]  
 * [[narrowMultipleWrapperToInteger]]  
 * [[narrowFunctionToInteger]]  
 
 Uses CPU clock.
 "
shared test async void isWrapperOrFunctionCPU(AsyncTestContext context) {
	writeRelativeToFastest (
		context,
		benchmark (
			Options(NumberOfLoops(1000), NumberOfLoops(100), 10, TimeUnit.milliseconds, CPUClock),
			[
				SingleBench<> (
					"narrowed single argument wrapper",
					narrowSingleWrapperToInteger(SingleArgumentWrapper<Integer>(integerArgumentFunction))
				),
				SingleBench<> (
					"not narrowed single argument wrapper",
					narrowSingleWrapperToInteger(SingleArgumentWrapper<Float>(floatArgumentFunction))
				),
				SingleBench<> (
					"narrowed multiple argument wrapper",
					narrowMultipleWrapperToInteger(MultipleArgumentWrapper<[Integer]>(integerArgumentFunction))
				),
				SingleBench<> (
					"not narrowed multiple argument wrapper",
					narrowMultipleWrapperToInteger(MultipleArgumentWrapper<[Float]>(floatArgumentFunction))
				),
				SingleBench<> (
					"narrowed function",
					narrowFunctionToInteger(integerArgumentFunction)
				),
				SingleBench<> (
					"not narrowed function",
					narrowFunctionToInteger(floatArgumentFunction)
				)
			]
		)
	);
	context.complete();
}


"Executes benchmark tests for:
 * [[narrowSingleWrapperToInteger]]  
 * [[narrowMultipleWrapperToInteger]]  
 * [[narrowFunctionToInteger]]  
 
 Uses wall clock.
 "
shared test async void isWrapperOrFunctionWall(AsyncTestContext context) {
	writeRelativeToFastest (
		context,
		benchmark (
			Options(NumberOfLoops(1000), NumberOfLoops(100), 10, TimeUnit.milliseconds, WallClock),
			[
			SingleBench<> (
				"narrowed single argument wrapper",
				narrowSingleWrapperToInteger(SingleArgumentWrapper<Integer>(integerArgumentFunction))
			),
			SingleBench<> (
				"not narrowed single argument wrapper",
				narrowSingleWrapperToInteger(SingleArgumentWrapper<Float>(floatArgumentFunction))
			),
			SingleBench<> (
				"narrowed multiple argument wrapper",
				narrowMultipleWrapperToInteger(MultipleArgumentWrapper<[Integer]>(integerArgumentFunction))
			),
			SingleBench<> (
				"not narrowed multiple argument wrapper",
				narrowMultipleWrapperToInteger(MultipleArgumentWrapper<[Float]>(floatArgumentFunction))
			),
			SingleBench<> (
				"narrowed function",
				narrowFunctionToInteger(integerArgumentFunction)
			),
			SingleBench<> (
				"not narrowed function",
				narrowFunctionToInteger(floatArgumentFunction)
			)
			]
		)
	);
	context.complete();
}
