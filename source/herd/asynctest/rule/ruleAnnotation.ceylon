import ceylon.language.meta.declaration {
	ValueDeclaration
}


"Indicates that the annotated value or attribute identifies a test rule.  
 The value declaration has to satisfy [[SuiteRule]], [[TestRule]] or [[TestStatement]] interfaces."
see( `interface TestRule`, `interface SuiteRule`, `interface TestStatement` )
since( "0.6.0" ) by( "Lis" )
shared final annotation class TestRuleAnnotation()
		satisfies OptionalAnnotation<TestRuleAnnotation, ValueDeclaration>
{}


"Indicates that the annotated value or attribute identifies a test rule.  
 The value declaration has to satisfy [[SuiteRule]], [[TestRule]] or [[TestStatement]] interfaces."
see( `interface TestRule`, `interface SuiteRule`, `interface TestStatement` )
since( "0.6.0" ) by( "Lis" )
shared annotation TestRuleAnnotation testRule() => TestRuleAnnotation();
