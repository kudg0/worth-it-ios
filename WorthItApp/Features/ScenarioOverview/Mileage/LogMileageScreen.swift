import SwiftUI

struct LogMileageScreen: View {
    let mode: Binding<ScenarioOverviewView.MileageMode>
    let value: Binding<String>
    let notes: Binding<String>
    let isEditing: Bool
    let currentOdometerValue: Int
    let mileageUnit: String
    let previousOdometerText: String
    let odometerDeltaText: String
    let resultingOdometerText: String
    let dateText: String
    let timeText: String
    let attachments: [ResourceAttachment]
    let pendingPhotos: [ScenarioPendingResourcePhoto]
    let links: [ResourceLink]
    let linkDraft: Binding<String>
    let linkValidationMessage: String?
    let sanitizeValue: (String) -> String
    let onModeChange: (ScenarioOverviewView.MileageMode) -> Void
    let onOpenDatePicker: () -> Void
    let onOpenTimePicker: () -> Void
    let onAddPhoto: () -> Void
    let onLinkDraftChange: () -> Void
    let onOpenAttachment: (ResourceAttachment) -> Void
    let onRemoveAttachment: (ResourceAttachment) -> Void
    let onRemovePendingPhoto: (ScenarioPendingResourcePhoto) -> Void
    let onOpenLink: (ResourceLink) -> Void
    let onRemoveLink: (ResourceLink) -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            modePicker

            if mode.wrappedValue == .odometer {
                odometerForm
            } else {
                tripForm
            }

            if isEditing {
                deleteButton
            }
        }
        .padding(.bottom, 120)
    }

    private var modePicker: some View {
        WISegmentedControl(
            items: [
                (title: i18n.t("Update Odometer"), value: ScenarioOverviewView.MileageMode.odometer),
                (title: i18n.t("Add Trip"), value: ScenarioOverviewView.MileageMode.trip),
            ],
            selection: mode
        )
        .allowsHitTesting(!isEditing)
        .onChange(of: mode.wrappedValue) { _, newMode in
            guard !isEditing else { return }
            onModeChange(newMode)
        }
    }

    private var odometerForm: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            LogMileageHeroInput(
                label: i18n.t("Current Odometer (\(mileageUnit))"),
                placeholder: i18n.t("0"),
                value: value,
                sanitizeValue: sanitizeValue
            )

            HStack(spacing: WorthItSpacing.l) {
                LogMileageStatTile(title: i18n.t("Previous"), value: previousOdometerText, color: WorthItColor.textPrimary)
                LogMileageStatTile(title: i18n.t("Delta"), value: odometerDeltaText, color: WorthItColor.accentGold)
            }

            formFields
        }
    }

    private var tripForm: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            LogMileageHeroInput(
                label: i18n.t("Trip Distance (\(mileageUnit))"),
                placeholder: i18n.t("0"),
                value: value,
                sanitizeValue: sanitizeValue
            )
            formFields

            LogMileageResultRow(title: i18n.t("Resulting Odometer"), value: resultingOdometerText, systemName: "doc.text")

            WITipInfo(
                title: i18n.t("Usage Analytics"),
                bodyText: i18n.t("This trip improves your usage analytics and cost-per-\(mileageUnit) accuracy.")
            )
        }
    }

    private var formFields: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack(spacing: WorthItSpacing.l) {
                LogMileagePickerField(label: i18n.t("Date"), value: dateText, systemName: "calendar", action: onOpenDatePicker)
                LogMileagePickerField(label: i18n.t("Time (optional)"), value: timeText, systemName: "clock", action: onOpenTimePicker)
            }

            LogMileageNotesField(notes: notes)

            ScenarioPhotoUploadInput(
                title: i18n.t("Photos"),
                attachments: attachments,
                pendingPhotos: pendingPhotos,
                links: links,
                linkDraft: linkDraft,
                linkValidationMessage: linkValidationMessage,
                onAddPhoto: onAddPhoto,
                onLinkDraftChange: onLinkDraftChange,
                onOpenAttachment: onOpenAttachment,
                onRemoveAttachment: onRemoveAttachment,
                onRemovePendingPhoto: onRemovePendingPhoto,
                onOpenLink: onOpenLink,
                onRemoveLink: onRemoveLink
            )
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive, action: onDelete) {
            Text("Delete Mileage Entry")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
