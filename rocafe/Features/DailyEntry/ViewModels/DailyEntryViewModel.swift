import Foundation
import Combine

// Using SwiftUI and Combine for the UI layer.
// This assumes the project is set up for a SwiftUI lifecycle.

@MainActor
class DailyEntryViewModel: ObservableObject {
    
    @Published var dailyEntry: DailyEntry
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: DailyEntryRepository
    
    init(entry: DailyEntry? = nil, repository: DailyEntryRepository = DailyEntryRepositoryImpl()) {
        self.dailyEntry = entry ?? DailyEntry.new()
        self.repository = repository
    }
    
    func save() {
        // Basic Validation
        guard dailyEntry.date <= Date() else {
            errorMessage = "A data do lançamento não pode ser no futuro."
            return
        }
        
        // Ensure no negative values
        guard dailyEntry.salesCash >= 0, dailyEntry.salesCredit >= 0, dailyEntry.salesDebit >= 0, dailyEntry.salesPix >= 0,
              dailyEntry.receivedCash >= 0, dailyEntry.receivedCredit >= 0, dailyEntry.receivedDebit >= 0, dailyEntry.receivedPix >= 0 else {
            errorMessage = "Valores não podem ser negativos."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // In a real app, you might want to perform this on a background thread
        // if there were more complex operations involved.
        do {
            var entryToSave = dailyEntry
            if entryToSave.id == nil {
                entryToSave.createdAt = Date()
            }
            entryToSave.updatedAt = Date()
            
            try repository.save(&entryToSave)
            
            // Update the local model with the saved one (which may have a new ID)
            self.dailyEntry = entryToSave
            
        } catch {
            errorMessage = "Falha ao salvar o lançamento: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
