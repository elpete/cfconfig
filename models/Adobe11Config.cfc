/**
* I represent the behavior of reading and writing CF engine config in the format compatible with an Adobe 11.x server
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='BaseConfig' {
	
	property name='runtimeConfigPath' type='string';
	property name='runtimeConfigTemplate' type='string';

	property name='clientStoreConfigPath' type='string';
	property name='clientStoreConfigTemplate' type='string';

	property name='watchConfigPath' type='string';
	property name='watchConfigTemplate' type='string';

	property name='mailConfigPath' type='string';
	property name='mailConfigTemplate' type='string';

	property name='datasourceConfigPath' type='string';
	property name='datasourceConfigTemplate' type='string';


	property name='seedPropertiesPath' type='string';
	property name='passwordPropertiesPath' type='string';
		
	/**
	* Constructor
	*/
	function init() {
		setRuntimeConfigTemplate( expandPath( '/resources/adobe11/neo-runtime.xml' ) );		
		setRuntimeConfigPath( '/lib/neo-runtime.xml' );
		
		setClientStoreConfigTemplate( expandPath( '/resources/adobe11/neo-clientstore.xml' ) );		
		setClientStoreConfigPath( '/lib/neo-clientstore.xml' );
		
		setWatchConfigTemplate( expandPath( '/resources/adobe11/neo-watch.xml' ) );		
		setWatchConfigPath( '/lib/neo-watch.xml' );
		
		setMailConfigTemplate( expandPath( '/resources/adobe11/neo-mail.xml' ) );		
		setMailConfigPath( '/lib/neo-mail.xml' );
		
		setDatasourceConfigTemplate( expandPath( '/resources/adobe11/neo-datasource.xml' ) );
		setDatasourceConfigPath( '/lib/neo-datasource.xml' );
		
		setSeedPropertiesPath( '/lib/seed.properties' );
		setPasswordPropertiesPath( '/lib/password.properties' );
		
		super.init();
	}
	
	// This is not a singleton since it holds state regarding the encryption seeds, so create it fresh each time as a transient.
	private function getAdobePasswordManager() {
		return wirebox.getInstance( 'PasswordManager@adobe-password-util' );
	}
	
	/**
	* I read in config
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		
		if( !len( getCFHomePath() ) ) {
			throw 'No CF home specified to read from';
		}
		
		readRuntime();
		readClientStore();
		readWatch();
		readMail();
		readDatasource();
		readAuth();
			
		return this;
	}
	
	private function readRuntime() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getRuntimeConfigPath(), '/' ) );
				
		setSessionMangement( thisConfig[ 7 ].session.enable );
		setSessionTimeout( thisConfig[ 7 ].session.timeout );
		setSessionMaximumTimeout( thisConfig[ 7 ].session.maximum_timeout );
		setSessionType( thisConfig[ 7 ].session.usej2eesession ? 'j2ee' : 'cfml' );
		
		setApplicationMangement( thisConfig[ 7 ].application.enable );
		setApplicationTimeout( thisConfig[ 7 ].application.timeout );
		setApplicationMaximumTimeout( thisConfig[ 7 ].application.maximum_timeout );
		
		// Stored as 0/1
		setErrorStatusCode( ( thisConfig[ 8 ].EnableHTTPStatus == 1 ) );
		setMissingErrorTemplate( thisConfig[ 8 ].missing_template );
		setGeneralErrorTemplate( thisConfig[ 8 ].site_wide );
		
		var ignoreList = '/CFIDE,/gateway';
		for( var thisMapping in thisConfig[ 9 ] ) {
			if( !listFindNoCase( ignoreList, thisMapping ) ){
				addCFMapping( thisMapping, thisConfig[ 9 ][ thisMapping ] );
			}
		}		
		
		setRequestTimeoutEnabled( thisConfig[ 10 ].timeoutRequests );
		// Convert from seconds to timespan
		setRequestTimeout( '0,0,0,#thisConfig[ 10 ].timeoutRequestTimeLimit#' );
		setPostParametersLimit( thisConfig[ 10 ].postParametersLimit );
		setPostSizeLimit( thisConfig[ 10 ].postSizeLimit );
				
		setTemplateCacheSize( thisConfig[ 11 ].templateCacheSize );
		if( thisConfig[ 11 ].trustedCacheEnabled ) {
			setInspectTemplate( 'never' );
		} else if ( thisConfig[ 11 ].inRequestTemplateCacheEnabled ?: false ) {
			setInspectTemplate( 'once' );
		} else {
			setInspectTemplate( 'always' );
		}
		setSaveClassFiles(  thisConfig[ 11 ].saveClassFiles  );
		setComponentCacheEnabled( thisConfig[ 11 ].componentCacheEnabled );
		
		setMailDefaultEncoding( thisConfig[ 12 ].defaultMailCharset );
		
		setCFFormScriptDirectory( thisConfig[ 14 ].CFFormScriptSrc );
		
		// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.
		setScriptProtect( thisConfig[ 15 ] );
		
		setPerAppSettingsEnabled( thisConfig[ 16 ].isPerAppSettingsEnabled );				
		// Adobe stores the inverse of Lucee
		setUDFTypeChecking( !thisConfig[ 16 ].cfcTypeCheckEnabled );
		setDisableInternalCFJavaComponents( thisConfig[ 16 ].disableServiceFactory );
		// Lucee and Adobe store opposite value
		setDotNotationUpperCase( !thisConfig[ 16 ].preserveCaseForSerialize );
		setSecureJSON( thisConfig[ 16 ].secureJSON );
		setSecureJSONPrefix( thisConfig[ 16 ].secureJSONPrefix );
		setMaxOutputBufferSize( thisConfig[ 16 ].maxOutputBufferSize );
		setInMemoryFileSystemEnabled( thisConfig[ 16 ].enableInMemoryFileSystem );
		setInMemoryFileSystemLimit( thisConfig[ 16 ].inMemoryFileSystemLimit );
		setInMemoryFileSystemAppLimit( thisConfig[ 16 ].inMemoryFileSystemAppLimit );
		setAllowExtraAttributesInAttrColl( thisConfig[ 16 ].allowExtraAttributesInAttrColl );
		setDisallowUnamedAppScope( thisConfig[ 16 ].dumpunnamedappscope );
		setAllowApplicationVarsInServletContext( thisConfig[ 16 ].allowappvarincontext );
		setCFaaSGeneratedFilesExpiryTime( thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime );
		setORMSearchIndexDirectory( thisConfig[ 16 ].ORMSearchIndexDirectory );
		setGoogleMapKey( thisConfig[ 16 ].googleMapKey );
		setServerCFCEenabled( thisConfig[ 16 ].enableServerCFC );
		setServerCFC( thisConfig[ 16 ].serverCFC );
		setCompileExtForCFInclude( thisConfig[ 16 ].compileextforinclude );
		setSessionCookieTimeout( thisConfig[ 16 ].sessionCookieTimeout );
		setSessionCookieHTTPOnly( thisConfig[ 16 ].httpOnlySessionCookie );
		setSessionCookieSecure( thisConfig[ 16 ].secureSessionCookie );
		setSessionCookieDisableUpdate( thisConfig[ 16 ].internalCookiesDisableUpdate );
		
		// Map Adobe values to shared Lucee settings
		switch( thisConfig[ 16 ].applicationCFCSearchLimit ) {
			case '1' :
				setApplicationMode( 'curr2driveroot' );
				break;
			case '2' :
				setApplicationMode( 'curr2root' );
				break;
			case '3' :
				setApplicationMode( 'currorroot' );
		}
				
		setThrottleThreshold( thisConfig[ 18 ][ 'throttle-threshold' ] );
		setTotalThrottleMemory( thisConfig[ 18 ][ 'total-throttle-memory' ] );
		
	}
	
	private function readClientStore() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getClientStoreConfigPath(), '/' ) );
				
		setUseUUIDForCFToken( thisConfig[ 2 ].uuidToken );
	}
	
	private function readWatch() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getWatchConfigPath(), '/' ) );
	
		setWatchConfigFilesForChangesEnabled( thisConfig[ 'watch.watchEnabled' ] );
		setWatchConfigFilesForChangesInterval( thisConfig[ 'watch.interval' ] );
		setWatchConfigFilesForChangesExtensions( thisConfig[ 'watch.extensions' ] );
	}
	
	private function readMail() {
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getMailConfigPath(), '/' ) );
		
		setMailSpoolEnable( thisConfig.spoolEnable );
		setMailSpoolInterval( thisConfig.schedule );
		setMailConnectionTimeout( thisConfig.timeout );
		setMailDownloadUndeliveredAttachments( thisConfig.allowDownload );
		setMailSignMesssage( thisConfig.sign );
		setMailSignKeystore( thisConfig.keystore );
		setMailSignKeystorePassword( passwordManager.decryptMailServer( thisConfig.keystorepassword ) );
		setMailSignKeyAlias( thisConfig.keyAlias );
		setMailSignKeyPassword( passwordManager.decryptMailServer( thisConfig.keypassword ) );
		
		addMailServer(
			smtp = thisConfig.server,
			username = thisConfig.username,
			password = passwordManager.decryptMailServer( thisConfig.password ),
			port = thisConfig.port,
			SSL= thisConfig.useSSL,
			TSL = thisConfig.useTLS		
		);	
	}
	
	private function readDatasource() {
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDatasourceConfigPath(), '/' ) );
		var datasources = thisConfig[ 1 ];
		
		for( var datasource in datasources ) {
			// For brevity
			var ds = datasources[ datasource ];
			
			addDatasource(
				name = datasource,
				// TODO:  Turn ds.alter, ds.create, ds.drop, ds.grant, etc, etc into bitmask
				//allow = '',
				// Invert logic
				blob = !ds.disable_blob,	
				class = ds.class,
				// Invert logic
				clob = !ds.disable_clob,
				// If the field doesn't exist, it's unlimited
				connectionLimit = ds.urlmap.maxConnections ?: -1,
				// Convert from seconds to minutes
				connectionTimeout = round( ds.timeout / 60 ),
				database = ds.urlmap.database,
				// Normalize names
				dbdriver = translateDatasourceDriverToGeneric( ds.driver ),
				dsn = ds.url,
				host = ds.urlmap.host,
				password = passwordManager.decryptDataSource( ds.password ),
				port = ds.urlmap.port,
				username = ds.username,
				validate = ds.validateConnection
			);
		}
	}

	function readAuth() {
		var propertyFile = wirebox.getInstance( 'propertyFile@propertyFile' ).load( getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' ) );
		if( !propertyFile.encrypted ) {
			setAdminPassword( propertyFile.password );
			setAdminRDSPassword( propertyFile.rdspassword );	
		} else {
			setACF11Password( propertyFile.password );
			setACF11RDSPassword( propertyFile.rdspassword );
		}
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath ){
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}
		
		writeRuntime();
		writeClientStore();
		writeWatch();
		writeMail();
		writeDatasource();
		writeAuth();
		
		return this;
	}
	
	private function writeRuntime() {		
		var configFilePath = getCFHomePath().listAppend( getRuntimeConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getRuntimeConfigTemplate() );
		}
				
		if( !isNull( getSessionMangement() ) ) { thisConfig[ 7 ].session.enable = getSessionMangement(); }
		if( !isNull( getSessionTimeout() ) ) { thisConfig[ 7 ].session.timeout = getSessionTimeout(); }
		if( !isNull( getSessionMaximumTimeout() ) ) { thisConfig[ 7 ].session.maximum_timeout = getSessionMaximumTimeout(); }
		if( !isNull( getSessionType() ) ) { thisConfig[ 7 ].session.usej2eesession = ( getSessionType() == 'j2ee' ); }

		if( !isNull( getApplicationMangement() ) ) { thisConfig[ 7 ].application.enable = getApplicationMangement(); }
		if( !isNull( getApplicationTimeout() ) ) { thisConfig[ 7 ].application.timeout = getApplicationTimeout(); }
		if( !isNull( getApplicationMaximumTimeout() ) ) { thisConfig[ 7 ].application.maximum_timeout = getApplicationMaximumTimeout(); }
		
		// Convert from boolean back to 1/0
		if( !isNull( getErrorStatusCode() ) ) { thisConfig[ 8 ].EnableHTTPStatus = ( getErrorStatusCode() ? 1 : 0 ); }
		if( !isNull( getMissingErrorTemplate() ) ) { thisConfig[ 8 ].missing_template = getMissingErrorTemplate(); }
		if( !isNull( getGeneralErrorTemplate() ) ) { thisConfig[ 8 ].site_wide = getGeneralErrorTemplate(); }
		
		for( var virtual in getCFmappings() ?: {} ) {
			if( !isNull( getCFmappings()[ virtual ][ 'physical' ] ) && len( getCFmappings()[ virtual ][ 'physical' ] ) ) {
				var physical = getCFmappings()[ virtual ][ 'physical' ];
				thisConfig[ 9 ][ virtual ] = physical;	
			}
		}
		
		if( !isNull( getRequestTimeoutEnabled() ) ) { thisConfig[ 10 ].timeoutRequests = getRequestTimeoutEnabled(); }
		if( !isNull( getRequestTimeout() ) ) {
			// Convert from timepsan to seconds
			var rt = getRequestTimeout();
			var ts = createTimespan( rt.listGetAt( 1 ), rt.listGetAt( 2 ), rt.listGetAt( 3 ), rt.listGetAt( 4 ) );
			// timespan of "1" is one day.  Multiple to get seconds
			thisConfig[ 10 ].timeoutRequestTimeLimit = round( ts*24*60*60 );
		}
		if( !isNull( getPostParametersLimit() ) ) { thisConfig[ 10 ].postParametersLimit = getPostParametersLimit(); }
		if( !isNull( getPostSizeLimit() ) ) { thisConfig[ 10 ].postSizeLimit = getPostSizeLimit(); }
		
		if( !isNull( getTemplateCacheSize() ) ) { thisConfig[ 11 ].templateCacheSize = getTemplateCacheSize(); }
		if( !isNull( getSaveClassFiles() ) ) { thisConfig[ 11 ].saveClassFiles = getSaveClassFiles(); }
		if( !isNull( getComponentCacheEnabled() ) ) { thisConfig[ 11 ].componentCacheEnabled = getComponentCacheEnabled(); }
		
		if( !isNull( getInspectTemplate() ) ) {
			
			switch( getInspectTemplate() ) {
				case 'never' :
					thisConfig[ 11 ].trustedCacheEnabled = false;
					thisConfig[ 11 ].inRequestTemplateCacheEnabled = false;
					break;
				case 'once' :
					thisConfig[ 11 ].trustedCacheEnabled = false;
					thisConfig[ 11 ].inRequestTemplateCacheEnabled = true;
					break;
				case 'always' :
					thisConfig[ 11 ].trustedCacheEnabled = true;
					thisConfig[ 11 ].inRequestTemplateCacheEnabled = true;
			}
			
		}
		
		if( !isNull( getMailDefaultEncoding() ) ) { thisConfig[ 12 ].defaultMailCharset = getMailDefaultEncoding(); }
				
		if( !isNull( getCFFormScriptDirectory() ) ) { thisConfig[ 14 ].CFFormScriptSrc = getCFFormScriptDirectory(); }
		
		if( !isNull( getScriptProtect() ) ) {
		
			// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.	
			switch( getScriptProtect() ) {
				case 'all' :
					thisConfig[ 15 ] = 'FORM,URL,COOKIE,CGI';
					break;
				case 'none' :
					thisConfig[ 15 ] = '';
					break;
				default :
					thisConfig[ 15 ] = getScriptProtect();
			}
			
		}
		
		
		if( !isNull( getPerAppSettingsEnabled() ) ) { thisConfig[ 16 ].isPerAppSettingsEnabled = getPerAppSettingsEnabled(); }
		// Adobe stores the inverse of Lucee
		if( !isNull( getUDFTypeChecking() ) ) { thisConfig[ 16 ].cfcTypeCheckEnabled = !getUDFTypeChecking(); }
		if( !isNull( getDisableInternalCFJavaComponents() ) ) { thisConfig[ 16 ].disableServiceFactory = getDisableInternalCFJavaComponents(); }
		// Lucee and Adobe store opposite value
		if( !isNull( getDotNotationUpperCase() ) ) { thisConfig[ 16 ].preserveCaseForSerialize = getDotNotationUpperCase(); }
		if( !isNull( getSecureJSON() ) ) { thisConfig[ 16 ].secureJSON = getSecureJSON(); }
		if( !isNull( getSecureJSONPrefix() ) ) { thisConfig[ 16 ].secureJSONPrefix = getSecureJSONPrefix(); }
		if( !isNull( getMaxOutputBufferSize() ) ) { thisConfig[ 16 ].maxOutputBufferSize = getMaxOutputBufferSize(); }
		if( !isNull( getInMemoryFileSystemEnabled() ) ) { thisConfig[ 16 ].enableInMemoryFileSystem = getInMemoryFileSystemEnabled(); }
		if( !isNull( getInMemoryFileSystemLimit() ) ) { thisConfig[ 16 ].inMemoryFileSystemLimit = getInMemoryFileSystemLimit(); }
		if( !isNull( getInMemoryFileSystemAppLimit() ) ) { thisConfig[ 16 ].inMemoryFileSystemAppLimit = getInMemoryFileSystemAppLimit(); }
		if( !isNull( getAllowExtraAttributesInAttrColl() ) ) { thisConfig[ 16 ].allowExtraAttributesInAttrColl = getAllowExtraAttributesInAttrColl(); }
		if( !isNull( getDisallowUnamedAppScope() ) ) { thisConfig[ 16 ].dumpunnamedappscope = getDisallowUnamedAppScope(); }
		if( !isNull( getAllowApplicationVarsInServletContext() ) ) { thisConfig[ 16 ].allowappvarincontext = getAllowApplicationVarsInServletContext(); }
		if( !isNull( getCFaaSGeneratedFilesExpiryTime() ) ) { thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime = getCFaaSGeneratedFilesExpiryTime(); }
		if( !isNull( getORMSearchIndexDirectory() ) ) { thisConfig[ 16 ].ORMSearchIndexDirectory = getORMSearchIndexDirectory(); }
		if( !isNull( getGoogleMapKey() ) ) { thisConfig[ 16 ].googleMapKey = getGoogleMapKey(); }
		if( !isNull( getServerCFCEenabled() ) ) { thisConfig[ 16 ].enableServerCFC = getServerCFCEenabled(); }
		if( !isNull( getServerCFC() ) ) { thisConfig[ 16 ].serverCFC = getServerCFC(); }
		if( !isNull( getCompileExtForCFInclude() ) ) { thisConfig[ 16 ].compileextforinclude = getCompileExtForCFInclude(); }
		if( !isNull( getSessionCookieTimeout() ) ) { thisConfig[ 16 ].sessionCookieTimeout = getSessionCookieTimeout(); }
		if( !isNull( getSessionCookieHTTPOnly() ) ) { thisConfig[ 16 ].httpOnlySessionCookie = getSessionCookieHTTPOnly(); }
		if( !isNull( getSessionCookieSecure() ) ) { thisConfig[ 16 ].secureSessionCookie = getSessionCookieSecure(); }
		if( !isNull( getSessionCookieDisableUpdate() ) ) { thisConfig[ 16 ].internalCookiesDisableUpdate = getSessionCookieDisableUpdate(); }
		
		if( !isNull( getApplicationMode() ) ) {
			
			// See comments in BaseConfig class for descriptions
			switch( getApplicationMode() ) {
				case 'curr2driveroot' :
				// Next best match for "current only"
				case 'curr' :
					thisConfig[ 16 ].applicationCFCSearchLimit = 1;
					break;
				case 'curr2root' :
					thisConfig[ 16 ].applicationCFCSearchLimit = 2;
					break;
				case 'currorroot' :
				// Next best match for "root only"
				case 'root' :
					thisConfig[ 16 ].applicationCFCSearchLimit = 3;
			}
				
		}
						
		if( !isNull( getSessionCookieDisableUpdate() ) ) { thisConfig[ 18 ][ 'throttle-threshold' ] = getThrottleThreshold(); }
		if( !isNull( getTotalThrottleMemory() ) ) { thisConfig[ 18 ][ 'total-throttle-memory' ] = getTotalThrottleMemory(); }

		writeWDDXConfigFile( thisConfig, configFilePath );
		
	}
	
	private function writeClientStore() {
		var configFilePath = getCFHomePath().listAppend( getClientStoreConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getClientStoreConfigTemplate() );
		}
				
		if( !isNull( getUseUUIDForCFToken() ) ) { thisConfig[ 2 ].uuidToken = getUseUUIDForCFToken(); }

		writeWDDXConfigFile( thisConfig, configFilePath );
	}
	
	private function writeWatch() {
		var configFilePath = getCFHomePath().listAppend( getWatchConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getWatchConfigTemplate() );
		}
				
		if( !isNull( getWatchConfigFilesForChangesEnabled() ) ) { thisConfig[ 'watch.watchEnabled' ] = getWatchConfigFilesForChangesEnabled(); }
		if( !isNull( getWatchConfigFilesForChangesInterval() ) ) { thisConfig[ 'watch.interval' ] = getWatchConfigFilesForChangesInterval(); }
		if( !isNull( getWatchConfigFilesForChangesExtensions() ) ) { thisConfig[ 'watch.extensions' ] = getWatchConfigFilesForChangesExtensions(); }
		
		writeWDDXConfigFile( thisConfig, configFilePath );
	
	}
	
	private function writeMail() {
		var configFilePath = getCFHomePath().listAppend( getMailConfigPath(), '/' );
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getMailConfigTemplate() );
		}
				
		if( !isNull( getMailSpoolEnable() ) ) { thisConfig.spoolEnable = getMailSpoolEnable(); }
		if( !isNull( getMailSpoolInterval() ) ) { thisConfig.schedule = getMailSpoolInterval(); }
		if( !isNull( getMailConnectionTimeout() ) ) { thisConfig.timeout = getMailConnectionTimeout(); }
		if( !isNull( getMailDownloadUndeliveredAttachments() ) ) { thisConfig.allowDownload = getMailDownloadUndeliveredAttachments(); }
		if( !isNull( getMailSignMesssage() ) ) { thisConfig.sign = getMailSignMesssage(); }
		if( !isNull( getMailSignKeystore() ) ) { thisConfig.keystore = getMailSignKeystore(); }
		if( !isNull( getMailSignKeystorePassword() ) ) { thisConfig.keystorepassword = passwordManager.encryptMailServer( getMailSignKeystorePassword() ); }
		if( !isNull( getMailSignKeyAlias() ) ) { thisConfig.keyAlias = getMailSignKeyAlias(); }
		if( !isNull( getMailSignKeyPassword() ) ) { thisConfig.keypassword = passwordManager.encryptMailServer( getMailSignKeyPassword() ); }
		
		// Adobe can only store 1 mail server, so ignore any others.
		if( !isNull( getMailServers() ) && arrayLen( getMailServers() ) ) {
			var mailServer = getMailServers()[ 1 ];
			
			if( !isNull( mailServer.smtp ) ) { thisConfig.server = mailServer.smtp; }
			if( !isNull( mailServer.username ) ) { thisConfig.username = mailServer.username; }
			if( !isNull( mailServer.password ) ) { thisConfig.password = passwordManager.encryptMailServer( mailServer.password ); }
			if( !isNull( mailServer.port ) ) { thisConfig.port = mailServer.port; }
			if( !isNull(  mailServer.SSL ) ) { thisConfig.useSSL =  mailServer.SSL; }
			if( !isNull( mailServer.TSL ) ) { thisConfig.useTLS = mailServer.TSL; }
		}		
		
		writeWDDXConfigFile( thisConfig, configFilePath );	
	}

	private function writeDatasource() {
		
		if( isNull( getDatasources() ) || !structCount( getDatasources() ) ) {
			return;
		}
		
		var configFilePath = getCFHomePath().listAppend( getDatasourceConfigPath(), '/' );
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getDatasourceConfigTemplate() );
		}
		
		var datasources = getDatasources();
		
		for( var datasource in datasources ) {
			// For brevity
			var incomingDS = datasources[ datasource ];
			thisConfig[ 1 ][ datasource ] = thisConfig[ 1 ][ datasource ] ?: {};
			var savingDS = thisConfig[ 1 ][ datasource ];
			
	
			// Invert logic
			if( !isNull( incomingDS.blob ) ) { savingDS.disable_blob = !incomingDS.blob; }
			if( !isNull( incomingDS.class ) ) { savingDS.class = translateDatasourceClassToAdobe( translateDatasourceDriverToAdobe( incomingDS.dbdriver ), incomingDS.class ); }
			// Invert logic
			if( !isNull( incomingDS.clob ) ) { savingDS.disable_clob = !incomingDS.clob; }
			
			if( !isNull( incomingDS.connectionLimit ) ) {
				// If the field is "-1" (unlimited) then remove it entirely from the config
				if( incomingDS.connectionLimit == -1 ) {
					structDelete( savingDS.urlmap, 'maxConnections' );
				} else {
					savingDS.urlmap.maxConnections = incomingDS.connectionLimit;
				}
			}
			
			// Convert from minutes to seconds
			if( !isNull( incomingDS.connectionTimeout ) ) { savingDS.timeout = incomingDS.connectionTimeout * 60; }
			if( !isNull( incomingDS.database ) ) { savingDS.urlmap.database = incomingDS.database; }
			// Normalize names
			if( !isNull( incomingDS.dbdriver ) ) { savingDS.driver = translateDatasourceDriverToAdobe( incomingDS.dbdriver ); }
			if( !isNull( incomingDS.dsn ) ) { savingDS.url = incomingDS.dsn; }
			if( !isNull( incomingDS.host ) ) { savingDS.urlmap.host = incomingDS.host; }
			if( !isNull( incomingDS.password ) ) { savingDS.password = passwordManager.encryptDataSource( incomingDS.password ); }
			if( !isNull( incomingDS.port ) ) { savingDS.urlmap.port = incomingDS.port; }
			if( !isNull( incomingDS.username ) ) { savingDS.username = incomingDS.username; }
			if( !isNull( incomingDS.validate ) ) { savingDS.validateConnection = incomingDS.validate; }
		}
		
		writeWDDXConfigFile( thisConfig, configFilePath );	
	}

	private function writeAuth() {		
		var configFilePath = getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' );
		
		var propertyFile = wirebox.getInstance( 'propertyFile@propertyFile' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			propertyFile.load( configFilePath );
		}
		
		if( !isNull( getAdminPassword() ) ) {
			propertyFile[ 'password' ] = getAdminPassword();
			propertyFile[ 'encrypted' ] = 'false';
			
			if( !isNull( getAdminRDSPassword() ) ) { propertyFile[ 'rdspassword' ] = getAdminRDSPassword(); }
			
		} else if( !isNull( getACF11Password() ) ) {
			propertyFile[ 'password' ] = getACF11Password();
			propertyFile[ 'encrypted' ] = 'true';
			
			if( !isNull( getACF11RDSPassword() ) ) { propertyFile[ 'rdspassword' ] = getACF11RDSPassword(); }
		}
		
		propertyFile.store();
	
	}







	private function readWDDXConfigFile( required string configFilePath ) {
		if( !fileExists( configFilePath ) ) {
			throw "The config file doesn't exist [#configFilePath#]";
		}
		
		var thisConfigRaw = fileRead( configFilePath );
		if( !isXML( thisConfigRaw ) ) {
			throw "Config file doesn't contain XML [#configFilePath#]";
		}
		
		// Work around Lucee bug:
		// https://luceeserver.atlassian.net/browse/LDEV-1167
		thisConfigRaw = reReplaceNoCase( thisConfigRaw, '\s*type=["'']coldfusion\.server\.ConfigMap["'']', '', 'all' );
		
		wddx action='wddx2cfml' input=thisConfigRaw output='local.thisConfig';
		return local.thisConfig;		
	}
	
	private function writeWDDXConfigFile( required any data, required string configFilePath ) {
		
		// Ensure the parent directories exist		
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true )
		
		wddx action='cfml2wddx' input=data output='local.thisConfigRaw';
		
		fileWrite( configFilePath, thisConfigRaw );
		
	}

	private function getDefaultDatasourceStruct() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    // "url":"jdbc:mysql://localhost:3306/test?tinyInt1isBit=false&",
		    "url":"",
		    "update":true,
		    "password":"",
		    "DRIVER":"",
		    "NAME":"",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"",
		    "grant":true,
		    "buffer":64000,
		    "username":"",
		    "login_timeout":30,
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            "HOST":"",
		            "DATABASE":"",
		            "PORT":"0"
		        },
		        "host":"",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":0,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "sendStringParametersAsUnicode":"false",
		        "database":"test",
		        "informixServer":"",
		        "port":"0",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
	
	private function translateDatasourceDriverToGeneric( required string driverName ) {
		
		switch( driverName ) {
			case 'MSSQLServer' :
				return 'MSSQL';
			case 'PostgreSQL' :
				return 'PostgreSql';
			case 'Oracle' :
				return 'Oracle';
			case 'MySQL5' :
				return 'MySQL';
			case 'DB2' :
				return 'DB2';
			case 'Sybase' :
				return 'Sybase';
			case 'Apache Derby Client' :
				return 'Apache Derby Client';
			case 'Apache Derby Embedded' :
				return 'Apache Derby Embedded';
			case 'MySQL_DD' :
				return 'MySQL_DD';
			case 'jndi' :
				return 'jndi';
			default :
				return arguments.driverName;
		}
	
	}
	
	private function translateDatasourceDriverToAdobe( required string driverName ) {
		
		switch( driverName ) {
			case 'MSSQL' :
				return 'MSSQLServer';
			case 'PostgreSQL' :
				return 'PostgreSql';
			case 'Oracle' :
				return 'Oracle';
			case 'MySQL' :
				return 'MySQL5';
			case 'DB2' :
				return 'DB2';
			case 'Sybase' :
				return 'Sybase';
			// These all just fall through to default "other"
			case 'ODBC' :
			case 'HSQLDB' :
			case 'H2Server' :
			case 'H2' :
			case 'Firebird' :
			case 'MSSQL2' : // jTDS driver
			default :
				return arguments.driverName;
		}
	
	}
	
	private function translateDatasourceClassToAdobe( required string driverName, required string className ) {
		
		switch( driverName ) {
			case 'MSSQLServer' :
				return 'macromedia.jdbc.MacromediaDriver';
			case 'Oracle' :
				return 'macromedia.jdbc.MacromediaDriver';
			case 'MySQL5' :
				return 'com.mysql.jdbc.Driver';
			default :
				return arguments.className;
		}
	
	}
	
}