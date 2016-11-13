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
import ceylon.language.meta.declaration {

	Package,
	ClassDeclaration,
	FunctionDeclaration
}
import ceylon.language.meta {

	type
}
import herd.asynctest.internal {

	typeName,
	findContainerTypedAnnotations,
	findTypedAnnotations
}


"Evaluates test conditions applied as annotations."
since( "0.0.1" )
by( "Lis" )
TestOutput? runAnnotatedConditions (
	TestCondition[] conditions,
	"Test context used for evaluation." TestExecutionContext context
) {
	for ( condition in conditions ) {
		try {
			value result = condition.evaluate( context );
			if ( !result.successful ) {
				String title =
					if ( exists reason = result.reason, !reason.empty )
					then "skipped with ``reason``"
					else "skipped by condition '``typeName( type( condition ) )``'";
				String exTitle =
						if ( exists reason = result.reason, !reason.empty )
						then "'``typeName( type( condition ) )``' condition with ``reason``"
						else "'``typeName( type( condition ) )``' condition";
				return TestOutput( TestState.skipped, TestSkippedException( exTitle ), 0, title );
			}
		}
		catch ( Throwable err ) {
			return TestOutput (
				TestState.skipped, err, 0,
				"skipped by condition '``typeName( type( condition ) )``'"
			);
		}
	}
	return null;
}


"Evaluates test conditions applied as annotations."
since( "0.0.1" )
by( "Lis" )
TestOutput? evaluateAnnotatedConditions (
	"Declaration to evaluate conditions on." FunctionDeclaration declaration,
	"Test context used for evaluation." TestExecutionContext context
) {
	return runAnnotatedConditions( findTypedAnnotations<TestCondition>( declaration ), context );
}


"Evaluates test conditions applied as annotations."
since( "0.0.1" )
by( "Lis" )
TestOutput? evaluateContainerAnnotatedConditions (
	"Declaration to evaluate conditions on." Package | ClassDeclaration declaration,
	"Test context used for evaluation." TestExecutionContext context
) {
	return runAnnotatedConditions( findContainerTypedAnnotations<TestCondition>( declaration ), context );
}
