//
//  GameViewController.swift
//  Obstacle Run Game
//
//  Created by Lambros Tzanetos on 20/09/16.
//  Copyright © 2016 LamprosTzanetos. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
//import AVFoundation

class GameViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
        
                scene.viewController = self
                
                
                // Present the scene
                view.presentScene(scene)
                
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            //MUSIC
            
            /*do {
                
                try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                
            }
            catch {
                // process error
                
            }
            
            audioPlayer.play() */
            
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
  /*  override func viewWillDisappear(_ animated: Bool) {
        //audioPlayer.pause()
    } */
}
