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
    var poopEmojiTemp = ""
    
    @IBAction func poopButtonTouchCancel(sender: AnyObject) {
            poopButton.setImage(UIImage(named: "button.png"), forState: UIControlState.Normal)
    }
    //variables to count poops sent and remaining
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var poopSlider: UISlider!
    var sent = NSUserDefaults.standardUserDefaults().integerForKey("totalSent")
    var remaining =  NSUserDefaults.standardUserDefaults().integerForKey("remaining")
    
    @IBAction func poopButtonTouchDown(sender: AnyObject) {
        poopButton.setImage(UIImage(named: "button_depressed.png"), forState: UIControlState.Normal)
    }
    
    @IBAction func numPoopsSlider(sender: UISlider) {
        timesToPoop = lroundf(sender.value)
        poopEmojiTemp=""
        for var i = 0; i<timesToPoop; ++i{
            poopEmojiTemp += "\u{1F4A9} "
        }
        numPoopsLabel.text = poopEmojiTemp
    }
    
    func numPoopsSliderUpdate(){
        timesToPoop = lroundf(poopSlider.value)
        poopEmojiTemp=""
        for var i = 0; i<timesToPoop; ++i{
            poopEmojiTemp += "\u{1F4A9} "
        }
        print("working?")
        numPoopsLabel.text = poopEmojiTemp
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
            throbPoop()

        } else {
            print("No phone numbers are available")
        }
    }
    
    func throbPoop(){
        // throb poop after contact selected
    }
    

    func hasPoopsToSend() -> Bool {
        if numPoops <= remaining {
            return true
        }
        showNoPoopsLeftAlert() 
        return false
    }
    
    func updatePoopCounts() {
        remaining -= 1
        sent += 1
    }
    
    func updatePoopLabels() {
        sentLabel.text = String(remaining) + " poops remaining"
        remainingLabel.text = String(sent) + " poops sent"
    }
    
    //Alert that no poops left
    func showNoPoopsLeftAlert() {
        let alertController = UIAlertController(title: "No more poops!", message: "Please buy more poops to send", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    func validatePhone(phoneStr: String) -> Bool {
        let regExp = "^\\d{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regExp).evaluateWithObject(phoneStr)
    }
    
    @IBAction func sendSMS(sender: UIButton) {
        poopButton.setImage(UIImage(named: "button.png"), forState: UIControlState.Normal)
        // IF NO FRIEND PICKED, POP UP, ELSE DO THE REST
        if lastName == "" {
            pickContact()
        } else if(!validatePhone(contactNumber)){
        // ERROR
            let alert = UIAlertController(title: "Oh nos!", message: "Invalid phone number", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            lastName = ""
            self.pickAFriendButton.setTitle("Pick a friend", forState: .Normal)
        
        } else{
            numPoops = Int(timesToPoop.value)
            if hasPoopsToSend() {
                for _ in 1...numPoops {
                    sendMessage(cleanedUpNumber)
                    updatePoopCounts()
                    playFartSound(numPoops)
                }
                updatePoopLabels()
            }
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
        
        if(numPoops>1){
            delayForSeconds(Double(numPoops)) {
                do {
                    self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("flush", ofType: "mp3")!))
                    self.audioPlayer.play()
                } catch {
                    print("Error")
                }
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
            self.animateFeedbackMessage("You \u{1F4A9} \(self.firstName) \(self.lastName)", delay: 2)
            self.poopButton.enabled = true
            // UIView.animateWithDuration(0.7, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {self.numPoopsLabel.alpha = 0.0}, completion: nil)
            self.pickAFriendButton.setTitle("Pick a friend", forState: .Normal)
            self.lastName = ""
        }
        let delay2 = Double(numPoops+2) * Double(NSEC_PER_SEC)
        let time2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        dispatch_after(time2, dispatch_get_main_queue()) {
            self.numPoopsSliderUpdate()
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
        updatePoopLabels()
        poopButton.adjustsImageWhenHighlighted = false
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}