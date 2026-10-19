import UIKit

public final class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        if identifier == "com.melodybox.audio.download" {
            BackgroundDownloadManager.shared.backgroundCompletionHandler = completionHandler
        } else {
            completionHandler()
        }
    }
}
