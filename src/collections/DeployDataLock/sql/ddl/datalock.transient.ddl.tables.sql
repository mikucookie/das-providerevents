--====================================================================================
-- Component tables
--====================================================================================
IF NOT EXISTS (SELECT [schema_id] FROM sys.schemas WHERE [name] = 'DataLock')
	BEGIN
		EXEC('CREATE SCHEMA DataLock')
	END
GO

-----------------------------------------------------------------------------------------------------------------------------------------------
-- TaskLog
-----------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(SELECT [object_id] FROM sys.tables WHERE [name]='TaskLog' AND [schema_id] = SCHEMA_ID('DataLock'))
BEGIN
    DROP TABLE DataLock.TaskLog
END
GO

CREATE TABLE DataLock.TaskLog
(
    [TaskLogId] uniqueidentifier NOT NULL DEFAULT(NEWID()),
    [DateTime] datetime NOT NULL DEFAULT(GETDATE()),
    [Level] nvarchar(10) NOT NULL,
    [Logger] nvarchar(512) NOT NULL,
    [Message] nvarchar(1024) NOT NULL,
    [Exception] nvarchar(max) NULL
)
GO


--------------------------------------------------------------------------------------
-- DataLockEvents
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEvents' AND [schema_id] = SCHEMA_ID('DataLock'))
	BEGIN
		DROP TABLE [DataLock].[DataLockEvents]
	END
GO

CREATE TABLE [DataLock].[DataLockEvents]
(
	Id							bigint			PRIMARY KEY,
	ProcessDateTime				datetime		NOT NULL,
	IlrFileName					nvarchar(50)	NOT NULL,
	SubmittedDateTime		    datetime		NOT NULL,
	AcademicYear				varchar(4)    	NOT NULL,
	UKPRN						bigint			NOT NULL,
	ULN							bigint			NOT NULL,
	LearnRefNumber				varchar(100)	NOT NULL,
    AimSeqNumber				bigint			NOT NULL,
	PriceEpisodeIdentifier		varchar(25)		NOT NULL,
	CommitmentId				bigint			NOT NULL,
	EmployerAccountId			bigint			NOT NULL,
	EventSource					int				NOT NULL,
	HasErrors					bit				NOT NULL,
	IlrStartDate				date			NULL,
	IlrStandardCode				bigint			NULL,
	IlrProgrammeType			int				NULL,
	IlrFrameworkCode			int				NULL,
	IlrPathwayCode				int				NULL,
	IlrTrainingPrice			decimal(12,5)	NULL,
	IlrEndpointAssessorPrice	decimal(12,5)	NULL
)
GO

--------------------------------------------------------------------------------------
-- DataLockEventPeriods
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEventPeriods' AND [schema_id] = SCHEMA_ID('DataLock'))
	BEGIN
		DROP TABLE [DataLock].[DataLockEventPeriods]
	END
GO

CREATE TABLE [DataLock].[DataLockEventPeriods]
(
	DataLockEventId			bigint			NOT NULL,
	CollectionPeriodName	varchar(8)		NOT NULL,
	CollectionPeriodMonth	int				NOT NULL,
	CollectionPeriodYear	int				NOT NULL,
	CommitmentVersion		bigint			NOT NULL,
	IsPayable				bit				NOT NULL
)
GO

--------------------------------------------------------------------------------------
-- DataLockEventCommitmentVersions
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEventCommitmentVersions' AND [schema_id] = SCHEMA_ID('DataLock'))
	BEGIN
		DROP TABLE [DataLock].[DataLockEventCommitmentVersions]
	END
GO

CREATE TABLE [DataLock].[DataLockEventCommitmentVersions]
(
	DataLockEventId				bigint			NOT NULL,
	CommitmentVersion			bigint			NOT NULL,
	CommitmentStartDate			date			NULL,
	CommitmentStandardCode		bigint			NULL,
	CommitmentProgrammeType		int				NULL,
	CommitmentFrameworkCode		int				NULL,
	CommitmentPathwayCode		int				NULL,
	CommitmentNegotiatedPrice	decimal(12,5)	NULL,
	CommitmentEffectiveDate		date			NULL
)
GO

--------------------------------------------------------------------------------------
-- DataLockEventErrors
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEventErrors' AND [schema_id] = SCHEMA_ID('DataLock'))
	BEGIN
		DROP TABLE [DataLock].[DataLockEventErrors]
	END
GO

CREATE TABLE [DataLock].[DataLockEventErrors]
(
	DataLockEventId			bigint			NOT NULL,
	ErrorCode				varchar(15)		NOT NULL,
	SystemDescription		nvarchar(255)	NOT NULL,
	PRIMARY KEY (DataLockEventId, ErrorCode)
)
GO

--====================================================================================
-- Reference tables
--====================================================================================
IF NOT EXISTS (SELECT [schema_id] FROM sys.schemas WHERE [name] = 'Reference')
	BEGIN
		EXEC('CREATE SCHEMA Reference')
	END
GO

--------------------------------------------------------------------------------------
-- IdentifierSeed
--------------------------------------------------------------------------------------
IF EXISTS(SELECT [object_id] FROM sys.tables WHERE [name]='IdentifierSeed' AND [schema_id] = SCHEMA_ID('Reference'))
BEGIN
    DROP TABLE Reference.IdentifierSeed
END
GO

CREATE TABLE Reference.IdentifierSeed
(
    IdentifierName		varchar(50)		PRIMARY KEY,
	MaxIdInDeds			bigint			NOT NULL
)
GO

--------------------------------------------------------------------------------------
-- Providers
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'Providers' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[Providers]
	END
GO

CREATE TABLE [Reference].[Providers]
(
	UKPRN			    bigint			PRIMARY KEY,
	IlrFilename		    nvarchar(50)	NOT NULL,
	SubmittedTime   	datetime		NOT NULL
)
GO

--------------------------------------------------------------------------------------
-- PriceEpisodeMatch
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'PriceEpisodeMatch' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[PriceEpisodeMatch]
	END
GO

CREATE TABLE [Reference].[PriceEpisodeMatch]
(
	Ukprn					bigint			NOT NULL,
	PriceEpisodeIdentifier	varchar(25)		NOT NULL,
	LearnRefNumber			varchar(100)	NOT NULL,
	AimSeqNumber			bigint			NOT NULL,
	CommitmentId			varchar(50)		NOT NULL,
	CollectionPeriodName	varchar(8)		NOT NULL,
	CollectionPeriodMonth	int				NOT NULL,
	CollectionPeriodYear	int				NOT NULL,
	IsSuccess				bit				NOT NULL
)
GO

--------------------------------------------------------------------------------------
-- PriceEpisodePeriodMatch
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'PriceEpisodePeriodMatch' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[PriceEpisodePeriodMatch]
	END
GO

CREATE TABLE [Reference].[PriceEpisodePeriodMatch]
(
	Ukprn					bigint			NOT NULL,
	PriceEpisodeIdentifier	varchar(25)		NOT NULL,
	LearnRefNumber			varchar(100)	NOT NULL,
	AimSeqNumber			bigint			NOT NULL,
	CommitmentId			bigint			NOT NULL,
	VersionId				bigint			NOT NULL,
	Period					int				NOT NULL,
	Payable					bit				NOT NULL,
	TransactionType			int				NOT NULL,
	CollectionPeriodName	varchar(8)		NOT NULL,
	CollectionPeriodMonth	int				NOT NULL,
	CollectionPeriodYear	int				NOT NULL
)
GO

--------------------------------------------------------------------------------------
-- ValidationError
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'ValidationError' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[ValidationError]
	END
GO

CREATE TABLE [Reference].[ValidationError]
(
	Ukprn					bigint			NULL,
	LearnRefNumber			varchar(100)	NULL,
	AimSeqNumber			bigint			NULL,
	RuleId					varchar(50)		NULL,
	PriceEpisodeIdentifier	varchar(25)		NOT NULL,
	CollectionPeriodName	varchar(8)		NOT NULL,
	CollectionPeriodMonth	int				NOT NULL,
	CollectionPeriodYear	int				NOT NULL
) 
GO

--------------------------------------------------------------------------------------
-- IlrPriceEpisodeData
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'IlrPriceEpisodeData' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[IlrPriceEpisodeData]
	END
GO

CREATE TABLE [Reference].[IlrPriceEpisodeData]
(
	Ukprn					bigint			NOT NULL,
	Uln						bigint			NOT NULL,
	PriceEpisodeIdentifier	varchar(25)		NOT NULL,
	LearnRefNumber			varchar(12)	    NOT NULL,
	AimSeqNumber			bigint			NULL,
    StartDate               date            NULL,
	ProgType			    int				NULL,
	FworkCode			    int				NULL,
	PwayCode			    int				NULL,
	StdCode				    bigint			NULL,
	TNP1					decimal(10,5)	NULL,
	TNP2					decimal(10,5)	NULL,
	TNP3					decimal(10,5)	NULL,
	TNP4					decimal(10,5)	NULL
) 
GO

--------------------------------------------------------------------------------------
-- DataLockEvents
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEvents' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[DataLockEvents]
	END
GO

CREATE TABLE [Reference].[DataLockEvents]
(
	Id							bigint			PRIMARY KEY,
	ProcessDateTime				datetime		NOT NULL,
	IlrFileName					nvarchar(50)	NOT NULL,
	SubmittedDateTime		    datetime		NOT NULL,
	AcademicYear				varchar(4)    	NOT NULL,
	UKPRN						bigint			NOT NULL,
	ULN							bigint			NOT NULL,
	LearnRefNumber				varchar(100)	NOT NULL,
    AimSeqNumber				bigint			NOT NULL,
	PriceEpisodeIdentifier		varchar(25)		NOT NULL,
	CommitmentId				bigint			NOT NULL,
	EmployerAccountId			bigint			NOT NULL,
	EventSource					int				NOT NULL,
	HasErrors					bit				NOT NULL,
	IlrStartDate				date			NULL,
	IlrStandardCode				bigint			NULL,
	IlrProgrammeType			int				NULL,
	IlrFrameworkCode			int				NULL,
	IlrPathwayCode				int				NULL,
	IlrTrainingPrice			decimal(12,5)	NULL,
	IlrEndpointAssessorPrice	decimal(12,5)	NULL
)
GO

--------------------------------------------------------------------------------------
-- DataLockEventPeriods
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEventPeriods' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[DataLockEventPeriods]
	END
GO

CREATE TABLE [Reference].[DataLockEventPeriods]
(
	DataLockEventId			bigint			NOT NULL,
	CollectionPeriodName	varchar(8)		NOT NULL,
	CollectionPeriodMonth	int				NOT NULL,
	CollectionPeriodYear	int				NOT NULL,
	CommitmentVersion		bigint			NOT NULL,
	IsPayable				bit				NOT NULL
)
GO

--------------------------------------------------------------------------------------
-- DataLockEventCommitmentVersions
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEventCommitmentVersions' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[DataLockEventCommitmentVersions]
	END
GO

CREATE TABLE [Reference].[DataLockEventCommitmentVersions]
(
	DataLockEventId				bigint			NOT NULL,
	CommitmentVersion			bigint			NOT NULL,
	CommitmentStartDate			date			NULL,
	CommitmentStandardCode		bigint			NULL,
	CommitmentProgrammeType		int				NULL,
	CommitmentFrameworkCode		int				NULL,
	CommitmentPathwayCode		int				NULL,
	CommitmentNegotiatedPrice	decimal(12,5)	NULL,
	CommitmentEffectiveDate		date			NULL
)
GO

--------------------------------------------------------------------------------------
-- DataLockEventErrors
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockEventErrors' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[DataLockEventErrors]
	END
GO

CREATE TABLE [Reference].[DataLockEventErrors]
(
	DataLockEventId			bigint			NOT NULL,
	ErrorCode				varchar(15)		NOT NULL,
	SystemDescription		nvarchar(255)	NOT NULL,
	PRIMARY KEY (DataLockEventId, ErrorCode)
)
GO

--------------------------------------------------------------------------------------
-- DataLockCommitmentData
--------------------------------------------------------------------------------------
IF EXISTS (SELECT [object_id] FROM sys.tables WHERE [name] = 'DataLockCommitmentData' AND [schema_id] = SCHEMA_ID('Reference'))
	BEGIN
		DROP TABLE [Reference].[DataLockCommitmentData]
	END
GO

CREATE TABLE [Reference].[DataLockCommitmentData]
(
	CommitmentId			bigint			NOT NULL,
	CommitmentVersion		bigint			NOT NULL,
    EmployerAccountId       bigint          NOT NULL,
	StartDate			    date			NOT NULL,
	StandardCode		    bigint			NULL,
	ProgrammeType		    int				NULL,
	FrameworkCode		    int				NULL,
	PathwayCode		        int				NULL,
	NegotiatedPrice	        decimal(12,5)	NOT NULL,
	EffectiveDate		    date			NOT NULL
) 
GO
