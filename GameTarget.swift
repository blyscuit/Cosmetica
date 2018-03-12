//
//  Target.swift
//  Koloda
//
//  Created by Bliss Wetchaye on 2017-03-12.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
class GameTarget {
    var target: [Color: Int] = [:]
    var currentTarget: [Color: Int] = [:]
    var level = 1
    var score = 0
	var isMatchColor = false
    var goalForLevel: [[Int]] = [[1,1],[1,3],[1,4],[2,5],[2,6],[2,7],[4,6],[4,8],[2,9],[4,11], [4,15], [4,15], [1,15], [1,17], [4,17], [9,19], [1,20]]
    var chanceDivide: [[Int]] = [[3],[3,1],[4],[4,3],[5],
                                 [4,4],[6],[4,3,1],[6,4],[5,5],
                                 [5,2,2],[8],[6,6],[7,2],[3,3,6],
                                 [8,8],[6,5,4],[2,2,2,2],[4,4,4,4]]
    var possibleColor: [Color] = [Color.blue, Color.blue, Color.green, Color.yellow]
	
    init() {
        level = 1
        score = 0
		isMatchColor = false
    }
	
    func resetAll() {
        level = 1
        score = 0
		isMatchColor = false
        resetTozero()
    }
	
    func resetTozero() {
        target.removeAll()
        currentTarget.removeAll()
        possibleColor = [Color.blue, Color.blue, Color.green, Color.yellow]
    }
    
    func nextTarget(level: Int) {
        self.level = level
        if (level > goalForLevel.count) {
            self.level = goalForLevel.count
        }
        let goalPatternBound = goalForLevel[self.level-1]
        let distance = (goalPatternBound.last!) - (goalPatternBound.first!)
        let goalPattern = chanceDivide[Int(arc4random_uniform(UInt32(distance + goalPatternBound.first!)))]
        resetTozero()
        
        for number in goalPattern {
            let color = randomColor()
            currentTarget[color] = 0
            target[color] = number
        }
    }
    
    func randomColor() -> Color {
        let colorIndex = Int(arc4random_uniform(UInt32(possibleColor.count)))
        let color = possibleColor[colorIndex]
        possibleColor.remove(at: colorIndex)
        return color
    }
    
    func updateTarget(color: Color, number: Int) {
        if currentTarget[color] != nil {
            let before = currentTarget[color]!
			if before < target[color]! {
				isMatchColor = true
			}
            currentTarget[color]! += number
            if (before < target[color]! && currentTarget[color]! >= target[color]!) {
                score += 100 * target[color]!
            }
        }
        let count = target.count
        var i = 0
        for (color, number) in target {
            if let now = currentTarget[color] {
                if now >= number {
                    i += 1
                }
            }
        }
        if i == count {
            level += 1
            nextTarget(level: level)
        }
    }
    
    func getNowTargets() -> (target: [Color: Int], currentTarget: [Color: Int]) {
        return (target: self.target, currentTarget: self.currentTarget)
    }
    
    func getIndexOfColor(color: Color) -> Int? {
        // Get key array of Dictionary
        let keyArray = Array(target.keys)
        return keyArray.index(of: color)
    }
}
