import herd.asynctest {
	AsyncTestContext
}


"Delegates benchmark run result writing to the given `writers`."
tagged( "Writer" )
see( `function benchmark`, `function writeRelativeToSlowest`,
	`function writeRelativeToFastest`, `function writeAbsolute` )
since( "0.7.0" ) by( "Lis" )
shared void delegateWriter<Parameter> (
	"Writers to be delegated to write benchmark run result."
	{Anything(AsyncTestContext, Result<Parameter>)*} writers
)
	( AsyncTestContext context, Result<Parameter> results )
		given Parameter satisfies Anything[]
{
	for ( item in writers ) {
		item( context, results );
	}
}
