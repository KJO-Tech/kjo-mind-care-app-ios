import Combine
import FirebaseFirestore
import Foundation

final class MoodRepositoryImpl: MoodRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService

    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }

    func getMoods() -> AnyPublisher<Resource<[Mood]>, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }

            self.firestore.collection("moods").order(by: "value", descending: true).getDocuments {
                snapshot, error in
                if let error = error {
                    promise(.success(.error("Error getting moods: \(error.localizedDescription)")))
                    return
                }

                guard let documents = snapshot?.documents else {
                    promise(.success(.error("No moods found")))
                    return
                }

                let moods = documents.compactMap { doc -> Mood? in
                    let data = doc.data()

                    // Manual mapping since Firestore data structure might need it
                    // Or use Codable if property names match exactly
                    // Ideally use Codable: try? doc.data(as: Mood.self)

                    // Using manual mapping to be safe/explicit based on requested structure
                    guard
                        let id = data["id"] as? String ?? doc.documentID as? String,
                        let name = data["name"] as? [String: String],
                        let description = data["description"] as? [String: String],
                        let image = data["image"] as? String,
                        let color = data["color"] as? String,
                        let isActive = data["isActive"] as? Bool,
                        let value = data["value"] as? Int
                    else {
                        return nil
                    }

                    return Mood(
                        id: id,
                        name: name,
                        description: description,
                        image: image,
                        color: color,
                        isActive: isActive,
                        value: value
                    )
                }

                promise(.success(.success(moods)))
            }
        }
        .eraseToAnyPublisher()
    }
}
