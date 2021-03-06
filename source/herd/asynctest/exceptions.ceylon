import ceylon.language.meta {
	type
}
import ceylon.test.engine {
	TestAbortedException
}
import ceylon.language.meta.declaration {
	ClassDeclaration,
	FunctionDeclaration
}


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


"Thrown when class is instantiated using member factory function (neither static nor toplevel)."
since( "0.7.1" ) by( "Lis" )
shared class MemberFactoryException (
	"Declaration of the trying to instantiate class."
	shared ClassDeclaration declaration,
	"Factory function"
	shared FunctionDeclaration factory
)
		extends Exception ( "Factory function ``factory.qualifiedName`` of class ``declaration.qualifiedName`` has to be either toplevel or static." )
{}


"Thrown when instantiated class has neither default constructor nor factory function."
since( "0.7.0" ) by( "Lis" )
shared class IncompatibleInstantiation (
	"Declaration of the trying to instantiate class."
	shared ClassDeclaration declaration 
)
	extends Exception (
		"Unable to instantiate class ``declaration.qualifiedName``.
		 It has neither default constructor nor factory function."
	)
{}


"Collects multiple abort reasons in a one exception."
since( "0.7.0" ) by( "Lis" )
shared class MultipleAbortException (
	"The collected exceptions." shared Throwable[] abortReasons,
	"A brief abort description" shared String description = "multiple abort reasons (``abortReasons.size``):"
)
		extends TestAbortedException()
{
	
	"Message collected from [[abortReasons]]."
	shared actual String message {
		value message = StringBuilder();
		message.append( description );
		for ( e in abortReasons ) {
			message.appendNewline();
			message.append("    ");
			message.append( type( e ).declaration.qualifiedName );
			message.append( "(" );
			message.append( e.message );
			message.append( ")" );
		}
		return message.string;
	}
	
}
