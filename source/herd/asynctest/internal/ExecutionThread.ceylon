import java.lang {
	Thread,
	ThreadGroup
}


"Runs a function in separate thread belonging to a group `group`."
since( "0.6.0" ) by( "Lis" )
shared class ExecutionThread( ThreadGroup group, String name, run )
		extends Thread( group, name )
{
	shared actual void run();
}
