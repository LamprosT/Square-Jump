//
//  MainMenuViewController.swift
//  Obstacle Run Game
//
//  Created by Lambros Tzanetos on 26/10/16.
//  Copyright © 2016 LamprosTzanetos. All rights reserved.
//

import UIKit
import AVFoundation

class MainMenuViewController: UIViewController {

    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var soundButton: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    let audioPath = Bundle.main.path(forResource: "happyDays", ofType: "wav")
    let defaults = UserDefaults.standard
    var playSound: Bool = true
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()  
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BG.png")!)

        //let defaults = UserDefaults.standard
        let HighScore = defaults.object(forKey: "High_Score")  //sets the variable highscore to the object assigned for the key "High_Score" in the permanent storage memory
        
        if HighScore != nil {  //basically checks if an existing highscore exists
            highScoreLabel.text = (HighScore as! String)  //if it does it sets it
        } else {  //if it does not its sets the highscore to 0
            highScoreLabel.text = "0"
        }
        
        
        if let x = defaults.object(forKey: "hasPlayed") as? Bool{  //if it is the 1st time running the app set it to play sound
            if x != true {
                defaults.set(true, forKey: "playSound")
                defaults.set(true, forKey: "hasPlayed")
                defaults.set(0, forKey: "coinAmount")
            
            }
        } else {
            defaults.set(true, forKey: "playSound")
            defaults.set(true, forKey: "hasPlayed")
            defaults.set(1, forKey: "playerSkinKey")
            defaults.set(0, forKey: "coinAmount")
            
            for i in 1...9 { //the first time sets all strings to false
                print("it is" + String(i))
                defaults.set(false, forKey: "playerSkin\(i)")
            }

        }
        
        
        //MUSIC
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }
        catch {
            // process error
        }
        
        audioPlayer.numberOfLoops = -1 //makes it repeat forever
        
        if let playMusic = defaults.object(forKey: "playSound") as? Bool {
            if playMusic {
                audioPlayer.play()
                if let image = UIImage(named: "SoundNew.png") {
                    soundButton.setImage(image, for: UIControlState.normal)

                }
            }
            else {
                if let image = UIImage(named: "noSound.png") {
                    soundButton.setImage(image, for: UIControlState.normal)
                }
            }
        }

    }
    
    
    
    
    @IBAction func noMusic(_ sender: Any) {
        let musicOrNot = defaults.object(forKey: "playSound")
        
        if(audioPlayer.play() == false && musicOrNot != nil) { //in the case that the game begins and was paused last time
            audioPlayer.play()
            audioPlayer.volume = 1
            playSound = true
            defaults.set(playSound, forKey: "playSound")
            if let image = UIImage(named: "SoundNew.png") {
                soundButton.setImage(image, for: UIControlState.normal)
            }
        }else { //in the case the user want to change sound option
          if musicOrNot != nil {
            if musicOrNot as! Bool{
                audioPlayer.volume = 0
                playSound = false
                defaults.set(playSound, forKey: "playSound")
                if let image = UIImage(named: "noSound.png") {
                    soundButton.setImage(image, for: UIControlState.normal)
                }
            } else {
                audioPlayer.volume = 1
                playSound = true
                defaults.set(playSound, forKey: "playSound")
                if let image = UIImage(named: "SoundNew.png") {
                    soundButton.setImage(image, for: UIControlState.normal)
                }
            }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer.pause()
    }
    
    

}
