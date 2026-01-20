import XCTest
import GRDB
@testable import rocafe // Import your app module

final class CustomerServiceTests: XCTestCase {

    private var dbQueue: DatabaseQueue!
    private var customerService: CustomerService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Create a fresh, in-memory database for each test
        dbQueue = try TestDatabase.newQueue()
        
        // Initialize repositories and services with the test database
        let customerRepo = CustomerRepositoryImpl(dbQueue: dbQueue)
        customerService = CustomerService(repository: customerRepo)
    }

    override func tearDownWithError() throws {
        dbQueue = nil
        customerService = nil
        try super.tearDownWithError()
    }

    // MARK: - Unit Tests for Save

    func testSaveCustomer_whenNameIsEmpty_throwsError() {
        var newCustomer = Customer(id: nil, name: "  ", isActive: true) // Empty name
        
        XCTAssertThrowsError(try customerService.save(customer: &newCustomer)) { error in
            XCTAssertEqual(error as? CustomerServiceError, CustomerServiceError.nameIsEmpty)
        }
    }
    
    func testSaveCustomer_whenEmailIsInvalid_throwsError() {
        var newCustomer = Customer(id: nil, name: "Test User", email: "invalid-email", isActive: true)
        
        XCTAssertThrowsError(try customerService.save(customer: &newCustomer)) { error in
            XCTAssertEqual(error as? CustomerServiceError, CustomerServiceError.emailInvalid)
        }
    }
    
    func testSaveCustomer_whenValid_succeeds() throws {
        var newCustomer = Customer(id: nil, name: "Valid Customer", isActive: true)
        
        try customerService.save(customer: &newCustomer)
        
        XCTAssertNotNil(newCustomer.id) // Should have an ID after saving
        
        let savedCustomer = try dbQueue.read { db in
            try Customer.fetchOne(db, key: newCustomer.id)
        }
        
        XCTAssertEqual(savedCustomer?.name, "Valid Customer")
    }

    // MARK: - Integration Tests for Delete

    func testDeleteCustomer_whenCustomerHasPayments_throwsCannotDeleteError() throws {
        // 1. Setup: Create a customer and a payment for them
        var customer = Customer(id: nil, name: "Customer With Payment", isActive: true)
        try dbQueue.write { db in
            try customer.save(db)
            var payment = CustomerPayment(id: nil, customerId: customer.id!, date: Date(), amount: 100, paymentMethod: .cash)
            try payment.save(db)
        }
        
        // 2. Action: Try to delete the customer
        XCTAssertThrowsError(try customerService.delete(customer: customer)) { error in
            // 3. Assertion: Check if the correct, user-friendly error is thrown
            guard let serviceError = error as? CustomerServiceError else {
                XCTFail("Unexpected error type: \(type(of: error))")
                return
            }
            
            if case .cannotDeleteWithPayments = serviceError {
                // Test passes
            } else {
                XCTFail("Incorrect error type thrown: \(serviceError)")
            }
        }
    }
    
    func testDeleteCustomer_whenCustomerHasNoPayments_succeeds() throws {
        // 1. Setup: Create a customer without any payments
        var customer = Customer(id: nil, name: "Customer Without Payment", isActive: true)
        try dbQueue.write { db in
            try customer.save(db)
        }
        let customerId = customer.id!

        // 2. Action: Delete the customer
        XCTAssertNoThrow(try customerService.delete(customer: customer))
        
        // 3. Assertion: Verify the customer is no longer in the database
        let deletedCustomer = try dbQueue.read { db in
            try Customer.fetchOne(db, key: customerId)
        }
        XCTAssertNil(deletedCustomer)
    }
}
