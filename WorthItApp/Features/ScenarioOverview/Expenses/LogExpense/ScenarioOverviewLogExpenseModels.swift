import SwiftUI

extension ScenarioOverviewView {
    var logExpenseScreenModel: LogExpenseScreen.Model {
        LogExpenseScreen.Model(
            currencySymbol: currencySymbol,
            amount: $expenseAmount,
            category: $expenseCategory,
            dateText: Self.displayFullDate(expenseDate),
            timeText: Self.timeFormatter.string(from: expenseDate),
            notes: $expenseNotes,
            isRecurring: recurringExpenseBinding,
            recurringSubtitle: recurringSubtitle,
            recurringFrequency: $recurringFrequency,
            recurringStartDate: $recurringStartDate,
            recurringEndDate: $recurringEndDate,
            serviceLink: logExpenseServiceLinkModel,
            attachments: visibleExpenseAttachments,
            pendingResources: expensePendingResources,
            links: visibleExpenseLinks,
            linkDraft: $expenseLinkDraft,
            linkValidationMessage: expenseLinkError,
            isEditing: editingCostEvent != nil,
            sanitizeAmount: sanitizedDecimalInput,
            onOpenDatePicker: { activeLogExpensePicker = .date },
            onOpenTimePicker: { activeLogExpensePicker = .time },
            onAddPhoto: { showsExpensePhotoPicker = true },
            onAddFile: { showsExpenseFileImporter = true },
            onLinkDraftChange: { expenseLinkError = nil },
            onOpenAttachment: { attachment in Task { await openAttachment(attachment) } },
            onRemoveAttachment: { attachment in expenseRemovedAttachmentIds.insert(attachment.id) },
            onRemovePendingResource: { resource in expensePendingResources.removeAll { $0.id == resource.id } },
            onOpenLink: { link in UIApplication.shared.open(link.url) },
            onRemoveLink: { link in expenseRemovedLinkIds.insert(link.id) },
            onDelete: { Task { await deleteEditingExpense() } }
        )
    }

    var logExpenseServiceLinkModel: LogExpenseServiceLink.Model {
        LogExpenseServiceLink.Model(
            isExpanded: $isExpenseServiceLinkExpanded,
            selectedServiceId: $selectedExpenseScheduledServiceId,
            shouldCompleteService: $shouldCompleteLinkedScheduledService,
            scheduledServices: scheduledServices,
            subtitle: expenseLinkedServiceSubtitle,
            optionSubtitle: expenseServiceOptionSubtitle
        )
    }
}
