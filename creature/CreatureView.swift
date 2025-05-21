//
//  CreatureView.swift
//  creature
//
//  Created by Nicholas Conant-Hiley on 5/20/25.
//

import SwiftUI

struct CreatureView: View {
    @StateObject private var viewModel = CreatureViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    ToolBarView(feedAction: {
                        viewModel.feed()
                    })
                    
                    Text("Emotion: \(viewModel.emotion.rawValue.capitalized)")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Age: \(viewModel.age)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    ProgressView("Hunger", value: Double(viewModel.hunger), total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .red))
                        .padding(.horizontal, 40)
                    Text("Relationship: \(viewModel.relationshipToOwner)/100")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(.bottom, 30)

                WobblyBlob(emotion: viewModel.emotion, hunger: viewModel.hunger, age: viewModel.age)
                    .frame(width: 220 * viewModel.sizeScale, height: 220 * viewModel.sizeScale)
                    .position(viewModel.position)
                    .opacity(viewModel.emotion == .afraid ? 0.6 : 1.0)
                    .scaleEffect(viewModel.emotion == .happy ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1), value: viewModel.emotion)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                viewModel.handleTap(at: value.location)
                            }
                    )
                    .onAppear {
                        viewModel.updateTankSize(geo.size)
                        viewModel.startRoamingIfNeeded()
                    }
            }
        }
    }
}

#Preview {
    CreatureView()
}
