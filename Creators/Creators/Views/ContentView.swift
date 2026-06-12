import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    let persistenceController = PersistenceController.shared

    var body: some View {
        ZStack(alignment: .bottom) {

            // Conteúdo das abas
            Group {
                if selectedTab == 0 { HomeView() }
                if selectedTab == 1 { NewPostView(selectedTab: $selectedTab)}
                if selectedTab == 2 { NavPublications() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar customizada
            if selectedTab != 1 {
                customTabBar
            }
            //customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var customTabBar: some View {
        ZStack {
            // Fundo da tab bar
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
                .frame(height: 83)

            HStack(alignment: .center) {

                // Home
                tabBarButton(
                    icon: "house.fill",
                    label: "Home",
                    tab: 0
                )

                Spacer()

                // Botão + central
                Button {
                    selectedTab = 1
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.indigo)
                            .frame(width: 68, height: 68)
                            .shadow(color: .indigo.opacity(0.35), radius: 8, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -10)

                Spacer()

                // Projetos
                tabBarButton(
                    icon: "folder",
                    label: "Projetos",
                    tab: 2
                )
            }
            .padding(.horizontal, 59)
            .padding(.bottom, 20)
        }
        .frame(height: 83)
    }

    @ViewBuilder
    private func tabBarButton(icon: String, label: String, tab: Int) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selectedTab == tab ? .indigo : Color(.systemGray2))
        }
    }
}

#Preview {
    ContentView()
}
