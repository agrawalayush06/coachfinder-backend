import Foundation
import Observation

@Observable
@MainActor
public final class BookSessionViewModel {
    public let provider: Provider
    public var selectedDate: Date
    public var selectedDurationMinutes: Int = 60
    public var notes: String = ""

    public var isLoading: Bool = false
    public var errorMessage: String?
    public var createdBooking: Booking?
    public var isSuccess: Bool = false

    private let bookingService: any BookingServiceProtocol

    public init(
        provider: Provider,
        bookingService: any BookingServiceProtocol = BookingService()
    ) {
        self.provider = provider
        self.bookingService = bookingService
        
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date().addingTimeInterval(86400))
        comps.hour = 10
        comps.minute = 0
        self.selectedDate = calendar.date(from: comps) ?? Date().addingTimeInterval(86400)
    }

    public func submitBooking() async {
        guard selectedDate > Date() else {
            errorMessage = "Please choose a future date and time for the session."
            return
        }

        isLoading = true
        errorMessage = nil

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let sessionTimeString = formatter.string(from: selectedDate)

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let req = CreateBookingRequest(
            providerId: provider.id,
            activityId: nil,
            sessionTime: sessionTimeString,
            durationMinutes: selectedDurationMinutes,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )

        do {
            let booking = try await bookingService.createBooking(req)
            self.createdBooking = booking
            self.isSuccess = true
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
