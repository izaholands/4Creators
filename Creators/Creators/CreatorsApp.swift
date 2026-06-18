import SwiftUI
import UserNotifications

@main
struct CreatorsApp: App {
  
    let persistenceController = PersistenceController.shared
    
    init() {
        UINavigationBar.appearance().tintColor = .systemIndigo
        
        // 2. Adicione a solicitação de autorização aqui
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permissão de notificação concedida!")
            } else if let error = error {
                print("Erro ao pedir permissão: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
        }
    }
}
