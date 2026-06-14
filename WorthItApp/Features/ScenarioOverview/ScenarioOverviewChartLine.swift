import SwiftUI


private struct ChartLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: rect.minX, y: rect.maxY * 0.82),
            CGPoint(x: rect.width * 0.18, y: rect.maxY * 0.74),
            CGPoint(x: rect.width * 0.35, y: rect.maxY * 0.62),
            CGPoint(x: rect.width * 0.52, y: rect.maxY * 0.50),
            CGPoint(x: rect.width * 0.70, y: rect.maxY * 0.47),
            CGPoint(x: rect.width * 0.86, y: rect.maxY * 0.39),
            CGPoint(x: rect.maxX, y: rect.maxY * 0.30),
        ]

        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
