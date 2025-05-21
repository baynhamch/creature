//
//  CreatureViewModel.swift
//  creature
//
//  Created by Nicholas Conant-Hiley on 5/20/25.
//

import Foundation
import SwiftUI

enum Emotion: String {
    case neutral
    case happy
    case sad
    case curious
    case afraid
    case playful
    case ennui
}

class CreatureViewModel: ObservableObject {
    @Published var position: CGPoint = CGPoint(x: 150, y: 300)
    @Published var emotion: Emotion = .curious
    @Published var secondaryEmotion: Emotion = .neutral
    @Published var sizeScale: CGFloat = 1.0
    @Published var age: Int = 0
    @Published var hunger: Int = 0
    @Published var relationshipToOwner: Int = 50  // 0 = hostile, 100 = bonded

    // Future: Personality & Memory System
    // Example traits: playfulness, sensitivity, trust, etc.
    // These will be influenced by interactions and time spent
    // var personalityTraits: [String: Float] = [:]

    var tankSize: CGSize = .zero
    private var roamTimer: Timer?
    private var tapTimestamps: [Date] = []
    private var fastRoamTimer: Timer?

    func updateTankSize(_ size: CGSize) {
        self.tankSize = size
    }

    func startRoamingIfNeeded() {
        guard emotion == .curious else {
            roamTimer?.invalidate()
            return
        }

        roamTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            self.moveRandomly()
        }
        startAging()
        startHunger()
    }

    private func moveRandomly() {
        guard emotion == .curious || emotion == .afraid else { return }
        let padding: CGFloat = 100
        let newX = CGFloat.random(in: padding...(tankSize.width - padding))
        let newY = CGFloat.random(in: padding...(tankSize.height - padding))

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 2.0)) {
                self.position = CGPoint(x: newX, y: newY)
            }
        }
    }

    func handleTap(at location: CGPoint) {
        let now = Date()
        tapTimestamps.append(now)
        tapTimestamps = tapTimestamps.filter { now.timeIntervalSince($0) <= 2 }

        if tapTimestamps.count >= 3 {
            // Rapid tapping: become afraid
            emotion = .afraid
            relationshipToOwner = max(0, relationshipToOwner - 5)
            fastRoamTimer?.invalidate()
            fastRoamTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.moveRandomly()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.emotion = .curious
                self.fastRoamTimer?.invalidate()
                self.startRoamingIfNeeded()
            }

            // Flee from touch
            flee(from: location)
        } else {
            // Single tap: become happy and hold position
            emotion = .happy
            relationshipToOwner = min(100, relationshipToOwner + 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.emotion = .curious
            }
        }
    }

    private func flee(from point: CGPoint) {
        let dx = position.x - point.x
        let dy = position.y - point.y
        let vector = CGPoint(x: dx * 1.5, y: dy * 1.5)

        let newX = min(max(position.x + vector.x, 100), tankSize.width - 100)
        let newY = min(max(position.y + vector.y, 100), tankSize.height - 100)

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.5)) {
                self.position = CGPoint(x: newX, y: newY)
            }
        }
    }
    private func startAging() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            DispatchQueue.main.async {
                self.age += 1
            }
        }
    }
    private func startHunger() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            DispatchQueue.main.async {
                self.hunger = min(self.hunger + 1, 100)
                // Visual feedback (slowing, greying) handled elsewhere if hunger > 75
            }
        }
    }

    func feed() {
        hunger = 0
        emotion = .happy
        roamTimer?.invalidate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.emotion = .curious
            self.startRoamingIfNeeded()
        }
    }
}
