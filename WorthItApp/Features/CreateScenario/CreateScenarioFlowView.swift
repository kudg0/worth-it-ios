import SwiftUI

struct CreateScenarioFlowView: View {
    enum Step: Int {
        case scenarioType = 1
        case carDetails = 2
        case success = 3

        var title: String {
            "New Scenario"
        }
    }

    enum AcquisitionType: Hashable {
        case cash
        case loan
    }

    enum Field: Hashable {
        case vehicleName
        case purchaseDate
        case odometer
        case resaleValue
        case vehiclePrice
        case loanAmount
        case loanTerm
        case interestRate
    }

    private let animation = Animation.easeInOut(duration: 0.24)
    let repository: ScenarioRepository
    let editingScenario: ScenarioListItem?
    let onScenarioCreated: (ScenarioListItem) -> Void
    let onScenarioUpdated: (ScenarioListItem) -> Void
    let onOpenOverview: (ScenarioListItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .scenarioType
    @State private var createdScenario: ScenarioListItem?
    @State private var acquisitionType: AcquisitionType = .cash
    @State private var vehicleName = ""
    @State private var purchaseDate: Date?
    @State private var odometer = ""
    @State private var resaleValue = ""
    @State private var vehiclePrice = ""
    @State private var currency = "EUR"
    @State private var loanAmount = ""
    @State private var loanTerm = "48"
    @State private var interestRate = "4.5"
    @State private var validationErrors: [Field: String] = [:]
    @State private var hasAttemptedCarDetailsSubmit = false
    @State private var isCreatingScenario = false
    @State private var submissionError: String?
    private let currencies = ["EUR", "USD", "GBP"]

    init(
        repository: ScenarioRepository,
        editingScenario: ScenarioListItem? = nil,
        onScenarioCreated: @escaping (ScenarioListItem) -> Void,
        onScenarioUpdated: @escaping (ScenarioListItem) -> Void,
        onOpenOverview: @escaping (ScenarioListItem) -> Void
    ) {
        self.repository = repository
        self.editingScenario = editingScenario
        self.onScenarioCreated = onScenarioCreated
        self.onScenarioUpdated = onScenarioUpdated
        self.onOpenOverview = onOpenOverview

        _step = State(initialValue: editingScenario == nil ? .scenarioType : .carDetails)
        _acquisitionType = State(initialValue: editingScenario?.acquisitionType == "loan" ? .loan : .cash)
        _vehicleName = State(initialValue: editingScenario?.name ?? "")
        _purchaseDate = State(initialValue: editingScenario?.startDate)
        _odometer = State(initialValue: editingScenario?.purchaseOdometer.map(String.init) ?? "")
        _resaleValue = State(initialValue: editingScenario?.expectedResaleValue ?? "")
        _vehiclePrice = State(initialValue: editingScenario?.purchasePrice ?? "")
        _currency = State(initialValue: editingScenario?.currency ?? "EUR")
        _loanAmount = State(initialValue: editingScenario?.loanAmount ?? "")
        _loanTerm = State(initialValue: editingScenario?.loanTermMonths.map(String.init) ?? "48")
        _interestRate = State(initialValue: editingScenario?.loanAnnualInterestRate ?? "4.5")
    }

    var body: some View {
        ZStack {
            WorthItColor.pageBackground.ignoresSafeArea()
            decorativeGlow

            VStack(spacing: 0) {
                if step == .success {
                    successTopBar
                        .transition(.opacity)
                } else {
                    WIFlowHeader(
                        title: flowTitle,
                        currentStep: step.rawValue,
                        totalSteps: 2,
                        showsProgress: editingScenario == nil
                    ) {
                        goBack()
                    }
                    .transition(.opacity)
                }

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        Color.clear
                            .frame(height: 0)
                            .id("flowTop")

                        ZStack {
                            switch step {
                            case .scenarioType:
                                scenarioTypeContent
                                    .transition(.opacity)
                            case .carDetails:
                                carDetailsContent
                                    .transition(.opacity)
                            case .success:
                                successContent
                                    .transition(.opacity)
                            }
                        }
                        .animation(animation, value: step)
                        .padding(.horizontal, WorthItSpacing.xxl)
                        .padding(.top, step == .success ? 32 : 40)
                        .padding(.bottom, step == .success ? 180 : 132)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: step) { _, _ in
                        withAnimation(animation) {
                            scrollProxy.scrollTo("flowTop", anchor: .top)
                        }
                    }
                }
            }

            if step != .success {
                footer
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                successFooter
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var scenarioTypeContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.m) {
                Text("What are we tracking?")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.75)

                Text("Start with one ownership scenario and\ncompare it against alternatives.")
                    .font(WorthItTypography.body)
                    .lineSpacing(4)
                    .foregroundStyle(WorthItColor.textSecondary.opacity(0.80))
            }

            VStack(spacing: WorthItSpacing.l) {
                WIOptionCard(
                    title: i18n.t("Car Ownership"),
                    subtitle: i18n.t("Analyze purchase costs, maintenance, and resale value."),
                    systemIcon: "car.fill",
                    state: .selected
                )

                WIOptionCard(
                    title: i18n.t("Other Assets"),
                    subtitle: i18n.t("Real estate and high-value collectibles tracking."),
                    systemIcon: "square.grid.2x2.fill",
                    state: .disabled,
                    badge: "COMING SOON"
                )
            }

            WITipInfo(
                title: "",
                bodyText: i18n.t("For cars, you’ll add vehicle details, acquisition type, and alternatives next."),
                size: .medium,
                tone: .info
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var carDetailsContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.m) {
                Text("Tell us about your car")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.75)

                Text(acquisitionType == .cash ? "Add the core acquisition details to start your\nscenario analysis." : "Add your financing and usage details to\ncalculate true ownership cost.")
                    .font(WorthItTypography.body)
                    .lineSpacing(4)
                    .foregroundStyle(WorthItColor.textSecondary.opacity(0.80))
            }

            assetSnapshot
            acquisitionDetails
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var assetSnapshot: some View {
        WIIsland(title: i18n.t("Asset Snapshot"), systemIcon: "car.fill") {
            VStack(spacing: WorthItSpacing.xxl) {
                WITextField(
                    label: i18n.t("Vehicle Name"),
                    placeholder: acquisitionType == .cash ? "e.g. Porsche 911" : "e.g. BMW i4 M50",
                    text: $vehicleName,
                    errorText: displayedError(for: .vehicleName)
                )
                .onChange(of: vehicleName) { _, _ in clearError(.vehicleName) }

                HStack(alignment: .top, spacing: WorthItSpacing.l) {
                    WIDateField(
                        label: i18n.t("Purchase Date"),
                        placeholder: i18n.t("MM/DD/YY"),
                        date: $purchaseDate,
                        errorText: displayedError(for: .purchaseDate)
                    )
                    .onChange(of: purchaseDate) { _, _ in clearError(.purchaseDate) }

                    WITextField(
                        label: i18n.t("Initial Odometer"),
                        placeholder: i18n.t("0"),
                        text: $odometer,
                        trailingText: "km",
                        keyboardType: .numberPad,
                        errorText: displayedError(for: .odometer)
                    )
                    .onChange(of: odometer) { _, _ in clearError(.odometer) }
                }

                HStack(alignment: .top, spacing: WorthItSpacing.l) {
                    WITextField(
                        label: i18n.t("Expected Resale Value"),
                        placeholder: i18n.t("0"),
                        text: $resaleValue,
                        leadingText: currencySymbol,
                        keyboardType: .decimalPad,
                        errorText: displayedError(for: .resaleValue)
                    )
                    .frame(maxWidth: .infinity)
                    .onChange(of: resaleValue) { _, _ in clearError(.resaleValue) }

                    WISelectField(label: i18n.t("Currency"), options: currencies, selection: $currency)
                        .frame(width: 112)
                }
            }
        }
    }

    private var acquisitionDetails: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            sectionHeader(title: i18n.t("Acquisition Details"), systemIcon: "building.columns.fill")

            WISegmentedControl(
                items: [("Cash", AcquisitionType.cash), ("Loan", AcquisitionType.loan)],
                selection: $acquisitionType
            )

            VStack(spacing: WorthItSpacing.xxl) {
                HStack(alignment: .top, spacing: WorthItSpacing.l) {
                    WITextField(
                        label: i18n.t("Vehicle Price"),
                        placeholder: i18n.t("0"),
                        text: $vehiclePrice,
                        leadingText: currencySymbol,
                        keyboardType: .decimalPad,
                        errorText: displayedError(for: .vehiclePrice)
                    )
                    .frame(maxWidth: .infinity)
                    .onChange(of: vehiclePrice) { _, _ in clearError(.vehiclePrice) }

                    WISelectField(label: i18n.t("Currency"), options: currencies, selection: $currency)
                        .frame(width: 112)
                }

                if acquisitionType == .loan {
                    loanFields
                    financingSummary
                } else {
                    WITipInfo(
                        title: "",
                        bodyText: i18n.t("Cash acquisition avoids interest drag, but we still factor in capital depreciation to show your real ownership cost."),
                        size: .small,
                        tone: .info
                    )
                }
            }
        }
    }

    private var loanFields: some View {
        VStack(spacing: WorthItSpacing.xxl) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                WITextField(
                    label: i18n.t("Loan Amount"),
                    placeholder: i18n.t("0"),
                    text: $loanAmount,
                    leadingText: currencySymbol,
                    keyboardType: .decimalPad,
                    errorText: displayedError(for: .loanAmount)
                )
                .onChange(of: loanAmount) { _, _ in clearError(.loanAmount) }

                calculatedMetricField(label: i18n.t("Monthly Payment"), value: formattedMoney(calculatedMonthlyPayment))
            }

            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                WITextField(
                    label: i18n.t("Loan Term (mo)"),
                    placeholder: i18n.t("48"),
                    text: $loanTerm,
                    keyboardType: .numberPad,
                    errorText: displayedError(for: .loanTerm)
                )
                .onChange(of: loanTerm) { _, _ in clearError(.loanTerm) }

                WITextField(
                    label: i18n.t("Interest Rate"),
                    placeholder: i18n.t("4.5"),
                    text: $interestRate,
                    trailingText: "%",
                    keyboardType: .decimalPad,
                    errorText: displayedError(for: .interestRate)
                )
                .onChange(of: interestRate) { _, _ in clearError(.interestRate) }
            }
        }
    }

    private var financingSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("TOTAL PAID OVER TIME")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary.opacity(0.50))
                    .tracking(1.8)

                HStack(alignment: .firstTextBaseline, spacing: WorthItSpacing.s) {
                    Text(formattedMoney(calculatedTotalPaid))
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text("+\(formattedMoney(calculatedInterest)) INTEREST")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color(hex: 0x34D399))
                }
            }

            Spacer()

            Image(systemName: "banknote.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 40, height: 40)
                .background(Color(hex: 0xD8E2FF).opacity(0.10), in: Circle())
        }
        .padding(17)
        .frame(maxWidth: .infinity)
        .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
        .shadow(color: WorthItColor.primaryContainer.opacity(0.08), radius: 30)
    }

    private func calculatedMetricField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, WorthItSpacing.l)
                .frame(height: 52)
                .background(WorthItColor.surfaceLowest.opacity(0.60), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
        }
    }

    private var successTopBar: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x60A5FA))

            Text("Scenario Created")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .tracking(-0.45)

            Spacer()
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.xxl)
        .background(WorthItColor.pageBackground.opacity(0.92))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
        }
    }

    private var successContent: some View {
        VStack(spacing: WorthItSpacing.xxxl) {
            successVisual

            VStack(spacing: WorthItSpacing.m) {
                Text("You’re ready to compare")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.75)
                    .multilineTextAlignment(.center)

                Text("Your car ownership analysis is calculated and ready.")
                    .font(WorthItTypography.body)
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 336)
            }

            successSummaryCard

            HStack(alignment: .top, spacing: WorthItSpacing.m) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x60A5FA))
                    .frame(width: 16, height: 20)

                Text("Alternatives can be added or edited later from the Comparison tab.")
                    .font(.system(size: 12, weight: .regular))
                    .lineSpacing(3)
                    .foregroundStyle(WorthItColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 320)
        }
        .frame(maxWidth: 448)
        .frame(maxWidth: .infinity)
    }

    private var successFooter: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground.opacity(0.92),
                    WorthItColor.pageBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .allowsHitTesting(false)

            VStack(spacing: WorthItSpacing.l) {
                WIButton(title: i18n.t("Open Overview"), height: 52) {
                    openCreatedScenarioOverview()
                }

                WIButton(title: i18n.t("Go to Comparison"), style: .secondary, height: 56) {
                    openCreatedScenarioOverview()
                }
            }
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.top, WorthItSpacing.s)
            .padding(.bottom, 32)
            .background(WorthItColor.pageBackground)
        }
    }

    private var successVisual: some View {
        ZStack {
            Circle()
                .fill(WorthItColor.primaryContainer.opacity(0.10))
                .frame(width: 256, height: 256)
                .blur(radius: 50)

            Image("ScenarioSuccessCar")
                .resizable()
                .scaledToFill()
                .frame(height: 342)
                .frame(maxWidth: .infinity)
                .opacity(0.60)
                .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
                .overlay {
                    LinearGradient(
                        colors: [
                            WorthItColor.pageBackground.opacity(0.80),
                            WorthItColor.pageBackground.opacity(0.00)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
                }
                .overlay {
                    LinearGradient(
                        colors: [
                            WorthItColor.pageBackground,
                            WorthItColor.pageBackground.opacity(0.00),
                            WorthItColor.pageBackground
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.l)
                        .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.25), radius: 30, y: 20)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var successSummaryCard: some View {
        VStack(spacing: 0) {
            summaryRow(label: i18n.t("Asset Name"), value: vehicleName.trimmingCharacters(in: .whitespacesAndNewlines))
            divider
            summaryRow(label: i18n.t("Type"), value: "Ownership Scenario", valueColor: Color(hex: 0x60A5FA))
            divider
            summaryRow(label: i18n.t("Path"), value: acquisitionPathLabel, systemIcon: acquisitionType == .loan ? "building.columns.fill" : "banknote.fill")
        }
        .padding(25)
        .background(WorthItColor.surfaceContainer.opacity(0.60), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
        .shadow(color: WorthItColor.primaryContainer.opacity(0.15), radius: 40)
    }

    private func summaryRow(label: String, value: String, valueColor: Color = WorthItColor.textPrimary, systemIcon: String? = nil) -> some View {
        HStack(spacing: WorthItSpacing.m) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(0.7)
                .textCase(.uppercase)

            Spacer()

            HStack(spacing: WorthItSpacing.s) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(valueColor)
                }

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(height: 44)
    }

    private var divider: some View {
        Rectangle()
            .fill(WorthItColor.outlineSubtle)
            .frame(height: 1)
            .padding(.vertical, WorthItSpacing.s)
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)

            if let submissionError {
                Text(submissionError)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WorthItColor.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, WorthItSpacing.xxl)
                    .padding(.top, WorthItSpacing.m)
            }

            WIButton(title: isCreatingScenario ? savingTitle : footerButtonTitle) {
                guard !isCreatingScenario else { return }
                Task {
                    await advance()
                }
            }
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.top, 17)
            .padding(.bottom, 40)
        }
        .background(WorthItColor.pageBackground.opacity(0.80))
        .animation(animation, value: step)
    }

    private func sectionHeader(title: String, systemIcon: String) -> some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemIcon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary.opacity(0.90))

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary.opacity(0.90))
                .tracking(1.8)
                .textCase(.uppercase)
        }
    }

    private func advance() async {
        switch step {
        case .scenarioType:
            validationErrors = [:]
            hasAttemptedCarDetailsSubmit = false
            submissionError = nil
            withAnimation(animation) {
                step = .carDetails
            }
        case .carDetails:
            guard validateCarDetails() else { return }
            if editingScenario == nil {
                await createScenario()
            } else {
                await updateScenario()
            }
        case .success:
            break
        }
    }

    private func createScenario() async {
        isCreatingScenario = true
        submissionError = nil
        defer { isCreatingScenario = false }

        do {
            let scenario = try await repository.createScenario(createScenarioRequest)
            createdScenario = scenario
            onScenarioCreated(scenario)
            withAnimation(animation) {
                step = .success
            }
        } catch {
            submissionError = "Could not create scenario. Check backend connection and try again."
        }
    }

    private func updateScenario() async {
        guard let editingScenario else { return }

        isCreatingScenario = true
        submissionError = nil
        defer { isCreatingScenario = false }

        do {
            let scenario = try await repository.updateScenario(
                scenarioId: editingScenario.id,
                request: updateScenarioRequest
            )
            onScenarioUpdated(scenario)
            onOpenOverview(scenario)
        } catch {
            submissionError = "Could not save scenario. Check backend connection and try again."
        }
    }

    private func validateCarDetails() -> Bool {
        hasAttemptedCarDetailsSubmit = true
        var errors: [Field: String] = [:]

        requireText(vehicleName, field: .vehicleName, message: "Add a vehicle name.", into: &errors)
        if purchaseDate == nil {
            errors[.purchaseDate] = "Choose a purchase date."
        }
        requireNumber(odometer, field: .odometer, message: "Enter initial odometer.", into: &errors)
        requireNumber(resaleValue, field: .resaleValue, message: "Enter expected resale value.", into: &errors)
        requireNumber(vehiclePrice, field: .vehiclePrice, message: "Enter vehicle price.", into: &errors)

        if acquisitionType == .loan {
            requireNumber(loanAmount, field: .loanAmount, message: "Enter loan amount.", into: &errors)
            requireNumber(loanTerm, field: .loanTerm, message: "Enter loan term.", into: &errors)
            requireNumber(interestRate, field: .interestRate, message: "Enter interest rate.", into: &errors)
        }

        withAnimation(animation) {
            validationErrors = errors
        }

        return errors.isEmpty
    }

    private func requireText(_ value: String, field: Field, message: String, into errors: inout [Field: String]) {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors[field] = message
        }
    }

    private func requireNumber(_ value: String, field: Field, message: String, into errors: inout [Field: String]) {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !normalized.isEmpty, Double(normalized) != nil else {
            errors[field] = message
            return
        }
    }

    private func clearError(_ field: Field) {
        validationErrors[field] = nil
    }

    private func displayedError(for field: Field) -> String? {
        hasAttemptedCarDetailsSubmit ? validationErrors[field] : nil
    }

    private var calculatedMonthlyPayment: Decimal {
        let principal = decimalValue(loanAmount)
        let months = max(decimalValue(loanTerm), 0)
        let annualRate = decimalValue(interestRate) / 100

        guard principal > 0, months > 0 else { return 0 }
        guard annualRate > 0 else { return principal / months }

        let monthlyRate = doubleValue(annualRate / 12)
        let monthCount = doubleValue(months)
        let principalValue = doubleValue(principal)
        let denominator = 1 - pow(1 + monthlyRate, -monthCount)

        guard denominator > 0 else { return 0 }
        return Decimal(principalValue * monthlyRate / denominator)
    }

    private var calculatedTotalPaid: Decimal {
        calculatedMonthlyPayment * max(decimalValue(loanTerm), 0)
    }

    private var calculatedInterest: Decimal {
        max(calculatedTotalPaid - decimalValue(loanAmount), 0)
    }

    private func decimalValue(_ value: String) -> Decimal {
        Decimal(string: normalizedNumber(value)) ?? 0
    }

    private func doubleValue(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }

    private func normalizedNumber(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
    }

    private func formattedMoney(_ value: Decimal) -> String {
        guard value > 0 else { return "\(currencySymbol)0" }

        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        let number = value as NSDecimalNumber
        return "\(currencySymbol)\(formatter.string(from: number) ?? number.stringValue)"
    }

    private var createScenarioRequest: CreateScenarioRequest {
        CreateScenarioRequest(
            name: vehicleName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: "car",
            scenarioType: "car_ownership",
            baseUnit: "km",
            currency: currency,
            region: "en-CY",
            startDate: purchaseDate ?? Date(),
            purchasePrice: decimalValue(vehiclePrice),
            purchaseOdometer: Int(odometer.trimmingCharacters(in: .whitespacesAndNewlines)),
            expectedResaleValue: decimalValue(resaleValue),
            acquisitionType: acquisitionType == .loan ? "loan" : "cash",
            loanAmount: acquisitionType == .loan ? decimalValue(loanAmount) : nil,
            loanTermMonths: acquisitionType == .loan ? Int(loanTerm.trimmingCharacters(in: .whitespacesAndNewlines)) : nil,
            loanAnnualInterestRate: acquisitionType == .loan ? decimalValue(interestRate) : nil
        )
    }

    private var updateScenarioRequest: UpdateScenarioRequest {
        UpdateScenarioRequest(
            name: vehicleName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: "car",
            scenarioType: "car_ownership",
            baseUnit: editingScenario?.baseUnit,
            currency: currency,
            region: editingScenario?.region,
            startDate: purchaseDate ?? Date(),
            purchasePrice: decimalValue(vehiclePrice),
            purchaseOdometer: Int(odometer.trimmingCharacters(in: .whitespacesAndNewlines)),
            expectedResaleValue: decimalValue(resaleValue),
            acquisitionType: acquisitionType == .loan ? "loan" : "cash",
            loanAmount: acquisitionType == .loan ? decimalValue(loanAmount) : nil,
            loanTermMonths: acquisitionType == .loan ? Int(loanTerm.trimmingCharacters(in: .whitespacesAndNewlines)) : nil,
            loanAnnualInterestRate: acquisitionType == .loan ? decimalValue(interestRate) : nil,
            isFavorite: editingScenario?.isFavorite,
            analytics: nil
        )
    }

    private func openCreatedScenarioOverview() {
        guard let createdScenario else { return }
        onOpenOverview(createdScenario)
    }

    private var acquisitionPathLabel: String {
        switch acquisitionType {
        case .cash:
            "Cash"
        case .loan:
            "Loan"
        }
    }

    private var currencySymbol: String {
        switch currency {
        case "USD":
            "$"
        case "GBP":
            "£"
        default:
            "€"
        }
    }

    private func goBack() {
        switch step {
        case .scenarioType:
            dismiss()
        case .carDetails:
            if editingScenario == nil {
                withAnimation(animation) {
                    step = .scenarioType
                }
            } else {
                dismiss()
            }
        case .success:
            dismiss()
        }
    }

    private var flowTitle: String {
        editingScenario == nil ? "New Scenario" : "Edit Scenario"
    }

    private var footerButtonTitle: String {
        switch step {
        case .scenarioType:
            "Continue"
        case .carDetails:
            editingScenario == nil ? "Create Scenario" : "Save Changes"
        case .success:
            ""
        }
    }

    private var savingTitle: String {
        editingScenario == nil ? "Creating..." : "Saving..."
    }

    private var decorativeGlow: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0xD8E2FF).opacity(0.05))
                .frame(width: 234, height: 790)
                .blur(radius: 60)
                .offset(x: -150, y: -260)

            Circle()
                .fill(Color(hex: 0xD8E2FF).opacity(0.05))
                .frame(width: 156, height: 528)
                .blur(radius: 50)
                .offset(x: 190, y: 250)
        }
        .allowsHitTesting(false)
    }
}
