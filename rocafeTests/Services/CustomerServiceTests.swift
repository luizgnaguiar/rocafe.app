import XCTest
import GRDB
@testable import rocafe

@MainActor
final class CustomerServiceTests: XCTestCase {

    private var dbPool: DatabasePool!
    private var customerService: CustomerService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dbPool = try TestDatabase.newPool()
        let customerRepo = CustomerRepositoryImpl(dbPool: dbPool)
        customerService = CustomerService(repository: customerRepo)
    }

    override func tearDownWithError() throws {
        dbPool = nil
        customerService = nil
        try super.tearDownWithError()
    }

    // MARK: - Unit Tests for Save

    func testSaveCustomer_whenNameIsEmpty_throwsError() async throws {
        var newCustomer = Customer(id: nil, name: "  ", isActive: true)
        
        do {
            try await customerService.save(customer: &newCustomer)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? CustomerServiceError, CustomerServiceError.nameIsEmpty)
        }
    }
    
    func testSaveCustomer_whenEmailIsInvalid_throwsError() async throws {
        var newCustomer = Customer(id: nil, name: "Test User", email: "invalid-email", isActive: true)
        
        do {
            try await customerService.save(customer: &newCustomer)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? CustomerServiceError, CustomerServiceError.emailInvalid)
        }
    }
    
    func testSaveCustomer_whenValid_succeeds() async throws {
        var newCustomer = Customer(id: nil, name: "Valid Customer", isActive: true)
        
        try await customerService.save(customer: &newCustomer)
        
        XCTAssertNotNil(newCustomer.id)
        
        let savedCustomer = try await dbPool.read { db in
            try Customer.fetchOne(db, key: newCustomer.id)
        }
        
        XCTAssertEqual(savedCustomer?.name, "Valid Customer")
    }

    // MARK: - Integration Tests for Delete

    func testDeleteCustomer_whenCustomerHasPayments_throwsCannotDeleteError() async throws {
        // 1. Setup
        var customer = Customer(id: nil, name: "Customer With Payment", isActive: true)
        try await dbPool.write { db in
            try customer.save(db)
            var payment = CustomerPayment(id: nil, customerId: customer.id!, date: Date(), amount: 100, paymentMethod: .cash)
            try payment.save(db)
        }
        
        // 2. Action & Assertion
        do {
            try await customerService.delete(customer: customer)
            XCTFail("Should have thrown cannotDeleteWithPayments error")
        } catch let CustomerServiceError.cannotDeleteWithPayments {
            // Test passes
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testDeleteCustomer_whenCustomerHasNoPayments_succeeds() async throws {
        // 1. Setup
        var customer = Customer(id: nil, name: "Customer Without Payment", isActive: true)
        try await dbPool.write { db in
            try customer.save(db)
        }
        let customerId = customer.id!

        // 2. Action
        try await customerService.delete(customer: customer)
        
        // 3. Assertion
        let deletedCustomer = try await dbPool.read { db in
            try Customer.fetchOne(db, key: customerId)
        }
        XCTAssertNil(deletedCustomer)
    }
}
