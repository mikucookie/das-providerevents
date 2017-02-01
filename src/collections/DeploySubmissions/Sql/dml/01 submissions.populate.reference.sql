DECLARE @LastProcessedDate datetime = (SELECT MAX(SubmittedTime) FROM ${DAS_ProviderEvents.FQ}.Submissions.LatestVersion)
DECLARE @ProvidersToProcess TABLE (UKPRN bigint)


INSERT INTO @ProvidersToProcess
(UKPRN)
SELECT
	p.UKPRN
FROM ${ILR_Deds.FQ}.Valid.LearningProvider p
INNER JOIN ${ILR_Deds.FQ}.dbo.FileDetails fd
	ON p.UKPRN = fd.UKPRN
	AND fd.SubmittedTime > @LastProcessedDate


INSERT INTO [Reference].[Providers]
(UKPRN)
SELECT
	p.UKPRN,
	fd.Filename,
	fd.SubmittedTime
FROM @ProvidersToProcess p
INNER JOIN ${ILR_Deds.FQ}.dbo.FileDetails fd
	ON p.UKPRN = fd.UKPRN


INSERT INTO [Reference].[LearningDeliveries]
(UKPRN, LearnRefNumber, AimSeqNumber, ULN, NINumber, ProgType, FworkCode, PwayCode, StdCode, LearnStartDate, LearnPlanEndDate, LearnActEndDate)
SELECT
	ld.UKPRN,
	ld.LearnRefNumber,
	ld.AimSeqNumber,
	l.ULN,
	l.NINumber,
	ld.ProgType,
	ld.FworkCode,
	ld.PwayCode,
	ld.StdCode,
	ld.LearnStartDate,
	ld.LearnPlanEndDate,
	ld.LearnActEndDate,
FROM ${ILR_Deds.FQ}.Valid.LearningDelivery ld
INNER JOIN @ProvidersToProcess p
	ON ld.UKPRN = p.UKPRN
INNER JOIN ${ILR_Deds.FQ}.Valid.Learner l
	ON ld.UKPRN = l.UKPRN
	AND ld.LearnRefNumber = l.LearnRefNumber
