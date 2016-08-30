//
//  ViewController.swift
//  F3BarGauge_Demo
//
//  Created by Saud on 2016-08-30.
//  Copyright © 2016 Saud. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: AVAudioPlayerDelegate
extension ViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
    
}

class ViewController: UIViewController {
    @IBOutlet weak var playMeButton: UIButton!
    @IBOutlet weak var gaugeBar: F3BarGauge!
    @IBOutlet weak var timeLabel: UILabel!
    var player:AVAudioPlayer!
    var lowPassReslts: Double = 0.0
    var meterTimer:NSTimer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gaugeBar.numBars = 50;
        gaugeBar.minLimit = 0.05;
        gaugeBar.maxLimit = 1.00;
        gaugeBar.holdPeak = false;
        gaugeBar.litEffect = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playMeAction(sender: UIButton) {
        play()
    }
    
    func play() {
        // Construct URL to sound file
        let soundUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bird_hunting", ofType: "mp3")!)
        print("playing \(soundUrl)")
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: soundUrl)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.meteringEnabled = true
            player.play()
            self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                                                                     target:self,
                                                                     selector:#selector(ViewController.updateAudioMeter(_:)),
                                                                     userInfo:nil,
                                                                     repeats:true)
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    func updateAudioMeter(timer:NSTimer) {
        if player.playing {
            let min = Int(player.currentTime / 60)
            let sec = Int(player.currentTime % 60)
            timeLabel.text = String(format: "%02d:%02d", min, sec)
            player.updateMeters()

            let peak0 = player.peakPowerForChannel(0)
            let peakPowerForChannel: Double = pow(10, (0.05 * Double(peak0)));
            lowPassReslts = 1.50 * peakPowerForChannel + (1.0 - 1.50) * lowPassReslts;
            gaugeBar.value = Float(lowPassReslts)
        }
    }

}

