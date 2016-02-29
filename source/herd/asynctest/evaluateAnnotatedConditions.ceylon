import ceylon.test {

	TestState
}
import ceylon.test.engine.spi {

	TestExecutionContext,
	TestCondition
}
import ceylon.test.engine {

	TestSkippedException
}
import ceylon.collection {

	ArrayList
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}


"Evaluate test conditions applied as annotations."
by( "Lis" )
TestOutput[] evaluateAnnotatedConditions( FunctionDeclaration functionDeclaration, TestExecutionContext context ) {
	value conditions = findTypedAnnotations<TestCondition>( functionDeclaration );
	ArrayList<TestOutput> builder = ArrayList<TestOutput>(); 
	for ( condition in conditions ) {
		value result = condition.evaluate( context );
		if ( !result.successful ) {
			builder.add (
				TestOutput( TestState.skipped, TestSkippedException( result.reason ), 0, "condition '``condition``'" )
			);
		}
	}
	return builder.sequence();
}
