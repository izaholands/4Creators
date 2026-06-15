import SwiftUI

struct NewFolderBottomView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    
    @State private var folderName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Interno (Cancelar | Título | Salvar)
            HStack {
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
                } label: {
                    Text("Cancelar")
                        .foregroundColor(.indigo)
                }
                Spacer()
                Text("Nova pasta")
                    .font(.headline)
                    .bold()
                Spacer()
                Button {
                    saveFolder()
                } label: {
                    Text("Salvar")
                        .bold()
                        .foregroundColor(folderName.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .indigo)
                }
                .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            // Campo de Entrada Compacto
            HStack {
                ZStack(alignment: .leading) {
                    if folderName.isEmpty {
                        Text("Nome da pasta")
                            .foregroundColor(Color(.systemGray3))
                            .font(.body)
                    }
                    
                    SearchTextView(text: $folderName)
                        .frame(height: 24)
                }
                
                Spacer()
                
                Text("\(folderName.count)/25")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func saveFolder() {
        let nameCleaned = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nameCleaned.isEmpty else { return }
        
        let folderService = FolderService()
        folderService.createFolder(name: nameCleaned, context: context)
        
        do {
            try folderService.save(context: context)
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            withAnimation(.easeInOut(duration: 0.25)) {
                isPresented = false
            }
            
        } catch {
            print("Erro ao salvar pasta: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NewFolderBottomView(isPresented: .constant(true), selectedTab: .constant(0))
}
