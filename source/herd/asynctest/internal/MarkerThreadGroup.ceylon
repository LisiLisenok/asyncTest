import java.lang {
	ThreadGroup
}

"Just a marker for the thread group - means the group is test executor group."
since( "0.7.0" ) by( "Lis" )
shared abstract class MarkerThreadGroup( String title ) extends ThreadGroup( title ) {
	"ID of the currently run test."
	shared formal Integer testID; 
}
