﻿using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Moq;
using NUnit.Framework;
using SFA.DAS.Provider.Events.Api.Types;
using SFA.DAS.Provider.Events.Application.Data.Entities;
using SFA.DAS.Provider.Events.Application.DataLock.WriteDataLocksQuery;
using SFA.DAS.Provider.Events.Application.Repositories;
using SFA.DAS.Provider.Events.Application.Validation.Rules;

namespace SFA.DAS.Provider.Events.Application.UnitTests.DataLock.WriteDataLocksQuery
{
    public class WhenHandling
    {
        private Mock<IDataLockEventRepository> _dataLockEventRepository;
        private WriteDataLocksQueryHandler _handler;
        private WriteDataLocksQueryRequest _request;

        [SetUp]
        public void Arrange()
        {
            _dataLockEventRepository = new Mock<IDataLockEventRepository>();

            _handler = new WriteDataLocksQueryHandler(_dataLockEventRepository.Object);

            _request = new WriteDataLocksQueryRequest();
        }

        [Test]
        public async Task ThenItShouldReturnValidResultWithEmptyList()
        {
            // Arrange
            _request.DataLocks = new Api.Types.DataLock[0];

            // Act
            var actual = await _handler.Handle(_request);

            // Assert
            _dataLockEventRepository.VerifyAll();
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual.IsValid);
        }

        [Test]
        public async Task ThenItShouldReturnValidResultWithNull()
        {
            // Arrange
            _request.DataLocks = null;

            // Act
            var actual = await _handler.Handle(_request);

            // Assert
            _dataLockEventRepository.VerifyAll();
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual.IsValid);
        }

        [Test]
        public async Task ThenItShouldReturnErrorWithInternalException()
        {
            // Arrange
            _request.DataLocks = new List<Api.Types.DataLock> { new Api.Types.DataLock() };
            _dataLockEventRepository.Setup(r => r.WriteDataLocks(It.IsAny<IList<DataLockEntity>>())).Throws(new ApplicationException("test ex")).Verifiable();

            // Act
            var actual = await _handler.Handle(_request);

            // Assert
            _dataLockEventRepository.VerifyAll();

            Assert.IsNotNull(actual);
            Assert.IsFalse(actual.IsValid);
            Assert.AreEqual("test ex", actual.Exception.Message);
        }

        [Test]
        public async Task ThenItShouldWriteEntitiesWithNoSubObjects()
        {
            // Arrange
            _request.DataLocks = new List<Api.Types.DataLock>
            {
                new Api.Types.DataLock
                {
                    Ukprn = 1,
                    AimSequenceNumber = 1,
                    LearnerReferenceNumber = "1",
                    PriceEpisodeIdentifier = "1"
                }
            };

            IList<DataLockEntity> actualEntities = null;

            _dataLockEventRepository.Setup(r => r.WriteDataLocks(It.IsAny<IList<DataLockEntity>>()))
                .Returns(Task.FromResult(default(object)))
                .Callback<IList<DataLockEntity>>(e => { actualEntities = e; });

            // Act
            var actual = await _handler.Handle(_request);

            // Assert
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual.IsValid);

            Assert.AreEqual(1, actualEntities.Count);
            Assert.AreEqual(1, actualEntities[0].Ukprn);
            Assert.AreEqual(1, actualEntities[0].AimSequenceNumber);
            Assert.AreEqual("1", actualEntities[0].LearnerReferenceNumber);
            Assert.AreEqual("1", actualEntities[0].PriceEpisodeIdentifier);
            Assert.IsNull(actualEntities[0].ErrorCodes);
            Assert.IsNull(actualEntities[0].Commitments);
        }

        [Test]
        public async Task ThenItShouldWriteEntitiesWithSubObjects()
        {
            // Arrange
            var dataLock1 = new Api.Types.DataLock
            {
                Ukprn = 2,
                AimSequenceNumber = 3,
                LearnerReferenceNumber = "L1",
                PriceEpisodeIdentifier = "P1"
            };

            var dataLock2 = new Api.Types.DataLock
            {
                Ukprn = 4,
                AimSequenceNumber = 5,
                LearnerReferenceNumber = "L2",
                PriceEpisodeIdentifier = "P2",
                ErrorCodes = new[] {"E1", "E2"},
                Commitments = new[] {9L, 8L, 7L}
            };

            _request.DataLocks = new List<Api.Types.DataLock> { dataLock1, dataLock2 };

            IList<DataLockEntity> actualEntities = null;

            _dataLockEventRepository.Setup(r => r.WriteDataLocks(It.IsAny<IList<DataLockEntity>>()))
                .Returns(Task.FromResult(default(object)))
                .Callback<IList<DataLockEntity>>(e => { actualEntities = e; });

            // Act
            var actual = await _handler.Handle(_request);

            // Assert
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual.IsValid);

            Assert.AreEqual(2, actualEntities.Count);
            Assert.AreEqual(2, actualEntities[0].Ukprn);
            Assert.AreEqual(3, actualEntities[0].AimSequenceNumber);
            Assert.AreEqual("L1", actualEntities[0].LearnerReferenceNumber);
            Assert.AreEqual("P1", actualEntities[0].PriceEpisodeIdentifier);
            Assert.IsNull(actualEntities[0].ErrorCodes);
            Assert.IsNull(actualEntities[0].Commitments);

            Assert.AreEqual(4, actualEntities[1].Ukprn);
            Assert.AreEqual(5, actualEntities[1].AimSequenceNumber);
            Assert.AreEqual("L2", actualEntities[1].LearnerReferenceNumber);
            Assert.AreEqual("P2", actualEntities[1].PriceEpisodeIdentifier);
            Assert.AreEqual("[\"E1\",\"E2\"]", actualEntities[1].ErrorCodes);
            Assert.AreEqual("[9,8,7]", actualEntities[1].Commitments);
        }
    }
}