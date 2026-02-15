import Foundation

// This structure defines everything your website can display.
// Both your Website and your Editor App will use this exact same file.

struct UserProfile: Codable {
    var name: String
    var title: String
    var bio: String
    var email: String
    var imagePath: String
    
    // Lists of your work
    var research: [ProjectItem]
    var publications: [PublicationItem]
}

struct ProjectItem: Codable, Identifiable {
    var id: UUID = UUID() // Unique ID for the App to track it
    var title: String
    var description: String
    var year: String
}

struct PublicationItem: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var journal: String
    var link: String
    var year: String
}
