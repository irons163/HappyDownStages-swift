//
//  MyScene+UI.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import SpriteKit

extension MyScene {

    // MARK: - UI Updates

    func initTimeNode() {
        let timeNodeSize = CGSize(width: 36, height: 36)
        let timeTextures = TextureHelper.timeTextures()
        let hasTimeImages = TextureHelper.timeImages().count >= 10
        guard timeTextures.count > 10 else {
            print("Error: Missing time textures")
            return
        }
        let adBottomY: CGFloat
        if let adView = myAdView {
            adBottomY = adView.position.y - adView.size.height
        } else {
            let topInset = view?.safeAreaInsets.top ?? 0
            adBottomY = sceneHeight - topInset
        }
        let yPos = adBottomY - timeNodeSize.height / 2 - 6 // Keep timer below ad bar
        let totalWidth = timeNodeSize.width * 5
        let startX = (sceneWidth - totalWidth) / 2 + timeNodeSize.width * 0.5

        timeMinuteTensDigital = SKSpriteNode(texture: timeTextures[0])
        timeMinuteTensDigital?.size = timeNodeSize
        timeMinuteTensDigital?.position = CGPoint(x: startX, y: yPos)

        timeMinuteSingalDigital = SKSpriteNode(texture: timeTextures[0])
        timeMinuteSingalDigital?.size = timeNodeSize
        timeMinuteSingalDigital?.position = CGPoint(x: timeMinuteTensDigital!.position.x + timeNodeSize.width, y: yPos)

        timeQmark = SKSpriteNode(texture: timeTextures[10]) // Colon texture
        timeQmark?.size = timeNodeSize
        timeQmark?.position = CGPoint(x: timeMinuteSingalDigital!.position.x + timeNodeSize.width, y: yPos)

        timeScecondTensDigital = SKSpriteNode(texture: timeTextures[0])
        timeScecondTensDigital?.size = timeNodeSize
        timeScecondTensDigital?.position = CGPoint(x: timeQmark!.position.x + timeNodeSize.width, y: yPos)

        timeSecondSingalDigital = SKSpriteNode(texture: timeTextures[0])
        timeSecondSingalDigital?.size = timeNodeSize
        timeSecondSingalDigital?.position = CGPoint(x: timeScecondTensDigital!.position.x + timeNodeSize.width, y: yPos)

        // Add nodes to scene
        [timeMinuteTensDigital, timeMinuteSingalDigital, timeQmark, timeScecondTensDigital, timeSecondSingalDigital].forEach { node in
            if let node = node {
                node.zPosition = 120
                addChild(node)
            }
        }

        // Fallback to label if image assets are missing
        if !hasTimeImages {
            setTimerFallbackVisible(true, yPos: yPos)
        }
    }

    func setTimeTextures() {
        let displayTime: Int
        if level < MyScene.infinityLevel {
            displayTime = max(0, MyScene.gameTime - state.gameTimerCount) // Countdown
        } else {
            displayTime = state.gameTimerCount // Count up for infinity mode
        }

        if TextureHelper.timeImages().count < 10 {
            setTimerFallbackVisible(true, yPos: timeMinuteTensDigital?.position.y ?? 0)
            gameTimerLabel?.text = formatTime(displayTime)
            return
        } else {
            setTimerFallbackVisible(false, yPos: 0)
        }

        // Update digital display nodes
        let minutes = displayTime / 60
        let seconds = displayTime % 60

        timeMinuteTensDigital?.texture = getTimeTexture(for: (minutes / 10) % 10)
        timeMinuteSingalDigital?.texture = getTimeTexture(for: minutes % 10)
        timeScecondTensDigital?.texture = getTimeTexture(for: seconds / 10)
        timeSecondSingalDigital?.texture = getTimeTexture(for: seconds % 10)
    }

    private func getTimeTexture(for digit: Int) -> SKTexture? {
        let textures = TextureHelper.timeTextures()
        guard digit >= 0 && digit <= 9 else {
            return textures.first // Return '0' texture or nil on error
        }
        return textures[digit]
    }

    private func setTimerFallbackVisible(_ isVisible: Bool, yPos: CGFloat) {
        gameTimerLabel?.isHidden = !isVisible
        if isVisible {
            gameTimerLabel?.fontSize = 22
            gameTimerLabel?.fontColor = .white
            gameTimerLabel?.zPosition = 121
            gameTimerLabel?.position = CGPoint(x: frame.midX, y: yPos)
        }
        [timeMinuteTensDigital, timeMinuteSingalDigital, timeQmark, timeScecondTensDigital, timeSecondSingalDigital].forEach { node in
            node?.isHidden = isVisible
        }
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func changeHpBar() {
        guard let lifeNode = lifeNode, let lifeBgNode = lifeBgNode else { return }

        let maxLife: CGFloat = CGFloat(MyScene.config.maxLife)
        let currentLife = CGFloat(max(0, state.life)) // Ensure life isn't negative

        // Calculate width based on life percentage
        let bgWidth: CGFloat = sceneWidth / 3.0 + 6 // Background slightly wider
        let maxFillWidth: CGFloat = sceneWidth / 3.0 // Max width of the fill part
        let hpBarWidth = maxFillWidth * (currentLife / maxLife)

        // Positioning (Top Right)
        let topInset = view?.safeAreaInsets.top ?? 0
        let adHeight = myAdView?.size.height ?? 0
        let yPos = sceneHeight - lifeNode.size.height / 2 - topInset - adHeight - 8 // Avoid status bar + ad
        let offsetX: CGFloat = 15 // Offset from the right edge

        // Set sizes
        lifeNode.size = CGSize(width: hpBarWidth, height: 26) // Height from Obj-C
        lifeBgNode.size = CGSize(width: bgWidth, height: 36) // Height from Obj-C

        // Set anchors (Left edge for fill, Center or Left for background)
        lifeNode.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor left-middle for width scaling
        lifeBgNode.anchorPoint = CGPoint(x: 1.0, y: 0.5) // Anchor right-middle for positioning

        // Set positions
        lifeBgNode.position = CGPoint(x: sceneWidth - offsetX, y: yPos)
        // Position lifeNode's left edge relative to the background's right edge (minus padding)
        lifeNode.position = CGPoint(x: lifeBgNode.position.x - lifeBgNode.size.width + 3, y: yPos) // +3 for padding inside bg

        lifeBgNode.zPosition = 48
        lifeNode.zPosition = 49 // Fill on top of background
    }

    func applyDamageFlash() {
        redFlashNode?.isHidden = false
        // Optional: Add a fade out action for the flash effect
        // redFlashNode?.run(SKAction.sequence([
        //     SKAction.fadeIn(withDuration: 0.05),
        //     SKAction.fadeOut(withDuration: 0.15)
        // ]))
    }
}
