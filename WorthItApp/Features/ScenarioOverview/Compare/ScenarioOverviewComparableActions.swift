import Foundation

extension ScenarioOverviewView {
    func saveComparable() async {
        guard !isSavingEntry else { return }
        guard let request = comparableRequest() else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            if let editingAlternative {
                _ = try await repository.updateAlternative(alternativeId: editingAlternative.id, request: request.update)
            } else {
                _ = try await repository.createAlternative(scenarioId: activeScenario.id, request: request.create)
            }

            await loadSummary()
            closeComparableEditor()
        } catch {
            actionError = String(describing: error)
        }
    }

    func deleteEditingComparable() async {
        guard let editingAlternative else {
            closeComparableEditor()
            return
        }
        guard !isSavingEntry else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            try await repository.deleteAlternative(alternativeId: editingAlternative.id)
            await loadSummary()
            closeComparableEditor()
        } catch {
            actionError = String(describing: error)
        }
    }

    func saveComparisonVisibility(selectedIds: Set<UUID>) async {
        guard !isSavingEntry else { return }

        let changedAlternatives = alternatives.filter { selectedIds.contains($0.id) != $0.isIncluded }
        guard !changedAlternatives.isEmpty else {
            popScenarioTab()
            return
        }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            for alternative in changedAlternatives {
                _ = try await repository.updateAlternative(
                    alternativeId: alternative.id,
                    request: UpdateAlternativeRequest(
                        name: alternative.name,
                        pricingMode: alternative.pricingMode,
                        paramsJson: alternative.paramsJson,
                        note: alternative.note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? alternative.note : nil,
                        isIncluded: selectedIds.contains(alternative.id)
                    )
                )
            }

            await loadSummary()
            popScenarioTab()
        } catch {
            actionError = String(describing: error)
        }
    }

    private func comparableRequest() -> (create: CreateAlternativeRequest, update: UpdateAlternativeRequest)? {
        let trimmedName = comparableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            actionError = "Comparable name is required."
            return nil
        }

        guard let params = comparableParams() else {
            actionError = "Cost parameter is required."
            return nil
        }

        let note = comparableNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedNote = note.isEmpty ? nil : note

        return (
            CreateAlternativeRequest(
                name: trimmedName,
                pricingMode: comparablePricingModel,
                paramsJson: params,
                note: normalizedNote,
                isIncluded: isComparableIncluded
            ),
            UpdateAlternativeRequest(
                name: trimmedName,
                pricingMode: comparablePricingModel,
                paramsJson: params,
                note: normalizedNote,
                isIncluded: isComparableIncluded
            )
        )
    }

    private func comparableParams() -> AlternativeParams? {
        switch comparablePricingModel {
        case .perDistance:
            guard let value = comparableDouble(comparablePricePerKm) else { return nil }
            return AlternativeParams(pricePerKm: value, includedCostCategories: inheritedCostCategories)
        case .distanceCurve:
            let points = comparableCurvePoints.compactMap(curvePoint)

            guard points.count >= 2 else { return nil }
            return AlternativeParams(pricePoints: points, includedCostCategories: inheritedCostCategories)
        case .perPeriod:
            guard let value = comparableDouble(comparablePricePerMonth) else { return nil }
            return AlternativeParams(pricePerMonth: value, includedCostCategories: inheritedCostCategories)
        case .manualEquivalent:
            guard let value = comparableDouble(comparableManualTotal) else { return nil }
            return AlternativeParams(kind: "total", value: value, includedCostCategories: inheritedCostCategories)
        case .mixed:
            guard let pricePerKm = comparableDouble(comparablePricePerKm) else { return nil }
            guard let pricePerMinute = comparableDouble(comparablePricePerMinute) else { return nil }
            return AlternativeParams(
                pricePerKm: pricePerKm,
                pricePerMinute: pricePerMinute,
                includedCostCategories: inheritedCostCategories
            )
        case .perTime:
            guard let value = comparableDouble(comparableManualTotal) else { return nil }
            return AlternativeParams(kind: "total", value: value, includedCostCategories: inheritedCostCategories)
        }
    }

    private var inheritedCostCategories: [String]? {
        let categories = comparableInheritedCostCategories.sorted()
        return categories.isEmpty ? nil : categories
    }

    private func comparableDouble(_ value: String) -> Double? {
        Double(sanitizedDecimalInput(value))
    }

    private func curvePoint(_ point: ComparableCurveInputPoint) -> AlternativePricePoint? {
        guard let distanceKm = comparableDouble(point.distanceKm), distanceKm > 0 else { return nil }
        guard let price = comparableDouble(point.totalPrice) else { return nil }
        return AlternativePricePoint(distanceKm: distanceKm, totalPrice: price)
    }
}
