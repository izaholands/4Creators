import SwiftUI
import CoreData

struct NewPostView: View {
    @Binding var selectedTab: Int
    var postToEdit: Post? = nil

    @Environment(\.managedObjectContext) 
    private var context
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.presentationMode)
    private var presentationMode


    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Folder.createdAt,
                ascending: true
            )
        ]
    )
    private var folders: FetchedResults<Folder>

    // Campos do formulário
    @State private var titleText: String = ""
    @State private var briefingText: String = ""
    @State private var roteiroText: String = ""
    @State private var titleHeight: CGFloat = 24

    // Seleções
    @State private var selectedStatus: PostStatus = .not_posted
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var selectedPlatform: Plataform = .instagram
    @State private var selectedFolder: Folder? = nil

    // Toggles
    @State private var isBriefingEnabled: Bool = false
    @State private var isRoteiroEnabled: Bool = false

    // Modais
    @State private var showStatusSheet: Bool = false
    @State private var showPlatformSheet: Bool = false

    // Feedback
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let postService = PostService()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        if postToEdit != nil {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            selectedTab = 0
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Voltar")
                        }
                        .font(.body)
                        .foregroundColor(.indigo)
                    }
                    Spacer()
                    Text(postToEdit == nil ? "Criar postagem" : "Editar postagem")
                        .font(.headline)
                        .bold()
                    Spacer()
                    Text("Voltar").opacity(0).accessibilityHidden(true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Título
                        HStack(alignment: .top, spacing: 0) {
                            ZStack(alignment: .topLeading) {

                                if titleText.isEmpty {
                                    Text("Título")
                                        .foregroundColor(Color(.systemGray3))
                                        .font(.body)
                                        .padding(.top, 2)
                                }

                                MultilineTitleTextView(
                                    text: $titleText,
                                    height: $titleHeight,
                                    maxHeight: 60
                                )
                                .frame(
                                    height: max(
                                        24,
                                        min(titleHeight, 60)
                                    )
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer(minLength: 16)

                            Text("\(titleText.count)/50")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        // Formulário
                        VStack(spacing: 0) {

                            // Status
                            FormRow(
                                icon: selectedStatus == .posted ? "arrow.up.circle" : "arrow.down.circle",
                                iconColor: selectedStatus == .posted ? .green : .red,
                                title: "Status"
                            ) {
                                Menu {
                                    
                                    ForEach(PostStatus.allCases, id: \.self){ status in
                                        Button {
                                            selectedStatus = status
                                        } label: {
                                            HStack {
                                                Text(status.rawValue)
                                                
                                                if selectedStatus == status {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                            
                                        }
                                    }
                                } label: {
                                    HStack (spacing: 6){
                                        Text(selectedStatus.rawValue)
                                            .foregroundColor(Color(.systemGray))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    
                                }
                            }

                            Divider().padding(.leading, 52)

                            // Data
                            FormRow(icon: "calendar", iconColor: .indigo, title: "Data") {
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .environment(\.locale, Locale(identifier: "pt_BR"))
                            }

                            Divider().padding(.leading, 52)

                            // Hora
                            FormRow(icon: "clock", iconColor: .indigo, title: "Hora") {
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }

                            Divider().padding(.leading, 52)

                            // Plataforma
                            FormRow(icon: "play.square.stack.fill", iconColor: .indigo, title: "Plataforma") {
                                Menu {
                                    
                                    ForEach(Plataform.allCases, id: \.self){ plataform in
                                        Button {
                                            selectedPlatform = plataform
                                        } label : {
                                            HStack {
                                                Text(plataform.rawValue)
                                                
                                                if selectedPlatform == plataform {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                    
                                } label : {
                                    HStack(spacing: 6){
                                        Text(selectedPlatform.rawValue)
                                            .foregroundColor(Color(.systemGray))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(.systemGray))
                                    }
                                }
                            }
                            
                            Divider().padding(.leading, 52)

                            // Pasta — Menu nativo
                            FormRow(icon: "folder.fill", iconColor: .indigo, title: "Pasta") {
                                Menu {
                                    Button {
                                        selectedFolder = nil
                                    } label: {
                                        HStack {
                                            Text("Nenhuma")
                                            if selectedFolder == nil {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                    ForEach(folders) { folder in
                                        Button {
                                            selectedFolder = folder
                                        } label: {
                                            HStack {
                                                Text(folder.name ?? "Sem nome")
                                                if selectedFolder == folder {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(selectedFolder?.name ?? "Nenhuma")
                                            .foregroundColor(Color(.systemGray))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(.systemGray3))
                                    }
                                }
                            }
                        }
                        .background(Color.white)

                        // Briefing
                        VStack(spacing: 12) {
                            ToggleRow(title: "Briefing", isOn: $isBriefingEnabled)
                            if isBriefingEnabled {
                                ZStack(alignment: .topLeading) {
                                    if briefingText.isEmpty {
                                        Text("Digite algo...")
                                            .foregroundColor(Color(.systemGray3))
                                            .font(.body)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                    }
                                    iOS15CompatTextEditor(text: $briefingText).font(.body)
                                }
                                .frame(height: 140)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        // Roteiro
                        VStack(spacing: 12) {
                            ToggleRow(title: "Roteiro", isOn: $isRoteiroEnabled)
                            if isRoteiroEnabled {
                                ZStack(alignment: .topLeading) {
                                    if roteiroText.isEmpty {
                                        Text("Digite algo...")
                                            .foregroundColor(Color(.systemGray3))
                                            .font(.body)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                    }
                                    iOS15CompatTextEditor(text: $roteiroText).font(.body)
                                }
                                .frame(height: 140)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Botão Salvar
                Button {
                    if postToEdit == nil {
                        savePost()
                    } else {
                        updatePost()
                    }
                } label: {
                    Text("Salvar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(titleText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.indigo)
                        .cornerRadius(14)
                }
                .disabled(titleText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            // Sheets de seleção (mantém o visual original)
            if showStatusSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showStatusSheet = false } }
                VStack {
                    Spacer()
                    StatusSelectionView(currentStatus: $selectedStatus, isPresented: $showStatusSheet)
                        .frame(height: 250)
                        .background(Color.white)
                        .clipShape(CornerShape(radius: 24, corners: [.topLeft, .topRight]))
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }

            if showPlatformSheet {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showPlatformSheet = false } }
                VStack {
                    Spacer()
                    PlatformSelectionView(currentPlatform: $selectedPlatform, isPresented: $showPlatformSheet)
                        .frame(height: 460)
                        .background(Color.white)
                        .clipShape(CornerShape(radius: 24, corners: [.topLeft, .topRight]))
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(2)
            }
        }
        .alert("Erro ao salvar", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear{
            guard let post = postToEdit else { return }
               titleText = post.title ?? ""
               roteiroText = post.script ?? ""
               briefingText = post.briefing ?? ""
               selectedStatus = PostStatus(rawValue: post.status ?? "") ?? .not_posted
               selectedPlatform = Plataform(rawValue: post.plataform ?? "") ?? .instagram
               selectedFolder = post.folder

               if let date = post.publishDate {
                   selectedDate = date
                   selectedTime = date
               }

               isRoteiroEnabled = !(post.script ?? "").isEmpty
               isBriefingEnabled = !(post.briefing ?? "").isEmpty
        }
        .navigationBarHidden(true)
    }
    

    // MARK: - Save

    private func savePost() {
        let publishDate = combineDateAndTime(date: selectedDate, time: selectedTime)

        postService.createPost(
            title: titleText.trimmingCharacters(in: .whitespaces),
            script: isRoteiroEnabled ? roteiroText : "",
            plataform: selectedPlatform,
            status: selectedStatus,
            publishDate: publishDate,
            briefing: isBriefingEnabled ? briefingText : nil,
            folder: selectedFolder,
            context: context
        )

        do {
            try postService.save(context: context)
            selectedTab = 0
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute

        return calendar.date(from: combined) ?? date
    }
    
    private func updatePost(){
        
        guard let post = postToEdit else {return}
        let publishedDate = combineDateAndTime(date: selectedDate, time: selectedTime)
        
        postService.updatePost(
            post,
            title: titleText.trimmingCharacters(in: .whitespaces),
            script: isRoteiroEnabled ? roteiroText : "",
            plataform: selectedPlatform,
            status: selectedStatus,
            publishDate: publishedDate,
            briefing: isBriefingEnabled ? briefingText : "",
            folder: selectedFolder
        )
        
        
        do {
            
            try postService.save(context: context)
            presentationMode.wrappedValue.dismiss()
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
}

// MARK: - Componente de Título Multiline Dinâmico (iOS 15 Corrigido)
struct MultilineTitleTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var maxHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        tv.delegate = context.coordinator
        
        // Mantemos true para que o iOS respeite as margens horizontais e quebre as linhas
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.lineBreakMode = .byCharWrapping // Força quebra de linha por caractere
        
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tv.returnKeyType = .done
        
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
        let width = uiView.frame.width > 0 ? uiView.frame.width : 200
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
            // Impede quebras de linha manuais (Enter), mantendo apenas o wrap automático
            let filtered = textView.text.replacingOccurrences(of: "\n", with: "")
            
            if filtered.count > 50 {
                text = String(filtered.prefix(50))
                textView.text = text
            } else {
                text = filtered
            }
            
            let width = textView.frame.width > 0 ? textView.frame.width : 200
            let size = textView.sizeThatFits(CGSize(width: width, height: .infinity))
            let newHeight = min(size.height, maxHeight)
            
            if height != newHeight {
                DispatchQueue.main.async { self.height = newHeight }
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    }
}

struct StatusSelectionView: View {
    @Binding var currentStatus: PostStatus
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Status").font(.headline).bold().padding(.leading, 24)
                Spacer()
                Button { withAnimation { isPresented = false } } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(Color(.systemGray3)).font(.title3)
                }
            }
            .padding()

            VStack(spacing: 12) {
                ForEach(PostStatus.allCases, id: \.self) { status in
                    Button {
                        currentStatus = status
                        withAnimation { isPresented = false }
                    } label: {
                        HStack {
                            Image(systemName: status == .posted ? "arrow.up.circle" : "arrow.up.circle.dotted")
                                .foregroundColor(status == .posted ? .green : .red)
                                .font(.system(size: 18, weight: .medium))
                            Text(status.rawValue).foregroundColor(.primary)
                            Spacer()
                            if currentStatus == status {
                                Image(systemName: "checkmark").foregroundColor(.indigo)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}

struct PlatformSelectionView: View {
    @Binding var currentPlatform: Plataform
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Plataforma").font(.headline).bold().padding(.leading, 24)
                Spacer()
                Button { withAnimation { isPresented = false } } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(Color(.systemGray3)).font(.title3)
                }
            }
            .padding()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Plataform.allCases, id: \.self) { platform in
                        Button {
                            currentPlatform = platform
                            withAnimation { isPresented = false }
                        } label: {
                            HStack {
                                Text(platform.rawValue).foregroundColor(.primary).font(.body)
                                Spacer()
                                if currentPlatform == platform {
                                    Image(systemName: "checkmark").foregroundColor(.indigo)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
}

// MARK: - Componentes auxiliares

struct CornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct iOS15CompatTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text { uiView.text = text }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }
        func textViewDidChange(_ textView: UITextView) { text = textView.text }
    }
}

struct FormRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .medium))
            }
            Text(title).font(.body)
            Spacer()
            content()
        }
        .padding(.vertical, 12)
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title).font(.body).bold()
        }
        .padding(.vertical, 4)
        .tint(.indigo)
        .onChange(of: isOn) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {}
        }
    }
}
