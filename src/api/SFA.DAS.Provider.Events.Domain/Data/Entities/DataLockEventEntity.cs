﻿using System;

namespace SFA.DAS.Provider.Events.Domain.Data.Entities
{
    public class DataLockEventEntity
    {
        public long Id { get; set; }
        public DateTime ProcessDateTime { get; set; }
        public string IlrFileName { get; set; }
        public long Ukprn { get; set; }
        public long Uln { get; set; }
        public string LearnRefNumber { get; set; }
        public long AimSeqNumber { get; set; }
        public string PriceEpisodeIdentifier { get; set; }
        public long ApprenticeshipId { get; set; }
        public long EmployerAccountId { get; set; }
        public int EventSource { get; set; }
        public bool HasErrors { get; set; }
        public DateTime? IlrStartDate { get; set; }
        public long? IlrStandardCode { get; set; }
        public int? IlrProgrammeType { get; set; }
        public int? IlrFrameworkCode { get; set; }
        public int? IlrPathwayCode { get; set; }
        public decimal? IlrTrainingPrice { get; set; }
        public decimal? IlrEndpointAssessorPrice { get; set; }

        public DataLockEventErrorEntity[] Errors { get; set; }
        public DataLockEventPeriodEntity[] Periods { get; set; }
        public DataLockEventApprenticeshipEntity[] Apprenticeships { get; set; }
    }
}