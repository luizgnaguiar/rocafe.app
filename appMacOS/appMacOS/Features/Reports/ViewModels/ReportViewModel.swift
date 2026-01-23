import Foundation
import Combine

@MainActor
class ReportViewModel: ObservableObject {
    
    @Published var dateRange: ClosedRange<Date> {
        didSet {
            generateReports()
        }
    }
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Report Data
    @Published var dreReport: DRE_DTO?
    @Published var salesByPaymentMethod: [PaymentMethod: Decimal] = [:]
    
    private let reportService: ReportService
    
    init(reportService: ReportService = ReportService()) {
        // Default to the last 30 days
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate)!
        self.dateRange = startDate...endDate
        self.reportService = reportService
    }
    
    func onAppear() {
        generateReports()
    }
    
    func generateReports() {
        isLoading = true
        errorMessage = nil
        
        // Use a background task to avoid blocking the UI
        Task {
            // --- Placeholder calls to the service ---
            self.dreReport = reportService.generateSimplifiedDRE(for: dateRange)
            self.salesByPaymentMethod = reportService.generateSalesByPaymentMethod(for: dateRange)
            
            isLoading = false
        }
    }
}
