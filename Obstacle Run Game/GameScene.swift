//
//  GameScene.swift
//  Obstacle Run Game
//
//  Created by Lambros Tzanetos on 20/09/16.
//  Copyright © 2016 LamprosTzanetos. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation


struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let Obstacles : UInt32 = 0b1     // 1
    static let Player    : UInt32 = 0010
    static let Floor     : UInt32 = 0100
    static let Gap       : UInt32 = UInt32(8)//1000
    static let coin         : UInt32 = UInt32(16)

}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viewController: UIViewController?
    
    //===Sprites===/
    var player = SKSpriteNode()
    var background = SKSpriteNode() //Den xriazete na kouniete - to xrisimopio mono gia to xroma
    var platform = SKSpriteNode()
    
  //  var obstacle = SKSpriteNode()
  //   var gap = SKNode()
    
    //===Game Flow Variables ===//
    var previousWasDiff = true
    //var isSliding = false
    var hasTouchedFloor = true
    var scoreCounter = 0
    var timer = Timer()
    var gameOverBool: Bool = false
    var pauseBoolean: Bool = false
    var gameOverButtonsHaveBeenCreated: Bool = false
    var canJump: Bool = true
    var buttonTouch: Bool = false
    let defaults = UserDefaults.standard
    var coinCounter = 0
    let speedOfMovement: CGFloat = 500
    
    //======Labels and Buttons======/
    var Scorelabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var soundButton = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var highScoreLabel = SKLabelNode()
    var coinCollector = SKSpriteNode()
    var coinCollectorLabel = SKLabelNode()

    //Tapped gesture global
    //var tap = UITapGestureRecognizer(target: self, action: #selector(GameScene.tapped(gesture:)))
    
    //==========Player + Obstacles Main Characteristics============//
    var playerSize = CGSize(width: 45, height: 45)
    let obstacleWidthSize: CGFloat = 50

    
    //===========Music============//
    var audioPlayer = AVAudioPlayer()
    let audioPath = Bundle.main.path(forResource: "electroDrive", ofType: "wav")
    
    let jumpSound = SKAction.playSoundFileNamed("Jump.wav", waitForCompletion: false)
    let whooshSound = SKAction.playSoundFileNamed("whoosh2.wav", waitForCompletion: false)
    //============================//
    
    //Buttons that appear when game is over
    var gameOverRestart = SKSpriteNode()
    var gameOverMainMenu = SKSpriteNode()
    var gameOverShopButton = SKSpriteNode()
    //+ music button which is declared elsewhere
    
    //=====zPosition variable======//
    let obstacleGOverZPosition: CGFloat = -2
    let coinNodeGapZPosition: CGFloat = -3
    let labelsZPosition: CGFloat = -1
    let platformZPosition: CGFloat = -4
    let playerZPosition: CGFloat = 1
    let bgZPosition: CGFloat = -5
    //============================//

    
    override func didMove(to view: SKView) { //initial run of application
        physicsWorld.contactDelegate = self

        //highScoreLabel.text = "0"  //might be needed when ran for the first time
        
        //let defaults = UserDefaults.standard //is declared initially and globally
        
        setupGame()  //calls the function that sets up the game
        playMusic()
        //print("MIN FRAME IS \(self.frame.minX)")

        
    }
    
    
    
    func playMusic() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
            
        } catch {
            // process error
        }
        
        //let defaults = UserDefaults.standard //is declared initially and globally
        
        if let soundOrNot = defaults.object(forKey: "playSound") {
            if(soundOrNot as! Bool) {
                audioPlayer.volume = 1
            } else {
                audioPlayer.volume = 0
            }
        } else {
            defaults.set(true, forKey: "playSound:")
        }
        
        audioPlayer.numberOfLoops = -1  //makes it repeat forever
        audioPlayer.play()
    }
    
    
    
    func setupGame(){ //main function of game
        if self.isPaused == true {  //incase the game was paused and user clicked restart
            self.isPaused = false
        }
        
        canJump = true
        pauseBoolean = false
        gameOverBool = false
        gameOverButtonsHaveBeenCreated = false
        coinCounter = 0
        
        let yPositionScoreCounters: CGFloat = self.frame.maxY - 185
    
        //Scoring Label - Prototype        Scorelabel.text = "0"
        scoreCounter = 0
        Scorelabel.position = CGPoint(x: self.frame.midX, y: yPositionScoreCounters)
        
        Scorelabel.fontName = "Helsinkifjes-Regular"
        Scorelabel.fontSize = 90
        Scorelabel.fontColor = UIColor.black
        Scorelabel.text = "0"
    
        addChild(Scorelabel)

        
        //Highscore Label
        highScoreLabel.position = CGPoint(x: self.frame.midX + 300, y: yPositionScoreCounters)
        highScoreLabel.fontName = "Helsinkifjes-Regular"
        highScoreLabel.fontSize = 90
        let medal = SKSpriteNode(imageNamed: "highScoreIn.png")
        medal.setScale(0.5)
        medal.position = CGPoint(x:highScoreLabel.position.x - highScoreLabel.fontSize, y: highScoreLabel.position.y)
        
        addChild(medal)
        addChild(highScoreLabel)
        
        //let defaults = UserDefaults.standard //is declared initially and globally
        let HighScore = defaults.object(forKey: "High_Score")  //sets the variable highscore to the object assigned for the key "High_Score" in the permanent storage memory

        
        if HighScore != nil {  //basically checks if an existing highscore exists
            highScoreLabel.text = (HighScore as! String)  //if it does it sets it
        } else {  //if it does not its sets the highscore to 0
            highScoreLabel.text = "0"
        }
        
        //defaults.removeObject(forKey: "High_Score")  gia na svino edelos to highscore
        
        //size for buttons so they can be easily changed
        let buttonSize = 70
        let differenceFromY: CGFloat = self.frame.maxY - 60
        let diffFromPreButton: CGFloat = CGFloat(buttonSize + 10)
        
        //RestartButton
        restartButton = SKSpriteNode(imageNamed: "Replay.png")
        restartButton.position = CGPoint(x: -self.frame.maxX + CGFloat(buttonSize), y: differenceFromY)
        restartButton.size = CGSize(width: buttonSize, height: buttonSize)
        
        addChild(restartButton)
        
        
        //PauseButton
        pauseButton = SKSpriteNode(imageNamed: "DoPause.png")
        pauseButton.position = CGPoint(x: restartButton.position.x + diffFromPreButton , y: differenceFromY)
        pauseButton.size = CGSize(width: buttonSize, height: buttonSize)
        
        addChild(pauseButton)
        
        
        //SoundButton
        if let soundOrNot = defaults.object(forKey: "playSound") {
            if soundOrNot as! Bool {
                soundButton = SKSpriteNode(imageNamed: "SoundNew")
            } else {
                soundButton = SKSpriteNode(imageNamed: "noSound")
            }
        }
        
        soundButton.position = CGPoint(x: pauseButton.position.x + diffFromPreButton, y: differenceFromY)
        soundButton.size = CGSize(width: buttonSize, height: buttonSize)
        
        addChild(soundButton)
        
        
        //CoinCollector /
        coinCollector = SKSpriteNode(imageNamed: "Money.png") //not used now but defined for later
        //coinCollector.size = CGSize(width: 422*0.70, height: 125*0.70)
        //coinCollector.position = CGPoint(x: self.frame.maxX - 20 - coinCollector.size.width/2, y: differenceFromY) */
        
        coinCollectorLabel.position = CGPoint(x: highScoreLabel.position.x, y: highScoreLabel.position.y + 95)
        coinCollectorLabel.fontSize = 90
        coinCollectorLabel.fontColor = UIColor.yellow
        coinCollectorLabel.fontName = "Helsinkifjes-Regular"
        coinCollectorLabel.text = String(coinCounter)
        let coinIcon = SKSpriteNode(imageNamed: "coin.png")
        coinIcon.setScale(0.5)
        coinIcon.position = CGPoint(x:medal.position.x, y: highScoreLabel.position.y + 110)
        
        addChild(coinIcon)
        
        coinCollector.zPosition = obstacleGOverZPosition //it appears only when the game is over
        coinCollectorLabel.zPosition = labelsZPosition
        //addChild(coinCollector)
        
        addChild(coinCollectorLabel)
        
        
        
        //Detecting Swipes
        let swipeDown = UISwipeGestureRecognizer(target: self, action:  #selector(GameScene.swiped(gesture:))) //creates the swipe for when swiping downwards
        
        swipeDown.direction = UISwipeGestureRecognizerDirection.down  //sets the direction for which this gesture should be triggered
        
        self.view!.addGestureRecognizer(swipeDown)  //adds the swipe to the game
        
        //////
        
        //Detecting Taps  -  in order for the taps to not interfere with the swipes it is necessary to use a distinct gesture for taping
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameScene.tapped(gesture:)))
        tap.cancelsTouchesInView = false
        
        self.view!.addGestureRecognizer(tap)
        
        ///
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * 2)  //sets the gravity for the gameScene
        
        
        //Player Setup
   
        //var playerTexture = SKTexture(imageNamed: "square.png")
        var playerTexture = SKTexture()
        
        if let index = defaults.object(forKey: "playerSkinKey") as? Int{
            let playerSkinCode = "playerSkin"+String(index)+".png"
            playerTexture = SKTexture(imageNamed: playerSkinCode)
            print(playerSkinCode)
        } else {
            playerTexture = SKTexture(imageNamed: "playerSkin1.png")
        }
        
        player = SKSpriteNode(texture: playerTexture)
        player.size = playerSize
        player.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        player.position = CGPoint(x: self.frame.midX - 100, y: self.frame.midY - 14)
        
        player.physicsBody!.restitution = 0
        player.physicsBody!.friction = 0
        player.physicsBody!.isDynamic = true
        player.physicsBody!.allowsRotation = false
     
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player                                //players belongs to category of Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Gap    //players triggeres contactdelegete when contacting physicsbodies of Obstacles and Gap
        player.physicsBody!.collisionBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Floor    //player can collide with Obstacles and the Floor
        //player.physicsBody!.collisionBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Floor | PhysicsCategory.Gap
        
        player.zPosition = playerZPosition
        
        
        //Background Construction Animation
        let backgroundTexture = SKTexture(imageNamed: "bg4.png")

        /*
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -self.frame.size.width, dy: 0), duration: 4)  //animation that moves the background from one end of screen to the other
        
        let shiftBackgroundAnimation = SKAction.move(by: CGVector(dx: self.frame.size.width, dy: 0), duration: 0) //animation that shifts the background back to its initial position instantly
        
        let infiniteBGMove = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBackgroundAnimation] ))  //sequences above animations and repeats the infinitely.
        */
        
        
        //Platform Construction Animation
        let platformTexture = SKTexture(imageNamed: "blackbox.jpg")
        
        let movePlatform = SKAction.move(by: CGVector(dx: -platformTexture.size().width, dy: 0), duration: 5)  //animation similar to the corresponding one for the background
        
        let shiftPlatformBack = SKAction.move(by: CGVector(dx: platformTexture.size().width, dy: 0), duration: 0) //animation similar to the corresponding one for the background
        
        let infinitePlatformMove = SKAction.repeatForever(SKAction.sequence([movePlatform, shiftPlatformBack])) //animation similar to the corresponding one for the background
        
        
        
        //Move Background
       /* var i: CGFloat = 0
        
        while i < 3 {  // in charge for creating seamless movement - it sets 3 backgrounds in continuous positions and rotates them indefinitely
            */
            background = SKSpriteNode(texture: backgroundTexture)
            /*
            background.position = CGPoint(x: self.frame.size.width  * i, y: self.frame.midY)
            */
            background.size.height = self.frame.height
            background.size.width = self.frame.width
            /*
            background.run(infiniteBGMove)  //runs the animation created previously
            */
            background.zPosition = bgZPosition

            
            self.addChild(background)
            /*
            i += 1
            
        }
        */
        
        //Move Platform
        var j: CGFloat = 0
        
        while j < 3 {  // similar action as the one above for the background - the platform is created
            
            platform = SKSpriteNode(texture: platformTexture)
            
            platform.size.height = self.frame.height / 10
            platform.size.width = platform.size.width * 5
            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
            
            platform.physicsBody!.isDynamic = false
            
            //since the platform must intereact with the other sprites it needs a physicsBody
            platform.physicsBody?.categoryBitMask = PhysicsCategory.Floor                                   //the platform belongs to a category of Floor
            platform.physicsBody?.contactTestBitMask = PhysicsCategory.Player                               //the platofrom triggers contactDelegate when in contact with the Player
            platform.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Obstacles     //the platform can collide with Player and Obstacles
            
            platform.position = CGPoint(x: platformTexture.size().width * j, y: self.frame.midY - 100)
            
            platform.run(infinitePlatformMove) //runs the animation created previously
            
            platform.zPosition = platformZPosition
            
            platform.physicsBody!.restitution = 0
            platform.physicsBody!.friction = 0
            
            self.addChild(platform)
            
            j += 1
            
        }
        
        //Timer that is in charge of spawning obstacles  -  calls the function addObstacles
        timer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(self.addObstacles), userInfo: nil, repeats: true)
        
        // /*1*/ TimeInterval(Double(arc4random_uniform(1)) + 1.0)
        
        self.addChild(player)
    }
    
    
    func addCoin() {
        
        let initialXLocation: CGFloat = self.frame.maxX + (obstacleWidthSize * 6)
        let finalXLocation: CGFloat = self.frame.minX * 2 - obstacleWidthSize
        let yLocation: CGFloat = platform.position.y + (2 * obstacleWidthSize) + 5
        
        let coinNode = SKSpriteNode(imageNamed: "coin.png")
        coinNode.size = CGSize(width: 48, height: 48)
        coinNode.position = CGPoint(x: initialXLocation, y: yLocation)
        //print("coin initial is \(coinNode.position.x)")
        let moveCoin = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: yLocation), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()])
        //print("coin it is \(self.frame.minX * 2 - 40)")
        print("WORKING")
        
        coinNode.physicsBody = SKPhysicsBody(rectangleOf: coinNode.size)
        coinNode.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coinNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        coinNode.physicsBody!.collisionBitMask = 0
        coinNode.physicsBody?.isDynamic = true
        coinNode.physicsBody?.affectedByGravity = false
        
        addChild(coinNode)
        coinNode.run(moveCoin)
        coinNode.zPosition = coinNodeGapZPosition

        }
    
    
    func addObstacles() {  //spawns obstacles
        
        let objectType = Int(arc4random_uniform(4))  //generates a random number so the generation of obstacles is random
        
        switch objectType {
        case 0:                     // if the number generated is 0 a single obstacle is created
            previousWasDiff = true
            createSingleObstacle(obstacleDifference: 0, zPositionValue: obstacleGOverZPosition)
            addCoin()
            break;
        
        case 1:                     // if the number generated is 1 a double joined obstacle is created
            previousWasDiff = true
            createDoubleObstacleJoined()
            break;
        
        case 2:                     //If the number generated is 2 the are two possible outcomes so the game doesn't become too hard
            if previousWasDiff {
                createDoubleObstacleSeparated()     //since the previous obstacle was different and the random number is 2 a double separated obstacle is spawned
                previousWasDiff = false
            } else {                                //since the previous obstacle was not different and the random number is 2 a random number is between 0 - 2 is generated so a different obstacle can be spawned
                let otherObj = Int(arc4random_uniform(2))  //chooses between the other options
                
                if otherObj == 0 {
                    createSingleObstacle(obstacleDifference: 0, zPositionValue: obstacleGOverZPosition)
                } else if otherObj == 1 {
                    createAboveObstacle()
                } else {
                    createDoubleObstacleJoined()
                }
            }
            break;
        
        case 3:                     // if the number generated is 3 a top obstacles is created
            previousWasDiff = true
            createAboveObstacle()
            addCoin()
            break;
            
        default:
            break;
        }
        
    }
    
    
    
    
    func calculateTimeNeeded(initialLocation: CGFloat, finalLocation: CGFloat) -> TimeInterval {
        var timeNeeded: TimeInterval = 0
        
        let final = abs(finalLocation)
        let initial = abs(initialLocation)
        
        timeNeeded = TimeInterval((final + initial)/speedOfMovement)
        
        return timeNeeded
        
    }
    
    
    func createSingleObstacle(obstacleDifference: CGFloat, zPositionValue: CGFloat) {
        
        // Attempt to create new obstacle everytime
        var obstacle = SKSpriteNode()
        
        //Create Obstacle
        let obstacleTexture = SKTexture(imageNamed: "blackbox.jpg")
        obstacle = SKSpriteNode(texture: obstacleTexture)
        
        let initialXLocation: CGFloat = self.frame.maxX + obstacleWidthSize + obstacleDifference
        let finalXLocation: CGFloat = self.frame.minX * 2 - obstacleWidthSize + obstacleDifference
        let yLocation: CGFloat = platform.position.y + platform.size.height/2 + obstacleWidthSize/2
            
        obstacle.size = CGSize(width: obstacleWidthSize, height: obstacleWidthSize)
        obstacle.position = CGPoint(x: initialXLocation, y: yLocation)
        //print("Initial is \(obstacle.position.x)")
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacle.size.width - 3, height: obstacle.size.height))  //make it smaller than obstacle.size so it is clear when they contact
        obstacle.physicsBody!.isDynamic = false
        
        let moveObstacle = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: yLocation), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()]) //must add the + obstacleDifference so both objects move at the same speed
        //print("finalLocation is \(self.frame.minX * 2 - 40)")
        
  
        obstacle.physicsBody!.friction = 0
        obstacle.physicsBody!.restitution = 0
        obstacle.zPosition = zPositionValue
        
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.Obstacles                          //Obstacle has a physicsBody of type Obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.Player                          //Obstacle triggers the contact delegate when contacting Player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Floor    //Obstacle can collide with Player and Floor
    
        obstacle.run(moveObstacle,withKey: "stop")
        self.addChild(obstacle)
        
        
        
        
       //Gap  -  A gap must be created everytime an obstacle is generated so score can be kept
        let gap = SKNode()
        
        gap.position = CGPoint(x: initialXLocation, y:  yLocation + (3/2*obstacleWidthSize)  + 5) //+5 is to ensure that they do not touch
        
        let moveGap = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: gap.position.y), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()]) //moves gap the same way the object is moved
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacleWidthSize , height:  obstacleWidthSize + obstacleWidthSize/2))
        
        gap.physicsBody!.isDynamic = false
        //gap.physicsBody!.affectedByGravity = false
        
        gap.physicsBody!.contactTestBitMask = PhysicsCategory.Player  //Triggers contact with Player in order for score to increase
        gap.physicsBody!.categoryBitMask = PhysicsCategory.Gap
        gap.physicsBody!.collisionBitMask = 0 // PhysicsCategory.Gap  //Does not collide with anything

        gap.run(moveGap)
        self.addChild(gap)
        
   
    }
    
    
    
    func createDoubleObstacleJoined() {
        
        // Attempt to create new obstacle everytimy
        var obstacle = SKSpriteNode()
        
        let initialXLocation: CGFloat = self.frame.maxX + obstacleWidthSize
        let finalXLocation: CGFloat = self.frame.minX * 2 - obstacleWidthSize
        let yLocation: CGFloat = platform.position.y + platform.size.height/2 + obstacleWidthSize/2

        //Create Obstacle
        let obstacleTexture = SKTexture(imageNamed: "blackbox.jpg")
        obstacle = SKSpriteNode(texture: obstacleTexture)
        
        
        obstacle.size = CGSize(width: obstacleWidthSize * 2, height: obstacleWidthSize)
        obstacle.position = CGPoint(x: initialXLocation, y:  yLocation)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacle.size.width - 10, height: obstacle.size.height))  //make it smaller than obstacle.size so it is clear when they contact
        obstacle.physicsBody!.isDynamic = false
    
        let moveObstacle = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: yLocation), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()]) //must add the + obstacleDifference so both objects move at the same speed
        
        
        obstacle.physicsBody!.friction = 0
        obstacle.physicsBody!.restitution = 0
        obstacle.zPosition = obstacleGOverZPosition
        
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.Obstacles  //see previous
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.Player  //see previous
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Floor  //see previous
        
        obstacle.run(moveObstacle)
        self.addChild(obstacle)
        
        
        
      
        //Gap - See previous comments for gap
        let gap = SKNode()
        
        gap.position = CGPoint(x: initialXLocation, y:  yLocation + obstacleWidthSize + 5)
        
        let moveGap = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: gap.position.y), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()])
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacle.size.width , height: obstacleWidthSize))
        
        gap.physicsBody!.isDynamic = false

        
        gap.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        gap.physicsBody!.categoryBitMask = PhysicsCategory.Gap
        gap.physicsBody!.collisionBitMask = 0 // PhysicsCategory.Gap

        gap.run(moveGap)
        self.addChild(gap)
        
    }
    
    
    
    func createDoubleObstacleSeparated() { //when creating a double separated and continuous obstacles two distinct single obstacles are created
        
        createSingleObstacle(obstacleDifference: 0, zPositionValue: obstacleGOverZPosition)
        createSingleObstacle(obstacleDifference: 230, zPositionValue: obstacleGOverZPosition)
    }
    
    
    
    func createAboveObstacle() {
        
        var obstacle = SKSpriteNode()
        
        let initialXLocation: CGFloat = self.frame.maxX + obstacleWidthSize
        let finalXLocation: CGFloat = self.frame.minX * 2 - obstacleWidthSize
        let yLocation: CGFloat = platform.position.y + platform.size.height/2 + obstacleWidthSize/2 + obstacleWidthSize + 5  //first 2 reach it at top then /2 leaves a 25 area gap and the rest positions it
        
        //Create Obstacle
        let obstacleTexture = SKTexture(imageNamed: "blackbox.jpg")
        obstacle = SKSpriteNode(texture: obstacleTexture)
        
        
        obstacle.size = CGSize(width: obstacleWidthSize, height: obstacleWidthSize * 2)
        obstacle.position = CGPoint(x: initialXLocation , y: yLocation)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacleWidthSize, height: obstacle.size.height))
        obstacle.physicsBody!.isDynamic = false
        
        let moveObstacle = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: yLocation), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()])
        
        obstacle.physicsBody!.friction = 0
        obstacle.physicsBody!.restitution = 0
        
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.Obstacles //see previous
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.Player //see previous
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Floor //see previous  -- doesn't really need to collide with floor since it never touches it
        
        obstacle.run(moveObstacle)
        
        obstacle.zPosition = obstacleGOverZPosition
        self.addChild(obstacle)
    
        
        
        
        //Gap - See above comments for gap
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: initialXLocation, y: platform.position.y + platform.size.height/2 + 5 )
        
        let moveGap = SKAction.sequence([SKAction.move(to: CGPoint(x: finalXLocation, y: gap.position.y), duration: calculateTimeNeeded(initialLocation: initialXLocation, finalLocation: finalXLocation)), SKAction.removeFromParent()])
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: obstacleWidthSize, height:  3))
        
        gap.physicsBody!.isDynamic = false
        //gap.physicsBody!.affectedByGravity = false
        
        gap.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        gap.physicsBody!.categoryBitMask = PhysicsCategory.Gap
        gap.physicsBody!.collisionBitMask = 0 // PhysicsCategory.Gap
    
        gap.run(moveGap)
        self.addChild(gap)
        
    }
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {  //touches began is only used for GUI buttons -> not to affect player
    
        for touch: AnyObject in touches {
            //We get location of the touch
            let locationOfTouch = touch.location(in: self)
            
            if restartButton.contains(locationOfTouch) {  //restart the game
                Scorelabel.text = "0"
                timer.invalidate()
                self.removeAllChildren()
                buttonTouch = true
                setupGame()
            }
            
            if gameOverShopButton.contains(locationOfTouch) { //navigates to shop
                Scorelabel.text = "0"
                timer.invalidate()
                self.removeAllChildren()
                self.returnToShop()
            }
            
            //if game is already paused touching the screen anywhere will pause is
            if pauseBoolean == true { //if the game is already paused
                canJump = false

                if timer.isValid == false { //if the timer is not valid re-validate it to continue to spawn obstacles
                    timer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(self.addObstacles), userInfo: nil, repeats: true) //re-set timer for obstacle spawning
                }
                pauseBoolean = false
                self.isPaused = false
                let nonPausedTexture = SKTexture(imageNamed: "DoPause")
                pauseButton.texture = nonPausedTexture
            }

            //if the game is not paused
            if pauseButton.contains(locationOfTouch) && !gameOverBool {
                canJump = false

                //if the game is not paused
                timer.invalidate() //stop obstacles from being spawned while the game is paused
                pauseBoolean = true
                self.isPaused = true
                let pauseTexture = SKTexture(imageNamed: "DoUnPause.png")
                pauseButton.texture = pauseTexture
               
            }
            
            //Handle the toggle of soundButton
            if soundButton.contains(locationOfTouch) {
                let musicOrNot = defaults.object(forKey: "playSound")
                var playSound: Bool = true

                buttonTouch = true
                
                if(audioPlayer.play() == false && musicOrNot != nil) { //in the case that the game begins and was paused last time
                    audioPlayer.play()
                    audioPlayer.volume = 1
                    playSound = true
                    defaults.set(playSound, forKey: "playSound")
                    soundButton.texture = SKTexture(imageNamed: "SoundNew.png")
                    
                }else { //in the case the user want to change sound option
                    if musicOrNot != nil {
                        if musicOrNot as! Bool{
                            audioPlayer.volume = 0
                            playSound = false
                            defaults.set(playSound, forKey: "playSound")
                            soundButton.texture = SKTexture(imageNamed: "noSound.png")
                            
                        } else {
                            audioPlayer.volume = 1
                            playSound = true
                            defaults.set(playSound, forKey: "playSound")
                            if(!gameOverBool) { //distinguishes between the button if the game has ended
                                soundButton.texture = SKTexture(imageNamed: "SoundNew.png")
                            } else {
                                soundButton.texture = SKTexture(imageNamed: "SoundGreen.png")
                            }
                        }
                    }
                }
            }
            
            
            
            if (gameOverRestart.contains(locationOfTouch) && gameOverButtonsHaveBeenCreated == true && gameOverRestart.alpha == 1) {
                Scorelabel.text = "0"
                timer.invalidate()
                self.removeAllChildren()
                buttonTouch = true
                setupGame()
               // canJump = false
            }
            
            if (gameOverMainMenu.contains(locationOfTouch) && gameOverButtonsHaveBeenCreated == true && gameOverMainMenu.alpha == 1) {
                Scorelabel.text = "0"
                timer.invalidate()
                self.removeAllChildren()
                
                //move To other view
                self.returnToMainMenu()
               // canJump = false
            }
            
        
        }
    }
 
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonTouch = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonTouch = false
    }
    
    
    
    
    func tapped(gesture: UIGestureRecognizer) {  //used to make the player jump
        //normal touch
        if canJump == true && buttonTouch == false {
        if gameOverBool == false { //when the game normaly runs
        
            if hasTouchedFloor && (player.size == playerSize) {  //variable used to not allow double jumps
            
                hasTouchedFloor = false  //since it jumps it sets it to false so it prohibits the player from double jumping
            
                player.physicsBody!.isDynamic = true
                player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 67))
                player.physicsBody!.allowsRotation = false
                player.physicsBody!.affectedByGravity = true
                
                //let jumpSound = SKAction.playSoundFileNamed("Jump.wav", waitForCompletion: false) -> moved to initial declare
                
                if let soundOrNot = defaults.object(forKey: "playSound") {
                    if(soundOrNot as! Bool) {
                        player.run(jumpSound)
                    }
                }

                let rotateJump = SKAction.rotate(byAngle: -6.283195, duration: 0.45)  //action that rotates the player in a full circle -!!- meassurement is in radians not degrees
                player.run(rotateJump, withKey: "rotateAction")  //runs the action and sets a key to stop it -- when swiping the action must be cancelled
                
                }
            }
            
        } else {
            canJump = true
        }
    }

        

    
    
     func swiped(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
          switch swipeGesture.direction {
     
            case UISwipeGestureRecognizerDirection.down:
              ////actions when swiped
                //Play whoosh sound
                if let soundOrNot = defaults.object(forKey: "playSound") {
                    if(soundOrNot as! Bool) {
                        player.run(whooshSound)
                    }
                }
                //
                
                //Adapt players body to slide
                let shrinkPhysicsBodyAction = SKAction.run {
                    let shrinkPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.playerSize.width, height: self.playerSize.height/2))
                    self.player.physicsBody = shrinkPhysicsBody
                    self.player.physicsBody!.isDynamic = true
                    self.player.physicsBody!.restitution = 0
                    self.player.physicsBody!.friction = 0

                    self.player.physicsBody?.categoryBitMask = PhysicsCategory.Player
                    self.player.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Gap
                    self.player.physicsBody?.collisionBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Floor
        
                }

                let shrinkPlayerSize = SKAction.run {
                    self.player.size = CGSize(width: self.playerSize.width, height: self.playerSize.height/2)
                }
                
                
                let remakePhysicsBodyAction = SKAction.run {
                    
                    let remakePhysicsBody = SKPhysicsBody(rectangleOf: self.player.size)
                    
                    self.player.physicsBody = remakePhysicsBody
                    self.player.physicsBody!.restitution = 0
                    self.player.physicsBody!.isDynamic = true
                    self.player.physicsBody!.friction = 0
                    
                    self.player.physicsBody?.categoryBitMask = PhysicsCategory.Player
                    self.player.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Gap
                    self.player.physicsBody?.collisionBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Floor

                }
                
                let remakePlayerSize = SKAction.run {
                    self.player.size = self.playerSize
                }
                
                
                let sendDown = SKAction.run {
                    
                    self.player.physicsBody!.isDynamic = true
                    self.player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    self.player.physicsBody!.affectedByGravity = true
                    self.player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: -85))
                }
                
                //////
                
                if hasTouchedFloor == false {  //xrisimopio afto to kritirio adi gia if isOnAir
                    
                    self.player.run(SKAction.sequence([sendDown, shrinkPhysicsBodyAction, shrinkPlayerSize, SKAction.wait(forDuration: 0.7), remakePlayerSize, remakePhysicsBodyAction]))
                    
                } else {
                    self.player.run(SKAction.sequence([shrinkPhysicsBodyAction, shrinkPlayerSize, SKAction.wait(forDuration: 0.7), remakePlayerSize, remakePhysicsBodyAction])) //otan pesi na kanei slide
                }
            
            default:
                break
            }
        }
    }
    


    
    func resetGame() {
        if gameOverBool == true {
            self.removeAllChildren()

            let backgroundGO = SKSpriteNode(imageNamed: "BG.png") //GO = game over
            //backgrounGO.size = self.frame.size
            backgroundGO.size.height = self.frame.size.height
            backgroundGO.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            backgroundGO.zPosition = bgZPosition
            addChild(backgroundGO)
    
            self.isPaused = true //pause game
            //Create buttons that appear when game is over  -- Ta ftiaxno edo gia na min svithoun apo to removeAllChildren
            
            let gameOverNode = SKSpriteNode(imageNamed: "gameOverrPn.png")
            gameOverNode.size = CGSize(width: 600, height: 324)
            gameOverNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 200)
            
            
            //=====Navigation Buttons=====//
            gameOverRestart = SKSpriteNode(imageNamed: "Replay.png")
            gameOverMainMenu = SKSpriteNode(imageNamed: "Home.png")
            soundButton = SKSpriteNode(imageNamed: "SoundGreen.png") //already has properties but change now
            gameOverShopButton = SKSpriteNode(imageNamed: "Shop.png")
            
            let buttonSize = CGSize(width: 130, height: 130)
            let yGOLocation: CGFloat = self.frame.midY - 380
            
            gameOverRestart.position = CGPoint(x: self.frame.midX - CGFloat(buttonSize.width/2) - 5, y: yGOLocation)
            gameOverMainMenu.position = CGPoint(x: self.frame.midX + CGFloat(buttonSize.width/2) + 5, y: yGOLocation)
            soundButton.position = CGPoint(x: gameOverRestart.position.x - CGFloat(buttonSize.width/1) - 10, y: yGOLocation)
            gameOverShopButton.position = CGPoint(x: gameOverMainMenu.position.x + CGFloat(buttonSize.width/1) + 10, y: yGOLocation)
            
            gameOverRestart.size = buttonSize
            gameOverMainMenu.size = buttonSize
            gameOverShopButton.size = buttonSize
            soundButton.size = buttonSize
            
            
            gameOverMainMenu.alpha = 0
            soundButton.alpha = 0
            gameOverShopButton.alpha = 0
            gameOverRestart.alpha = 0


            
            //======Leaderboards + Coincollector=======//
            let sizeRatio:CGFloat = 1.2
            coinCollector.size = CGSize(width: 422 * sizeRatio, height: 125 * sizeRatio) //imageHasBeen already set from setup game
            let gameOverHighScoreButton = SKSpriteNode(imageNamed: "LeaderboardYellow.png")
            gameOverHighScoreButton.size = coinCollector.size
            let gameOverCurrentScoreButton = SKSpriteNode(imageNamed: "LeaderboardGreen.png")
            gameOverCurrentScoreButton.size = coinCollector.size
          
            gameOverCurrentScoreButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 150)
            gameOverHighScoreButton.position = CGPoint(x: gameOverCurrentScoreButton.position.x, y: gameOverCurrentScoreButton.position.y - 20 - gameOverHighScoreButton.size.height)
            coinCollector.position = CGPoint(x: gameOverCurrentScoreButton.position.x, y: gameOverHighScoreButton.position.y - 20 - coinCollector.size.height)
            
            gameOverCurrentScoreButton.zPosition = obstacleGOverZPosition
            gameOverHighScoreButton.zPosition = obstacleGOverZPosition
            coinCollector.zPosition = obstacleGOverZPosition

            addChild(coinCollector)
            addChild(gameOverCurrentScoreButton)
            addChild(gameOverHighScoreButton)
            
            
            //======Labels for buttons======//
            let highScoreButtonLabel = SKLabelNode()
            let currentScoreButtonLabel = SKLabelNode()
            let gameOverCoinLabel = SKLabelNode()
            let fontSize:CGFloat = 120
            
            highScoreButtonLabel.position = CGPoint(x: gameOverHighScoreButton.position.x + (116 * sizeRatio)/2, y: gameOverHighScoreButton.position.y - (fontSize/5))
            highScoreButtonLabel.text = defaults.object(forKey: "High_Score") as! String?
            highScoreButtonLabel.fontSize = fontSize
            highScoreButtonLabel.fontName = "Helsinkifjes-Regular"
            highScoreButtonLabel.zPosition = labelsZPosition
            
            currentScoreButtonLabel.position = CGPoint(x: gameOverCurrentScoreButton.position.x + (116 * sizeRatio)/2, y: gameOverCurrentScoreButton.position.y - (fontSize/5))
            currentScoreButtonLabel.text = defaults.object(forKey: "currentScore") as! String? //tha borusa na valo kai to value tou counter
            currentScoreButtonLabel.fontSize = fontSize
            currentScoreButtonLabel.fontName = "Helsinkifjes-Regular"
            currentScoreButtonLabel.zPosition = labelsZPosition
            
            gameOverCoinLabel.position = CGPoint(x: coinCollector.position.x + (116 * sizeRatio)/2, y: coinCollector.position.y - (fontSize/5))
            gameOverCoinLabel.text = String(coinCounter)
            gameOverCoinLabel.fontSize = fontSize
            gameOverCoinLabel.fontName = "Helsinkifjes-Regular"
            gameOverCoinLabel.zPosition = labelsZPosition


            addChild(gameOverRestart)
            addChild(gameOverMainMenu)
            addChild(gameOverShopButton)
            addChild(soundButton)
            addChild(highScoreButtonLabel)
            addChild(currentScoreButtonLabel)
            addChild(gameOverCoinLabel)
            addChild(gameOverNode)
            
            //============================//

            let fade = SKAction.fadeAlpha(to: 1, duration: 1)
            self.isPaused = false //unpauses screen to make make the animations visible
            
            gameOverMainMenu.run(fade)
            gameOverRestart.run(fade)
            gameOverShopButton.run(fade)
            soundButton.run(fade)
 
            gameOverButtonsHaveBeenCreated = true //restricts user from pressing on screen and reseting when buttons have not been created

        
            ////////////////////////////////////////////
            
            
            //setupGame()
        }
    }
    
   
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Player && contact.bodyB.categoryBitMask == PhysicsCategory.Obstacles ) || (contact.bodyB.categoryBitMask == PhysicsCategory.Player && contact.bodyA.categoryBitMask == PhysicsCategory.Obstacles) {    //case where PLAYER collides with OBSTACLE
            
            print("I detect Contact")
            
           /* if let myHighscore = highScoreLabel.text { //if it is not the first time playing the game
                if scoreCounter > Int(myHighscore)! {
                    let defaults = UserDefaults.standard
                    defaults.set(String(scoreCounter), forKey : "High_Score") // Saving the String to NSUserDefaults
                }
            }
            else {  //if ti is the first time playing the game
                let defaults = UserDefaults.standard
                defaults.set(String(scoreCounter), forKey : "High_Score") // Saving the String to NSUserDefaults
            } */
            
            gameOverBool = true
            
            timer.invalidate()
            
            self.removeAllActions() //gia na stamatisoun na kouniounte ta obstaceles kai nane akinita ola
            
            player.physicsBody?.collisionBitMask = 0
            player.physicsBody?.contactTestBitMask = 0
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
            player.physicsBody?.applyForce(CGVector(dx: 0, dy: -40))
            player.physicsBody?.affectedByGravity = true
            player.run(SKAction.rotate(byAngle: 6, duration: 3))
            player.run(SKAction.fadeOut(withDuration: 2))
            
            self.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 1), SKAction.run { self.resetGame() }, SKAction.fadeAlpha(to: 1, duration: 1.5)]))
          
        }

        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Player && contact.bodyB.categoryBitMask == PhysicsCategory.Floor ) || (contact.bodyB.categoryBitMask == PhysicsCategory.Player && contact.bodyA.categoryBitMask == PhysicsCategory.Floor) {
            
            print("Jump Reseted")
            removeAction(forKey: "rotateAction")
            hasTouchedFloor = true
  
        }
        
        
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Player && contact.bodyB.categoryBitMask == PhysicsCategory.Gap ) || (contact.bodyB.categoryBitMask == PhysicsCategory.Player && contact.bodyA.categoryBitMask == PhysicsCategory.Gap) {    //Player jumps over obstacle

            //let gapBody: SKNode
            
            if contact.bodyA.categoryBitMask == PhysicsCategory.Gap {
                let gap = contact.bodyA.node
                gap?.removeFromParent()
                
            } else {
                let gap = contact.bodyB.node
                gap?.removeFromParent()
            }
            
            scoreCounter += 1
            Scorelabel.text = String(scoreCounter)
            
        }
        
        if(contact.bodyA.categoryBitMask == PhysicsCategory.coin || contact.bodyB.categoryBitMask == PhysicsCategory.coin) {
            coinCounter += 1
            coinCollectorLabel.text = String(coinCounter)
            
            if(contact.bodyA.categoryBitMask == PhysicsCategory.coin) {
                (contact.bodyA.node as! SKSpriteNode).removeFromParent()
            } else {
                (contact.bodyB.node as! SKSpriteNode).removeFromParent()
            }
            
            if var allCoins = defaults.object(forKey: "coinAmount") as? Int{
                allCoins += 1
                defaults.set(allCoins, forKey: "coinAmount")
            } else {
                defaults.set(coinCounter, forKey: "coinAmount")
            }
            
            if let canPlay = defaults.object(forKey: "playSound") as? Bool {
                if canPlay {
                    self.run(SKAction.playSoundFileNamed("coinSound.wav", waitForCompletion: false))
                }
            }
        }
        
    }
    
    
  
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //updates highscore label at live time
        defaults.set(String(scoreCounter), forKey: "currentScore")
        
        if let myHighscore = highScoreLabel.text { //if it is not the first time playing the game
            if scoreCounter > Int(myHighscore)! {
                //let defaults = UserDefaults.standard //is declared initially and globally
                
                defaults.set(String(scoreCounter), forKey : "High_Score") // Saving the String to NSUserDefaults
                
                highScoreLabel.text = defaults.object(forKey: "High_Score") as? String //instantly updates highscore
            }
        } else {  //if it is the first time playing the game
            //let defaults = UserDefaults.standard //is declared initially and globally
    
            defaults.set(String(scoreCounter), forKey : "High_Score") // Saving the String to NSUserDefaults
        }
    }
    
    
    func returnToMainMenu(){
        
       // var mainMenuViewController: UIViewController = UIViewController()
        
       // mainMenuViewContrfoller = self.view!.window!.rootViewController!
        
       // mainMenuViewController.performSegue(withIdentifier: "menu", sender: mainMenuViewController)
    
        if viewController != nil {
            self.viewController?.performSegue(withIdentifier: "push", sender: viewController)
            audioPlayer.stop()
        }
    }
    
    
    func returnToShop(){
        if viewController != nil {
            self.viewController?.performSegue(withIdentifier: "pushToShop", sender: viewController)
            audioPlayer.stop()
        }
    }
}

/* Saving Permanently
 To save the high score:
 
 let x : Int = 45 // This int is your high score
 var myString = String(x) // This String is you high score as a String
 
 var defaults = NSUserDefaults.standardUserDefaults()
 
 defaults.setObject(String(scoreLabel), forkey : "High_Score") // Saving the String to NSUserDefaults
 
 
 To access the high score:
 
 var defaults = NSUserDefaults.standardUserDefaults()
 
 var HighScore = defaults.objectForKey("High_Score")
 */
