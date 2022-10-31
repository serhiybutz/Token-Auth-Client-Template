import SwiftUI

@main
struct TokenAuthClientTemplateApp: App {

    @AppStorage var serverSettings: ServerSettings
    // Leverage State's reference-based storage under the hood to achieve a long-lived state:
    @State var injectionContainer: AppDependencyContainer

    var body: some Scene {

        WindowGroup {

            injectionContainer.contentView()
        }
    }

    init() {

        let serverSettings = AppStorage(wrappedValue: ServerSettings(), Constants.Server.UserDefaultsKey)
        self._serverSettings = serverSettings

        self._injectionContainer = State<AppDependencyContainer>(wrappedValue: AppDependencyContainer(serverSettings: serverSettings.projectedValue))

        suppressUnsatisfiableConstrantsWarning()
    }

    func suppressUnsatisfiableConstrantsWarning() {

        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
}
