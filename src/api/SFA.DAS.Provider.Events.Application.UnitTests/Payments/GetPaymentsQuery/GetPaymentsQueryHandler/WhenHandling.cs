﻿using System;
using System.Threading.Tasks;
using FluentAssertions;
using Moq;
using NUnit.Framework;
using Ploeh.AutoFixture.NUnit3;
using SFA.DAS.Provider.Events.Api.Types;
using SFA.DAS.Provider.Events.Application.Data.Entities;
using SFA.DAS.Provider.Events.Application.Mapping;
using SFA.DAS.Provider.Events.Application.Payments.GetPaymentsQuery;
using SFA.DAS.Provider.Events.Application.Repositories;
using SFA.DAS.Provider.Events.Application.UnitTests.AutoFixture;

namespace SFA.DAS.Provider.Events.Application.UnitTests.Payments.GetPaymentsQuery.GetPaymentsQueryHandler
{
    public class WhenHandling
    {
        [Test, AutoMoqData]
        public async Task ThenMatchingPaymentsShouldBeReturned(
            [Frozen] Mock<IPaymentRepository> repository,
            [Frozen] Mock<IMapper> autoMapper,
            Application.Payments.GetPaymentsQuery.GetPaymentsQueryHandler sut,
            GetPaymentsQueryRequest request, PageOfResults<PaymentEntity> paymentEntities, PageOfResults<Payment> expectedResults
        )
        {
            // Arrange
            repository.Setup(x => x.GetPayments(request.PageNumber, request.PageSize, request.EmployerAccountId, request.Period.CalendarYear,
                request.Period.CalendarMonth, request.Ukprn)).ReturnsAsync(paymentEntities);

            autoMapper.Setup(x => x.Map<Api.Types.PageOfResults<Payment>>(paymentEntities)).Returns(expectedResults);

            // Act
            var actualResult = await sut.Handle(request).ConfigureAwait(false);

            // Assert
            actualResult.IsValid.Should().BeTrue();
            actualResult.Result.Should().BeSameAs(expectedResults);
        }

        [Test, AutoMoqData]
        public async Task ThenItShouldReturnAnInvalidResponseIfExceptionThrown(
            [Frozen] Mock<IPaymentRepository> repository,
            [Frozen] Mock<IMapper> autoMapper,
            Application.Payments.GetPaymentsQuery.GetPaymentsQueryHandler sut,
            GetPaymentsQueryRequest request)
        {
            // Arrange
            var ex = new Exception();
            repository.Setup(r => r.GetPayments(It.IsAny<int>(), It.IsAny<int>(), It.IsAny<string>(), It.IsAny<int?>(), It.IsAny<int?>(), It.IsAny<long?>()))
                .Throws(ex);

            // Act
            var actual = await sut.Handle(request).ConfigureAwait(false);

            // Assert
            actual.IsValid.Should().BeFalse();
            actual.Exception.Should().Be(ex);
        }
    }
}
