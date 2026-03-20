//
//  FootboardSpawner.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import SpriteKit

final class FootboardSpawner {

    private weak var scene: MyScene?

    init(scene: MyScene) {
        self.scene = scene
    }

    func createFootboards(offsetY: CGFloat = 0) {
        guard let scene = scene else { return }
        guard MyScene.gameFlag else { return }
        guard !scene.currentXs.isEmpty else {
            print("Warning: currentXs is empty, cannot create new footboards.")
            // Maybe regenerate a default starting line?
            let initialX: CGFloat = scene.sceneWidth / 2 - scene.footboardWidth / 2
            scene.currentXs.append(initialX)
            // Potentially create a single board here if needed
            return
        }

        let previousXs = scene.currentXs // Copy the X positions from the last generated line
        var nextXs: [CGFloat] = [] // Store the X positions generated in this line
        var newFootboardsInLine: [Footboard] = [] // Store the footboards created in this line

        // Determine number of footboards to create (Max 2 per previous board)
        let maxNewBoardsPerSource = 2
        var boardsToCreateTotal = Int.random(in: 1...maxNewBoardsPerSource * previousXs.count)
        boardsToCreateTotal = min(boardsToCreateTotal, 2)

        var createdCount = 0
        for sourceX in previousXs {
            if createdCount >= boardsToCreateTotal { break }

            // How many to create from *this* sourceX (usually 1, maybe 2 if needed)
            let numToCreateFromThis = (boardsToCreateTotal - createdCount >= 2 && previousXs.count == 1) ? 2 : 1 // Try to create 2 if possible and only one source
            // let numToCreateFromThis = 1 // Simpler: always 1 from each source needed

            for _ in 0..<numToCreateFromThis {
                if createdCount >= boardsToCreateTotal { break }

                // Calculate horizontal offset (des in Obj-C)
                var randomOffset = CGFloat(Int.random(in: 7...20)) // 7-20 range from Obj-C logic
                randomOffset = (Int.random(in: 0...1) == 0) ? -randomOffset : randomOffset // Random direction
                randomOffset *= scene.distanceMultiple

                // Calculate new X position
                var newX = sourceX + randomOffset

                // Clamp X position within screen bounds, leaving space if creating two
                let minX: CGFloat = (numToCreateFromThis == 2) ? 0 : scene.minimumDistanceBetweenFootboards
                let maxX: CGFloat = (numToCreateFromThis == 2) ? scene.sceneWidth - scene.footboardWidth : scene.sceneWidth - scene.footboardWidth - scene.minimumDistanceBetweenFootboards

                newX = max(minX, newX) // Clamp minimum to 0
                newX = min(maxX, newX) // Clamp maximum

                // Avoid overlap if creating two from the same source or close sources
                if let lastX = nextXs.last {
                    // Ensure minimum distance
                    if (newX > lastX && newX < lastX + scene.footboardWidth + scene.minimumDistanceBetweenFootboards) ||
                        (newX < lastX && newX + scene.footboardWidth + scene.minimumDistanceBetweenFootboards > lastX) {
                        // Too close, try nudging it away or skipping
                        if newX > lastX {
                            newX = lastX + scene.footboardWidth + scene.minimumDistanceBetweenFootboards
                            if newX >= scene.sceneWidth - scene.footboardWidth {
                                newX = lastX - scene.footboardWidth - scene.minimumDistanceBetweenFootboards
                            }
                        } else {
                            newX = lastX - scene.footboardWidth - scene.minimumDistanceBetweenFootboards
                            if newX <= 0 {
                                newX = lastX + scene.footboardWidth + scene.minimumDistanceBetweenFootboards
                            }
                        }
                        // Re-clamp after nudge
                        newX = max(0, newX)
                        newX = min(scene.sceneWidth - scene.footboardWidth, newX)
                    }
                }

                // --- Create the actual Footboard ---
                // Spawn below the screen view
                let spawnY: CGFloat = offsetY - scene.footboardHeight // Adjust if anchor point is not (0,1)

                // Debug logging removed for performance

                let newBoard = scene.dequeueFootboard() // Reuse from pool when available
                newBoard.setFrame(x: newX, y: spawnY, h: scene.footboardHeight, w: scene.footboardWidth) // Use the Footboard's method
                newBoard.anchorPoint = CGPoint(x: 0, y: 1) // Match Obj-C
                newBoard.position = CGPoint(x: newX, y: spawnY) // Set position

                // Randomly assign type (conveyor, spikes, etc.) or tool
                // newBoard.setWhich(...) // Add logic for different types
                // newBoard.setToolNum(...) // Add logic for tools (bomb, cure)

                newFootboardsInLine.append(newBoard)
                nextXs.append(newX)
                scene.addChild(newBoard) // Add to the scene

                createdCount += 1
            } // end loop for creating 1 or 2 from sourceX
        } // end loop through previousXs

        // --- Cleanup and Update State ---
        if !newFootboardsInLine.isEmpty {
            scene.footboards.append(newFootboardsInLine) // Add the new line of boards
            scene.currentXs = nextXs // Update the reference X positions for the *next* generation
        } else if !previousXs.isEmpty && nextXs.isEmpty {
            // Failsafe: If we couldn't generate any new boards but had sources,
            // reuse the previous X positions to avoid getting stuck.
            scene.currentXs = previousXs
            print("Warning: Failed to generate new footboards, reusing previous X positions.")
        }

        // Remove old footboard lines that are way off-screen (optional optimization)
        if scene.footboards.count > 20 { // Example limit
            let lineToRemove = scene.footboards.removeFirst()
            lineToRemove.forEach { $0.removeFromParent() }
        }
    }
}
