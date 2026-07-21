//
//  ConnectView.swift
//  InTouch
//
//  The Connect tab. DESIGN.md: ceremonial moments go dark navy, full-bleed —
//  stepping into a different room makes the ritual feel like a ritual. So this is
//  the one screen that leaves the paper world while the tab bar stays put.
//
//  No camera this phase. A scanner-frame placeholder sets the stage, and two
//  simulate buttons stand in for a real scan so the result screens are reachable
//  and reviewable. The rotating QR, reciprocal FaceID and proximity check are
//  Phase 2 (see docs/PRD.md § 3).
//

import SwiftUI

struct ConnectView: View {

    /// The pushed scan result. Setting it navigates; nil means we're on Connect.
    @State private var result: ScanResult?

    var body: some View {
        ZStack {
            Color.night.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                scanner
                Spacer()
                buttons
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)      // stay full-bleed dark
        .navigationDestination(item: $result) { ScanResultView(result: $0) }
    }

    private var scanner: some View {
        VStack(spacing: 26) {
            ScannerBrackets()
                .stroke(Color.paper.opacity(0.85), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 220, height: 220)
                .overlay {
                    Image(systemName: "qrcode")
                        .resizable().scaledToFit()
                        .frame(width: 96)
                        .foregroundStyle(Color.paper.opacity(0.14))
                }

            VStack(spacing: 8) {
                Text(Typography.chrome("Hold still"))
                    .font(Typography.emptyTitle)
                    .foregroundStyle(Color.paper)
                Text("Point this at someone's code and you'll both feel the stamp land. There's no other way in.")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.paper.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 280)
            }
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Text("NO CAMERA YET")
                .font(Typography.stampMark)
                .tracking(Typography.stampTracking)
                .foregroundStyle(Color.paper.opacity(0.4))

            simulateButton("Simulate scanning a person") {
                result = .person(MockData.scannedPerson)
            }
            simulateButton("Simulate scanning an event") {
                result = .event(MockData.scannedEvent)
            }
        }
    }

    private func simulateButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(Typography.chrome(title))
                .font(Typography.label)
                .foregroundStyle(Color.paper)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .overlay(Capsule().stroke(Color.paper.opacity(0.55), lineWidth: 1.5))
        }
    }
}

/// Four corner brackets, the way a scanner frames its target.
private struct ScannerBrackets: Shape {
    var cornerLength: CGFloat = 36

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = cornerLength
        // top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + c))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + c, y: rect.minY))
        // top-right
        path.move(to: CGPoint(x: rect.maxX - c, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + c))
        // bottom-right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.maxY))
        // bottom-left
        path.move(to: CGPoint(x: rect.minX + c, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - c))
        return path
    }
}

#Preview {
    NavigationStack { ConnectView() }
}
