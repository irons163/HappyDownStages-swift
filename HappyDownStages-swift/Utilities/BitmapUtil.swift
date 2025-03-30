//
//  BitmapUtil.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit
import UIKit

class BitmapUtil {

    static let shared = BitmapUtil()

    let PLAYER_WIDTH_PERSENT: CGFloat = 2.5
    let TOOL_WIDTH_PERSENT: Int = 4
    let FIREBALL_WIDTH_PERSENT: CGFloat = 3

    var sreenWidth: CGFloat = 300
    var sreenHeight: CGFloat = 600

    // Girl player textures
    var player_girl_left01_bitmap: SKTexture!
    var player_girl_left02_bitmap: SKTexture!
    var player_girl_left03_bitmap: SKTexture!
    var player_girl_right01_bitmap: SKTexture!
    var player_girl_right02_bitmap: SKTexture!
    var player_girl_right03_bitmap: SKTexture!
    var player_girl_injure_left_bitmap: SKTexture!
    var player_girl_injure_right_bitmap: SKTexture!
    var player_girl_down_left_bitmap: SKTexture!
    var player_girl_down_right_bitmap: SKTexture!

    // Boy player textures
    var player_boy_left01_bitmap: SKTexture!
    var player_boy_left02_bitmap: SKTexture!
    var player_boy_left03_bitmap: SKTexture!
    var player_boy_right01_bitmap: SKTexture!
    var player_boy_right02_bitmap: SKTexture!
    var player_boy_right03_bitmap: SKTexture!
    var player_boy_injure_left_bitmap: SKTexture!
    var player_boy_injure_right_bitmap: SKTexture!
    var player_boy_down_left_bitmap: SKTexture!
    var player_boy_down_right_bitmap: SKTexture!

    // Footboards
    var footboard_normal_bitmap: SKTexture!
    var footboard_moving_left1_bitmap: SKTexture!
    var footboard_moving_left2_bitmap: SKTexture!
    var footboard_moving_left3_bitmap: SKTexture!
    var footboard_moving_right1_bitmap: SKTexture!
    var footboard_moving_right2_bitmap: SKTexture!
    var footboard_moving_right3_bitmap: SKTexture!
    var footboard_unstable1_bitmap: SKTexture!
    var footboard_unstable2_bitmap: SKTexture!
    var footboard_unstable3_bitmap: SKTexture!
    var footboard_spring_bitmap: SKTexture!
    var footboard_spiked_bitmap: SKTexture!
    var footboard_wood_bitmap: SKTexture!
    var footboard_wood2_bitmap: SKTexture!
    var footboard_wood3_bitmap: SKTexture!

    // Tools
    var tool_bomb_bitmap: SKTexture!
    var toll_cure_bitmap: SKTexture!
    var tool_bomb_explosion_bitmap: SKTexture!
    var toll_eat_man_tree_bitmap: SKTexture!
    var toll_eat_man_tree2_bitmap: SKTexture!
    var toll_eat_man_tree3_bitmap: SKTexture!

    // Fireball
    var fire_ball: SKTexture!
    var fire_ball_size: CGSize!

    // Sizes
    var player_girl_left01_size: CGSize!
    var player_girl_left02_size: CGSize!
    var player_girl_left03_size: CGSize!
    var player_girl_right01_size: CGSize!
    var player_girl_right02_size: CGSize!
    var player_girl_right03_size: CGSize!
    var player_girl_injure_left_size: CGSize!
    var player_girl_injure_right_size: CGSize!
    var player_girl_down_left_size: CGSize!
    var player_girl_down_right_size: CGSize!
    var player_boy_left01_size: CGSize!
    var player_boy_left02_size: CGSize!
    var player_boy_left03_size: CGSize!
    var player_boy_right01_size: CGSize!
    var player_boy_right02_size: CGSize!
    var player_boy_right03_size: CGSize!
    var player_boy_injure_left_size: CGSize!
    var player_boy_injure_right_size: CGSize!
    var player_boy_down_left_size: CGSize!
    var player_boy_down_right_size: CGSize!

    var numberImageArray: [UIImage] = []

    private init() {
        let footbarWidth = sreenWidth / MyScene.footboardWidthPercent
        let playerWidth = CGFloat(footbarWidth) / PLAYER_WIDTH_PERSENT
        let fireballWidth = footbarWidth / FIREBALL_WIDTH_PERSENT

        func sizeFor(texture: SKTexture, width: CGFloat) -> CGSize {
            let ratio = texture.size().height / texture.size().width
            return CGSize(width: width, height: ratio * width)
        }

        // Load textures
        func tex(_ name: String) -> SKTexture {
            return SKTexture(imageNamed: name)
        }

        // Player girl
        player_girl_left01_bitmap = tex("player_girl_left01")
        player_girl_left02_bitmap = tex("player_girl_left02")
        player_girl_left03_bitmap = tex("player_girl_left03")
        player_girl_right01_bitmap = tex("player_girl_right01")
        player_girl_right02_bitmap = tex("player_girl_right02")
        player_girl_right03_bitmap = tex("player_girl_right03")
        player_girl_injure_left_bitmap = tex("player_girl_injure_left")
        player_girl_injure_right_bitmap = tex("player_girl_injure_right")
        player_girl_down_left_bitmap = tex("player_girl_down_left")
        player_girl_down_right_bitmap = tex("player_girl_down_right")

        // Sizes
        player_girl_left01_size = sizeFor(texture: player_girl_left01_bitmap, width: playerWidth)
        player_girl_left02_size = sizeFor(texture: player_girl_left02_bitmap, width: playerWidth)
        player_girl_left03_size = sizeFor(texture: player_girl_left03_bitmap, width: playerWidth)
        player_girl_right01_size = sizeFor(texture: player_girl_right01_bitmap, width: playerWidth)
        player_girl_right02_size = sizeFor(texture: player_girl_right02_bitmap, width: playerWidth)
        player_girl_right03_size = sizeFor(texture: player_girl_right03_bitmap, width: playerWidth)
        player_girl_injure_left_size = sizeFor(texture: player_girl_injure_left_bitmap, width: playerWidth)
        player_girl_injure_right_size = sizeFor(texture: player_girl_injure_right_bitmap, width: playerWidth)
        player_girl_down_left_size = sizeFor(texture: player_girl_down_left_bitmap, width: playerWidth)
        player_girl_down_right_size = sizeFor(texture: player_girl_down_right_bitmap, width: playerWidth)

        // Player boy
        player_boy_left01_bitmap = tex("player_boy_walk01")
        player_boy_left02_bitmap = tex("player_boy_walk02")
        player_boy_left03_bitmap = tex("player_boy_walk03")
        player_boy_right01_bitmap = tex("player_boy_right01")
        player_boy_right02_bitmap = tex("player_boy_right02")
        player_boy_right03_bitmap = tex("player_boy_right03")
        player_boy_injure_left_bitmap = tex("player_boy_injure_left")
        player_boy_injure_right_bitmap = tex("player_boy_injure_right")
        player_boy_down_left_bitmap = tex("player_boy_down_left")
        player_boy_down_right_bitmap = tex("player_boy_down_right")

        player_boy_left01_size = sizeFor(texture: player_boy_left01_bitmap, width: playerWidth)
        player_boy_left02_size = sizeFor(texture: player_boy_left02_bitmap, width: playerWidth)
        player_boy_left03_size = sizeFor(texture: player_boy_left03_bitmap, width: playerWidth)
        player_boy_right01_size = sizeFor(texture: player_boy_right01_bitmap, width: playerWidth)
        player_boy_right02_size = sizeFor(texture: player_boy_right02_bitmap, width: playerWidth)
        player_boy_right03_size = sizeFor(texture: player_boy_right03_bitmap, width: playerWidth)
        player_boy_injure_left_size = sizeFor(texture: player_boy_injure_left_bitmap, width: playerWidth)
        player_boy_injure_right_size = sizeFor(texture: player_boy_injure_right_bitmap, width: playerWidth)
        player_boy_down_left_size = sizeFor(texture: player_boy_down_left_bitmap, width: playerWidth)
        player_boy_down_right_size = sizeFor(texture: player_boy_down_right_bitmap, width: playerWidth)

        // Footboards
        footboard_normal_bitmap = tex("footboard_normal")
        footboard_moving_left1_bitmap = tex("footboard_moving_left1")
        footboard_moving_left2_bitmap = tex("footboard_moving_left2")
        footboard_moving_left3_bitmap = tex("footboard_moving_left3")
        footboard_moving_right1_bitmap = tex("footboard_moving_right1")
        footboard_moving_right2_bitmap = tex("footboard_moving_right2")
        footboard_moving_right3_bitmap = tex("footboard_moving_right3")
        footboard_unstable1_bitmap = tex("footboard_unstable1")
        footboard_unstable2_bitmap = tex("footboard_unstable2")
        footboard_unstable3_bitmap = tex("footboard_unstable3")
        footboard_spring_bitmap = tex("footboard_spring")
        footboard_spiked_bitmap = tex("footboard_spiked")
        footboard_wood_bitmap = tex("footboard_wood")
        footboard_wood2_bitmap = tex("footboard_wood2")
        footboard_wood3_bitmap = tex("footboard_wood3")

        // Tools
        tool_bomb_bitmap = tex("bomb")
        tool_bomb_explosion_bitmap = tex("bomb_explosion")
        toll_cure_bitmap = tex("cure")
        toll_eat_man_tree_bitmap = tex("eat_human_tree")
        toll_eat_man_tree2_bitmap = tex("eat_human_tree01")
        toll_eat_man_tree3_bitmap = tex("eat_human_tree02")

        // Fireball
        fire_ball = tex("fireball")
        fire_ball_size = sizeFor(texture: fire_ball, width: fireballWidth)

        // Number images
        numberImageArray = (0...9).compactMap { UIImage(named: "s\($0)") }
    }

    func getNumberImage(_ number: Int) -> UIImage? {
        guard (0..<numberImageArray.count).contains(number) else { return nil }
        return numberImageArray[number]
    }
}
