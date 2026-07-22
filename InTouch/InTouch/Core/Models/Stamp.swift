//
//  Stamp.swift
//  InTouch
//
//  One entry in the passport: a city you connected with someone in, or an
//  event you tapped into.
//
//  Retained this phase only to feed the passport/profile counts while the
//  procedural stamp rendering is gone. The per-kind ink (person / event /
//  first city) returns with the rebuilt passport booklet.
//

import Foundation

struct Stamp: Identifiable, Hashable {
    let id: String
    let city: String
    let country: String
    let date: Date
}
