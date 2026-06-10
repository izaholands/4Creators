//
//  ProjectsView.swift
//  Creators
//
//  Created by academy on 09/06/26.
//

import SwiftUI

struct ProjectsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundColor(Color(.systemGray3))
            Text("Projetos")
                .font(.title2.bold())
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ProjectsView()
}
