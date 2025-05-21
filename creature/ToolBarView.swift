//
//  ToolBarView.swift
//  creature
//
//  Created by Nicholas Conant-Hiley on 5/20/25.
//

import SwiftUI

struct ToolBarView: View {
    @State private var showTools = false
    var feedAction: () -> Void
    @State private var feedCount = 0

    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    showTools.toggle()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .padding()
            }

            if showTools {
                HStack(spacing: 16) {
                    Button(action: {
                        if feedCount < 8 {
                            feedAction()
                            feedCount += 1
                        }
                    }) {
                        Image(systemName: "carrot.fill")
                            .font(.title)
                    }
                    .disabled(feedCount >= 8)
                    Button(action: { print("Clean") }) {
                        Image(systemName: "drop.fill")
                    }
                    Button(action: { print("Play") }) {
                        Image(systemName: "gamecontroller.fill")
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
                .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
            }

            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: showTools)
    }
}

#Preview {
    ToolBarView(feedAction: {})
}
