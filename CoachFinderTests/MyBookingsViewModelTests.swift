import Testing
import Foundation
@testable import CoachFinderCore

@Suite("MyBookingsViewModel Tests")
@MainActor
struct MyBookingsViewModelTests {

    private func makeBooking(id: Int, status: String, sessionTime: String) -> Booking {
        Booking(
            id: id,
            userId: 1,
            userName: "Alice",
            userEmail: "alice@example.com",
            providerId: 10,
            providerName: "Coach Alice",
            providerType: "COACH",
            providerCity: "New York",
            sessionTime: sessionTime,
            durationMinutes: 60,
            status: status
        )
    }

    @Test
    func loadBookings_Success_UpdatesBookingsList() async {
        let mockService = MockBookingService()
        let bookings = [
            makeBooking(id: 1, status: "CONFIRMED", sessionTime: "2026-11-01T10:00:00Z"),
            makeBooking(id: 2, status: "CONFIRMED", sessionTime: "2026-11-05T14:00:00Z")
        ]
        mockService.getMyBookingsResult = .success(PageResponse(content: bookings))

        let viewModel = MyBookingsViewModel(bookingService: mockService)
        await viewModel.loadBookings()

        #expect(viewModel.bookings.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func loadBookings_Failure_SetsErrorMessage() async {
        let mockService = MockBookingService()
        mockService.getMyBookingsResult = .failure(APIError.serverError(message: "Could not fetch bookings"))

        let viewModel = MyBookingsViewModel(bookingService: mockService)
        await viewModel.loadBookings()

        #expect(viewModel.bookings.isEmpty)
        #expect(viewModel.errorMessage == "Could not fetch bookings")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func filteredBookings_FiltersByStatusCorrectly() async {
        let mockService = MockBookingService()
        let futureISO = ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 5))
        let pastISO = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 5))

        let b1 = makeBooking(id: 1, status: "CONFIRMED", sessionTime: futureISO)
        let b2 = makeBooking(id: 2, status: "CANCELLED", sessionTime: futureISO)
        let b3 = makeBooking(id: 3, status: "CONFIRMED", sessionTime: pastISO)

        let viewModel = MyBookingsViewModel(bookingService: mockService)
        viewModel.bookings = [b1, b2, b3]

        viewModel.selectedFilter = .all
        #expect(viewModel.filteredBookings.count == 3)

        viewModel.selectedFilter = .upcoming
        #expect(viewModel.filteredBookings.count == 1)
        #expect(viewModel.filteredBookings.first?.id == 1)

        viewModel.selectedFilter = .cancelled
        #expect(viewModel.filteredBookings.count == 1)
        #expect(viewModel.filteredBookings.first?.id == 2)

        viewModel.selectedFilter = .past
        #expect(viewModel.filteredBookings.count == 1)
        #expect(viewModel.filteredBookings.first?.id == 3)
    }

    @Test
    func cancelBooking_Success_UpdatesStatusInList() async {
        let mockService = MockBookingService()
        let futureISO = ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 2))
        let original = makeBooking(id: 7, status: "CONFIRMED", sessionTime: futureISO)
        let cancelled = makeBooking(id: 7, status: "CANCELLED", sessionTime: futureISO)
        mockService.cancelBookingResult = .success(cancelled)

        let viewModel = MyBookingsViewModel(bookingService: mockService)
        viewModel.bookings = [original]

        await viewModel.cancelBooking(original)

        #expect(mockService.lastCancelledBookingId == 7)
        #expect(viewModel.bookings.first?.status == "CANCELLED")
        #expect(viewModel.errorMessage == nil)
    }
}
