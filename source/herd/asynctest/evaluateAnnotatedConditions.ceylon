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

	Package,
	ClassDeclaration,
	FunctionDeclaration
}
import ceylon.language.meta {

	type
}


"Evaluates test conditions applied as annotations."
by( "Lis" )
TestOutput[] runAnnotatedConditions (
	TestCondition[] conditions,
	"Test context used for evaluation." TestExecutionContext context
) {
	ArrayList<TestOutput> builder = ArrayList<TestOutput>(); 
	for ( condition in conditions ) {
		value result = condition.evaluate( context );
		if ( !result.successful ) {
			builder.add (
				TestOutput (
					TestState.skipped,
					TestSkippedException( result.reason ),
					0,
					"skipped by condition '``type( condition )``'"
				)
			);
		}
	}
	return builder.sequence();
}


"Evaluates test conditions applied as annotations."
by( "Lis" )
TestOutput[] evaluateAnnotatedConditions (
	"Declaration to evaluate conditions on." FunctionDeclaration declaration,
	"Test context used for evaluation." TestExecutionContext context
) {
	return runAnnotatedConditions( findTypedAnnotations<TestCondition>( declaration ), context );
}


"Evaluates test conditions applied as annotations."
by( "Lis" )
TestOutput[] evaluateContainerAnnotatedConditions (
	"Declaration to evaluate conditions on." Package | ClassDeclaration declaration,
	"Test context used for evaluation." TestExecutionContext context
) {
	return runAnnotatedConditions( findContainerTypedAnnotations<TestCondition>( declaration ), context );
}
