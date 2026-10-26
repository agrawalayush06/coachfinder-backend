import Foundation
@testable import CoachFinderCore

public final class MockBookingService: BookingServiceProtocol, @unchecked Sendable {
    public var createBookingResult: Result<Booking, Error> = .failure(APIError.serverError(message: "Not configured"))
    public var getMyBookingsResult: Result<PageResponse<Booking>, Error> = .success(PageResponse(content: []))
    public var cancelBookingResult: Result<Booking, Error> = .failure(APIError.serverError(message: "Not configured"))

    public private(set) var lastCreateBookingRequest: CreateBookingRequest?
    public private(set) var lastCancelledBookingId: Int?
    public private(set) var getMyBookingsCallCount = 0

    public init() {}

    public func createBooking(_ request: CreateBookingRequest) async throws -> Booking {
        lastCreateBookingRequest = request
        return try createBookingResult.get()
    }

    public func getMyBookings(page: Int, size: Int) async throws -> PageResponse<Booking> {
        getMyBookingsCallCount += 1
        return try getMyBookingsResult.get()
    }

    public func cancelBooking(id: Int) async throws -> Booking {
        lastCancelledBookingId = id
        return try cancelBookingResult.get()
    }
}
