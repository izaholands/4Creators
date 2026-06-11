import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AISheetView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var isLoading: Bool = false
    
    // Altura inicial padrão para 1 linha (trazido do Arquivo 2)
    @State private var inputHeight: CGFloat = 38
    
    // Mantida a injeção do serviço real (do Arquivo 1)
    private var agentService: AIAgentService {
        AIAgentService(
            postService: PostService(),
            folderService: FolderService(),
            context: context
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("IA")
                    .font(.title3.bold())
                Spacer()
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(.systemGray))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Área de conversa
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        
                        // Garante que o topo sempre tenha uma folga do cabeçalho
                        Spacer()
                            .frame(height: 10)

                        if messages.isEmpty && !isLoading {
                            Text("Olá creator! No que\nvocê está pensando?")
                                .font(.title)
                                .foregroundColor(Color(.systemGray2))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 120)
                        }

                        ForEach(messages) { message in
                            HStack {
                                if message.isUser { Spacer() }

                                Text(message.text)
                                    .font(.body)
                                    .foregroundColor(message.isUser ? .white : .primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(message.isUser ? Color.indigo : Color(.systemGray5))
                                    )
                                    .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)

                                if !message.isUser { Spacer() }
                            }
                            .id(message.id)
                        }

                        if isLoading {
                            HStack {
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { _ in
                                        Circle()
                                            .fill(Color(.systemGray3))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(.systemGray5))
                                )
                                Spacer()
                            }
                            .id("loading")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        if let lastId = messages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _ in
                    withAnimation {
                        proxy.scrollTo("loading", anchor: .bottom)
                    }
                }
            }

            // Input Bar - Estrutura customizada e segura (do Arquivo 2)
            HStack(alignment: .bottom, spacing: 0) {
                ZStack(alignment: .leading) {
                    if messageText.isEmpty {
                        Text("Digite algo...")
                            .foregroundColor(Color(.systemGray2))
                            .font(.body)
                            .padding(.leading, 4)
                            .padding(.bottom, 8)
                    }

                    DynamicTextView(
                        text: $messageText,
                        height: $inputHeight,
                        maxHeight: 90 // Trava em aproximadamente 4 linhas (Arquivo 2)
                    )
                    .frame(height: max(38, min(inputHeight, 90)))
                }
                .padding(.leading, 16)
                .padding(.vertical, 4)
                
                Spacer(minLength: 8)

                // Botão Send
                Button {
                    sendMessage()
                } label: {
                    ZStack {
                        Circle()
                            .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  ? Color(.systemGray4)
                                  : Color.indigo)
                            .frame(width: 32, height: 32)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.trailing, 8)
                .padding(.bottom, 6)
            }
            .background(
                Capsule()
                    .fill(Color(.systemGray5))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
    }

    // Lógica real de integração mantida (Arquivo 1)
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("text: \(text)")
        guard !text.isEmpty else { return }
        
        messages.append(Message(text: text, isUser: true))
        messageText = ""
        inputHeight = 38 // Reseta para a altura de 1 linha (Arquivo 2)
        isLoading = true

        Task {
            do {
                let reply = try await agentService.handle(userMessage: text)
                print("reply: \(reply)")
                await MainActor.run {
                    isLoading = false
                    messages.append(Message(text: reply, isUser: false))
                }
            } catch {
                print("cai nesse catch")
                print("Erro detalhado: \(error.localizedDescription)")

                await MainActor.run {
                    isLoading = false
                    messages.append(Message(text: "Error: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
}

// DynamicTextView com as proteções de layout (Arquivo 2)
struct DynamicTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var maxHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        tv.delegate = context.coordinator
        
        // CORREÇÃO: Força o componente a respeitar a largura da tela
        tv.isScrollEnabled = true
        
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.lineBreakMode = .byCharWrapping
        
        // Diz ao layout para priorizar a compressão horizontal se faltar espaço
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        recalcHeight(uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, height: $height, maxHeight: maxHeight)
    }

    private func recalcHeight(_ uiView: UITextView) {
        // Proteção contra larguras zeradas
        let width = uiView.frame.width > 0 ? uiView.frame.width : 250
        let size = uiView.sizeThatFits(CGSize(width: width, height: .infinity))
        let newHeight = min(size.height, maxHeight)
        
        if height != newHeight {
            DispatchQueue.main.async { height = newHeight }
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var height: CGFloat
        var maxHeight: CGFloat

        init(text: Binding<String>, height: Binding<CGFloat>, maxHeight: CGFloat) {
            _text = text
            _height = height
            self.maxHeight = maxHeight
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            
            // Proteção contra larguras zeradas
            let width = textView.frame.width > 0 ? textView.frame.width : 250
            let size = textView.sizeThatFits(CGSize(width: width, height: .infinity))
            let newHeight = min(size.height, maxHeight)
            
            if height != newHeight {
                DispatchQueue.main.async { self.height = newHeight }
            }
        }
    }
}

#Preview {
    AISheetView()
}
