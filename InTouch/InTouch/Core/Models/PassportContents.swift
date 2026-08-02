//
//  PassportContents.swift
//  InTouch
//
//  What is actually inside one person's passport: the cities they have photos
//  in, the moments inside those cities, and the per-city photo counts the
//  collages are composed from.
//
//  This exists so `PassportBookView` stops reaching for `MockData` directly.
//  The view previously read `MockData.cities` and `MockData.entries` from
//  inside its own body and helpers, which meant "the book" and "MY book" were
//  the same object — there was no seam at which a different holder could be
//  supplied. This is that seam. It is still only ever built for the current
//  user; supplying anyone else is a later step.
//
//  ✅ THE PHOTO COUNTS ARE NOW PER-HOLDER. They used to delegate to a global
//  `PassportMockPhotos.count(for:)` that switched on `city.name` — a per-CITY
//  oracle standing in for a per-HOLDER fact, so two holders who had both been to
//  Oslo would each have been credited with its 8 photos. `f6a5df3` flagged that
//  and said routing it through here did not fix it. This is the fix: the counts
//  are a stored field on the record, so they belong to the holder the way the
//  cities and entries already did.
//
//  MOVED TO `Core/Models/` BECAUSE THE SECOND CONSUMER ARRIVED. This file used
//  to say it lived in `Features/Passport/` because only the passport read it,
//  and that per CLAUDE.md it moves to `Core/` the moment a second feature does.
//  That moment is the ID card: `UserProfile.cityCount` was a stored duplicate of
//  `cityCount` below, and the card now reads THIS count instead of its own copy.
//  The prediction was right about the rule and wrong about the occasion — it
//  guessed a scan result handing over a book; what actually forced it was
//  deleting a second source of truth.
//
//  This satisfies "extract when the second consumer EXISTS, not when it is
//  forecast" (DECISIONS.md 2026-07-25) rather than violating it: the card is
//  reading it today, in this commit, not predicted to later.
//

import Foundation

struct PassportContents {

    /// One pin per city, in book order.
    let cities: [PassportCity]

    /// Every recorded moment, across all of `cities`.
    let entries: [PassportEntry]

    /// How many photos this holder has in each city, keyed by `PassportCity.name`
    /// (which IS `PassportCity.id`).
    ///
    /// ⚠️ A DICTIONARY, READ BY KEY LOOKUP ONLY AND NEVER ITERATED — and that
    /// restriction is load-bearing, not tidiness. Swift reseeds its hasher every
    /// process launch, so `Dictionary`/`Set` iteration order differs across
    /// launches; "some rendering input is constant WITHIN a process and different
    /// ACROSS processes" is the exact signature of the card-variance
    /// investigation, and hash-order iteration was its named candidate mechanism
    /// (DECISIONS.md 2026-07-26). Both `b38dc21` and `4a3c65b` checked and
    /// recorded that NOTHING IN THIS APP RENDERS IN HASH ORDER. This field is the
    /// first thing that could break that, so `totalPhotoCount` below sums over
    /// the `cities` ARRAY and looks each count up by key. Never `.values`,
    /// never `.keys`, never a bare `for` over this.
    let photoCounts: [String: Int]

    /// The current user's own book.
    ///
    /// The only HAND-AUTHORED record, and the asymmetry is worth naming: every
    /// other holder's record is derived from their posts, which the current user
    /// does not have — `MockData.posts` is the friends feed, and you do not
    /// appear in your own. So this one cannot be derived the same way, and the
    /// two constructions answer the same question by two different routes. That
    /// is the shape that produced the `cityCount` defect (`4a3c65b`), kept here
    /// deliberately rather than papered over, because inventing posts for the
    /// current user to make the rule uniform would be inventing content.
    static let currentUser = PassportContents(
        cities: MockData.cities,
        entries: MockData.entries,
        photoCounts: PassportMockPhotos.currentUser
    )

    // MARK: - Other people's records — DERIVED, never authored

    /// One holder's record, built entirely from the posts they made.
    ///
    /// ⚠️ ZERO INVENTION, AND THAT IS THE WHOLE DESIGN. Nothing here is written
    /// to look plausible: every city, every date and every photo count is read
    /// off a `FeedPost` that already existed. No city anyone did not post from,
    /// no entry date, no count. Contrast the three fixture sets this project has
    /// had to ⚠️-block precisely because they WERE invented — the five profiles
    /// in `d5b6ef8`, the five cities in `2e2593f`, the six serials in `b38dc21`.
    /// This one needs no such block, because there is nothing in it that came
    /// from nowhere.
    ///
    /// THE LICENCE IS WRITTEN IN `FeedPost.city`: "a post's city is wherever the
    /// *author* was standing." A post is photos in a place, and PRD § 4.4 defines
    /// a passport city as "a place you have photos" — so an author's posts are
    /// evidence about the author's own record in the one direction that holds.
    /// The same comment forbids the other direction, and nothing here does it:
    /// a friend's city never enters `MockData.cities`.
    ///
    /// BOOK ORDER FALLS OUT, IT IS NOT CHOSEN. `MockData.posts` is newest-first,
    /// so taking cities in first-appearance order puts each holder's most
    /// recently-posted city first. That happens to be the rule the plan's
    /// separate P5 will apply to everyone — this is not that change, and the
    /// current user's order stays hand-authored.
    ///
    /// ⚠️ ACCEPTED AND RECORDED, NOT ABSORBED: the derived counts are only ever
    /// 1 or 2, so friends' collages exercise only the 1-cell and 2-cell
    /// templates. `CollageTemplate`'s 3, 4, 5 and 6+ will never render for
    /// anyone but the current user, whose counts were authored specifically to
    /// cover all six. That coverage loss is the price of inventing nothing, it
    /// was weighed, and it is the accepted cost rather than an oversight.
    ///
    /// No `Set` anywhere — dedup is `contains` on the growing Array, which for
    /// two-city holders is cheaper than hashing and, more to the point, keeps
    /// every ordered structure here an Array (see `photoCounts`).
    static func derived(for user: UserProfile) -> PassportContents {
        var cities: [PassportCity] = []
        var entries: [PassportEntry] = []
        var counts: [String: Int] = [:]

        for post in MockData.posts where post.author.id == user.id {
            if !cities.contains(post.city) { cities.append(post.city) }
            entries.append(PassportEntry(id: "entry-\(post.id)",
                                         city: post.city,
                                         date: post.date))
            counts[post.city.name, default: 0] += post.photos.count
        }

        return PassportContents(cities: cities, entries: entries, photoCounts: counts)
    }

    /// The five feed friends and the scanned person, all six of them.
    ///
    /// Done for all six rather than for `scannedPerson` alone — the plan's step 5
    /// named only the scanned person, but that was written before `d5b6ef8`
    /// authored the other five profiles the same afternoon. Six now, once,
    /// instead of one now and five later.
    ///
    /// ⚠️ NOTHING READS THESE YET. A friend's book has no route to it until the
    /// CTA is wired (step 7): `PassportBookView` has two call sites, both the
    /// current user's, and `ScanResultView`'s button is still `Button(action: {})`.
    /// These are the record, not a screen.
    static let nora = derived(for: MockData.friendNora)
    static let sam  = derived(for: MockData.friendSam)
    static let juno = derived(for: MockData.friendJuno)
    static let drew = derived(for: MockData.friendDrew)
    static let ada  = derived(for: MockData.friendAda)
    static let emil = derived(for: MockData.scannedPerson)

    // MARK: - What the pages read

    /// The number the colophon prints.
    var cityCount: Int { cities.count }

    /// The most recent moment recorded in a city (its label date), if any.
    func latestDate(for city: PassportCity) -> Date? {
        entries.filter { $0.city == city }.map(\.date).max()
    }

    /// How many photos a city's collage composes.
    ///
    /// ⚠️ ZERO, NOT THREE, for a city this holder has no count for — and that is
    /// the one behaviour the per-holder change altered. The old global answered
    /// `default: 3`, which was a per-city oracle guessing on behalf of a holder
    /// it knew nothing about. A holder with no photos recorded in a place has no
    /// photos there; zero is the truthful answer and three was a placeholder
    /// wearing one.
    ///
    /// UNREACHABLE FOR EVERY HOLDER THAT EXISTS, which is why it changed nothing.
    /// Both call sites pass a member of `cities` — `PassportBookView.spreadView`
    /// passes `cities[index - 1]`, and `totalPhotoCount` folds over `cities` —
    /// so the fallback fires only if a city is in `cities` and missing from
    /// `photoCounts`. `currentUser` supplies all seven; a derived record builds
    /// both lists from the same posts in one pass. Nothing constructs a mismatch.
    func photoCount(for city: PassportCity) -> Int {
        photoCounts[city.name] ?? 0
    }

    /// Total photos across all cities — the honest count for the colophon,
    /// consistent with the per-city collages (mocked until a photo model exists).
    ///
    /// Folds over the `cities` ARRAY, looking each count up by key. NOT over
    /// `photoCounts` — see the warning on that field; a `.values.reduce` here
    /// would give the same sum today and would still be wrong, because it makes
    /// the app's output depend on a hash-ordered walk for the first time.
    var totalPhotoCount: Int {
        cities.reduce(0) { $0 + photoCount(for: $1) }
    }
}
