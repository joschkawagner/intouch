//
//  ProfileView.swift
//  InTouch
//
//  A profile is the person's collage, framed. The collage is loud; the chrome
//  around it — name, handle, the two counts — is quiet Josefin and ink, the same
//  loud-content-inside-quiet-order rule DESIGN.md applies to photos.
//
//  Reachable two ways: the masthead avatar (your own, `isCurrentUser`) and a
//  simulated scan of someone else. On your own profile a (non-functional) edit
//  button and a gear to Settings appear; on someone else's they don't.
//
//  Presented as a sheet wrapped in a NavigationStack — this is where real
//  navigation returns (the gear *pushes* Settings), as docs/DECISIONS.md foresaw.
//

import SwiftUI

struct ProfileView: View {

    let profile: UserProfile
    var isCurrentUser: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CollageView(collage: profile.collage)
                        .padding(.horizontal, 16)
                        .shadow(color: Color.text.opacity(0.18), radius: 12, x: 0, y: 6)
                        .padding(.top, 8)

                    identity

                    if isCurrentUser {
                        Button(action: {}) {          // editor arrives a later phase
                            Text(Typography.chrome("Edit collage"))
                                .font(Typography.label)
                                .foregroundStyle(Color.ink)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 22)
                                .overlay(Capsule().stroke(Color.ink, lineWidth: 1.5))
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .paperBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(Color.ink)
                    }
                    .accessibilityLabel("Close")
                }
                if isCurrentUser {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink { SettingsView() } label: {
                            Image(systemName: "gearshape").foregroundStyle(Color.ink)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
        }
    }

    private var identity: some View {
        VStack(spacing: 6) {
            Text(Typography.chrome(profile.displayName))
                .font(Typography.masthead)
                .foregroundStyle(Color.ink)

            Text(profile.handle)
                .font(Typography.timestamp)
                .tracking(1)
                .foregroundStyle(Color.muted)

            HStack(spacing: 28) {
                stat(profile.friendCount, "friends")
                stat(profile.stampCount, "stamps")
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 20)
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(Typography.statNumber)
                .foregroundStyle(Color.text)
            Text(label.uppercased())
                .font(Typography.stampMark)         // Courier — reads as a form field
                .tracking(Typography.stampTracking)
                .foregroundStyle(Color.muted)
        }
    }
}

#Preview {
    ProfileView(profile: MockData.currentUser, isCurrentUser: true)
}
