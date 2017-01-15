import java.lang {
	Runnable
}


"Bench with start synchronization and completion notification."
since( "0.7.0" ) by( "Lis" )
class SyncBench<in Parameter> (
	"Bench title. Generally unique."
	String title,
	"Function to be tested."
	shared actual Anything(*Parameter) bench,
	"Completed notification."
	void completed( StatisticSummary stat ),
	"Options the bench has to be executed with."
	Options options,
	"Parameters the bench has to be executed with."
	Parameter parameter
)
		extends BaseBench<Parameter>( title )
		satisfies Runnable
		given Parameter satisfies Anything[]
{
	
	shared actual void run() => completed( execute( options, parameter ) );
	
}
