//
//  Game.swift
//  
//
//  Created by Bliss Watchaye on 2017-03-10.
//
//

import Foundation
private let DrawStart = 15
protocol GameDelegate {
    func gameDidDraw(number: Int)
    func gameDidDrawAndPlay(number: Int)
    func gameDidClearGoal(index: Int)
    func gameDidPlayCard(index: Int)
    func gameDidGameOver(score: Int)
    func gameDidScoreChange(score: Int)
    func gameDidEndTurn(match: Bool)
    func gameDidMatch()
    func gameDidNewTarget(target: [Color: Int], currentTarget: [Color: Int])
}
class Game {
	var drawDeck = DrawDeck()
	var playDeck = Deck()
	var shufflingDeck = DiscardDeck()
	var isMatchedThisTurn = false
	var matchGauge: [Card] = []
    var gameTarget = GameTarget()
    var delegate: GameDelegate?
    var cardsToPlay = 0
    var cardsToSkip = 0
    var messageArray = ["Game Over"]
	
	init() {
		
	}
	
	func newGame() {
        cardsToPlay = 0
        cardsToSkip = 0
		isMatchedThisTurn = false
		drawDeck = DrawDeck()
		drawDeck.createNewDeck()
		playDeck = Deck()
        
        gameTarget.resetAll()
        newTarget()
        
		shufflingDeck = DiscardDeck()
		for i in 0 ..< DrawStart {
			playDeck.insertRandomly(card: drawDeck.draw()!)
		}
		
	}
    
    func newTarget() {
        gameTarget.nextTarget(level: gameTarget.level)
        delegate?.gameDidNewTarget(target: gameTarget.target, currentTarget: gameTarget.currentTarget)
    }
	
    func drawCardToTop() {
        if drawDeck.isDeckEmpty() {
            delegate?.gameDidGameOver(score: gameTarget.score)
        } else {
            playDeck.insertToTop(card: drawDeck.draw()!)
        }
	}
	
	func playToShuffleDeck() {
        cardsToPlay -= 1
        if(cardsToPlay < 0) {
            cardsToPlay = 0
        }
		shufflingDeck.insertToTop(card: playDeck.draw()!)
		checkAfterPlayedCard()
	}
	
//	func drawToShuffleDeck() {
//		shufflingDeck.insertToTop(card: drawDeck.draw()!)
//		checkAfterPlayedCard()
//    }
    
    func checkAfterPlayedCard() {
        if cardsToSkip <= 0 {
            if let c = matchGauge.first {
                if let cc = shufflingDeck.cards.first {
                    if c.getCurrentColor() == cc.getCurrentColor() {
                        matchGauge.append(cc)
                    } else {
                        matchGauge.removeAll()
                        matchGauge.append(cc)
                    }
                }
                if matchGauge.count == 3 {
                    isMatchedThisTurn = true
                    var sum = 0
                    for card in matchGauge {
                        sum += card.getCurrentPoint()
                    }
                    delegate?.gameDidMatch()
                    if let c = matchGauge.last {
                        if let index = gameTarget.getIndexOfColor(color: c.getCurrentColor()) {
                            delegate?.gameDidClearGoal(index: index)
                        }
                        gameTarget.updateTarget(color: c.getCurrentColor(), number: sum)
                        delegate?.gameDidScoreChange(score: gameTarget.score)
                        delegate?.gameDidNewTarget(target: gameTarget.target, currentTarget: gameTarget.currentTarget)
                    }
                    
                    for i in 0 ..< 2 {
//                        delegate?.gameDidPlayCard(index: matchGauge.count-1)
                        matchGauge.removeLast()
                    }
                    for i in 0 ..< 3 {
                        drawCardToTop()
                    }
                    cardsToPlay += 3
                    cardsToSkip += 3
                    delegate?.gameDidDrawAndPlay(number: cardsToPlay)
                }
            } else {
                matchGauge.append(shufflingDeck.cards.first!)
            }
            if let cs = shufflingDeck.cards.first {
                if cs.getCurrentDraw() > 0 {
                    for i in 0 ..< cs.getCurrentDraw() {
                        drawCardToTop()
                    }
                    cardsToPlay += cs.getCurrentDraw()
                    delegate?.gameDidDrawAndPlay(number: cs.getCurrentDraw())
                }
            }
            delegate?.gameDidPlayCard(index: matchGauge.count-1)
        } else {
            cardsToSkip -= 1
            if cardsToSkip < 0 {
                cardsToSkip = 0
            }
            delegate?.gameDidDraw(number: 1)
        }
        
        if playDeck.isDeckEmpty() {
            shuffleIntoPlayDeck()
        }
	}
	
	func playToDiscard() {
		playDeck.flipTopCard()
		drawDeck.insertToMiddle(card: playDeck.draw()!)
        
        if playDeck.isDeckEmpty() {
            shuffleIntoPlayDeck()
        }
	}
	
    func shuffleIntoPlayDeck() {
        if shufflingDeck.isDeckEmpty() {
            delegate?.gameDidGameOver(score: gameTarget.score)
            return
        }
		if gameTarget.isMatchColor == false {
//        if isMatchedThisTurn == false {
            delegate?.gameDidEndTurn(match: false)
			return
		}
		gameTarget.isMatchColor = false
		startNewTurn()
	}
    
    func startNewTurn() {
        isMatchedThisTurn = false
        playDeck.takeAllCardsFromDeck(deck: shufflingDeck)
        shufflingDeck.emptyDeck()
        playDeck.shuffle()
        matchGauge.removeAll()
        
        if playDeck.isDeckEmpty() {
            delegate?.gameDidGameOver(score: gameTarget.score)
            return
        }
        delegate?.gameDidEndTurn(match: true)
    }
	
    func chooseToDiscardOne() {
        discardShuffleToDraw()
        startNewTurn()
    }
    
    func chooseToDiscardThree() {
        if drawDeck.cards.count < 2 {
            delegate?.gameDidGameOver(score: gameTarget.score)
            return
        } else {
            shufflingDeck.insertToTop(card: drawDeck.draw()!)
            shufflingDeck.insertToTop(card: drawDeck.draw()!)
        }
        discardShuffleToDraw()
        discardShuffleToDraw()
        discardShuffleToDraw()
        if (shufflingDeck.isDeckEmpty()) {
            delegate?.gameDidGameOver(score: gameTarget.score)
            return
        }
        startNewTurn()
    }
    
	func isGameOver() -> Bool {
		if (playDeck.cards.count <= 0 || drawDeck.cards.count <= 0) {
			return true
		}
		return false
	}
	
	func discardShuffleToDraw() {
		if let c = shufflingDeck.randomDiscard() {
			drawDeck.insertRandomly(card: c)
		}
	}
}

class Deck {
	var cards: [Card] = []
	
	init() {
		
	}
	
	func insertToMiddle(card:Card) {
		let midIndex: Int = cards.count/2
		cards.insert(card, at: midIndex)
	}
	
	func draw() -> Card? {
		if let card = cards.first {
			cards.removeFirst()
			return card
		}
		return nil
	}
	
	func insertRandomly(card: Card) {
		let index = Int(arc4random_uniform(UInt32(cards.count)))
		cards.insert(card, at: index)
	}
	
	func isDeckEmpty() -> Bool {
		if cards.count<=0 {
			return true
		}
		return false
	}
	
	func insertToTop(card: Card) {
		cards.insert(card, at: 0)
	}
	
	func shuffle() {
		cards.shuffle()
	}
	
	func flipTopCard() {
		if let card = cards.first {
			card.isBackSide = !card.isBackSide
		}
	}
	
	func randomDiscard() -> Card? {
		if cards.count <= 0 {
			return nil
		}
		let index = Int(arc4random_uniform(UInt32(cards.count)))
		if let card:Card? = cards[index] {
			cards.remove(at: index)
			return card
		}
		return nil
	}
	
	func emptyDeck() {
		cards = []
	}
	
	func takeAllCardsFromDeck(deck: Deck) {
		cards.append(contentsOf: deck.cards)
	}
}

public enum CardScore: Int {
	case Draw2 = 0, Draw4, Zero, One, Two, Three
}
class DrawDeck: Deck {
	var deckScoreTemplate: [[Int]] = [[0, 0, 3, 4, 3, 2], [0, 0, 3, 4, 3, 2], [1, 0, 3, 4, 3, 2], [1, 0, 3, 4, 3, 2], [0, 1, 0, 0, 0, 0]]
	var deckBackScoreTemplate: [[Int]] = [[1, 0, 3, 4, 3, 2], [1, 0, 3, 4, 3, 2], [0, 0, 3, 4, 3, 2], [0, 0, 3, 4, 3, 2], [0, 1, 0, 0, 0, 0]]

//	let deck
	func createNewDeck() {
		var sum = 0
		for array in deckScoreTemplate {
			for count in array {
				sum += count
			}
		}
		var colorIn = [Color.green, Color.red, Color.blue, Color.yellow]
		colorIn.shuffle()
		colorIn.append(Color.black)
		while sum != 0 {
			let color = Int(arc4random_uniform(UInt32(deckScoreTemplate.count)))
			let score = Int(arc4random_uniform(UInt32(deckScoreTemplate[color].count)))
			let backColor = Int(arc4random_uniform(UInt32(deckBackScoreTemplate.count)))
			let backScore = Int(arc4random_uniform(UInt32(deckBackScoreTemplate[backColor].count)))
			
			if deckScoreTemplate[color][score] > 0 && deckBackScoreTemplate[backColor][backScore] > 0 {
				let cColor = colorIn[color]
				let cScore = CardScore(rawValue: score)
				let cBackScore = CardScore(rawValue: backScore)
				let cBackColor = colorIn[backColor]
				let c = Card(color: cColor, point: cScore, backColor: cBackColor, backPoint: cBackScore)
				deckScoreTemplate[color][score] = deckScoreTemplate[color][score]-1
				deckBackScoreTemplate[backColor][backScore] = deckBackScoreTemplate[backColor][backScore]-1
				sum -= 1
				self.insertToMiddle(card: c)
			}
		}
	}
}

class DiscardDeck: Deck {
    func arrayOfHistory() -> [(Color, Int)] {
        var dic: [Color:Int] = [:]
        for color in iterateEnum(Color) {
            dic[color] = 0
        }
        for c in cards {
            if dic[c.getCurrentColor()] != nil {
                dic[c.getCurrentColor()]! += 1
            } else {
                dic[c.getCurrentColor()] = 1
            }
        }
        
        var rDic:  [(Color, Int)] = []
        var i = 0
        while rDic.count != dic.count {
            if i < cards.count {
                if let num = dic[cards[i].getCurrentColor()] {
                    let t = (cards[i].getCurrentColor(),num)
                    var notContain = true
                    for (c,n) in rDic {
                        if c == t.0 {
                            notContain = false
                            break
                        }
                    }
                    if notContain {
                        rDic.append(t)
                    }
                }
            } else {
                break
            }
            i += 1
        }
        return rDic
    }
}

extension Array {
	mutating func shuffle() {
		for _ in 0..<((count>0) ? (count-1) : 0) {
			sort { (_,_) in arc4random() < arc4random() }
		}
	}
}
func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
