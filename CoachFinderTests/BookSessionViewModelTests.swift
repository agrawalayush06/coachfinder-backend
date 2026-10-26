import Testing
import Foundation
@testable import CoachFinderCore

@Suite("BookSessionViewModel Tests")
@MainActor
struct BookSessionViewModelTests {

    private let sampleProvider = Provider(
        id: 42,
        userId: 1,
        type: "COACH",
        name: "Coach Mike",
        city: "San Francisco"
    )

    @Test
    func submitBooking_Success_UpdatesCreatedBookingAndSetsIsSuccess() async {
        let mockService = MockBookingService()
        let expectedBooking = Booking(
            id: 101,
            userId: 5,
            userName: "Alice",
            userEmail: "alice@example.com",
            providerId: 42,
            providerName: "Coach Mike",
            providerType: "COACH",
            providerCity: "San Francisco",
            sessionTime: "2026-11-01T10:00:00Z",
            durationMinutes: 60,
            status: "CONFIRMED",
            notes: "Need help with forehand"
        )
        mockService.createBookingResult = .success(expectedBooking)

        let viewModel = BookSessionViewModel(provider: sampleProvider, bookingService: mockService)
        viewModel.selectedDate = Date().addingTimeInterval(86400 * 2)
        viewModel.selectedDurationMinutes = 60
        viewModel.notes = "Need help with forehand"

        await viewModel.submitBooking()

        #expect(viewModel.isSuccess == true)
        #expect(viewModel.createdBooking?.id == 101)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.lastCreateBookingRequest?.providerId == 42)
        #expect(mockService.lastCreateBookingRequest?.durationMinutes == 60)
        #expect(mockService.lastCreateBookingRequest?.notes == "Need help with forehand")
    }

    @Test
    func submitBooking_PastDate_RejectsWithoutCallingService() async {
        let mockService = MockBookingService()
        let viewModel = BookSessionViewModel(provider: sampleProvider, bookingService: mockService)
        viewModel.selectedDate = Date().addingTimeInterval(-3600) // 1 hour ago

        await viewModel.submitBooking()

        #expect(viewModel.isSuccess == false)
        #expect(viewModel.errorMessage?.contains("future") == true)
        #expect(mockService.lastCreateBookingRequest == nil)
    }

    @Test
    func submitBooking_Failure_SetsErrorMessage() async {
        let mockService = MockBookingService()
        mockService.createBookingResult = .failure(APIError.serverError(message: "Provider is already booked"))

        let viewModel = BookSessionViewModel(provider: sampleProvider, bookingService: mockService)
        viewModel.selectedDate = Date().addingTimeInterval(86400 * 3)

        await viewModel.submitBooking()

        #expect(viewModel.isSuccess == false)
        #expect(viewModel.errorMessage == "Provider is already booked")
        #expect(viewModel.createdBooking == nil)
    }
}
