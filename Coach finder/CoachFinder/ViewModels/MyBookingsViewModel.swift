import Foundation
import Observation

public enum BookingFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case upcoming = "Upcoming"
    case past = "Past"
    case cancelled = "Cancelled"

    public var id: String { rawValue }
}

@Observable
@MainActor
public final class MyBookingsViewModel {
    public var bookings: [Booking] = []
    public var selectedFilter: BookingFilter = .all
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var cancellingBookingId: Int?

    private let bookingService: any BookingServiceProtocol

    public init(bookingService: any BookingServiceProtocol = BookingService()) {
        self.bookingService = bookingService
    }

    public var filteredBookings: [Booking] {
        switch selectedFilter {
        case .all:
            return bookings
        case .upcoming:
            return bookings.filter { $0.isUpcoming }
        case .past:
            return bookings.filter {
                guard let date = $0.parsedDate else { return false }
                return date <= Date() && !$0.isCancelled
            }
        case .cancelled:
            return bookings.filter { $0.isCancelled }
        }
    }

    public func loadBookings() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await bookingService.getMyBookings(page: 0, size: 50)
            self.bookings = response.content
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    public func cancelBooking(_ booking: Booking) async {
        cancellingBookingId = booking.id
        errorMessage = nil

        do {
            let updated = try await bookingService.cancelBooking(id: booking.id)
            if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
                bookings[index] = updated
            }
            cancellingBookingId = nil
        } catch {
            self.errorMessage = error.localizedDescription
            cancellingBookingId = nil
        }
    }
}
