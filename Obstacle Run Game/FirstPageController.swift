//
//  FirstPageController.swift
//  Obstacle Run Game
//
//  Created by Lambros Tzanetos on 20/12/16.
//  Copyright © 2016 LamprosTzanetos. All rights reserved.
//

/*
 playerSkinKey is the selected skin
 playerSkin<number> checks if the skin has been generally purchased
 */

import UIKit
import AVFoundation

class FirstPageController: UIViewController {
    
    @IBOutlet var coinLabel: UILabel!
    
    
    //Button references//
    @IBOutlet var playerSkin1: UIButton!
    @IBOutlet var playerSkin2: UIButton!
    @IBOutlet var playerSkin3: UIButton!
    @IBOutlet var playerSkin4: UIButton!
    @IBOutlet var playerSkin5: UIButton!
    @IBOutlet var playerSkin6: UIButton!
    @IBOutlet var playerSkin7: UIButton!
    @IBOutlet var playerSkin8: UIButton!
    @IBOutlet var playerSkin9: UIButton!
    
    var buttonArray = [UIButton]() //declared in viewDidLoad
    
    let defaults = UserDefaults.standard //is declared initially and globally
    
    var avPlayerBG = AVAudioPlayer()
    var avPlayerSelect = AVAudioPlayer()
    var avPlayerPurchaseNew = AVAudioPlayer()

    
    //I have made terrible mistake since all of these keys are nill. Thats why I initialize all keys to false in the main menu when running for the first time
    
    @IBAction func changeSkin(sender: UIButton) {
        let nameOfButton = "playerSkin\(sender.tag)"
        
        if let isPurchased = defaults.object(forKey: nameOfButton) as? Bool {
            if isPurchased == false { //if the user has not purchased this skin
                var coinsAvailable = defaults.object(forKey: "coinAmount") as? Int
                if (sender.tag <= 3 && coinsAvailable! >= 150) || (sender.tag > 3 && coinsAvailable! >= 75) {
                    purchaseNewMusic()
                    
                    if sender.tag <= 3 {
                        coinsAvailable! -= 150
                    } else {
                        coinsAvailable! -= 75
                    }
                    
                    defaults.set(coinsAvailable!, forKey: "coinAmount")
                    coinLabel.text = "\(coinsAvailable!)"
                    
                    sender.setBackgroundImage(UIImage(named: "\(nameOfButton)Unlocked.png"), for: UIControlState.normal)
                    defaults.set(true, forKey: nameOfButton)
                    
                    //first de-select previously selected button
                    if var index = defaults.object(forKey: "playerSkinKey") as? Int{
                        index -= 1 //use -1 since array are 0-based
                        buttonArray[index].backgroundColor? = UIColor.clear
                        buttonArray[index].layer.borderWidth = 0
                        buttonArray[index].layer.borderColor = UIColor.clear.cgColor
                    }
                    
                    //now that the skin has been bought select it
                    defaults.set(sender.tag, forKey: "playerSkinKey")
                    //select pressed button
                    sender.backgroundColor? = UIColor.clear
                    sender.layer.cornerRadius = 3
                    sender.layer.borderWidth = 3
                    sender.layer.borderColor = UIColor.green.cgColor
                    selectMusic()
                    
                }
            } else { //normally select button
                
                //first de-select previously selected button
                if var index = defaults.object(forKey: "playerSkinKey") as? Int{
                    index -= 1 //use -1 since array are 0-based
                    buttonArray[index].backgroundColor? = UIColor.clear
                    buttonArray[index].layer.borderWidth = 0
                    buttonArray[index].layer.borderColor = UIColor.clear.cgColor
                }
                
                defaults.set(sender.tag, forKey: "playerSkinKey")
                //select pressed button
                sender.backgroundColor? = UIColor.clear
                sender.layer.cornerRadius = 3
                sender.layer.borderWidth = 3
                sender.layer.borderColor = UIColor.green.cgColor
                selectMusic()
            }
        }

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.set(true, forKey: "playerSkin1") //it is always purchased
        
        //array of buttons present in the shop
        buttonArray = [playerSkin1, playerSkin2, playerSkin3, playerSkin4, playerSkin5, playerSkin6, playerSkin7, playerSkin8, playerSkin9]
        
        for button in buttonArray { //checks which skins have been generally purchased and arrange the bg image acordingly
            let buttonName = "playerSkin\(button.tag)" //the name of the button, used to see which button is iterated
            if let hasBeenPurchased = defaults.object(forKey: buttonName) as? Bool {
                if hasBeenPurchased {
                    button.setBackgroundImage(UIImage(named: "\(buttonName)Unlocked.png"), for: UIControlState.normal)
                } else {
                    button.setBackgroundImage(UIImage(named: "\(buttonName)Locked.png"), for: UIControlState.normal)
                }
            } else { //in case it shows an error or it has never been selected
                button.setBackgroundImage(UIImage(named: "\(buttonName)Locked.png"), for: UIControlState.normal)
            }
            
            //in the case it is refereing to the first button which is always selected:
            if button == playerSkin1 {
                playerSkin1.setBackgroundImage(UIImage(named: "playerSkin1Unlocked.png"), for: UIControlState.normal)
            }
        }

        if var index = defaults.object(forKey: "playerSkinKey") as? Int{ //finds the selected skin and highlights it
            index -= 1  //use -1 since array are 0-based
            buttonArray[index].backgroundColor? = UIColor.green
            buttonArray[index].layer.cornerRadius = 3
            buttonArray[index].layer.borderWidth = 3
            buttonArray[index].layer.borderColor = UIColor.green.cgColor
        } else { //first time running the game - so the default skin is highlighted
            buttonArray[0].backgroundColor? = UIColor.green
            buttonArray[0].layer.cornerRadius = 3
            buttonArray[0].layer.borderWidth = 3
            buttonArray[0].layer.borderColor = UIColor.green.cgColor
        }
    
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BG.png")!)
       //  defaults.set(0, forKey: "coinAmount")
        if let coins = defaults.object(forKey: "coinAmount") as? Int{
            coinLabel.text = String(coins)
        } else {
            coinLabel.text = "0"
        }
        
        playBackgroundMusic()

    }
    //=================//
    
    
    //Music functions =========//
    func playBackgroundMusic() {
        let audioPath = Bundle.main.path(forResource: "Joyful", ofType: "wav")
        
        do {
            try avPlayerBG = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }catch {
            // process error
        }
        
        avPlayerBG.numberOfLoops = -1 //makes it repeat forever
        
        if let playMusic = defaults.object(forKey: "playSound") as? Bool {
            if playMusic {
                avPlayerBG.play()
                avPlayerBG.volume = 0.8
            }
        }
    }
    
    
    func selectMusic() {
        let audioPath = Bundle.main.path(forResource: "select", ofType: "mp3")
        
        do {
            try avPlayerSelect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }catch {
            // process error
        }
  
        if let playMusic = defaults.object(forKey: "playSound") as? Bool {
            if playMusic {
                avPlayerSelect.play()
                avPlayerSelect.volume = 1
            }
        }
    }
    
    
    func purchaseNewMusic() {
        let audioPath = Bundle.main.path(forResource: "purchaseNewSound", ofType: "wav")
        
        do {
            try avPlayerPurchaseNew = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }catch {
            // process error
        }
        
        if let playMusic = defaults.object(forKey: "playSound") as? Bool {
            if playMusic {
                avPlayerPurchaseNew.play()
                avPlayerPurchaseNew.volume = 1
            }
        }
    }
    //==========================//

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        avPlayerBG.stop()
    }


}
