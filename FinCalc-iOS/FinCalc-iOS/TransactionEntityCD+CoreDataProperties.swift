//
//  TransactionEntityCD+CoreDataProperties.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.07.2025.
//
//

import Foundation
import CoreData


extension TransactionEntityCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntityCD> {
        return NSFetchRequest<TransactionEntityCD>(entityName: "TransactionEntityCD")
    }

    @NSManaged public var accountBalance: String?
    @NSManaged public var accountCurrency: String?
    @NSManaged public var accountId: Int64
    @NSManaged public var accountName: String?
    @NSManaged public var amount: String?
    @NSManaged public var categoryEmoji: String?
    @NSManaged public var categoryId: Int64
    @NSManaged public var categoryName: String?
    @NSManaged public var comment: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var direction: String?
    @NSManaged public var id: Int64
    @NSManaged public var transactionDate: String?
    @NSManaged public var updatedAt: String?

}

extension TransactionEntityCD : Identifiable {

}
