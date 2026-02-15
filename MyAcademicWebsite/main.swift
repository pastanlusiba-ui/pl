import Foundation
import Publish
import Plot

struct AcademicWebsite: Website {
    enum SectionID: String, WebsiteSectionID {
        case work
        case training
        case publications
        case presentations
        case connect
    }

    struct ItemMetadata: WebsiteItemMetadata {}

    // Update this if your final GitHub repo name changes.
    var url = URL(string: "https://pastanlusiba-ui.github.io/pl")!
    var name = "Pastan Lusiba"
    var description = "Builder focused on practical AI, automation, and web systems."
    var language: Language { .english }
    var imagePath: Path? { "profile-placeholder.svg" }
}

try AcademicWebsite().publish(withTheme: .academicMinimalist)
