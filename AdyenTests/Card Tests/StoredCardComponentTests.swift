//
//  StoredCardComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/17/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenCard
@testable import Adyen

class StoredCardComponentTests: XCTestCase {

    // This is not a real public key, this is just a random string with the right pattern.
    private static var randomTestValidCardPublicKey = "59554|59YWNVYSILHQWVXSIYY8XVK5HMLEAFT2JPJBDVHUD2798K12GKE652PYLJYYNBR0HVN0AYLC38VIU0TSBC9JTQZ4AHOHPPIGVH985H6EI5HAFZXZAM0QIXBAYEP180X0MM6HRHZONIM62TI9US8NXHXNKYSRE8ASJLY3KED6KDD6SY4I29CUY5FYTN8XEQ8NS8M0ECUAG0GV08XAX19HEX8IQ35SNRY8P9G0YOTTEFYC8QGM7N4PYRUWTSOEJV8W9AKJ8ZLR851OA0P7NZOJXZ2EOYNWSORS9RL4HGXVXGANDYXOWCD7XYPHJD6EPYGRUDV87EOT5FHR574DJW5881Y88Y2QR6R9W1WG5N0CV3WJGELJ971OR0S0PTKHOFW7PXRRDVQU1TT4Q8KJJLZ2VHS1BYP0VFQY1FOADWZ2YPGXDT6KPSN6OJ81G9B9BO7LMGYIONUDWQZQM41O27RROX44I89WRLHZHNYP5NEF2ACTF1AJHA4SNTUN9Z93HYQ2"

    func testUIWithClientKey() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = "client_key"

        let payemt = Payment(amount: Payment.Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedString("adyen.cancelButton", nil) } )
            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) } )

            expectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        wait(for: [expectation], timeout: 10)
    }

    func testUIWithPublicKey() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = nil
        CardPublicKeyProvider.cachedCardPublicKey = "public_key"

        let payemt = Payment(amount: Payment.Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedString("adyen.cancelButton", nil) } )
            XCTAssertTrue(alertController.actions.contains { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) } )

            expectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        wait(for: [expectation], timeout: 10)
    }

    func testPaymentSubmitWithSuccessfulCardPublicKeyFetching() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = "client_key"

        let payemt = Payment(amount: Payment.Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        let delegateExpectation = expectation(description: "expect delegate to be called.")
        let delegate = PaymentComponentDelegateMock()
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.paymentMethod as? CardDetails)

            let cardDetails = data.paymentMethod as! CardDetails
            XCTAssertNotNil(cardDetails.encryptedSecurityCode)
            XCTAssertNil(cardDetails.encryptedCardNumber)
            XCTAssertNil(cardDetails.encryptedExpiryYear)
            XCTAssertNil(cardDetails.encryptedExpiryMonth)

            delegateExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }
        sut.delegate = delegate

        let cardPublicKeyProviderExpectation = expectation(description: "Expect cardPublicKeyProvider to be called.")
        let cardPublicKeyProvider = CardPublicKeyProviderMock()
        cardPublicKeyProvider.onFetch = { completion in
            cardPublicKeyProviderExpectation.fulfill()
            completion(.success(Self.randomTestValidCardPublicKey))
        }
        sut.storedCardAlertManager.cardPublicKeyProvider = cardPublicKeyProvider

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            textField?.text = "737"
            textField?.sendActions(for: .editingChanged)

            let payAction = alertController.actions.first { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) }!

            payAction.tap()

            dummyExpectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPaymentSubmitWithFailedCardPublicKeyFetching() {
        let method = StoredCardPaymentMethod(type: "type",
                                             identifier: "id",
                                             name: "name",
                                             fundingSource: .credit,
                                             supportedShopperInteractions: [.shopperPresent],
                                             brand: "brand",
                                             lastFour: "1234",
                                             expiryMonth: "12",
                                             expiryYear: "22",
                                             holderName: "holderName")
        let sut = StoredCardComponent(storedCardPaymentMethod: method)
        sut.clientKey = "client_key"

        let payemt = Payment(amount: Payment.Amount(value: 174, currencyCode: "EUR"), countryCode: "NL")
        sut.payment = payemt

        let delegate = PaymentComponentDelegateMock()
        delegate.onDidSubmit = { _, _ in
            XCTFail("delegate.didSubmit() should never be called.")
        }
        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(error as? DummyError == DummyError.dummy)
            XCTAssertTrue(component === sut)
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        let cardPublicKeyProviderExpectation = expectation(description: "Expect cardPublicKeyProvider to be called.")
        let cardPublicKeyProvider = CardPublicKeyProviderMock()
        cardPublicKeyProvider.onFetch = { completion in
            cardPublicKeyProviderExpectation.fulfill()
            completion(.failure(DummyError.dummy))
        }
        sut.storedCardAlertManager.cardPublicKeyProvider = cardPublicKeyProvider

        UIApplication.shared.keyWindow?.rootViewController?.present(sut.viewController, animated: false, completion: nil)

        let dummyExpectation = expectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let alertController = sut.viewController as! UIAlertController
            let textField: UITextField? = sut.viewController.view.findView(by: "AdyenCard.StoredCardAlertManager.textField")
            XCTAssertNotNil(textField)

            textField?.text = "737"
            textField?.sendActions(for: .editingChanged)

            let payAction = alertController.actions.first { $0.title == ADYLocalizedSubmitButtonTitle(with: payemt.amount, nil) }!

            payAction.tap()

            dummyExpectation.fulfill()

            alertController.dismiss(animated: false, completion: nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

}

extension UIAlertAction {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tap() {
        let closure = self.value(forKey: "handler")

        let handler = unsafeBitCast(closure as AnyObject, to: AlertHandler.self)

        handler(self)
    }
}
