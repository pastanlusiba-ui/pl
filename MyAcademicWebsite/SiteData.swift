import Foundation

struct SiteNavItem: Codable {
    var title: String
    var path: String
}

struct SiteData: Codable {
    var siteName: String
    var tagline: String
    var baseURL: String
    var logoText: String
    var logoPath: String
    var profileImagePath: String
    var heroHeadline: String
    var heroIntro: String
    var email: String
    var github: String
    var linkedin: String
    var location: String
    var navItems: [SiteNavItem]

    static let fallback = SiteData(
        siteName: "Pastan Lusiba",
        tagline: "Builder focused on practical AI, automation, and web systems.",
        baseURL: "https://pastanlusiba-ui.github.io/pl",
        logoText: "",
        logoPath: "pastan-logo.png",
        profileImagePath: "profile-placeholder.svg",
        heroHeadline: "Practical AI and Automation for Real-World Workflows",
        heroIntro: "I design and ship systems that turn ideas into maintainable products.",
        email: "pastanlusiba@gmail.com",
        github: "https://github.com/pastanlusiba-ui",
        linkedin: "",
        location: "United States",
        navItems: [
            SiteNavItem(title: "Home", path: "/"),
            SiteNavItem(title: "Work", path: "work"),
            SiteNavItem(title: "Publications", path: "publications"),
            SiteNavItem(title: "Connect", path: "connect")
        ]
    )
}

enum SiteDataLoader {
    static func load() -> SiteData {
        let decoder = JSONDecoder()

        for url in candidateFileURLs() {
            do {
                let data = try Data(contentsOf: url)
                return try decoder.decode(SiteData.self, from: data)
            } catch {
                continue
            }
        }

        print("[site-data] Falling back to defaults. Could not load Data/site.json")
        return .fallback
    }

    private static func candidateFileURLs() -> [URL] {
        let fileManager = FileManager.default
        let cwd = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // MyAcademicWebsite
            .deletingLastPathComponent() // project root

        return [
            cwd.appendingPathComponent("Data/site.json"),
            sourceRoot.appendingPathComponent("Data/site.json")
        ]
    }
}
