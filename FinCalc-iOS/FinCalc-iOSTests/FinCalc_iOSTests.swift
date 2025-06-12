//
//  FinCalc_iOSTests.swift
//  FinCalc-iOSTests
//
//  Created by Soslan Dzampaev on 12.06.2025.
//

import XCTest
@testable import FinCalc_iOS

final class TransactionTests: XCTestCase {
    func makeTransaction() -> Transaction {
        guard
            let amount = Decimal(string: "1234.56"),
            let date1 = DateFormatters.iso8601.date(from: "2024-06-11T10:00:00.000Z"),
            let date2 = DateFormatters.iso8601.date(from: "2024-06-12T10:00:00.000Z")
        else {
            fatalError("Не удалось создать тестовые значения")
        }
        return Transaction(
            id: 1,
            accountId: 2,
            categoryId: 3,
            amount: amount,
            transactionDate: date1,
            comment: "Test comment",
            createdAt: date1,
            updatedAt: date2
        )
    }
    
    func test_jsonObject_and_parse_roundtrip() {
        let transaction = makeTransaction()
        let json = transaction.jsonObject
        guard let parsed = Transaction.parse(jsonObject: json) else {
            XCTFail("parse(jsonObject:) вернул nil")
            return
        }
        XCTAssertEqual(parsed.id, transaction.id)
        XCTAssertEqual(parsed.accountId, transaction.accountId)
        XCTAssertEqual(parsed.categoryId, transaction.categoryId)
        XCTAssertEqual(parsed.amount, transaction.amount)
        XCTAssertEqual(parsed.transactionDate, transaction.transactionDate)
        XCTAssertEqual(parsed.comment, transaction.comment)
        XCTAssertEqual(parsed.createdAt, transaction.createdAt)
        XCTAssertEqual(parsed.updatedAt, transaction.updatedAt)
    }
    
    func test_parse_invalid_json_returns_nil() {
        let badJson: [String: Any] = [
            "id": 1,
            "categoryId": 3,
            "amount": "1234.56",
            "transactionDate": "2024-06-11T10:00:00.000Z",
            "createdAt": "2024-06-11T10:00:00.000Z",
            "updatedAt": "2024-06-12T10:00:00.000Z"
        ]
        let parsed = Transaction.parse(jsonObject: badJson)
        XCTAssertNil(parsed)
    }
    
    func test_jsonObject_includes_all_fields() {
        let transaction = makeTransaction()
        guard let dict = transaction.jsonObject as? [String: Any] else {
            XCTFail("jsonObject не вернул словарь")
            return
        }
        XCTAssertEqual(dict["id"] as? Int, transaction.id)
        XCTAssertEqual(dict["accountId"] as? Int, transaction.accountId)
        XCTAssertEqual(dict["categoryId"] as? Int, transaction.categoryId)
        XCTAssertEqual(dict["amount"] as? String, "\(transaction.amount)")
        XCTAssertEqual(dict["transactionDate"] as? String, DateFormatters.iso8601.string(from: transaction.transactionDate))
        XCTAssertEqual(dict["comment"] as? String, transaction.comment)
        XCTAssertEqual(dict["createdAt"] as? String, DateFormatters.iso8601.string(from: transaction.createdAt))
        XCTAssertEqual(dict["updatedAt"] as? String, DateFormatters.iso8601.string(from: transaction.updatedAt))
    }
    
    func test_jsonObject_and_parse_withoutComment() {
        guard
            let amount = Decimal(string: "100.00"),
            let date = DateFormatters.iso8601.date(from: "2024-06-11T10:00:00.000Z"),
            let date2 = DateFormatters.iso8601.date(from: "2024-06-12T10:00:00.000Z")
        else {
            XCTFail("Не удалось создать тестовые значения")
            return
        }
        let transaction = Transaction(
            id: 1,
            accountId: 2,
            categoryId: 3,
            amount: amount,
            transactionDate: date,
            comment: nil,
            createdAt: date,
            updatedAt: date2
        )
        let json = transaction.jsonObject
        guard let parsed = Transaction.parse(jsonObject: json) else {
            XCTFail("parse(jsonObject:) вернул nil")
            return
        }
        XCTAssertNil(parsed.comment)
    }
    
    func test_parse_invalid_amount_returns_nil() {
        guard var dict = makeTransaction().jsonObject as? [String: Any] else {
            XCTFail("jsonObject не вернул словарь")
            return
        }
        dict["amount"] = "не число"
        let parsed = Transaction.parse(jsonObject: dict)
        XCTAssertNil(parsed)
    }
    
    func test_parse_empty_json_returns_nil() {
        let parsed = Transaction.parse(jsonObject: [String: Any]())
        XCTAssertNil(parsed)
    }
    
    func test_parse_invalid_date_returns_nil() {
        guard var dict = makeTransaction().jsonObject as? [String: Any] else {
            XCTFail("jsonObject не вернул словарь")
            return
        }
        dict["transactionDate"] = "randomData 123123"
        let parsed = Transaction.parse(jsonObject: dict)
        XCTAssertNil(parsed)
    }
    
    func test_parse_wrong_type_returns_nil() {
        let parsed = Transaction.parse(jsonObject: "not a dictionary")
        XCTAssertNil(parsed)
    }
    
    func test_parse_with_extra_fields() {
        guard var dict = makeTransaction().jsonObject as? [String: Any] else {
            XCTFail("jsonObject не вернул словарь")
            return
        }
        dict["extraField"] = "123123123"
        let parsed = Transaction.parse(jsonObject: dict)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.id, dict["id"] as? Int)
    }

    func test_export_and_import_single_csv() {
        let transaction = makeTransaction()
        let csvLine = transaction.csvLine
        guard let parsed = Transaction.fromCSV(csvLine) else {
            XCTFail("fromCSV returned nil for valid CSV line")
            return
        }
        XCTAssertEqual(parsed.id, transaction.id)
        XCTAssertEqual(parsed.accountId, transaction.accountId)
        XCTAssertEqual(parsed.categoryId, transaction.categoryId)
        XCTAssertEqual(parsed.amount, transaction.amount)
        XCTAssertEqual(parsed.transactionDate, transaction.transactionDate)
        XCTAssertEqual(parsed.comment, transaction.comment)
        XCTAssertEqual(parsed.createdAt, transaction.createdAt)
        XCTAssertEqual(parsed.updatedAt, transaction.updatedAt)
    }

    func test_import_csv_file_multiple_transactions() {
        let csv = """
        1,2,3,1234.56,2024-06-11T10:00:00.000Z,First comment,2024-06-11T10:00:00.000Z,2024-06-11T10:00:00.000Z
        2,2,4,789.00,2024-06-12T11:30:00.000Z,,2024-06-12T11:30:00.000Z,2024-06-12T11:30:00.000Z
        """
        let transactions = Transaction.fromCSVFile(csv)
        XCTAssertEqual(transactions.count, 2)
        XCTAssertEqual(transactions[0].id, 1)
        XCTAssertEqual(transactions[0].comment, "First comment")
        XCTAssertEqual(transactions[1].id, 2)
        XCTAssertNil(transactions[1].comment)
    }

    func test_fromCSV_invalid_string_returns_nil() {
        let badCSV = "invalid,csv,line"
        let parsed = Transaction.fromCSV(badCSV)
        XCTAssertNil(parsed)
    }
}
