import SwiftUI

public struct MyBookingsView: View {
    @State var viewModel: MyBookingsViewModel
    @State private var bookingToCancel: Booking?
    @State private var showingCancelAlert: Bool = false

    public init(viewModel: MyBookingsViewModel? = nil) {
        self._viewModel = State(initialValue: viewModel ?? MyBookingsViewModel())
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(BookingFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 10)

            // Content
            if viewModel.isLoading && viewModel.bookings.isEmpty {
                Spacer()
                ProgressView("Loading your bookings...")
                Spacer()
            } else if viewModel.filteredBookings.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.filteredBookings) { booking in
                        bookingCard(booking: booking)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.loadBookings()
                }
            }
        }
        .navigationTitle("My Bookings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadBookings()
        }
        .alert("Cancel Booking?", isPresented: $showingCancelAlert) {
            Button("Keep Booking", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                if let booking = bookingToCancel {
                    Task {
                        await viewModel.cancelBooking(booking)
                    }
                }
            }
        } message: {
            if let booking = bookingToCancel {
                Text("Are you sure you want to cancel your session with \(booking.providerName) on \(booking.formattedSessionTime)?")
            }
        }
    }

    // MARK: - Booking Card
    private func bookingCard(booking: Booking) -> some View {
        let isCancelled = booking.isCancelled
        let isPast = (booking.parsedDate ?? Date()) < Date() && !isCancelled

        return VStack(alignment: .leading, spacing: 12) {
            // Top Row: Provider info and status chip
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(booking.providerName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 6) {
                        Text(booking.providerType.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("•")
                            .foregroundStyle(.tertiary)
                        HStack(spacing: 3) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                            Text(booking.providerCity)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Status Badge
                statusBadge(for: booking, isPast: isPast)
            }

            Divider()

            // Session Details Row
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.accentColor)
                        .font(.subheadline)
                    Text(booking.formattedSessionTime)
                        .font(.subheadline.weight(.medium))
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text("\(booking.durationMinutes)m")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Notes
            if let notes = booking.notes, !notes.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(.top, 2)
            }

            // Action: Cancel button for upcoming confirmed sessions
            if booking.isUpcoming {
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        bookingToCancel = booking
                        showingCancelAlert = true
                    } label: {
                        HStack(spacing: 4) {
                            if viewModel.cancellingBookingId == booking.id {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "xmark.circle")
                                Text("Cancel Session")
                                    .font(.footnote.weight(.semibold))
                            }
                        }
                    }
                    .disabled(viewModel.cancellingBookingId != nil)
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .controlSize(.small)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }

    // MARK: - Status Badge
    private func statusBadge(for booking: Booking, isPast: Bool) -> some View {
        if booking.isCancelled {
            return AnyView(
                Text("CANCELLED")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.12), in: Capsule())
                    .foregroundStyle(.red)
            )
        } else if isPast {
            return AnyView(
                Text("COMPLETED")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.15), in: Capsule())
                    .foregroundStyle(.secondary)
            )
        } else {
            return AnyView(
                Text("CONFIRMED")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15), in: Capsule())
                    .foregroundStyle(.green)
            )
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 54))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("No Bookings Found")
                    .font(.title3.weight(.bold))
                Text("You don't have any \(viewModel.selectedFilter.rawValue.lowercased()) session bookings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
    }
}
