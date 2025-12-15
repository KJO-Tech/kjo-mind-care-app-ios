import Combine
import FirebaseFirestore
import Foundation

final class MoodEntryRepositoryImpl: MoodEntryRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func saveMoodEntry(_ entry: MoodEntry) -> AnyPublisher<Resource<MoodEntry>, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let collection = self.firestore.collection("moodEntries")
            let docRef = entry.id.isEmpty ? collection.document() : collection.document(entry.id)
            
            var entryToSave = entry
            if entry.id.isEmpty {
                entryToSave = MoodEntry(
                    id: docRef.documentID,
                    userId: entry.userId,
                    mood: entry.mood,
                    note: entry.note,
                    createdAt: entry.createdAt,
                    localDateTime: entry.localDateTime
                )
            }
            
            do {
                try docRef.setData(from: entryToSave) { error in
                    if let error = error {
                        promise(.success(.error("Error saving mood entry: \(error.localizedDescription)")))
                        return
                    }
                    promise(.success(.success(entryToSave)))
                }
            } catch {
                promise(.success(.error("Error encoding mood entry: \(error.localizedDescription)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getMoodEntries(userId: String) -> AnyPublisher<Resource<[MoodEntry]>, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.firestore.collection("moodEntries")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.success(.error("Error getting mood entries: \(error.localizedDescription)")))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success(.success([])))
                        return
                    }
                    
                    let entries = documents.compactMap { doc -> MoodEntry? in
                        try? doc.data(as: MoodEntry.self)
                    }
                    
                    promise(.success(.success(entries)))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getMoodEntriesByDateRange(
        userId: String, 
        startDate: Date, 
        endDate: Date
    ) -> AnyPublisher<Resource<[MoodEntry]>, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let startTimestamp = Timestamp(date: startDate)
            let endTimestamp = Timestamp(date: endDate)
            
            self.firestore.collection("moodEntries")
                .whereField("userId", isEqualTo: userId)
                .whereField("createdAt", isGreaterThanOrEqualTo: startTimestamp)
                .whereField("createdAt", isLessThanOrEqualTo: endTimestamp)
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.success(.error("Error getting mood entries by date range: \(error.localizedDescription)")))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success(.success([])))
                        return
                    }
                    
                    let entries = documents.compactMap { doc -> MoodEntry? in
                        try? doc.data(as: MoodEntry.self)
                    }
                    
                    promise(.success(.success(entries)))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getMoodEntryById(_ id: String) -> AnyPublisher<Resource<MoodEntry>, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.firestore.collection("moodEntries").document(id).getDocument { snapshot, error in
                if let error = error {
                    promise(.success(.error("Error getting mood entry: \(error.localizedDescription)")))
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    promise(.success(.error("Mood entry not found")))
                    return
                }
                
                do {
                    let entry = try snapshot.data(as: MoodEntry.self)
                    promise(.success(.success(entry)))
                } catch {
                    promise(.success(.error("Error decoding mood entry: \(error.localizedDescription)")))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteMoodEntry(id: String) -> AnyPublisher<Resource<Void>, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.firestore.collection("moodEntries").document(id).delete { error in
                if let error = error {
                    promise(.success(.error("Error deleting mood entry: \(error.localizedDescription)")))
                    return
                }
                promise(.success(.success(())))
            }
        }
        .eraseToAnyPublisher()
    }
}
