import SwiftUI

@main
struct VibeControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ControllerMapView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
        
        // 菜单栏
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "gamecontroller.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
