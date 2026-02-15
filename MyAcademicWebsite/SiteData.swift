import Foundation

struct SiteNavItem: Codable {
    var title: String
    var path: String
}

struct SiteHighlightItem: Codable {
    var category: String
    var tag: String
    var title: String
    var summary: String
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
    var highlights: [SiteHighlightItem]

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
            SiteNavItem(title: "Training", path: "training"),
            SiteNavItem(title: "Publications", path: "publications"),
            SiteNavItem(title: "Presentations", path: "presentations"),
            SiteNavItem(title: "Blog", path: "blog"),
            SiteNavItem(title: "Connect with me", path: "connect")
        ],
        highlights: [
            SiteHighlightItem(
                category: "Publications",
                tag: "Journal Article",
                title: "Designing practical automation systems for implementation teams",
                summary: "Draft manuscript focused on lightweight automation models for real operational settings.",
                path: "publications"
            ),
            SiteHighlightItem(
                category: "Publications",
                tag: "Policy Brief",
                title: "Adoption patterns for AI-assisted workflow systems",
                summary: "Brief in progress on how teams can introduce AI support while preserving process quality.",
                path: "publications"
            ),
            SiteHighlightItem(
                category: "Blog",
                tag: "Insight Post",
                title: "What I learned building an auto-updating personal website",
                summary: "A walkthrough of content architecture, deployment, and practical maintenance decisions.",
                path: "blog"
            ),
            SiteHighlightItem(
                category: "Training",
                tag: "Workshop",
                title: "Applied workflow automation for small implementation teams",
                summary: "Hands-on workshop design for building repeatable systems with immediate operational value.",
                path: "training"
            ),
            SiteHighlightItem(
                category: "Work",
                tag: "Project Milestone",
                title: "Launched local editor workflow for dynamic website field updates",
                summary: "Built a local form-based editor that updates structured data and rebuilds on save.",
                path: "work"
            ),
            SiteHighlightItem(
                category: "Presentations",
                tag: "Conference Talk",
                title: "Practical models for AI-enabled content operations",
                summary: "Upcoming presentation on implementation choices, risks, and scalable operating patterns.",
                path: "presentations"
            )
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
