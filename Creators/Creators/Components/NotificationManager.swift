import Foundation
import UserNotifications

struct NotificationManager {
    
    static func schedule(title: String, date: Date, identifier: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "Hora de postar! 🚀"
        content.body = "Seu conteúdo: \(title) está pronto para ir ao ar."
        content.sound = .default
        print("cheguei aqui manoooo")
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar: \(error.localizedDescription)")
            } else {
                print("Notificação agendada com sucesso para: \(date)")
            }
        }
    }

    static func cancel(identifier: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier.uuidString])
    }
    
    
    static func verificarAgendadas() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("--- AGORA TEM \(requests.count) NOTIFICAÇÕES NA FILA ---")
            for request in requests {
                print("Notificação agendada: \(request.content.title)")
            }
        }
    }
}
