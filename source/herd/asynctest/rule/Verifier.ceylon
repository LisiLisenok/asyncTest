import herd.asynctest {
	AsyncTestContext
}
import herd.asynctest.match {
	Matcher
}


"Verifies if element given by `source` matches to `matcher.  
 Actually `source` is called when the verifier is evaluated i.e. _after each_ test.
 This is main difference to [[VerifyRule]] which evaluates `source` _before_ each test."
see( `function AsyncTestContext.assertThat`, `package herd.asynctest.match`, `class VerifyRule` )
since ( "0.6.0" ) by( "Lis" )
shared class Verifier<Element> (
	"Element source, actually called when statement is evaluated" Element() source,
	"Matcher to verify stored value." Matcher<Element> matcher,
	"Optional title to be shown within test name." String title = "",
	"`True` if success to be reported otherwise only failure is reported." Boolean reportSuccess = false
)
		satisfies TestStatement
{
	
	shared actual void apply( AsyncTestContext context ) {
		context.assertThat( source(), matcher, title, reportSuccess );
		context.complete();
	}
	
}
