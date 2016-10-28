import herd.asynctest.match {
	Matcher
}
import herd.asynctest {
	AsyncTestContext
}


"Verifies if the stored value matches a given [[matcher]] when the statement is applied."
see( `function AsyncTestContext.assertThat` )
since( "0.6.0" ) by( "Lis" )
shared class VerifyRule<Element> (
	"Initial value." Element initial,
	"Matcher to verify stored value." Matcher<Element> matcher,
	"Optional title to be shown within test name." String title = "",
	"`True` if success to be reported otherwise only failure is reported." Boolean reportSuccess = false
)
		extends AtomicValueRule<Element>( initial )
		satisfies TestStatement
{
	
	shared actual void apply( AsyncTestContext context ) {
		context.assertThat( sense, matcher, title, reportSuccess );
		context.complete();
	}
	
}
