import SwiftUI

public struct BookSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: BookSessionViewModel
    var onBookingCreated: ((Booking) -> Void)? = nil

    public init(
        provider: Provider,
        bookingService: any BookingServiceProtocol = BookingService(),
        onBookingCreated: ((Booking) -> Void)? = nil
    ) {
        self._viewModel = State(initialValue: BookSessionViewModel(provider: provider, bookingService: bookingService))
        self.onBookingCreated = onBookingCreated
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isSuccess, let booking = viewModel.createdBooking {
                    successView(booking: booking)
                } else {
                    formContent
                }
            }
            .navigationTitle("Book Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(viewModel.isSuccess ? "Done" : "Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Form Content
    private var formContent: some View {
        Form {
            // Provider Header Info
            Section {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: viewModel.provider.type.uppercased() == "COACH" ? "person.fill" : "building.2.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.provider.name)
                            .font(.headline)
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                            Text(viewModel.provider.city)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // Date & Time Selection
            Section("Select Date & Time") {
                DatePicker(
                    "Session Time",
                    selection: $viewModel.selectedDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
            }

            // Duration
            Section("Duration") {
                Picker("Session Duration", selection: $viewModel.selectedDurationMinutes) {
                    Text("30 Minutes").tag(30)
                    Text("45 Minutes").tag(45)
                    Text("60 Minutes (1 hr)").tag(60)
                    Text("90 Minutes (1.5 hrs)").tag(90)
                    Text("120 Minutes (2 hrs)").tag(120)
                }
                .pickerStyle(.menu)
            }

            // Notes / Goals
            Section("Notes & Goals (Optional)") {
                TextField("E.g., Focus on backhand technique, fitness assessment...", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            // Error Display
            if let error = viewModel.errorMessage {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }

            // Submit Button
            Section {
                Button {
                    Task {
                        await viewModel.submitBooking()
                        if let booking = viewModel.createdBooking {
                            onBookingCreated?(booking)
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "calendar.badge.plus")
                            Text("Confirm Booking")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .disabled(viewModel.isLoading)
                .listRowBackground(Color.accentColor)
                .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Success View
    private func successView(booking: Booking) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 8) {
                Text("Session Booked!")
                    .font(.title2.weight(.bold))

                Text("Your session with \(booking.providerName) has been confirmed.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Date & Time", systemImage: "calendar")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(booking.formattedSessionTime)
                        .fontWeight(.semibold)
                }
                Divider()
                HStack {
                    Label("Duration", systemImage: "clock")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(booking.durationMinutes) min")
                        .fontWeight(.semibold)
                }
                Divider()
                HStack {
                    Label("Location", systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(booking.providerCity)
                        .fontWeight(.semibold)
                }
                Divider()
                HStack {
                    Label("Status", systemImage: "checkmark.shield.fill")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(booking.status.uppercased())
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.15), in: Capsule())
                        .foregroundStyle(.green)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}
