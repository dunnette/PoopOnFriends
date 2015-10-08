//
//  ViewController.swift
//  poop_interface1
//
//  Created by Jason Toff on 10/6/15.
//  Copyright © 2015 Jason Toff. All rights reserved.
//

import UIKit
import AVFoundation
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate {
    
    @IBOutlet weak var pickAFriendButton: UIButton!
    @IBOutlet weak var poopButton: UIButton!
    
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
    
    func resetPoopSlider(){
        if timesToPoop == 1{
            numPoopsLabel.text = String(timesToPoop) + " poop"
        } else{
            numPoopsLabel.text = String(timesToPoop) + " poops"
        }
    }
    
    var timesToPoop = 1
    var numPoops = 1
    var contactNumber = ""
    var cleanedUpNumber = ""
    var firstName = ""
    var lastName = ""
    
    @IBAction func pickContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.predicateForEnablingContact = NSPredicate(format:"phoneNumbers.@count > 0", argumentArray: nil)
        self.presentViewController(contactPicker, animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(picker: CNContactPickerViewController) {
        print("Cancelled picking a contact")
    }
    
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
            contactNumber = (contact.phoneNumbers[0].value as! CNPhoneNumber).stringValue
            firstName = contact.givenName
            lastName = contact.familyName
            print("\(contact.givenName) \(contact.familyName): \(contactNumber)")
            pickAFriendButton.setTitle("\(firstName) \(lastName)", forState: .Normal)
            let stringArray = contactNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            cleanedUpNumber = NSArray(array: stringArray).componentsJoinedByString("")
            poopButton.enabled = true
        } else {
            print("No phone numbers are available")
        }
    }
    
    @IBAction func sendSMS(sender: UIButton) {
        // ADD CHECK TO SEE IF THERE'S A PHONE NUMBER
        numPoops = Int(timesToPoop.value)
        for _ in 1...numPoops {
            print("Cleaned up number is: \(cleanedUpNumber)")
            sendMessage(cleanedUpNumber)
            playFartSound(numPoops)
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
            delayForSeconds(Double(ii)) {
                do {
                    self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("fart", ofType: "mp3")!))
                    self.audioPlayer.play()
                } catch {
                    print("Error")
                }
            }
        }
        delayForSeconds(Double(numPoops)) {
            do {
                self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("flush", ofType: "mp3")!))
                self.audioPlayer.play()
            } catch {
                print("Error")
            }
        }
    }
    
    func delayForSeconds(delay:Double, closure:()->()) {
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
            self.animateFeedbackMessage("You \u{1F4A9} on \(self.firstName) \(self.lastName)", delay: 2)
            self.poopButton.enabled = true
            // UIView.animateWithDuration(0.7, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.numPoopsLabel.alpha = 0.0}, completion: nil)
            self.delayForSeconds(Double(2)) {
                do{
                    
                self.resetPoopSlider()
            }
            }
        
        }
    }
    
    func animateFeedbackMessage(message:String, delay: Double){
        
        self.numPoopsLabel.text = message
        self.numPoopsLabel.alpha = 1.0
        
        // UIView.animateWithDuration(0.7, delay:delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.numPoopsLabel.alpha = 0.0}, completion: nil)
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
        poopButton.enabled = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}