//
//  TimelineEntry.swift
//  InTouch
//
//  One line in the passport's Calendar lens: a connection made, an event tapped
//  into, or a group started — anything that earned a place in your history. Each
//  row is led by a small StampView, so `kind` maps to an existing StampView.Kind
//  rather than inventing a parallel set of ink colours.
//

import Foundation

struct TimelineEntry: Identifiable, Hashable {
    let id: String
    let date: Date
    let kind: Kind
    let title: String
    let city: String

    enum Kind: Hashable {
        case connection
        case event
        case groupCreated

        /// The stamp that leads the row. Reuses the three passport inks.
        var stampKind: StampView.Kind {
            switch self {
            case .connection: .person
            case .event: .event
            case .groupCreated: .firstCity
            }
        }

        /// Small letterspaced label on the row.
        var mark: String {
            switch self {
            case .connection: "MET"
            case .event: "TAPPED IN"
            case .groupCreated: "STARTED"
            }
        }
    }
}
