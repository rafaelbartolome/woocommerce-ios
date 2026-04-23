import Foundation
import Testing
import WooFoundation
@testable import PointOfSale

struct AddCustomAmountFormViewModelTests {
    private let currencySettings = CurrencySettings(
        currencyCode: .USD,
        currencyPosition: .left,
        thousandSeparator: ",",
        decimalSeparator: ".",
        numberOfDecimals: 2
    )

    @Test func test_isAddEnabled_when_amount_is_empty_then_false() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When, Then
        #expect(sut.isAddEnabled == false)
    }

    @Test func test_isAddEnabled_when_amount_is_zero_then_false() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = "0.00"

        // Then
        #expect(sut.isAddEnabled == false)
    }

    @Test func test_isAddEnabled_when_amount_is_positive_then_true() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = "10.00"

        // Then
        #expect(sut.isAddEnabled == true)
    }

    @Test func test_resolvedInput_when_amount_is_invalid_then_returns_nil() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = ""

        // Then
        #expect(sut.resolvedInput() == nil)
    }

    @Test func test_resolvedInput_when_amount_valid_and_name_empty_then_returns_default_name() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = "12.50"
        sut.name = ""

        // Then
        let input = try #require(sut.resolvedInput())
        #expect(input.name == "Custom amount")
        #expect(input.amount == "12.50")
        #expect(input.isTaxable == true)
    }

    @Test func test_resolvedInput_when_name_has_whitespace_only_then_uses_default_name() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = "5.00"
        sut.name = "   "

        // Then
        let input = try #require(sut.resolvedInput())
        #expect(input.name == "Custom amount")
    }

    @Test func test_resolvedInput_when_name_is_provided_then_uses_trimmed_name() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = "5.00"
        sut.name = "  Service fee  "

        // Then
        let input = try #require(sut.resolvedInput())
        #expect(input.name == "Service fee")
    }

    @Test func test_resolvedInput_when_isTaxable_is_false_then_input_reflects_it() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When
        sut.amount = "5.00"
        sut.isTaxable = false

        // Then
        let input = try #require(sut.resolvedInput())
        #expect(input.isTaxable == false)
    }

    @Test func test_isTaxable_default_is_true() async throws {
        // Given
        let sut = AddCustomAmountFormViewModel(currencySettings: currencySettings)

        // When, Then
        #expect(sut.isTaxable == true)
    }
}
