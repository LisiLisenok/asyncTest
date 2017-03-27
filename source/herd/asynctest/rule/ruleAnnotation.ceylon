import ceylon.language.meta.declaration {
	ValueDeclaration,
	FunctionDeclaration
}
import ceylon.language.meta.model {
	ValueModel
}


"Indicates that the annotated value or attribute identifies a test rule.  
 The value declaration has to satisfy [[SuiteRule]], [[TestRule]] or [[TestStatement]] interfaces."
see( `interface SuiteRule`, `interface TestRule`, `interface TestStatement` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class TestRuleAnnotation()
		satisfies OptionalAnnotation<TestRuleAnnotation, ValueDeclaration,
			ValueModel<SuiteRule>|ValueModel<TestRule>|ValueModel<TestStatement>>
{}


"Indicates that the annotated value or attribute identifies a test rule.  
 The value declaration has to satisfy [[SuiteRule]], [[TestRule]] or [[TestStatement]] interfaces."
see( `interface SuiteRule`, `interface TestRule`, `interface TestStatement` )
since( "0.6.0" ) by( "Lis" )
shared annotation TestRuleAnnotation testRule() => TestRuleAnnotation();


"Indicates that the given test statements have to be applied to the annotated test function.  
 Each value declaration from [[statements]] list has to satisfy [[TestStatement]] interface.  
 The annotation may occur multiple times on the given function.  
 
 > If statement from the given list is marked with [[testRule]] annotation it will be executed twice!
 "
see( `interface TestStatement` )
since( "0.7.0" ) by( "Lis" )
shared final annotation class ApplyStatementAnnotation (
	"Statement declarations. Each item has to satisfy [[TestStatement]] interface."
	shared ValueDeclaration* statements
)
		satisfies SequencedAnnotation<ApplyStatementAnnotation, FunctionDeclaration>
{}


"Indicates that the given test statements have to be applied to the annotated test function.  
 Each value declaration from [[statements]] list has to satisfy [[TestStatement]] interface.  
 The annotation may occur multiple times on the given function.  
 
 > If statement from the given list is marked with [[testRule]] annotation it will be executed twice!
 "
see( `interface TestRule`, `interface TestStatement` )
since( "0.7.0" ) by( "Lis" )
shared annotation ApplyStatementAnnotation applyStatement (
	"Statement declarations. Each item has to satisfy [[TestStatement]] interface."
	ValueDeclaration* statements
) => ApplyStatementAnnotation( *statements );
