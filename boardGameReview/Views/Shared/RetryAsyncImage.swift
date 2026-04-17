import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

private let sasCacheKeyFilter = SDWebImageCacheKeyFilter { url in
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          components.queryItems?.contains(where: { $0.name == "sig" }) == true else {
        return url.absoluteString
    }
    var stripped = components
    stripped.query = nil
    return stripped.url?.absoluteString ?? url.absoluteString
}

struct RetryAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let context: ImageCacheContext
    let maxRetries: Int
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var attempt = 0

    init(
        url: URL?,
        context: ImageCacheContext = .default,
        maxRetries: Int = 2,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.context = context
        self.maxRetries = maxRetries
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        WebImage(
            url: url,
            options: [.retryFailed],
            context: [
                .imageCache: context.cache,
                .cacheKeyFilter: sasCacheKeyFilter
            ]
        ) { image in
            content(image)
        } placeholder: {
            placeholder()
        }
        .onFailure { _ in
            if attempt < maxRetries {
                attempt += 1
            }
        }
        .id(attempt)
    }
}
