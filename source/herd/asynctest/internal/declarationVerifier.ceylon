import herd.asynctest {
	AsyncPrePostContext,
	AsyncTestExecutor,
	AsyncFactoryContext,
	AsyncTestContext
}
import herd.asynctest.rule {
	TestRuleAnnotation
}
import ceylon.language.meta.declaration {
	ClassDeclaration,
	InterfaceDeclaration,
	FunctionDeclaration,
	OpenInterfaceType
}
import ceylon.language.meta.model {
	Class
}
import ceylon.test.annotation {
	TestExecutorAnnotation
}


"Verifies if declaration meets templates"
since( "0.7.0" ) by( "Lis" )
shared object declarationVerifier {
	
	"Memoization of [[TestRuleAnnotation]]."
	shared Class<TestRuleAnnotation, []> ruleAnnotationClass = `TestRuleAnnotation`;
	
	"AsyncTestContext declaration memoization."
	see( `function isAsyncDeclaration` )
	InterfaceDeclaration asyncContextDeclaration = `interface AsyncTestContext`;
	
	"AsyncPrePostContext declaration memoization."
	see( `function isAsyncPrepostDeclaration` )
	InterfaceDeclaration prepostContextDeclaration = `interface AsyncPrePostContext`;
	
	"AsyncFactoryContext declaration memoization."
	see( `function isAsyncFactoryDeclaration` )
	InterfaceDeclaration factoryContextDeclaration = `interface AsyncFactoryContext`;
	
	"Cache async test executor declaration. See `function isAsyncExecutedTest`" 
	ClassDeclaration asyncTestDeclaration = `class AsyncTestExecutor`;
	
	
	"`true` if execution is performed using `AsyncTestExecutor`"
	shared Boolean isAsyncExecutedTest( FunctionDeclaration functionDeclaration ) =>
			if ( exists ann = findFirstAnnotation<TestExecutorAnnotation>( functionDeclaration ) )
			then ann.executor == asyncTestDeclaration else false;
	
	
	"Returns `true` if function takes `firstArg` as first argument."
	Boolean isFirstArgSatisfies( FunctionDeclaration functionDeclaration, InterfaceDeclaration firstArg ) {
		if ( is OpenInterfaceType argType = functionDeclaration.parameterDeclarations.first?.openType,
			argType.declaration == firstArg
		) {
			return true;
		}
		else {
			return false;
		}
	}
	
	"Returns `true` if function runs async test == takes `AsyncTestContext` as first argument."
	shared Boolean isAsyncDeclaration( FunctionDeclaration functionDeclaration )
			=> isFirstArgSatisfies( functionDeclaration, asyncContextDeclaration );
	
	"Returns `true` if function runs async test initialization == takes `AsyncPrePostContext` as first argument."
	shared Boolean isAsyncPrepostDeclaration( FunctionDeclaration functionDeclaration )
			=> isFirstArgSatisfies( functionDeclaration, prepostContextDeclaration );
	
	"Returns `true` if function runs async test initialization == takes `AsyncFactoryContext` as first argument."
	shared Boolean isAsyncFactoryDeclaration( FunctionDeclaration functionDeclaration )
			=> isFirstArgSatisfies( functionDeclaration, factoryContextDeclaration );
	
	
}
