import Plot
import Publish
import Foundation

extension Theme where Site == AcademicWebsite {
    static var academicMinimalist: Self {
        Theme(htmlFactory: AcademicHTMLFactory())
    }
}

private struct AcademicHTMLFactory: HTMLFactory {
    private func withBasePath(_ path: String, for context: PublishingContext<AcademicWebsite>) -> String {
        let basePath = context.site.url.path == "/" ? "" : context.site.url.path
        let normalized = path.hasPrefix("/") ? path : "/\(path)"
        return "\(basePath)\(normalized)"
    }

    func makeLayout<T: Location>(for location: T, context: PublishingContext<AcademicWebsite>) -> HTML {
        HTML(
            .head(
                .title(location.title),
                .meta(.charset(.utf8)),
                .meta(.name("viewport"), .content("width=device-width, initial-scale=1")),
                .stylesheet(withBasePath("theme.css", for: context)),
                .link(
                    .rel(.stylesheet),
                    .href("https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&family=Merriweather:ital,wght@0,300;0,700;1,300&display=swap")
                )
            ),
            .body(
                .div(
                    .class("wrapper"),
                    .header(
                        .class("sidebar"),
                        .div(
                            .class("profile-container"),
                            .img(
                                .src(withBasePath(context.site.imagePath?.description ?? "profile-placeholder.svg", for: context)),
                                .class("profile-photo"),
                                .alt("Profile photo")
                            )
                        ),
                        .h1(.text(context.site.name)),
                        .p(.class("bio-text"), .text(context.site.description)),
                        .nav(
                            .ul(
                                .li(.a(.href(withBasePath("/", for: context)), "Home")),
                                .li(.a(.href(withBasePath("work", for: context)), "Work")),
                                .li(.a(.href(withBasePath("training", for: context)), "Training")),
                                .li(.a(.href(withBasePath("publications", for: context)), "Publications")),
                                .li(.a(.href(withBasePath("presentations", for: context)), "Presentations")),
                                .li(.a(.href(withBasePath("connect", for: context)), "Connect"))
                            )
                        )
                    ),
                    .main(
                        .class("content"),
                        .contentBody(location.content.body)
                    )
                )
            )
        )
    }

    func makeIndexHTML(for index: Index, context: PublishingContext<AcademicWebsite>) -> HTML {
        makeLayout(for: index, context: context)
    }

    func makeSectionHTML(for section: Section<AcademicWebsite>, context: PublishingContext<AcademicWebsite>) -> HTML {
        makeLayout(for: section, context: context)
    }

    func makeItemHTML(for item: Item<AcademicWebsite>, context: PublishingContext<AcademicWebsite>) -> HTML {
        makeLayout(for: item, context: context)
    }

    func makePageHTML(for page: Page, context: PublishingContext<AcademicWebsite>) -> HTML {
        makeLayout(for: page, context: context)
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<AcademicWebsite>) -> HTML? { nil }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<AcademicWebsite>) -> HTML? { nil }
}
