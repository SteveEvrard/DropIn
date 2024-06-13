//
//  GetLocationShortcut.swift
//  DropIn
//
//  Created by Stephen Evrard on 5/9/24.
//

import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetLocationIntent(),
            phrases: [
                "\(.applicationName)",
            ],
            shortTitle: "Get Location",
            systemImageName: "location.fill"
        )
    }
}
