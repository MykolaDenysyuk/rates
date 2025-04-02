import SwiftUI
import SwiftData

@main
struct RatesApp: App {

    var body: some Scene {
        WindowGroup {
            RatesView(
                repository: RatesRepository(
                    localStorage: LocalStorage(),
                    remoteStorage: RemoteStorage()
                )
            )
        }
    }
}
