import SwiftUI
import WooFoundation

struct AddCustomAmountView: View {
    @Binding var isPresented: Bool
    let onSubmit: (POSCustomAmountInput) -> Void

    @State private var viewModel: AddCustomAmountFormViewModel
    @FocusState private var isAmountFieldFocused: Bool

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
                    amountField
                        .frame(maxWidth: .infinity)
                        .padding(.top, POSSpacing.xxLarge)

                    taxesToggle

                    nameField

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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Localization.doneButton) {
                    isAmountFieldFocused = false
                }
            }
        }
    }

    private var amountField: some View {
        VStack(spacing: POSSpacing.small) {
            Text(Localization.amountLabel)
                .font(.posBodyMediumRegular())
                .foregroundColor(.posOnSurfaceVariantLowest)
                .frame(maxWidth: .infinity, alignment: .leading)

            POSCashAmountTextField(
                amount: $viewModel.amount,
                isFocused: $isAmountFieldFocused,
                sanitizer: viewModel.sanitizer,
                onSubmit: submit
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, POSPadding.large)
            .background(Color.posSurfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: POSCornerRadiusStyle.large.value))
            .contentShape(Rectangle())
            .onTapGesture { isAmountFieldFocused = true }
        }
    }

    private var taxesToggle: some View {
        Toggle(isOn: $viewModel.isTaxable) {
            Text(Localization.chargeTaxes)
                .font(.posBodyLargeRegular())
                .foregroundColor(.posOnSurface)
        }
        .tint(.posPrimary)
        .padding(POSPadding.large)
        .background(Color.posSurfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: POSCornerRadiusStyle.large.value))
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: POSSpacing.small) {
            Text(Localization.nameLabel)
                .font(.posBodyMediumRegular())
                .foregroundColor(.posOnSurfaceVariantLowest)

            TextField(Localization.namePlaceholder, text: $viewModel.name)
                .font(.posBodyLargeRegular())
                .foregroundColor(.posOnSurface)
                .padding(POSPadding.large)
                .background(Color.posSurfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: POSCornerRadiusStyle.large.value))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .onSubmit(submit)
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
        static let doneButton = NSLocalizedString(
            "pos.addCustomAmount.keyboardDone",
            value: "Done",
            comment: "Toolbar button above the keyboard that dismisses it in the Point of Sale add custom amount form.")
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
