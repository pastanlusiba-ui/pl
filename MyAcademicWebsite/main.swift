import Foundation
import Publish
import Plot

let siteData = SiteDataLoader.load()

struct AcademicWebsite: Website {
    enum SectionID: String, WebsiteSectionID {
        case blog
        case work
        case training
        case publications
        case presentations
        case connect
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var image: String?
        var summary: String?
    }

    private let data: SiteData

    init(data: SiteData) {
        self.data = data
    }

    var url: URL {
        URL(string: data.baseURL) ?? URL(string: "https://pastanlusiba-ui.github.io/pl")!
    }

    var name: String { data.siteName }
    var description: String { data.tagline }
    var language: Language { .english }
    var imagePath: Path? { Path(data.profileImagePath) }
}

let website = AcademicWebsite(data: siteData)
try website.publish(withTheme: .academicMinimalist(siteData: siteData))
