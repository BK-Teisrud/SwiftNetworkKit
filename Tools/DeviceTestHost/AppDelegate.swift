#if os(watchOS)
import SwiftUI

/// Static verification host; the library itself has no SwiftUI dependency.
@main
struct NetworkKitWatchTestHost: App {
    var body: some Scene {
        WindowGroup { Text("NetworkKit device tests") }
    }
}
#else
import UIKit

/// Local verification host only. It never creates a client or sends requests.
@main
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting session: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Device Tests", sessionRole: session.role)
        configuration.delegateClass = DeviceTestScene.self
        return configuration
    }
}

@MainActor
final class DeviceTestScene: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let controller = UIViewController()
        let label = UILabel()
        #if os(tvOS)
        controller.view.backgroundColor = .black
        label.textColor = .white
        #else
        controller.view.backgroundColor = .systemBackground
        #endif
        label.text = "NetworkKit device tests"
        label.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
        ])
        let window = UIWindow(windowScene: scene)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
    }
}
#endif
