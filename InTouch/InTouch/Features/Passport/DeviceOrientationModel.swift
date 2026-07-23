//
//  DeviceOrientationModel.swift
//  InTouch
//
//  Reads the *physical* device orientation for the passport's rotate-to-open
//  book. The app itself is portrait-locked (see project build settings), so the
//  interface never rotates — this reads rotation independently and drives the
//  book animation.
//
//  Why UIDevice.orientation and not CoreMotion: the iOS Simulator provides no
//  device-motion data, so a CoreMotion build can't be verified on the simulator
//  (which is how we test rotation). UIDevice.orientation updates on the simulator
//  when you rotate it, works on device, and — crucially — is independent of the
//  app's declared interface orientations, so it coexists with the portrait lock.
//  It can report .faceUp/.faceDown/.unknown; we ignore those and hold the last
//  meaningful orientation. See docs/DECISIONS.md.
//

import SwiftUI
import UIKit

@Observable
final class DeviceOrientationModel {

    /// The last portrait / landscape orientation seen. Flat and unknown states
    /// are ignored so a phone laid on a table doesn't close the book.
    private(set) var orientation: UIDeviceOrientation = .portrait

    /// True while the phone is held in either landscape — the book is open.
    var isLandscape: Bool { orientation.isLandscape }

    /// Angle to counter-rotate the (portrait-locked) book content so it reads
    /// upright to someone holding the phone in landscape. Only meaningful while
    /// `isLandscape` is true.
    var contentRotation: Angle {
        switch orientation {
        case .landscapeLeft:  return .degrees(90)
        case .landscapeRight: return .degrees(-90)
        default:              return .zero
        }
    }

    private var observer: NSObjectProtocol?

    /// Begin listening. Call from `.onAppear` on the passport tab.
    func start() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.update(UIDevice.current.orientation)
        }
        // Seed from the current physical orientation.
        update(UIDevice.current.orientation)
    }

    /// Stop listening. Call from `.onDisappear` so we don't run off-tab.
    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    private func update(_ new: UIDeviceOrientation) {
        switch new {
        case .portrait, .landscapeLeft, .landscapeRight:
            orientation = new
        default:
            break   // .portraitUpsideDown (unsupported), .faceUp/.faceDown, .unknown
        }
    }
}
