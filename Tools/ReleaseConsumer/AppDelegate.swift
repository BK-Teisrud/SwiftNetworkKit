import UIKit
import NetworkKit

// Rehearsal-only consumer. No network traffic starts on launch.
@main final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var client: APIClient?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        do { client = try APIClient(configuration: .init(baseURL: URL(string: "https://example.invalid")!)) }
        catch { return false }
        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        let label = UILabel(frame: controller.view.bounds)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.text = "NetworkKit consumer rehearsal"
        controller.view.addSubview(label)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        let client = client
        Task { await client?.shutdown() }
    }
}
