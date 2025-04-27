//
//  AuthViewModel.swift
//  Linea
//

import Foundation
import GoogleSignIn
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: GIDGoogleUser?
    @Published var isSignedIn: Bool = false

    func signInWithGoogle(onSuccess: @escaping () -> Void) {
        guard let rootViewController = getRootViewController() else { return }

        let config = GIDConfiguration(clientID: "1098134127602-j6h2gv82q3akt1kigpq5h0kb67ibd4hu.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/calendar.readonly"]
        ) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else { return }
            
            self.user = result.user
            self.isSignedIn = true
            
            print("Signed in as: \(result.user.profile?.name ?? "No Name")")
            print("Email: \(result.user.profile?.email ?? "No Email")")
            
            let accessToken = result.user.accessToken.tokenString
            self.fetchPrimaryCalendarEvents(accessToken: accessToken)
            
            onSuccess()
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }
    
    private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        return vc
    }
    
    private func fetchPrimaryCalendarEvents(accessToken: String) {
        let formatter = ISO8601DateFormatter()
        let currentDateTime = formatter.string(from: Date())
        
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events?orderBy=startTime&singleEvents=true&timeMin=\(currentDateTime)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Primary Calendar API Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Primary Calendar Events JSON: \(jsonString)")
            }
            
            do {
                //Decoder for Google's event format
                struct GoogleCalendarEvents: Codable {
                    let items: [GoogleEvent]?
                }

                struct GoogleEvent: Codable {
                    let summary: String?
                    let start: EventDateTime?
                    let end: EventDateTime?
                }

                struct EventDateTime: Codable {
                    let date: String?
                    let dateTime: String?
                }
                
                let calendarResponse = try JSONDecoder().decode(GoogleCalendarEvents.self, from: data)
                
                if let items = calendarResponse.items, !items.isEmpty {
                    print("Fetched \(items.count) events from primary calendar.")
                    
                    let mappedTasks: [LineaTask] = items.compactMap { event in
                        guard let startDateString = event.start?.dateTime ?? event.start?.date,
                              let startDate = ISO8601DateFormatter().date(from: startDateString) else {
                            return nil
                        }
                        
                        let endDate: Date = {
                            if let endDateString = event.end?.dateTime ?? event.end?.date,
                               let parsedEnd = ISO8601DateFormatter().date(from: endDateString) {
                                return parsedEnd
                            } else {
                                return Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
                            }
                        }()
                        
                        return LineaTask(
                            group: "Blue", // Default group color, could change this
                            title: event.summary ?? "No Title",
                            start: startDate,
                            end: endDate
                        )
                    }
                    
                    print("Mapped Tasks:")
                    for task in mappedTasks {
                        print("- \(task.title) | \(task.start) → \(task.end)")
                    }
                    
                    // TODO: Insert mappedTasks into TaskViewModel

                } else {
                    print("User has no events in primary calendar.")
                }
            } catch {
                print("Primary Events JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
