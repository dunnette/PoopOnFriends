//
//  ViewController.swift
//  poop_interface1
//
//  Created by Jason Toff on 10/6/15.
//  Copyright © 2015 Jason Toff. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var poopButton: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var numPoopsLabel: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    @IBAction func numPoopsSlider(sender: UISlider) {
        timesToPoop = lroundf(sender.value)
        if timesToPoop == 1{
            numPoopsLabel.text = String(timesToPoop) + " poop"
        } else{
            numPoopsLabel.text = String(timesToPoop) + " poops"
        }
    }
    
    var timesToPoop = 1
    var numPoops = 1
    
    @IBAction func sendSMS(sender: UIButton) {
        
        if let currentNum = phoneNumberTextField.text where !currentNum.isEmpty && currentNum != "Enter a number"{
            
            numPoops = Int(timesToPoop.value)
            
            for _ in 1...numPoops {
                sendMessage(currentNum)
            }
            
            playFartSound(numPoops)
            
            // sendMessage(currentNum)
        } else{
            animateFeedbackMessage("could not poop on this person", delay: 2)
            // sendMessage("")
        }
    }
    
    func sendMessage(number:String){
        sendingFeedback()
        let urlToSend = NSURL(string:"http://tellmewhich.com/poop.php?phone=" + number)
        sendRequest(urlToSend!)
        sentFeedback()
    }
    
    func playFartSound(numPoops: Int){
        
        for ii in 0...(numPoops-1){
            delay(Double(ii)) {
                do {
                    self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("fart", ofType: "mp3")!))
                    self.audioPlayer.play()
                } catch {
                    print("Error")
                }
            }
        }
        delay(Double(numPoops)) {
            do {
                self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("flush", ofType: "mp3")!))
                self.audioPlayer.play()
            } catch {
                print("Error")
            }
    }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), closure)
    }
    
    func sendingFeedback(){
        poopButton.enabled = false
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.5
        animation.repeatCount = 2 * Float(numPoops-1)
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(poopButton.center.x, poopButton.center.y - 3))
        animation.toValue = NSValue(CGPoint: CGPointMake(poopButton.center.x, poopButton.center.y + 3))
        poopButton.layer.addAnimation(animation, forKey: "position")
        animateFeedbackMessage("pooping...", delay: Double(numPoops))
        
        
    }
    
    func sentFeedback(){
        let delay = Double(numPoops) * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.animateFeedbackMessage("pooped", delay: 2)
            self.poopButton.enabled = true
            UIView.animateWithDuration(0.7, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.feedbackLabel.alpha = 0.0}, completion: nil)
        }
    }
    
    func animateFeedbackMessage(message:String, delay: Double){
        
        self.feedbackLabel.text = message
        self.feedbackLabel.alpha = 1.0
        
        UIView.animateWithDuration(0.7, delay:delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.feedbackLabel.alpha = 0.0}, completion: nil)
    }
    
    
    
    
    func pauseForSeconds(seconds:Int){
        
    }
    func sendRequest(url: NSURL) -> NSURLSessionTask {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request)
        task.resume()
        
        return task
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

