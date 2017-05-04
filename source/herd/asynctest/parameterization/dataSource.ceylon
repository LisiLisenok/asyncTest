import ceylon.language.meta.declaration {
	FunctionOrValueDeclaration,
	ValueDeclaration
}


"Indicates that the test has to be performed by applying a list of values to the marked test function argument.  
 `source` has to provide the values.  
 `kind` indicates the kind of the provided values.
 The kind is used by _variant generator_ in order to identify strategy for the variant generations."
tagged( "Data source" )
see( `class CombinatorialAnnotation` )
since( "0.7.0" ) by( "Lis" )
shared final annotation class DataSourceAnnotation (
	"The source function or value declaration which has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	shared FunctionOrValueDeclaration source,
	"The test data kind. Has to extend [[CombinatorialKind]]."
	shared ValueDeclaration kind
)
		satisfies OptionalAnnotation<DataSourceAnnotation, FunctionOrValueDeclaration>
{}


"Provides values for the marked test function argument. See [[DataSourceAnnotation]] for details."
tagged( "Data source" )
see( `function zippedSource`, `function permutationSource` )
since( "0.7.0" ) by( "Lis" )
shared annotation DataSourceAnnotation dataSource (
	"The source function or value declaration which has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	FunctionOrValueDeclaration source,
	"The test data kind. Returned value has to extend [[CombinatorialKind]]."
	ValueDeclaration kind
) => DataSourceAnnotation( source, kind );


"Provides [[zippedKind]] kind values for the marked test function argument.  
 See [[DataSourceAnnotation]] for details.  
 The annotation is shortcut for `\`dataSource(`value zippedKind`)`\`."
tagged( "Data source" )
see( `function dataSource`, `function permutationSource` )
since( "0.7.0" ) by( "Lis" )
shared annotation DataSourceAnnotation zippedSource (
	"The source function or value declaration which has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	FunctionOrValueDeclaration source
) => DataSourceAnnotation( source, `value zippedKind` );


"Provides [[permutationKind]] kind values for the marked test function argument.  
 See [[DataSourceAnnotation]] for details.  
 The annotation is shortcut for `\`dataSource(`value permutationKind`)`\`."
tagged( "Data source" )
see( `function zippedSource`, `function dataSource` )
since( "0.7.0" ) by( "Lis" )
shared annotation DataSourceAnnotation permutationSource (
	"The source function or value declaration which has to return a stream of values.
	 The source may be either top-level or tested class shared member."
	FunctionOrValueDeclaration source
) => DataSourceAnnotation( source, `value permutationKind` );
