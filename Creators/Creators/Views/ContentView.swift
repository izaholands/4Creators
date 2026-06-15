import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var navigationDepth : Int = 0
    @State private var showCreateMenu: Bool = false
    @State private var showNewFolderSheet: Bool = false
    
    private var hideTabBar: Bool {
        navigationDepth > 0
    }
    let persistenceController = PersistenceController.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Conteúdo das abas
            Group {
                if selectedTab == 0 { HomeView(navigationDepth: $navigationDepth) }
                if selectedTab == 1 { NewPostView(selectedTab: $selectedTab)}
                if selectedTab == 2 { NavPublications(navigationDepth: $navigationDepth) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar customizada
            if selectedTab != 1  && !hideTabBar{
                customTabBar
            }
           
            if showCreateMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showCreateMenu = false
                        }
                    }

                VStack {
                    Spacer()

                    CreateSelectionView(
                        selectedTab: $selectedTab,
                        isPresented: $showCreateMenu,
                        showNewFolderSheet: $showNewFolderSheet
                    )
                    .frame(height: 240)
                    .background(Color.white)
                    .clipShape(
                        CornerShape(
                            radius: 24,
                            corners: [.topLeft, .topRight]
                        )
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
                .zIndex(10)
            }
                
            if showNewFolderSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )

                        withAnimation(.easeInOut(duration: 0.25)) {
                            showNewFolderSheet = false
                        }
                    }

                VStack {
                    Spacer()

                    NewFolderBottomView(
                        isPresented: $showNewFolderSheet,
                        selectedTab: $selectedTab
                    )
                    .frame(height: 200)
                    .background(Color.white)
                    .clipShape(
                        CornerShape(
                            radius: 24,
                            corners: [.topLeft, .topRight]
                        )
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
                .zIndex(11)
            }
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showCreateMenu = true
                    }
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

struct CreateSelectionView: View {
    @Binding var selectedTab: Int
    @Binding var isPresented: Bool
    @Binding var showNewFolderSheet: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Criar novo").font(.headline).bold().padding(.leading, 24)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray3))
                        .font(.title3)
                }
            }
            .padding()

            VStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedTab = 1
                        isPresented = false
                    }
                } label: {
                    HStack {
                        Image(systemName: "doc.plaintext.fill")
                            .foregroundColor(.indigo)
                            .font(.system(size: 18))
                        Text("Nova Publicação")
                            .foregroundColor(.primary)
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.systemGray3))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                    // Abre a aba menorzinha de pastas logo em seguida
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showNewFolderSheet = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.indigo)
                            .font(.system(size: 18))
                        Text("Nova Pasta")
                            .foregroundColor(.primary)
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.systemGray3))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
