﻿namespace SFA.DAS.Provider.Events.Domain
{
    public class DataLockEventPeriod
    {
        public long ApprenticeshipVersion { get; set; }
        public NamedCalendarPeriod Period { get; set; }
        public bool Payable { get; set; }
    }
}