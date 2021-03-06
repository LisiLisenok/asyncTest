import herd.asynctest {
	AsyncTestContext,
	async
}
import ceylon.test {
	test
}
import herd.asynctest.benchmark {
	writeRelativeToFastest,
	benchmark,
	SingleBench,
	Options,
	NumberOfLoops
}


// benchmark parameters
Integer integerValue => 1;
Integer integerFunction() => 1;


"Benchmark function - narrow to `Integer` firstly." 
Boolean isValue(Integer|Integer() source) {
	if (is Integer source) {return true;}
	else {return false;}
}

"Benchmark function - narrow to `Integer()` firstly."
Boolean isFunction(Integer|Integer() source) {
	if (is Integer() source) {return true;}
	else {return false;}
}


"What is faster narrowing to function of to class?:  
 
 		Integer|Integer() source => ...  
 		
 		...
 		
 		if (is Integer source) {return true; }
 		else {return false;}

 or  
 		 		
 		if (is Integer() source) {return true; }
 		else {return false;}
 
 "
shared test async void isValueOrFunction(AsyncTestContext context) {
	writeRelativeToFastest (
		context,
		benchmark (
			Options(NumberOfLoops(1000), NumberOfLoops(100)),
			[
				SingleBench("value", isValue),
				SingleBench("function", isFunction)
			],
			[integerValue], [integerFunction]
		)
	);
	context.complete();
}

