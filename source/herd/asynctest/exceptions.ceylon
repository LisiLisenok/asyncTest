
"Exception which shows that time out has been reached."
since( "0.6.0" ) by( "Lis" )
shared class TimeOutException( "Time out in milliseconds." shared Integer timeOutMilliseconds )
		extends Exception( "Time out of ``Float.format( timeOutMilliseconds / 1000.0, 0, 3 )``s has been reached" )
{}


"Exception errored when no object instantiated no error throwed by factory."
see( `function factory`, `interface AsyncFactoryContext` )
since( "0.6.0" ) by( "Lis" )
shared class FactoryReturnsNothing( String factoryTitle )
		extends Exception( "Factory ``factoryTitle`` has neither instantiated object or throwed." )
{}
