import Plot
import Publish
import Foundation

extension Theme where Site == AcademicWebsite {
    static func academicMinimalist(siteData: SiteData) -> Self {
        Theme(htmlFactory: AcademicHTMLFactory(siteData: siteData))
    }
}

private struct AcademicHTMLFactory: HTMLFactory {
    let siteData: SiteData

    func makeIndexHTML(for index: Index, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: index.title,
            pageBody: .contentBody(index.content.body),
            includeHero: true,
            context: context
        )
    }

    func makeSectionHTML(for section: Section<AcademicWebsite>, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: section.title,
            pageBody: .contentBody(section.content.body),
            includeHero: false,
            context: context
        )
    }

    func makeItemHTML(for item: Item<AcademicWebsite>, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: item.title,
            pageBody: .contentBody(item.content.body),
            includeHero: false,
            context: context
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: page.title,
            pageBody: .contentBody(page.content.body),
            includeHero: false,
            context: context
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<AcademicWebsite>) -> HTML? { nil }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<AcademicWebsite>) -> HTML? { nil }

    private func makePage(
        title: String,
        pageBody: Node<HTML.BodyContext>,
        includeHero: Bool,
        context: PublishingContext<AcademicWebsite>
    ) -> HTML {
        HTML(
            .head(
                .title(title),
                .meta(.charset(.utf8)),
                .meta(.name("viewport"), .content("width=device-width, initial-scale=1")),
                .meta(.name("description"), .content(siteData.tagline)),
                .stylesheet(resolvePath("theme.css", context: context)),
                .link(
                    .rel(.stylesheet),
                    .href("https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;700;800&family=Literata:opsz,wght@7..72,500;7..72,700&display=swap")
                )
            ),
            .body(
                .header(
                    .class("site-header"),
                    .div(
                        .class("site-header-inner"),
                        .a(
                            .class("brand"),
                            .href(resolvePath("/", context: context)),
                            .img(
                                .class("brand-mark"),
                                .src(resolvePath(siteData.logoPath, context: context)),
                                .alt("Logo")
                            ),
                            siteData.logoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? .empty
                                : .span(.class("brand-text"), .text(siteData.logoText))
                        ),
                        .nav(
                            .class("top-nav"),
                            .ul(
                                .forEach(siteData.navItems) { navItem in
                                    .li(
                                        .a(
                                            .href(resolvePath(navItem.path, context: context)),
                                            .text(navItem.title)
                                        )
                                    )
                                }
                            )
                        )
                    )
                ),
                .main(
                    .class("page-shell"),
                    includeHero ? heroSection(context: context) : .empty,
                    .article(
                        .class("article"),
                        pageBody
                    )
                ),
                .footer(
                    .class("site-footer"),
                    .p(.text("\(siteData.siteName) • \(siteData.location)")),
                    .p(
                        .a(.href("mailto:\(siteData.email)"), .text(siteData.email)),
                        .text(" • "),
                        .a(.href(siteData.github), .text("GitHub")),
                        siteData.linkedin.isEmpty ? .empty : .text(" • "),
                        siteData.linkedin.isEmpty ? .empty : .a(.href(siteData.linkedin), .text("LinkedIn"))
                    )
                )
            )
        )
    }

    private func heroSection(context: PublishingContext<AcademicWebsite>) -> Node<HTML.BodyContext> {
        .section(
            .class("hero"),
            .div(
                .class("hero-copy"),
                .p(.class("hero-name"), .text(siteData.siteName)),
                .h1(.text(siteData.heroHeadline)),
                .p(.class("hero-intro"), .text(siteData.heroIntro)),
                .div(
                    .class("hero-actions"),
                    .a(.class("btn btn-primary"), .href(resolvePath("work", context: context)), .text("View Work")),
                    .a(.class("btn"), .href(resolvePath("connect", context: context)), .text("Get In Touch"))
                )
            ),
            .div(
                .class("hero-photo-card"),
                .img(
                    .class("hero-photo"),
                    .src(resolvePath(siteData.profileImagePath, context: context)),
                    .alt("Profile picture")
                )
            )
        )
    }

    private func resolvePath(_ rawPath: String, context: PublishingContext<AcademicWebsite>) -> String {
        let trimmed = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") || trimmed.hasPrefix("mailto:") {
            return trimmed
        }

        let basePath = context.site.url.path == "/" ? "" : context.site.url
            .path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        let basePrefix = basePath.isEmpty ? "" : "/\(basePath)"

        if trimmed == "/" {
            return basePrefix.isEmpty ? "/" : "\(basePrefix)/"
        }

        let normalized = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
        return "\(basePrefix)\(normalized)"
    }
}
