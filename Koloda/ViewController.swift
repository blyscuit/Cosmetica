//
//  ViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 4/23/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////				THIS IS THE CORRECT PAGE OF GAME					//////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
import UIKit
import Koloda
import SpriteKit
import GoogleMobileAds
import Spring
import FirebaseRemoteConfig

private let kolodaCountOfVisibleCards = 3
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.9

class ViewController: UIViewController {
	
    @IBOutlet weak var kolodaView: KolodaView!
	@IBOutlet weak var deckLabel: SpringLabel!
	@IBOutlet weak var goal1Label: SpringLabel!
	@IBOutlet weak var goal2Label: SpringLabel!
	@IBOutlet weak var goal3Label: SpringLabel!
	@IBOutlet weak var goal4Label: SpringLabel!
	@IBOutlet weak var goal1Color: UIView!
	@IBOutlet weak var goal2Color: UIView!
	@IBOutlet weak var goal3Color: UIView!
	@IBOutlet weak var goal4Color: UIView!
	@IBOutlet weak var drawLabel: SpringLabel!
	@IBOutlet weak var keepLabel: SpringLabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var match1Color: UIView!
	@IBOutlet weak var match2Color: UIView!
	@IBOutlet weak var match3Color: UIView!
	@IBOutlet weak var historyTable: UITableView!
	@IBOutlet weak var match1Label: UILabel!
	@IBOutlet weak var match2Label: UILabel!
	@IBOutlet weak var match3Label: UILabel!
    @IBOutlet weak var hHourImage: UIImageView!
    @IBOutlet weak var hMinuteImage: UIImageView!
    @IBOutlet weak var tutorialButton: UIButton!
	
	let startBirthRate = 14
	var timer: Timer!
	var scoreTimer: Timer!
    var score = 0
	var game = Game()
	var handDeck: [Card] = []
    var historyArray: [(Color,Int)] = []
    var overMessage = "Game Over"
    var welcomeMessage = "Flip \nFlap \nShift \nDrop"
    var gameState = GameState.welcoming
    var hiScore = 0
    var particle2: SKEmitterNode!
    var particle3: SKEmitterNode!
    let tutorialArray = ["Tutorial0","Tutorial1","Tutorial2","Tutorial3"]
	
	var interstitial: GADInterstitial!

    var shouldShowAds = false
	
    enum GameState: Int {
        case playing, shuffling, scoreViewing, welcoming, tutorial
    }
	
//    fileprivate var dataSource: [UIImage] = {
//        var array: [UIImage] = []
//        for index in 0..<numberOfCards {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
//        
//        return array
//    }()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        getRemoteConfigure()
		
		print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion() + ",,,")
		interstitial = createAndLoadInterstitial()
		
		kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
//		kolodaView.alphaValueTransparent = 0.01
		kolodaView.alphaValueOpaque = 1.0
		kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        game.delegate = self
		
		roundViews()
		resetViews()
        hideEverythingLoad()
//		newGameCall()
        
        historyTable.dataSource = self
        historyTable.allowsSelection = false
//        view.backgroundColor = UIColor.black
        
        if let particles = SKEmitterNode(fileNamed: "SmokeParticle.sks") {
            let skView:SKView = SKView(frame: view.frame)
//			skView.backgroundColor = .clear
			skView.allowsTransparency = true;
            let skScene:SKScene = SKScene(size: skView.frame.size);
            skScene.scaleMode = .aspectFill;
            skScene.backgroundColor = .clear
            particle2 = SKEmitterNode(fileNamed: "SmokeParticle.sks")
			particle2.position = CGPoint(x: view.frame.width-(match2Color.frame.origin.x + match2Color.frame.size.width  / 2),
			                             y: view.frame.height-(match2Color.frame.origin.y))
            skScene.addChild(particle2)
            skView.presentScene(skScene)
			particle3 = SKEmitterNode(fileNamed: "SmokeParticle.sks")
			particle3.position = CGPoint(x: match3Color.frame.origin.x + match3Color.frame.size.width  / 2,
			                             y: view.frame.height-(match3Color.frame.origin.y))
			skScene.addChild(particle3)
			particle2.particleColorSequence = nil;
			particle2.particleColorBlendFactor = 1.0;
			particle3.particleColorSequence = nil;
			particle3.particleColorBlendFactor = 1.0;
			particle2.particleBirthRate = 0.0
			particle3.particleBirthRate = 0.0
			view.insertSubview(skView, aboveSubview: match3Color)
		}
		let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(decreaseBirthRate), userInfo: nil, repeats: true)
    }
	
    @objc func decreaseBirthRate() {
		if particle2.particleBirthRate <= 0 && particle3.particleBirthRate <= 0 {
			return
		}
		particle2.particleBirthRate -= 1.0
		particle3.particleBirthRate -= 1.0
	}
	
	func birthRateGo(color: UIColor) {
		particle2.particleColor = color
		particle3.particleColor = color
		particle2.particleBirthRate = CGFloat(startBirthRate)
		particle3.particleBirthRate = CGFloat(startBirthRate + 10)
	}
	
	func hideEverythingLoad() {
		kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
		self.view.isUserInteractionEnabled = true
		incrementText(view: deckLabel, from: 0, to: 51)
		let userDefaults = UserDefaults.standard
		if let highscore = userDefaults.value(forKey: "highscore") as? Int {
            // do something here when a highscore exists
            self.hiScore = highscore
			if shouldShowAds && interstitial.isReady {
				interstitial.present(fromRootViewController: self)
			} else {
				print("Ad wasn't ready")
			}
        }
        else {
            // no highscore exists
            
        }
		
        incrementText(view: scoreLabel, from: score, to: hiScore, text: "Hi-Score : ")
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
            self.goal1Color.alpha = 0
            self.goal2Color.alpha = 0
            self.goal3Color.alpha = 0
            self.goal4Color.alpha = 0
            self.goal1Label.alpha = 0
            self.goal2Label.alpha = 0
            self.goal3Label.alpha = 0
            self.goal4Label.alpha = 0
            self.match1Color.alpha = 0
            self.match2Color.alpha = 0
            self.match3Color.alpha = 0
            self.match1Label.alpha = 0
            self.match2Label.alpha = 0
            self.match3Label.alpha = 0
            self.drawLabel.alpha = 0
            self.keepLabel.alpha = 0
            self.hHourImage.alpha = 0
            self.hMinuteImage.alpha = 0
            self.tutorialButton.alpha = 1
        }, completion: { finished in
        })
    }
    
    func newGameCall() {
        unHideEverything()
        roundViews()
        game.newGame()
		handDeck.removeAll()
        handDeck.append(contentsOf: game.playDeck.cards)
        resetViews()
        updateDeckView()
//        delayedCardSelect2()
    }
    
    ///////////////
    ///////////////
    // this is BOT #1
    func delayedCardSelect2() {
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(repeatDekayedCardSelect2), userInfo: nil, repeats: true)
    }
    @objc func repeatDekayedCardSelect2(timer: Timer) {
        if gameState != .playing {
            timer.invalidate()
            return
        }
        //        for i in 0 ..< game.cardsToPlay {
        kolodaView.swipe(.right, force: true)
        //        }
    }
    ///////////////
    ///////////////
    
    func animateHistoryIn() {
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
            var basketTopFrame = self.historyTable.frame
            basketTopFrame.origin.x = self.view.frame.size.width - basketTopFrame.size.width
            self.historyTable.frame = basketTopFrame
        }, completion: { finished in
        })
    }
    func animateHistoryOut() {
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn, animations: {
            var basketTopFrame = self.historyTable.frame
            basketTopFrame.origin.x = self.view.frame.size.width + basketTopFrame.size.width
            self.historyTable.frame = basketTopFrame
        }, completion: { finished in
        })
    }
    // MARK: IBActions

    @IBAction func tutorialPress(_ sender: Any) {
        if gameState != .welcoming {
            return
        }
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "tutorial")
        kolodaView?.swipe(.right)
    }
    
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
	}
    @IBAction func historyClick(_ sender: Any) {
        animateHistoryIn()
    }
	let colorArray = [UIColor.newGreen(), UIColor.newYellow(), UIColor.newBlue(), UIColor.newRed(), UIColor.black]
    
    func unHideEverything() {
        kolodaView.alphaValueSemiTransparent = 0.001
        self.view.isUserInteractionEnabled = true
        incrementText(view: scoreLabel, from: self.score, to: score, text: "Score : ")
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
            self.goal1Color.alpha = 1
            self.goal2Color.alpha = 1
            self.goal3Color.alpha = 1
            self.goal4Color.alpha = 1
            self.goal1Label.alpha = 1
            self.goal2Label.alpha = 1
            self.goal3Label.alpha = 1
            self.goal4Label.alpha = 1
            self.match1Color.alpha = 1
            self.match2Color.alpha = 1
            self.match3Color.alpha = 1
            self.match1Label.alpha = 1
            self.match2Label.alpha = 1
            self.match3Label.alpha = 1
            self.drawLabel.alpha = 1
            self.keepLabel.alpha = 1
            self.hHourImage.alpha = 1
            self.hMinuteImage.alpha = 1
            self.tutorialButton.alpha = 0
        }, completion: { finished in
        })
    }
	func roundViews() {
		goal1Color.layer.cornerRadius = goal1Color.frame.width/2
		goal2Color.layer.cornerRadius = goal1Color.frame.width/2
		goal3Color.layer.cornerRadius = goal1Color.frame.width/2
		goal4Color.layer.cornerRadius = goal1Color.frame.width/2
		
		match1Color.layer.cornerRadius = 16
		match2Color.layer.cornerRadius = 10
		match3Color.layer.cornerRadius = 6
        
        historyTable.layer.cornerRadius = 10
        historyTable.layer.shadowColor = UIColor.black.cgColor
        historyTable.layer.shadowOpacity = 1
        historyTable.layer.shadowOffset = CGSize.zero
        historyTable.layer.shadowRadius = 1
	}
	
	func resetViews() {
		UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
			self.match1Color.backgroundColor = UIColor.clear
			self.match2Color.backgroundColor = UIColor.clear
			self.match3Color.backgroundColor = UIColor.clear
			
			self.match1Label.text = ""
			self.match2Label.text = ""
			self.match3Label.text = ""
		}, completion: { finished in
		})
		
	}
	
    func updateDeckView() {
        historyArray = game.shufflingDeck.arrayOfHistory()
        historyTable.reloadData()

        if game.drawDeck.cards.count < 9 {
            deckLabel.textColor = UIColor.red
        } else {
            deckLabel.textColor = .greyAluminium()
        }
        
        if game.playDeck.cards.count + game.shufflingDeck.cards.count < 9 {
            drawLabel.textColor = UIColor.red
        } else {
            drawLabel.textColor = .greyAluminium()
        }
        
        guard let deckInt = Int(deckLabel.text!), let drawInt = Int(drawLabel.text!), let keepInt = Int(keepLabel.text!) else {
            deckLabel.text = String(game.drawDeck.cards.count)
            drawLabel.text = String(game.playDeck.cards.count)
            keepLabel.text = String(game.shufflingDeck.cards.count)
            return
        }
        incrementText(view: deckLabel, from: deckInt, to: game.drawDeck.cards.count)
        incrementText(view: drawLabel, from: drawInt, to: game.playDeck.cards.count)
        incrementText(view: keepLabel, from: keepInt, to: game.shufflingDeck.cards.count)
	}
    
    @objc func delayedCardSelect() {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(repeatDekayedCardSelect), userInfo: nil, repeats: true)
    }
    @objc func repeatDekayedCardSelect() {
        if game.cardsToPlay <= 0 {
            self.view.isUserInteractionEnabled = true
            timer.invalidate()
            return
        }
        //        for i in 0 ..< game.cardsToPlay {
        kolodaView.swipe(.right, force: true)
        //        }
    }
    
    func turnClock(){
        hHourImage.rotateByDegrees(duration: 1.3)
        hMinuteImage.rotateByDegrees(degree: Float(-M_PI*8), duration: 1.3)
    }
    
    func incrementText(view: UILabel, from: Int, to: Int, text: String = "") {
        if from == to {
            view.text = text + String(from)
            return
        }
        var time = 0.001
        if abs(to - from) > 10000 {
            time = 0.00001
        } else if abs(to - from) > 1000 {
            time = 0.00002
        } else if abs(to - from) > 100 {
            time = 0.00005
		} else if abs(to - from) > 50 {
			time = 0.00002
		} else if abs(to - from) < 8 {
            time = 0.05
        }
        let timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(animateText), userInfo: ["view" : view , "to" : to, "from" : from, "text": text], repeats: false)
    }
	
	func incrementScore(view: UILabel, from: Int, to: Int, text: String = "") {
		scoreTimer.invalidate()
		if from == to {
			view.text = text + String(from)
			return
		}
		var time = 0.001
		if abs(to - from) > 10000 {
			time = 0.00001
		} else if abs(to - from) > 1000 {
			time = 0.00002
		} else if abs(to - from) > 100 {
			time = 0.00005
		} else if abs(to - from) > 50 {
			time = 0.00002
		} else if abs(to - from) < 8 {
			time = 0.05
		}
		scoreTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(animateScore), userInfo: ["view" : view , "to" : to, "from" : from, "text": text], repeats: false)
	}
	
    @objc func animateText(timer2: Timer) {
        if let dic = timer2.userInfo as? Dictionary<String, AnyObject> {
            guard let view = dic["view"] as? UILabel else {
                timer2.invalidate()
                return
            }
            
            guard let to = dic["to"] as? Int else {
                timer2.invalidate()
                return
            }
            
            guard let from = dic["from"] as? Int else {
                timer2.invalidate()
                return
            }
            guard let text = dic["text"] as? String else {
                timer2.invalidate()
                return
            }
            var nFrom = from + 1
            if from > to {
                nFrom = from - 1
            }
            if text.length > 0 {
                let digit = (nFrom == 0) ? 1 : (floor(log10(Float(nFrom))) + 1)
                view.text = text + randomString(length: Int(digit))
            } else {
                view.text = text + String(nFrom)
            }
            incrementText(view: view, from: nFrom, to: to, text: text)
        } else {
            timer2.invalidate()
        }
        
    }
	
	
    @objc func animateScore(timer2: Timer) {
		if let dic = timer2.userInfo as? Dictionary<String, AnyObject> {
			guard let view = dic["view"] as? UILabel else {
				timer2.invalidate()
				return
			}
			
			guard let to = dic["to"] as? Int else {
				timer2.invalidate()
				return
			}
			
			guard let from = dic["from"] as? Int else {
				timer2.invalidate()
				return
			}
			guard let text = dic["text"] as? String else {
				timer2.invalidate()
				return
			}
			var nFrom = from + 1
			if from > to {
				nFrom = from - 1
			}
			if text.length > 0 {
				let digit = (nFrom == 0) ? 1 : (floor(log10(Float(nFrom))) + 1)
				view.text = text + randomString(length: Int(digit))
			} else {
				view.text = text + String(nFrom)
			}
			incrementScore(view: view, from: nFrom, to: to, text: text)
		} else {
			timer2.invalidate()
		}
		
	}
	
    func randomString(length: Int) -> String {
		
        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
		
        var randomString = ""
		
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func goalMoprhing(view:Springable) {
        try? {
            view.animation = "pop"
            view.duration = 1.0
            view.curve = "easeInOut"
            view.animate()
        }
    }
	func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: "ca-app-pub-8165662050219478/9891912143")
		interstitial.delegate = self
		let request = GADRequest()
		// Request test ads on devices you specify. Your test device ID is printed to the console when
		// an ad request is made.
//		request.testDevices = [ kGADSimulatorID ]
		interstitial.load(request)
//		interstitial.load(GADRequest())
		return interstitial
	}

    func getRemoteConfigure() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetch() { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.shouldShowAds = remoteConfig.configValue(forKey: "show_ads").stringValue == "true"
            remoteConfig.activate() { (changed, error) in
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        }
    }
}
// MARK: GameDelegate
extension ViewController: GameDelegate {
    func gameDidDrawAndPlay(number: Int) {
        if gameState != .playing {
            return
        }
		for i in 0 ..< number {
			ripple(CGPoint(x: kolodaView.frame.origin.x+kolodaView.frame.size.width  / 2,
                       y: kolodaView.frame.origin.y+kolodaView.frame.size.height  / 2), view: view, times: 1, duration: 1.7 + 0.8 * Double(i), size: kolodaView.frame.width * 5.0 / 6.0, multiplier: 1.7, divider: 2.2, color: colorArray[game.playDeck.cards[i].getCurrentColor().rawValue].withAlphaComponent(0.6), border: 0.7)
		}
        self.view.isUserInteractionEnabled = false
        handDeck = []
        handDeck.append(contentsOf: game.playDeck.cards)
        kolodaView.resetCurrentCardIndex()
    }
    
    func gameDidDraw(number: Int) {
        if gameState != .playing {
            return
        }
        animateHistoryIn()
        ripple(CGPoint(x: keepLabel.frame.origin.x+keepLabel.frame.size.width  / 2,
                       y: keepLabel.frame.origin.y+keepLabel.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 16, divider: 2.2, color: UIColor.greyAluminium(), border: 1.85)
    }
    
    func gameDidPlayCard(index: Int) {
        if gameState != .playing {
            return
        }
        if game.matchGauge.count < 1 {
			
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.match1Color.backgroundColor = UIColor.clear
				self.match2Color.backgroundColor = UIColor.clear
				self.match3Color.backgroundColor = UIColor.clear
			}, completion: { finished in
			})
            
            match1Label.text = ""
            match2Label.text = ""
            match3Label.text = ""
        } else if game.matchGauge.count < 2 {
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.match2Color.backgroundColor = UIColor.clear
				self.match3Color.backgroundColor = UIColor.clear
			}, completion: { finished in
			})
			
            match2Label.text = ""
            match3Label.text = ""
        } else if game.matchGauge.count < 3 {
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.match3Color.backgroundColor = UIColor.clear
			}, completion: { finished in
			})
			
            match3Label.text = ""
        }
        //        for (index,c) in game.matchGauge.enumerated() {
        if index >= 0 {
            if let c = game.matchGauge[index] as? Card {
                if index == 0 {
                    match1Label.text = String(c.getCurrentPoint())
                    match1Color.backgroundColor = colorArray[c.getCurrentColor().rawValue]
                    ripple(CGPoint(x: match1Color.frame.origin.x+match1Color.frame.size.width  / 2,
                                   y: match1Color.frame.origin.y+match1Color.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 21, divider: 2.2, color: match1Color.backgroundColor!, border: 1.85)
                } else if index == 1 {
                    match2Label.text = String(c.getCurrentPoint())
                    match2Color.backgroundColor = colorArray[c.getCurrentColor().rawValue]
                    ripple(CGPoint(x: match2Color.frame.origin.x+match2Color.frame.size.width  / 2,
                                   y: match2Color.frame.origin.y+match2Color.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 21, divider: 2.2, color: match2Color.backgroundColor!, border: 1.85)
                } else if index == 2 {
                    match3Label.text = String(c.getCurrentPoint())
                    match3Color.backgroundColor = colorArray[c.getCurrentColor().rawValue]
                    ripple(CGPoint(x: match3Color.frame.origin.x+match3Color.frame.size.width  / 2,
                                   y: match3Color.frame.origin.y+match3Color.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 21, divider: 2.2, color: match3Color.backgroundColor!, border: 1.85)
                }
            }
        }
//        }
    }
    
    func gameDidClearGoal(index: Int) {
        if gameState != .playing {
            return
        }
        if index == 0 {
            goalMoprhing(view: goal1Label)
            ripple(CGPoint(x: goal1Color.frame.origin.x+goal1Color.frame.size.width  / 2,
                           y: goal1Color.frame.origin.y+goal1Color.frame.size.height  / 2), view: goal1Color.superview!, times: 2, duration: 1.7, size: 4, multiplier: 21, divider: 2.2, color: goal1Color.backgroundColor!, border: 1.85)
        } else if index == 1 {
            goalMoprhing(view: goal2Label)
            ripple(CGPoint(x: goal2Color.frame.origin.x+goal2Color.frame.size.width  / 2,
                           y: goal2Color.frame.origin.y+goal2Color.frame.size.height  / 2), view: goal2Color.superview!, times: 2, duration: 1.7, size: 4, multiplier: 21, divider: 2.2, color: goal2Color.backgroundColor!, border: 1.85)
        } else if index == 2 {
            goalMoprhing(view: goal3Label)
            ripple(CGPoint(x: goal3Color.frame.origin.x+goal3Color.frame.size.width  / 2,
                           y: goal3Color.frame.origin.y+goal3Color.frame.size.height  / 2), view: goal3Color.superview!, times: 2, duration: 1.7, size: 4, multiplier: 21, divider: 2.2, color: goal3Color.backgroundColor!, border: 1.85)
        } else if index == 3 {
            goalMoprhing(view: goal4Label)
            ripple(CGPoint(x: goal4Color.frame.origin.x+goal4Color.frame.size.width  / 2,
                           y: goal4Color.frame.origin.y+goal4Color.frame.size.height  / 2), view: goal4Color.superview!, times: 2, duration: 1.7, size: 4, multiplier: 21, divider: 2.2, color: goal4Color.backgroundColor!, border: 1.85)
        }
    }
    func gameDidGameOver(score: Int) {
        if gameState != .playing && gameState != .shuffling {
            return
        }
        if score >= hiScore {
            let userDefaults = UserDefaults.standard
            userDefaults.set(score, forKey: "highscore")
            userDefaults.synchronize()
        }
        gameState = .scoreViewing
        incrementText(view: scoreLabel, from: self.score, to: score, text: "Score : ")
        kolodaView.resetCurrentCardIndex()
    }
    func gameDidScoreChange(score: Int) {
        if gameState != .playing {
            return
        }
        incrementText(view: scoreLabel, from: self.score, to: score, text: "Score : ")
        self.score = score
    }
    func gameDidEndTurn(match: Bool) {
        if gameState != .playing && gameState != .shuffling {
            return
        }
        if match {
            gameState = .playing
            handDeck = []
            handDeck.append(contentsOf: game.playDeck.cards)
            kolodaView.resetCurrentCardIndex()
            updateDeckView()
            turnClock()
            resetViews()
        } else {
            gameState = .shuffling
            kolodaView.resetCurrentCardIndex()
        }
    }
    func gameDidMatch() {
        if gameState != .playing {
            return
        }
		birthRateGo(color: match1Color.backgroundColor!)
            for (index,c) in game.matchGauge.enumerated() {
                if index == 0 {
                    match1Label.text = String(c.getCurrentPoint())
                    match1Color.backgroundColor = colorArray[c.getCurrentColor().rawValue]
                    ripple(CGPoint(x: match1Color.frame.origin.x+match1Color.frame.size.width  / 2,
                                   y: match1Color.frame.origin.y+match1Color.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 21, divider: 2.2, color: match1Color.backgroundColor!, border: 1.85)
                } else if index == 1 {
                    match2Label.text = String(c.getCurrentPoint())
                    match2Color.backgroundColor = colorArray[c.getCurrentColor().rawValue]
                    ripple(CGPoint(x: match2Color.frame.origin.x+match2Color.frame.size.width  / 2,
                                   y: match2Color.frame.origin.y+match2Color.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 21, divider: 2.2, color: match2Color.backgroundColor!, border: 1.85)
                } else if index == 2 {
                    match3Label.text = String(c.getCurrentPoint())
                    match3Color.backgroundColor = colorArray[c.getCurrentColor().rawValue]
                    ripple(CGPoint(x: match3Color.frame.origin.x+match3Color.frame.size.width  / 2,
                                   y: match3Color.frame.origin.y+match3Color.frame.size.height  / 2), view: view, times: 1, duration: 1.1, size: 4, multiplier: 21, divider: 2.2, color: match3Color.backgroundColor!, border: 1.85)
                }
        }
    }
    func gameDidNewTarget(target: [Color: Int], currentTarget: [Color: Int]) {
        if gameState != .playing {
            return
        }
		if target.count < 1 {
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.goal1Color.backgroundColor = UIColor.clear
				self.goal2Color.backgroundColor = UIColor.clear
				self.goal3Color.backgroundColor = UIColor.clear
				self.goal4Color.backgroundColor = UIColor.clear
				self.goal1Label.alpha = 0.0
				self.goal2Label.alpha = 0.0
				self.goal3Label.alpha = 0.0
				self.goal4Label.alpha = 0.0
			}, completion: { finished in
			})
		} else if target.count < 2 {
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.goal2Color.backgroundColor = UIColor.clear
				self.goal3Color.backgroundColor = UIColor.clear
				self.goal4Color.backgroundColor = UIColor.clear
				self.goal2Label.alpha = 0.0
				self.goal3Label.alpha = 0.0
				self.goal4Label.alpha = 0.0
			}, completion: { finished in
			})
		} else if target.count < 3 {
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.goal3Color.backgroundColor = UIColor.clear
				self.goal4Color.backgroundColor = UIColor.clear
				self.goal3Label.alpha = 0.0
				self.goal4Label.alpha = 0.0
			}, completion: { finished in
			})
		} else if target.count < 4 {
			UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
				self.goal4Color.backgroundColor = UIColor.clear
				self.goal4Label.alpha = 0.0
			}, completion: { finished in
			})
		}
		
        for (index, entry) in target.enumerated() {
            if index == 0 {
                let text = String(currentTarget[entry.key]!) + "/" + String(entry.value)
                goal1Label.text = text
                if (currentTarget[entry.key]! >= entry.value) {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal1Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal1Color.alpha = 0.5
						self.goal1Label.alpha = 0.5
					}, completion: { finished in
					})
                } else {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal1Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal1Color.alpha = 1.0
						self.goal1Label.alpha = 1.0
				}, completion: { finished in
				})
                }
            } else if index == 1 {
                let text = String(currentTarget[entry.key]!) + "/" + String(entry.value)
                goal2Label.text = text
				if (currentTarget[entry.key]! >= entry.value) {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal2Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal2Color.alpha = 0.5
						self.goal2Label.alpha = 0.5
					}, completion: { finished in
					})
				} else {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal2Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal2Color.alpha = 1.0
						self.goal2Label.alpha = 1.0
					}, completion: { finished in
					})
				}
            } else if index == 2 {
                let text = String(currentTarget[entry.key]!) + "/" + String(entry.value)
                goal3Label.text = text
				if (currentTarget[entry.key]! >= entry.value) {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal3Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal3Color.alpha = 0.5
						self.goal3Label.alpha = 0.5
					}, completion: { finished in
					})
				} else {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal3Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal3Color.alpha = 1.0
						self.goal3Label.alpha = 1.0
					}, completion: { finished in
					})
				}
            } else if index == 3 {
                let text = String(currentTarget[entry.key]!) + "/" + String(entry.value)
                goal4Label.text = text
				if (currentTarget[entry.key]! >= entry.value) {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal4Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal4Color.alpha = 0.5
						self.goal4Label.alpha = 0.5
					}, completion: { finished in
					})
				} else {
					UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
						self.goal4Color.backgroundColor = self.colorArray[entry.key.rawValue]
						self.goal4Color.alpha = 1.0
						self.goal4Label.alpha = 1.0
					}, completion: { finished in
					})
				}
            }
        }
    }
}

// MARK: KolodaViewDelegate

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        if gameState == .tutorial {
            gameState = .playing
            newGameCall()
            kolodaView.resetCurrentCardIndex()
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
//        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
	func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
		if gameState == .playing {
			self.view.isUserInteractionEnabled = false
            if game.cardsToSkip <= 0 {
                animateHistoryOut()
            }
            if direction == SwipeResultDirection.left {
                game.playToDiscard()
            } else {
                game.playToShuffleDeck()
            }
            updateDeckView()
        } else if gameState == .shuffling {
            if direction == SwipeResultDirection.left {
                game.chooseToDiscardOne()
            } else {
                game.chooseToDiscardThree()
            }
        } else if gameState == .welcoming {
            let userDefaults = UserDefaults.standard
            if userDefaults.bool(forKey: "tutorial") {
                gameState = .playing
                newGameCall()
                kolodaView.resetCurrentCardIndex()
            } else {
                unHideEverything()
                roundViews()
                resetViews()
                gameState = .tutorial
                userDefaults.set(true, forKey: "tutorial")
                kolodaView.resetCurrentCardIndex()
            }
        } else if gameState == .scoreViewing {
            hideEverythingLoad()
            gameState = .welcoming
            kolodaView.resetCurrentCardIndex()
        }
    }
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        if game.cardsToPlay > 0 && index == 0 {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(delayedCardSelect), userInfo: nil, repeats: false)
		} else if game.cardsToPlay <= 0 {
			self.view.isUserInteractionEnabled = true
		}
    }
    func kolodaDidResetCard(_ koloda: KolodaView) {
        
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.4
    }
}

// MARK: KolodaViewDataSource

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        if gameState == .playing {
            return handDeck.count
        } else if gameState == .welcoming {
            return 2
        } else if gameState == .tutorial {
            return tutorialArray.count
        } else {
            return 1
        }
    }
	
	func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if gameState == .playing {
            guard let view = Bundle.main.loadNibNamed("CustomCard", owner: self, options: nil)?[0] as? CustomCardView
                else{
                    return UIImageView(image: UIImage(named: "cards_1"))
            }
            //		view.mainImage.image = UIImage(named: "cards_\(index + 1)")
            let c = handDeck[index]
            view.label.text = String(c.getCurrentPoint())
            if c.getCurrentDraw() > 0 {
                view.label.text = "Draw" + String(c.getCurrentDraw())
            }
            let fColor = colorArray[c.getBackColor().rawValue]
            let mColor = colorArray[c.getCurrentColor().rawValue]
            view.mainImage.backgroundColor = mColor
            view.subImage.backgroundColor = fColor
            view.layer.cornerRadius = 12
            
            return view
        } else if gameState == .shuffling{
            guard let view = Bundle.main.loadNibNamed("LetterCard", owner: self, options: nil)?[0] as? CustomCardView
                else{
                    return UIImageView(image: UIImage(named: "Cover1"))
            }
            view.mainImage.backgroundColor = UIColor.greyLightAluminium()
//            view.layer.borderColor = UIColor.greyAluminium().cgColor
//            view.layer.borderWidth = 2.0
            view.layer.cornerRadius = 12
            return view
        } else if gameState == .scoreViewing{
            guard let view = Bundle.main.loadNibNamed("LastCard", owner: self, options: nil)?[0] as? CustomCardView
                else{
                    return UIImageView(image: UIImage(named: "Cover1"))
            }
            view.mainImage.backgroundColor = UIColor.greyLightAluminium()
//            view.layer.borderColor = UIColor.greyAluminium().cgColor
//            view.layer.borderWidth = 2.0
            if gameState == .welcoming {
                view.label.text = welcomeMessage
            } else if gameState == .scoreViewing {
                view.label.text = overMessage + "\nscore: \n" + String(score)
            }
            view.layer.cornerRadius = 12
            return view
        } else if gameState == .welcoming {
            let view = UIImageView(image: UIImage(named: "Cover\(index)"))
            view.layer.cornerRadius = 12
            view.contentMode = .scaleAspectFit
            return view
        } else if gameState == .tutorial {
            let view = UIImageView(image: UIImage(named: tutorialArray[index]))
            view.layer.cornerRadius = 12
            view.backgroundColor = .white
            view.contentMode = .scaleToFill
            return view
        }
        return UIImageView(image: UIImage(named: "Cover1"))
	}
	
	func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        if gameState == .playing {
            return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
        }
        return nil
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        if index < game.cardsToPlay {
            return [.right]
        }
        return [.left, .right]
    }
    
}

// MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return historyArray.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")

        guard let box = cell?.viewWithTag(11), let label = cell?.viewWithTag(12) as? UILabel else {
            return cell!
        }
        box.layer.cornerRadius = 6
        box.layer.borderWidth = 1.4
        box.backgroundColor = UIColor.clear
        if indexPath.row == 0 {
            box.layer.borderWidth = 0.8
            box.layer.borderColor = UIColor.greyAluminium().cgColor
            label.text = "#"
            label.textColor = UIColor.greyAluminium()
            return cell!
        }
        let t = historyArray[indexPath.row - 1]
        box.layer.borderColor = colorArray[t.0.rawValue].cgColor
        label.text = String(t.1)
        label.textColor = colorArray[t.0.rawValue]
        return cell!
	}
}

extension ViewController: GADInterstitialDelegate {
	func interstitialDidDismissScreen(_ ad: GADInterstitial) {
		interstitial = createAndLoadInterstitial()
	}
}

extension UIColor {
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	convenience init(netHex:Int) {
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}
	
	static func newRed() -> UIColor {
		return UIColor(netHex: 0xFC5C86)
	}
	static func newGreen() -> UIColor {
		return UIColor(netHex: 0x2EE09D)
	}
	static func newBlue() -> UIColor {
		return UIColor(netHex: 0x45B8F8)
	}
	static func newYellow() -> UIColor {
		return UIColor(netHex: 0xFFC657)
    }
    static func greyAluminium() -> UIColor {
        return UIColor(netHex: 0x9999999)
    }
    static func greyLightAluminium() -> UIColor {
        return UIColor(netHex: 0xF5F5F5)
    }
}
extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension Array {
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
extension UIView {
    func rotateByDegrees(degree: Float = Float(-M_PI * 2.0), duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.byValue = CGFloat(degree)
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate? = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
