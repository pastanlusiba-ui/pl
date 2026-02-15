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
            includeHighlights: true,
            context: context
        )
    }

    func makeSectionHTML(for section: Section<AcademicWebsite>, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: section.title,
            pageBody: .contentBody(section.content.body),
            includeHero: false,
            includeHighlights: false,
            context: context
        )
    }

    func makeItemHTML(for item: Item<AcademicWebsite>, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: item.title,
            pageBody: .contentBody(item.content.body),
            includeHero: false,
            includeHighlights: false,
            context: context
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<AcademicWebsite>) -> HTML {
        makePage(
            title: page.title,
            pageBody: .contentBody(page.content.body),
            includeHero: false,
            includeHighlights: false,
            context: context
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<AcademicWebsite>) -> HTML? { nil }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<AcademicWebsite>) -> HTML? { nil }

    private func makePage(
        title: String,
        pageBody: Node<HTML.BodyContext>,
        includeHero: Bool,
        includeHighlights: Bool,
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
                    ),
                    includeHighlights ? highlightsSection(context: context) : .empty
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
                    ),
                    includeHighlights ? highlightsSliderScriptNode() : .empty
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

    private func highlightsSection(context: PublishingContext<AcademicWebsite>) -> Node<HTML.BodyContext> {
        guard !siteData.highlights.isEmpty else { return .empty }

        return .section(
            .class("highlights-banner"),
            .attribute(named: "data-highlights-slider", value: "true"),
            .div(
                .class("highlights-header"),
                .h2("Highlights"),
                .p("Latest activity across publications, blog, training, work, and presentations.")
            ),
            .div(
                .class("highlights-slider"),
                .div(
                    .class("highlights-track"),
                    .forEach(siteData.highlights) { item in
                        .article(
                            .class("highlight-card"),
                            .div(
                                .class("highlight-media"),
                                .img(
                                    .class("highlight-image"),
                                    .src(resolvePath(highlightImagePath(for: item), context: context)),
                                    .alt("\(item.category) highlight image")
                                )
                            ),
                            .div(
                                .class("highlight-content"),
                                .p(
                                    .class("highlight-meta"),
                                    .span(.class("highlight-category"), .text(item.category)),
                                    .span(.class("highlight-tag"), .text(item.tag))
                                ),
                                .h3(.text(item.title)),
                                .p(.class("highlight-summary"), .text(item.summary)),
                                .a(
                                    .class("highlight-link"),
                                    .href(resolvePath(item.path, context: context)),
                                    .text("Open \(item.category)")
                                )
                            )
                        )
                    }
                )
            ),
            .div(
                .class("highlight-dots"),
                .forEach(Array(siteData.highlights.enumerated())) { entry in
                    let index = entry.offset
                    return .button(
                        .class(index == 0 ? "highlight-dot is-active" : "highlight-dot"),
                        .attribute(named: "type", value: "button"),
                        .attribute(named: "data-highlight-target", value: String(index)),
                        .attribute(named: "aria-label", value: "Show highlight \(index + 1)")
                    )
                }
            )
        )
    }

    private func highlightsSliderScript() -> String {
        """
        (() => {
          const root = document.querySelector('[data-highlights-slider=\"true\"]');
          if (!root) return;

          const track = root.querySelector('.highlights-track');
          if (!track) return;

          const cards = Array.from(root.querySelectorAll('.highlight-card'));
          const dots = Array.from(root.querySelectorAll('.highlight-dot'));
          if (cards.length === 0) return;

          let index = 0;
          let timer = null;

          const activate = (next, animated = true) => {
            index = (next + cards.length) % cards.length;

            track.style.transition = animated
              ? 'transform 620ms cubic-bezier(0.22, 0.61, 0.36, 1)'
              : 'none';
            track.style.transform = `translateX(-${index * 100}%)`;

            dots.forEach((dot, i) => {
              dot.classList.toggle('is-active', i === index);
            });
          };

          const start = () => {
            if (cards.length < 2 || timer) return;
            timer = setInterval(() => activate(index + 1), 4200);
          };

          const stop = () => {
            if (!timer) return;
            clearInterval(timer);
            timer = null;
          };

          dots.forEach((dot, i) => {
            dot.addEventListener('click', () => {
              activate(i);
              stop();
              start();
            });
          });

          root.addEventListener('mouseenter', stop);
          root.addEventListener('mouseleave', start);

          activate(0, false);
          start();
        })();
        """
    }

    private func highlightsSliderScriptNode() -> Node<HTML.BodyContext> {
        .script(.raw(highlightsSliderScript()))
    }

    private func highlightImagePath(for item: SiteHighlightItem) -> String {
        let candidate = item.imagePath?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return candidate.isEmpty ? siteData.profileImagePath : candidate
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
