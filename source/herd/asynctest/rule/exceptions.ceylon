

"Exception thrown when access to a value is requested from a test which doesn't own the value."
see( `class CurrentTestStore` )
since( "0.6.1" ) by( "Lis" )
shared class TestAccessDenied( String message ) extends Exception( message )
{}
