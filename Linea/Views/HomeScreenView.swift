//
//  HomeScreenView.swift
//  Linea
//

import SwiftUI
import Observation
import UIKit



struct HomeScreenView: View {
    @State private var selectedTab = 0
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var scrollX: CGFloat = 0 // current horizontal offset of the timeline
    @State private var isSheetExpanded = false
    @State private var sheetDragOffset: CGFloat = 0


    var body: some View {
        CustomTabBarController(selectedTab: $selectedTab)
            .ignoresSafeArea(edges: .bottom)
    }
}

extension Notification.Name {
    static let homeTabSelected = Notification.Name("homeTabSelected")
}

extension Notification.Name {
    static let commitGroupNames = Notification.Name("commitGroupNames")
}

private struct ScrollXKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomTabBarController: UIViewControllerRepresentable {
    @Binding var selectedTab: Int

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .gray // top border line
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        // Home Tab
        let homeVC = UIHostingController(rootView: TabHomeView())
        homeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "house"), tag: 0)
        // Add Tab
        let addVC = UIHostingController(rootView: TabAddView())
        addVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "add"), tag: 1)
        // Settings Tab
        let settingsVC = UIHostingController(rootView: TabSettingsView(selectedTab: $selectedTab))
        settingsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "settings"), tag: 2)

        tabBarController.viewControllers = [homeVC, addVC, settingsVC]
        tabBarController.selectedIndex = selectedTab
        tabBarController.delegate = context.coordinator
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        uiViewController.selectedIndex = selectedTab
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITabBarControllerDelegate {
        var parent: CustomTabBarController

        init(_ parent: CustomTabBarController) {
            self.parent = parent
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            parent.selectedTab = tabBarController.selectedIndex
            if parent.selectedTab == 0 {
                NotificationCenter.default.post(name: .homeTabSelected, object: nil)
            }
        }
    }
}


//TODO: Figure out this function
extension Color {
    func darkerCustom() -> Color {
        let uiColor = UIColor(self)

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let average = (r + g + b) / 3
            let vibrancyBoost: CGFloat = 0.2
        
            
            let lightnessThreshold: CGFloat = 0.85
            if (r + g + b) / 3 > lightnessThreshold {
                r *= 0.98
                g *= 0.98
                b *= 0.98
            }

            return Color(red: r, green: g, blue: b, opacity: a)
        } else {
            return self
        }
    }
}

#Preview {
    @Previewable @State var taskViewModel = TaskViewModel()
    HomeScreenView()
        .environment(taskViewModel)
}
