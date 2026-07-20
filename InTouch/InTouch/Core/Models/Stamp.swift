//
//  Stamp.swift
//  InTouch
//
//  One entry in the passport: a city you connected with someone in, or an
//  event you tapped into.
//
//  `kind` reuses `StampView.Kind` rather than declaring a parallel enum. The
//  kind decides the ink colour and the mark, which are design-system facts, so
//  the design system owns the type and the model refers to it. One enum, no
//  mapping layer to keep in sync.
//

import Foundation

struct Stamp: Identifiable, Hashable {
    let id: String
    let city: String
    let country: String
    let date: Date
    let kind: StampView.Kind
}
