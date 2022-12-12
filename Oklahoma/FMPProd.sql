	EXECUTE FILEVINE_META.PT1.FULL_MIGRATIONPROCESS 
		@DEBUGFLAG = 0,
		@LEGACYDBTYPE = 'Documents',
		@LEGACYDB = '7831_Oklahoma_GL',
		@PREVIOUSDB = '7831_Oklahoma', -- use for
		@ORGID = 7831,
		@SCHEMANAME = 'dbo',
		@FVPRODUCTIONPREFIX = '_OklahomaLegalService_', -- _8133_Setareh_RC_ used to do that find and replace. now we have synonym and it updates that to be new prefix. Makes it easier to not track the mispelled prefix etc. easier to write generic templates. 
		@FVPREVIOUSPREFIX = NULL,
		@IMPORTDATABASENAME = 'FilevineProductionImport', -- change to production
		@EXECUTIONDB = 'Filevine_META',
		@USEGENERICTEMPLATE = 0,
@TIMEZONE = 'central';