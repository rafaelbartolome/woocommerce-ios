import SwiftUI
import WooFoundation

struct AddCustomAmountView: View {
    @Binding var isPresented: Bool
    let onSubmit: (POSCustomAmountInput) -> Void

    @State private var viewModel: AddCustomAmountFormViewModel
    @State private var amountDisplayText: String = ""
    @FocusState private var focusedField: Field?

    private enum Field { case amount, name }

    init(isPresented: Binding<Bool>,
         currencySettings: CurrencySettings,
         onSubmit: @escaping (POSCustomAmountInput) -> Void) {
        self._isPresented = isPresented
        self.onSubmit = onSubmit
        self._viewModel = State(wrappedValue: AddCustomAmountFormViewModel(currencySettings: currencySettings))
    }

    var body: some View {
        VStack(spacing: 0) {
            POSPageHeaderView(
                title: Localization.title,
                backButtonConfiguration: .init(
                    state: .enabled,
                    action: { isPresented = false },
                    buttonIcon: "xmark"
                )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: POSSpacing.xLarge) {
                    amountSection
                        .padding(.top, POSSpacing.xLarge)

                    Divider()

                    taxesRow

                    Divider()

                    nameSection

                    Spacer(minLength: POSSpacing.xxLarge)
                }
                .padding(.horizontal, POSHeaderLayoutConstants.sectionHorizontalPadding)
            }
            .scrollDismissesKeyboard(.interactively)

            addButton
                .padding(.horizontal, POSHeaderLayoutConstants.sectionHorizontalPadding)
                .padding(.vertical, POSPadding.medium)
        }
        .background(Color.posSurfaceBright.ignoresSafeArea())
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: POSSpacing.small) {
            Text(Localization.amountLabel)
                .font(.posBodyMediumRegular())
                .foregroundColor(.posOnSurfaceVariantLowest)

            HStack(spacing: POSSpacing.xSmall) {
                Text(viewModel.currencySymbol)
                    .font(.posHeadingBold)
                    .foregroundColor(viewModel.isAddEnabled ? .posOnSurface : .posOnSurfaceVariantLowest)

                TextField(Localization.amountPlaceholder(symbol: viewModel.currencySymbol), text: $amountDisplayText)
                    .font(.posHeadingBold)
                    .foregroundColor(.posOnSurface)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .amount)
                    .onChange(of: amountDisplayText) { oldValue, newValue in
                        guard let sanitized = viewModel.sanitizer.sanitize(newValue) else {
                            amountDisplayText = oldValue
                            return
                        }
                        if sanitized != newValue {
                            amountDisplayText = sanitized
                        }
                        viewModel.amount = sanitized
                    }
            }
            .padding(POSPadding.large)
            .background(
                RoundedRectangle(cornerRadius: POSCornerRadiusStyle.large.value)
                    .stroke(focusedField == .amount ? Color.posPrimary : Color.posSurfaceContainerLowest, lineWidth: 2)
            )
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .amount }
        }
    }

    private var taxesRow: some View {
        Toggle(isOn: $viewModel.isTaxable) {
            Text(Localization.chargeTaxes)
                .font(.posBodyLargeRegular())
                .foregroundColor(.posOnSurface)
        }
        .tint(.posPrimary)
        .padding(.vertical, POSPadding.small)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: POSSpacing.small) {
            Text(Localization.nameLabel)
                .font(.posBodyMediumRegular())
                .foregroundColor(.posOnSurfaceVariantLowest)

            TextField(Localization.namePlaceholder, text: $viewModel.name)
                .font(.posBodyLargeRegular())
                .foregroundColor(.posOnSurface)
                .focused($focusedField, equals: .name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .onSubmit(submit)
                .padding(.vertical, POSPadding.small)
        }
    }

    private var addButton: some View {
        Button(action: submit) {
            Text(Localization.addButton)
        }
        .buttonStyle(POSFilledButtonStyle(size: .normal))
        .frame(maxWidth: .infinity)
        .disabled(!viewModel.isAddEnabled)
        .accessibilityIdentifier("pos-add-custom-amount-submit-button")
    }

    private func submit() {
        guard let input = viewModel.resolvedInput() else { return }
        onSubmit(input)
        isPresented = false
    }
}

private extension AddCustomAmountView {
    enum Localization {
        static let title = NSLocalizedString(
            "pos.addCustomAmount.title",
            value: "Custom amount",
            comment: "Title of the full-screen Point of Sale form for adding a custom amount to the order.")
        static let amountLabel = NSLocalizedString(
            "pos.addCustomAmount.amountLabel",
            value: "Amount",
            comment: "Label above the amount field in the Point of Sale add custom amount form.")
        static let chargeTaxes = NSLocalizedString(
            "pos.addCustomAmount.chargeTaxes",
            value: "Charge taxes",
            comment: "Title of the taxable toggle in the Point of Sale add custom amount form.")
        static let nameLabel = NSLocalizedString(
            "pos.addCustomAmount.nameLabel",
            value: "Name",
            comment: "Label above the name field in the Point of Sale add custom amount form.")
        static let namePlaceholder = NSLocalizedString(
            "pos.addCustomAmount.namePlaceholder",
            value: "Custom amount",
            comment: "Placeholder for the name field in the Point of Sale add custom amount form.")
        static let addButton = NSLocalizedString(
            "pos.addCustomAmount.addButton",
            value: "Add custom amount",
            comment: "Primary button in the Point of Sale add custom amount form that adds the amount to the order.")

        static func amountPlaceholder(symbol: String) -> String {
            "0"
        }
    }
}

#if DEBUG
#Preview {
    AddCustomAmountView(
        isPresented: .constant(true),
        currencySettings: CurrencySettings(),
        onSubmit: { _ in }
    )
}
#endif
