import Foundation

public protocol BookingServiceProtocol: Sendable {
    func createBooking(_ request: CreateBookingRequest) async throws -> Booking
    func getMyBookings(page: Int, size: Int) async throws -> PageResponse<Booking>
    func cancelBooking(id: Int) async throws -> Booking
}

public final class BookingService: BookingServiceProtocol, Sendable {
    private let apiClient: APIClient

    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    public func createBooking(_ request: CreateBookingRequest) async throws -> Booking {
        try await apiClient.request("v1/bookings", method: "POST", body: request)
    }

    public func getMyBookings(page: Int = 0, size: Int = 20) async throws -> PageResponse<Booking> {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        return try await apiClient.request("v1/bookings/me", method: "GET", queryItems: queryItems)
    }

    public func cancelBooking(id: Int) async throws -> Booking {
        try await apiClient.request("v1/bookings/\(id)/cancel", method: "PATCH")
    }
}
