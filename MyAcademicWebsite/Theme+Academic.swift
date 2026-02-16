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
    private let themeVersion = "20260216-highlights-from-pages-1"

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
        if section.id == .blog {
            return makePage(
                title: section.title,
                pageBody: blogSectionBody(section: section, context: context),
                includeHero: false,
                includeHighlights: false,
                includeBlogScripts: true,
                wrapInArticle: false,
                context: context
            )
        }

        return makePage(
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
        includeBlogScripts: Bool = false,
        wrapInArticle: Bool = true,
        context: PublishingContext<AcademicWebsite>
    ) -> HTML {
        HTML(
            .head(
                .title(title),
                .meta(.charset(.utf8)),
                .meta(.name("viewport"), .content("width=device-width, initial-scale=1")),
                .meta(.name("description"), .content(siteData.tagline)),
                .stylesheet(resolvePath("theme.css?v=\(themeVersion)", context: context)),
                .link(
                    .rel(.stylesheet),
                    .href("https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:wght@500;600;700&display=swap")
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
                    wrapInArticle
                        ? .article(
                            .class("article"),
                            pageBody
                        )
                        : pageBody,
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
                    includeHighlights ? highlightsSliderScriptNode() : .empty,
                    includeBlogScripts ? blogSectionScriptNode() : .empty
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

    private func blogSectionBody(
        section: Section<AcademicWebsite>,
        context: PublishingContext<AcademicWebsite>
    ) -> Node<HTML.BodyContext> {
        let posts = section.items.sorted { $0.date > $1.date }

        guard !posts.isEmpty else {
            return .section(
                .class("blog-layout"),
                .div(
                    .class("blog-main"),
                    .div(
                        .class("blog-page-header"),
                        .h2("Latest Blog Posts"),
                        .p("Posts will appear here as they are published.")
                    )
                )
            )
        }

        return .section(
            .class("blog-layout"),
            .attribute(named: "data-blog-layout", value: "true"),
            .div(
                .class("blog-main"),
                .div(
                    .class("blog-page-header"),
                    .h2("Latest Blog Posts"),
                    .p("Evidence-informed decision making notes, reflections, and practical learning for Uganda.")
                ),
                .div(
                    .class("blog-list"),
                    .forEach(posts) { post in
                        blogPreviewCard(for: post, context: context)
                    }
                ),
                .div(
                    .class("blog-pagination"),
                    .attribute(named: "data-blog-pagination", value: "true"),
                    .button(
                        .class("blog-page-btn"),
                        .attribute(named: "type", value: "button"),
                        .attribute(named: "data-blog-page-prev", value: "true"),
                        .text("Newer")
                    ),
                    .span(
                        .class("blog-page-state"),
                        .attribute(named: "data-blog-page-state", value: "true"),
                        .text("Page 1 of 1")
                    ),
                    .button(
                        .class("blog-page-btn"),
                        .attribute(named: "type", value: "button"),
                        .attribute(named: "data-blog-page-next", value: "true"),
                        .text("Older")
                    )
                )
            ),
            .div(
                .class("blog-sidebar"),
                .h3(.class("blog-sidebar-title"), .text("Auto Shuffling Posts")),
                .div(
                    .class("blog-spotlight"),
                    .attribute(named: "data-blog-spotlight", value: "true"),
                    .forEach(Array(posts.enumerated())) { entry in
                        blogSpotlightCard(for: entry.element, isActive: entry.offset == 0, context: context)
                    }
                )
            )
        )
    }

    private func blogPreviewCard(
        for item: Item<AcademicWebsite>,
        context: PublishingContext<AcademicWebsite>
    ) -> Node<HTML.BodyContext> {
        let targetPath = resolvePath(item.path.string, context: context)

        return .article(
            .class("blog-preview-card"),
            .attribute(named: "data-blog-post-card", value: "true"),
            .a(
                .class("blog-preview-media"),
                .href(targetPath),
                .img(
                    .class("blog-preview-image"),
                    .src(resolvePath(blogPostImagePath(for: item), context: context)),
                    .alt("\(item.title) preview image")
                )
            ),
            .div(
                .class("blog-preview-content"),
                .p(.class("blog-preview-date"), .text(formattedDate(item.date))),
                .h3(
                    .class("blog-preview-title"),
                    .a(.href(targetPath), .text(item.title))
                ),
                .p(.class("blog-preview-summary"), .text(blogPostSummary(for: item))),
                .a(.class("blog-preview-link"), .href(targetPath), .text("Read post"))
            )
        )
    }

    private func blogSpotlightCard(
        for item: Item<AcademicWebsite>,
        isActive: Bool,
        context: PublishingContext<AcademicWebsite>
    ) -> Node<HTML.BodyContext> {
        let targetPath = resolvePath(item.path.string, context: context)

        return .article(
            .class(isActive ? "blog-spotlight-card is-active" : "blog-spotlight-card"),
            .a(
                .class("blog-spotlight-media"),
                .href(targetPath),
                .img(
                    .class("blog-spotlight-image"),
                    .src(resolvePath(blogPostImagePath(for: item), context: context)),
                    .alt("\(item.title) featured image")
                )
            ),
            .div(
                .class("blog-spotlight-content"),
                .h4(.class("blog-spotlight-title"), .a(.href(targetPath), .text(item.title))),
                .p(.class("blog-spotlight-summary"), .text(blogPostSummary(for: item))),
                .a(.class("blog-spotlight-link"), .href(targetPath), .text("Open"))
            )
        )
    }

    private func highlightsSection(context: PublishingContext<AcademicWebsite>) -> Node<HTML.BodyContext> {
        let highlights = derivedHighlights(context: context)
        guard !highlights.isEmpty else { return .empty }

        return .section(
            .class("highlights-banner"),
            .attribute(named: "data-highlights-slider", value: "true"),
            .div(
                .class("highlights-header"),
                .h2("Highlights"),
                .p("Latest updates pulled from your pages and newest posts.")
            ),
            .div(
                .class("highlights-slider"),
                .div(
                    .class("highlights-track"),
                    .forEach(highlights) { item in
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
                .forEach(Array(highlights.enumerated())) { entry in
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

    private func derivedHighlights(context: PublishingContext<AcademicWebsite>) -> [SiteHighlightItem] {
        let orderedIDs: [AcademicWebsite.SectionID] = [.publications, .blog, .training, .work, .presentations]
        let sectionsByID = Dictionary(uniqueKeysWithValues: context.sections.map { ($0.id, $0) })

        return orderedIDs.compactMap { id in
            guard let section = sectionsByID[id] else { return nil }
            let latestItem = section.items.sorted { $0.date > $1.date }.first

            let imagePath: String = {
                if let latestItem {
                    let candidate = latestItem.metadata.image?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if !candidate.isEmpty { return candidate }
                }
                return highlightImagePath(for: id)
            }()

            let title = latestItem?.title ?? "\(section.title) Update"
            let summary = latestItem.map { blogPostSummary(for: $0) }
                ?? normalizedHighlightSummary(
                    section.content.description,
                    fallback: fallbackHighlightSummary(for: id)
                )

            return SiteHighlightItem(
                category: section.title,
                tag: highlightTag(for: id, hasItem: latestItem != nil),
                title: title,
                summary: summary,
                path: latestItem?.path.string ?? section.path.string,
                imagePath: imagePath
            )
        }
    }

    private func highlightTag(for sectionID: AcademicWebsite.SectionID, hasItem: Bool) -> String {
        switch sectionID {
        case .publications:
            return hasItem ? "Latest Output" : "Research Output"
        case .blog:
            return hasItem ? "Latest Post" : "Blog Update"
        case .training:
            return hasItem ? "Latest Session" : "Capacity Building"
        case .work:
            return hasItem ? "Latest Role" : "Current Role"
        case .presentations:
            return hasItem ? "Latest Talk" : "Recent Session"
        case .connect:
            return "Contact"
        }
    }

    private func highlightImagePath(for sectionID: AcademicWebsite.SectionID) -> String {
        switch sectionID {
        case .publications:
            return "highlight-publication-journal.svg"
        case .blog:
            return "highlight-blog.svg"
        case .training:
            return "highlight-training.svg"
        case .work:
            return "highlight-work.svg"
        case .presentations:
            return "highlight-presentation.svg"
        case .connect:
            return siteData.profileImagePath
        }
    }

    private func fallbackHighlightSummary(for sectionID: AcademicWebsite.SectionID) -> String {
        switch sectionID {
        case .publications:
            return "Recent evidence synthesis and research outputs."
        case .blog:
            return "Recent blog reflections and field notes."
        case .training:
            return "Latest capacity-building and workshop activity."
        case .work:
            return "Current professional role and responsibilities."
        case .presentations:
            return "Recent talks, sessions, and knowledge-sharing activities."
        case .connect:
            return "Ways to get in touch."
        }
    }

    private func normalizedHighlightSummary(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return fallback }

        let maxLength = 170
        if trimmed.count <= maxLength { return trimmed }
        let prefix = trimmed.prefix(maxLength)
        let withoutTrailingWhitespace = prefix.reversed().drop(while: { $0.isWhitespace }).reversed()
        return "\(withoutTrailingWhitespace)…"
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

    private func blogSectionScript() -> String {
        """
        (() => {
          const root = document.querySelector('[data-blog-layout=\"true\"]');
          if (!root) return;

          const posts = Array.from(root.querySelectorAll('[data-blog-post-card]'));
          const pagination = root.querySelector('[data-blog-pagination=\"true\"]');
          const prev = root.querySelector('[data-blog-page-prev=\"true\"]');
          const next = root.querySelector('[data-blog-page-next=\"true\"]');
          const state = root.querySelector('[data-blog-page-state=\"true\"]');
          const pageSize = 5;

          let page = 0;
          const pageCount = Math.max(1, Math.ceil(posts.length / pageSize));

          const renderPage = () => {
            posts.forEach((post, index) => {
              const visible = index >= page * pageSize && index < (page + 1) * pageSize;
              post.classList.toggle('is-hidden', !visible);
            });

            if (state) state.textContent = `Page ${page + 1} of ${pageCount}`;
            if (prev) prev.disabled = page === 0;
            if (next) next.disabled = page >= pageCount - 1;

            if (pagination) {
              pagination.classList.toggle('is-hidden', pageCount <= 1);
            }
          };

          prev?.addEventListener('click', () => {
            if (page <= 0) return;
            page -= 1;
            renderPage();
          });

          next?.addEventListener('click', () => {
            if (page >= pageCount - 1) return;
            page += 1;
            renderPage();
          });

          renderPage();

          const spotlight = root.querySelector('[data-blog-spotlight=\"true\"]');
          if (!spotlight) return;

          const cards = Array.from(spotlight.querySelectorAll('.blog-spotlight-card'));
          if (cards.length === 0) return;

          let active = 0;
          let timer = null;

          const activate = (nextIndex) => {
            active = (nextIndex + cards.length) % cards.length;
            cards.forEach((card, index) => {
              card.classList.toggle('is-active', index === active);
            });
          };

          const start = () => {
            if (cards.length < 2 || timer) return;
            timer = setInterval(() => activate(active + 1), 4300);
          };

          const stop = () => {
            if (!timer) return;
            clearInterval(timer);
            timer = null;
          };

          spotlight.addEventListener('mouseenter', stop);
          spotlight.addEventListener('mouseleave', start);

          activate(0);
          start();
        })();
        """
    }

    private func blogSectionScriptNode() -> Node<HTML.BodyContext> {
        .script(.raw(blogSectionScript()))
    }

    private func highlightImagePath(for item: SiteHighlightItem) -> String {
        let candidate = item.imagePath?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return candidate.isEmpty ? siteData.profileImagePath : candidate
    }

    private func blogPostImagePath(for item: Item<AcademicWebsite>) -> String {
        let candidate = item.metadata.image?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return candidate.isEmpty ? "highlight-blog.svg" : candidate
    }

    private func blogPostSummary(for item: Item<AcademicWebsite>) -> String {
        let candidate = item.metadata.summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return candidate.isEmpty ? "Read this post for key insights and practical reflections." : candidate
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
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
