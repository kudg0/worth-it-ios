import SwiftUI

extension ScenarioOverviewView {
    func openMileageForm(mode: MileageMode = .odometer) {
        resetMileageForm()
        mileageMode = mode
        if mode == .odometer, currentOdometerValue > 0 {
            mileageValue = "\(currentOdometerValue)"
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.mileage]
            selectedTab = .logMileage
        }
    }

    func beginEditingMileage(_ usageEventId: UUID) {
        guard let event = usageEvents.first(where: { $0.id == usageEventId }) else { return }

        let returnTab = selectedTab
        editingUsageEvent = event
        mileageMode = event.eventType == "odometer_update" ? .odometer : .trip
        mileageDate = event.date
        mileageNotes = event.note ?? ""

        if mileageMode == .odometer {
            mileageValue = event.odometerValue.map { formatEditableNumber($0) } ?? ""
        } else {
            mileageValue = formatEditableNumber(event.distanceValue)
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(returnTab)
            selectedTab = .logMileage
        }
    }

    func mileagePickerSheet(_ picker: MileagePicker) -> some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                Group {
                    switch picker {
                    case .date:
                        DatePicker("Date", selection: $mileageDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding(WorthItSpacing.xl)
                    case .time:
                        DatePicker("Time", selection: $mileageDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(WorthItSpacing.xl)
                    }
                }
                .tint(WorthItColor.primaryContainer)
            }
            .navigationTitle(picker == .date ? "Date" : "Time")
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { activeMileagePicker = nil }
                        .foregroundStyle(WorthItColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { activeMileagePicker = nil }
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }

    func saveMileage() async {
        guard !isSavingEntry else { return }
        guard let value = Double(mileageValue), value > 0 else {
            actionError = mileageMode == .trip ? "Enter trip distance." : "Enter odometer reading."
            return
        }

        if mileageMode == .odometer, previousOdometerForMileageForm > 0, value < Double(previousOdometerForMileageForm) {
            actionError = "Odometer reading cannot be lower than previous reading."
            return
        }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            if let editingUsageEvent {
                _ = try await repository.updateUsageEvent(
                    usageEventId: editingUsageEvent.id,
                    request: UpdateUsageEventRequest(
                        eventType: mileageMode.eventType,
                        date: mileageDate,
                        distanceValue: mileageMode == .trip ? value : nil,
                        odometerValue: mileageMode == .odometer ? value : nil,
                        durationMinutes: nil,
                        note: trimmedMileageNotes.isEmpty ? "" : trimmedMileageNotes
                    )
                )
            } else {
                _ = try await repository.createUsageEvent(
                    scenarioId: activeScenario.id,
                    request: CreateUsageEventRequest(
                        eventType: mileageMode.eventType,
                        date: mileageDate,
                        distanceValue: mileageMode == .trip ? value : nil,
                        odometerValue: mileageMode == .odometer ? value : nil,
                        durationMinutes: nil,
                        note: trimmedMileageNotes.isEmpty ? nil : trimmedMileageNotes
                    )
                )
            }

            await loadSummary()
            navigateAfterMileageSave()
            resetMileageForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    func deleteEditingMileage() async {
        guard !isSavingEntry, let editingUsageEvent else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            try await repository.deleteUsageEvent(usageEventId: editingUsageEvent.id)
            await loadSummary()
            navigateAfterMileageSave()
            resetMileageForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    var trimmedMileageNotes: String {
        mileageNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resetMileageForm() {
        editingUsageEvent = nil
        mileageMode = .odometer
        mileageValue = ""
        mileageDate = Date()
        mileageNotes = ""
        activeMileagePicker = nil
    }

    func navigateAfterMileageSave() {
        let destination: ScenarioTab = scenarioTabPath.contains(.mileageHistory) ? .mileageHistory : .mileage

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = destination == .mileageHistory ? [.mileage] : []
            selectedTab = destination
        }
    }
}
