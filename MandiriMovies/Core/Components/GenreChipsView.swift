import SwiftUI

struct GenreChipsView: View {
    let genres: [String]

    var body: some View {
        FlowLayout(spacing: AppTheme.Spacing.xxs, alignment: .center) {
            ForEach(genres, id: \.self) { genre in
                Text(genre)
                    .font(AppTheme.Typography.genre)
                    .foregroundStyle(AppTheme.ColorToken.genreText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.ColorToken.genreBorder, lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxs)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    var alignment: Alignment = .center

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * spacing
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x: CGFloat
            switch alignment {
            case .leading:
                x = bounds.minX
            case .trailing:
                x = bounds.maxX - row.width
            default:
                x = bounds.minX + (bounds.width - row.width) / 2
            }

            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var current = Row()

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            let nextWidth = current.indices.isEmpty
                ? size.width
                : current.width + spacing + size.width

            if nextWidth > maxWidth, !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }

            current.indices.append(index)
            current.width = current.indices.count == 1
                ? size.width
                : current.width + spacing + size.width
            current.height = max(current.height, size.height)
        }

        if !current.indices.isEmpty {
            rows.append(current)
        }
        return rows
    }
}
