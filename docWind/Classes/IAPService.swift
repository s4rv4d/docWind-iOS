//
//  IAPService.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    
    // MARK: - Properties
    private override init() {}
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    // MARK: - IAPService functions
    func getProducts() {
        let products: Set = [IAPProduct.nonConsumable.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchaseProduct(product: IAPProduct) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchase() {
        paymentQueue.restoreCompletedTransactions()
    }
}

// MARK: - Extensions
extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        for product in response.products {
            print(product.localizedTitle)
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            
            switch transaction.transactionState {
            case .purchasing: break
            default: queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
    }
}

