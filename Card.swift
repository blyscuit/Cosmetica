//
//  Card.swift
//  Koloda
//
//  Created by Bliss Watchaye on 2017-03-10.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
public enum Color: Int {
	case green = 0, yellow, blue, red, black
}
class Card {
	
	var color: Color = Color.green;
	var point: Int = 0
	var backColor: Color = Color.red
	var backPoint: Int = 0
	var isBackSide = false
	var draw = 0
	var backDraw = 0
	
	init() {
		
	}
	init(color: Color? = Color.green, point: Int? = 0, backColor: Color? = Color.red, backPoint: Int? = 0, draw: Int? = 0, backDraw: Int? = 0) {
		self.color = color!
		self.point = point!
		self.backColor = backColor!
		self.backPoint = backPoint!
		self.draw = draw!
		self.backDraw = backDraw!
	}
	init(color: Color? = Color.green, point: CardScore? = CardScore.Zero, backColor: Color? = Color.red, backPoint: CardScore? = CardScore.Zero) {
		self.color = color!
		if let point = point {
			switch point {
			case CardScore.Zero:
				self.point = 0
				self.draw = 0
			case CardScore.One:
				self.point = 1
				self.draw = 0
			case CardScore.Two:
				self.point = 2
				self.draw = 0
			case CardScore.Three:
				self.point = 3
				self.draw = 0
			case CardScore.Draw2:
				self.point = 0
				self.draw = 2
			case CardScore.Draw4:
				self.point = 0
				self.draw = 3
			default:
				self.point = 0
				self.draw = 0
			}
		}
		if let backPoint = backPoint {
			switch backPoint {
			case CardScore.Zero:
				self.backPoint = 0
				self.backDraw = 0
			case CardScore.One:
				self.backPoint = 1
				self.backDraw = 0
			case CardScore.Two:
				self.backPoint = 2
				self.backDraw = 0
			case CardScore.Three:
				self.backPoint = 3
				self.backDraw = 0
			case CardScore.Draw2:
				self.backPoint = 0
				self.backDraw = 2
			case CardScore.Draw4:
				self.backPoint = 0
				self.backDraw = 3
			default:
				self.backPoint = 0
				self.backDraw = 0
			}
		}
		if let backColor = backColor {
			self.backColor = backColor
		}
		if let color = color {
			self.color = color
		}
	}
	
	func getCurrentColor() -> Color {
		if isBackSide {
			return backColor
		}
		return color
	}
	
	func getCurrentPoint() -> Int {
		if isBackSide {
			return backPoint
		}
		return point
	}
	
	func getCurrentDraw() -> Int {
		if isBackSide {
			return backDraw
		}
		return draw
	}
	
	func getBackColor() -> Color {
		if isBackSide {
			return color
		}
		return backColor
	}
}
