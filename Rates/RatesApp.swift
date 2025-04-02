import SwiftUI
import SwiftData

@main
struct MainEntryPoint {
    static func main() {
        guard isProduction() else {
            TestApp.main()
            return
        }

        RatesApp.main()
    }

    private static func isProduction() -> Bool {
        return NSClassFromString("XCTestCase") == nil
    }
}

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

struct TestApp: App {
    var body: some Scene {
        WindowGroup {
        }
    }
}
