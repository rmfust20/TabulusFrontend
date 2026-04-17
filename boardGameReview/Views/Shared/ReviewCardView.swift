import SwiftUI

struct ReviewCardView: View {
    @EnvironmentObject var auth: Auth
    let reviewModel: ReviewPublicModel
    let profileImageURL: String?
    let onEllipsisTap: () -> Void
    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var fullTextHeight: CGFloat? = nil
    @State private var clampedTextHeight: CGFloat? = nil
    private let collapsedLineLimit = 3

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if let url = profileImageURL {
                    RetryAsyncImage(url: URL(string: url), context: .profiles) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(Color("MutedText"))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(reviewModel.user.username ?? "Unknown User")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("rated it")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("MutedText"))

                    FlexStarsView(rating: .constant(reviewModel.rating), size: 12, interactive: false)
                }

                let comment = reviewModel.comment ?? ""
                Text(comment)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(isExpanded ? nil : collapsedLineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        Text(comment)
                            .font(.system(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .background(GeometryReader { full in
                                Color.clear.preference(
                                    key: ReviewTextHeightKey.self,
                                    value: full.size.height
                                )
                            })
                    )
                    .background(
                        Text(comment)
                            .font(.system(size: 14))
                            .lineLimit(collapsedLineLimit)
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .background(GeometryReader { clamped in
                                Color.clear.preference(
                                    key: ReviewClampedHeightKey.self,
                                    value: clamped.size.height
                                )
                            })
                    )
                    .onPreferenceChange(ReviewTextHeightKey.self) { fullHeight in
                        evaluateTruncation(fullHeight: fullHeight, clampedHeight: nil)
                    }
                    .onPreferenceChange(ReviewClampedHeightKey.self) { clampedHeight in
                        evaluateTruncation(fullHeight: nil, clampedHeight: clampedHeight)
                    }

                if isTruncated {
                    Button {
                        isExpanded.toggle()
                    } label: {
                        Text(isExpanded ? "See less" : "See more")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color("MutedText"))
                    }
                }
            }
            Spacer(minLength: 0)
            if reviewModel.user.id != auth.userID {
                Button {
                    onEllipsisTap()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(Color("MutedText"))
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 14)
    }

    private func evaluateTruncation(fullHeight: CGFloat?, clampedHeight: CGFloat?) {
        if let full = fullHeight {
            fullTextHeight = full
        }
        if let clamped = clampedHeight {
            clampedTextHeight = clamped
        }
        guard let full = fullTextHeight, let clamped = clampedTextHeight else { return }
        let shouldTruncate = full > clamped + 0.5
        if shouldTruncate != isTruncated {
            isTruncated = shouldTruncate
        }
    }
}

enum ReviewCardAlert {
    case report(ReviewPublicModel)
    case block(ReviewPublicModel)
    case reportSuccess
    case blockSuccess(String)
}

struct ReviewCardActionsModifier: ViewModifier {
    @Binding var optionsTarget: ReviewPublicModel?
    @Binding var activeAlert: ReviewCardAlert?
    let accessToken: String
    let onReported: () -> Void
    let onBlocked: () -> Void

    private let reviewService = ReviewService()
    private let userService = UserService()

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "",
                isPresented: Binding(
                    get: { optionsTarget != nil },
                    set: { if !$0 { optionsTarget = nil } }
                ),
                presenting: optionsTarget
            ) { target in
                Button("Report", role: .destructive) {
                    activeAlert = .report(target)
                }
                Button("Block", role: .destructive) {
                    activeAlert = .block(target)
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert(
                alertTitle,
                isPresented: Binding(
                    get: { activeAlert != nil },
                    set: { if !$0 { activeAlert = nil } }
                ),
                presenting: activeAlert
            ) { alert in
                alertActions(for: alert)
            } message: { alert in
                alertMessage(for: alert)
            }
    }

    private var alertTitle: String {
        switch activeAlert {
        case .report: return "Report this review?"
        case .block(let review): return "Block \(review.user.username ?? "this user")?"
        case .reportSuccess: return "Reported"
        case .blockSuccess(let name): return "Blocked \(name)"
        case .none: return ""
        }
    }

    @ViewBuilder
    private func alertActions(for alert: ReviewCardAlert) -> some View {
        switch alert {
        case .report(let review):
            Button("Report", role: .destructive) {
                Task {
                    try? await reviewService.reportReview(reviewID: review.id, accessToken: accessToken)
                    onReported()
                    activeAlert = .reportSuccess
                }
            }
            Button("Cancel", role: .cancel) { }
        case .block(let review):
            Button("Block", role: .destructive) {
                Task {
                    try? await userService.blockUser(userID: review.user.id, accessToken: accessToken)
                    onBlocked()
                    activeAlert = .blockSuccess(review.user.username ?? "this user")
                }
            }
            Button("Cancel", role: .cancel) { }
        case .reportSuccess, .blockSuccess:
            Button("OK", role: .cancel) { }
        }
    }

    @ViewBuilder
    private func alertMessage(for alert: ReviewCardAlert) -> some View {
        switch alert {
        case .report:
            Text("This review will be reported for review.")
        case .block:
            Text("You won't see their reviews or game nights anymore.")
        case .reportSuccess:
            Text("Thanks for reporting. We'll review this post.")
        case .blockSuccess:
            Text("You won't see their reviews or game nights anymore.")
        }
    }
}

extension View {
    func reviewCardActions(
        optionsTarget: Binding<ReviewPublicModel?>,
        activeAlert: Binding<ReviewCardAlert?>,
        accessToken: String,
        onReported: @escaping () -> Void,
        onBlocked: @escaping () -> Void
    ) -> some View {
        modifier(ReviewCardActionsModifier(
            optionsTarget: optionsTarget,
            activeAlert: activeAlert,
            accessToken: accessToken,
            onReported: onReported,
            onBlocked: onBlocked
        ))
    }
}

private struct ReviewTextHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct ReviewClampedHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
