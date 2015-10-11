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
    
    @IBAction func poopButtonTouchCancel(sender: AnyObject) {
            poopButton.setImage(UIImage(named: "button.png"), forState: UIControlState.Normal)
    }
    
    //variables to count poops sent and remaining
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var poopSlider: UISlider!
    
    @IBAction func poopButtonTouchDown(sender: AnyObject) {
        poopButton.setImage(UIImage(named: "button_depressed.png"), forState: UIControlState.Normal)
    }
    
    @IBAction func numPoopsSlider(sender: UISlider) {
        numPoopsSliderUpdate()
    }
    
    func numPoopsSliderUpdate(){
        timesToPoop = lroundf(poopSlider.value)
        var poopEmojiTemp=""
        for var i = 0; i<timesToPoop; ++i{
            poopEmojiTemp += "\u{1F4A9} "
        }
        numPoopsLabel.text = poopEmojiTemp
    }
    
    var timesToPoop = 1
    var cleanedUpNumber = ""
    var firstName = ""
    var lastName = ""
    var audioPlayer: AVAudioPlayer!
    var thePoopBank: poopBank
    
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
            
            let contactNumber = (contact.phoneNumbers[0].value as! CNPhoneNumber).stringValue
            let stringArray = contactNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            cleanedUpNumber = NSArray(array: stringArray).componentsJoinedByString("")
            
            if(validatePhone(cleanedUpNumber)){
                firstName = contact.givenName
                lastName = contact.familyName
                print("\(contact.givenName) \(contact.familyName): \(contactNumber)")
                pickAFriendButton.setTitle("\(firstName) \(lastName)", forState: .Normal)
                poopButton.enabled = true
                self.dismissViewControllerAnimated(true, completion: {self.throbPoop()})
            } else {
                let alert = UIAlertController(title: "Oh nos!", message: "Invalid phone number", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
                picker.presentViewController(alert, animated: true, completion: nil)
            }

        } else {
            print("No phone numbers are available")
        }
    }
    
    func validatePhone(phoneStr: String) -> Bool {
        let regExp = "^\\d{10}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", regExp).evaluateWithObject(phoneStr)
        return isValid
    }
    
    func throbPoop(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 0
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(poopButton.center.x, poopButton.center.y - 3))
        animation.toValue = NSValue(CGPoint: CGPointMake(poopButton.center.x, poopButton.center.y + 3))
        poopButton.layer.addAnimation(animation, forKey: "position")
    }

    
    func updatePoopCountLabels() {
        sentLabel.text = String(thePoopBank.poopsRemaining) + " \u{1F4A9} remaining today"
        remainingLabel.text = String(thePoopBank.poopsSent) + " \u{1F4A9} sent today"
    }
    
    //Alert that no poops left
    func showNoPoopsLeftAlert() {
        let alertController = UIAlertController(title: "No more poops!", message: "Come back tomorrow!", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendSMS(sender: UIButton) {
        poopButton.setImage(UIImage(named: "button.png"), forState: UIControlState.Normal)
        if lastName == "" {
            pickContact()
        } else {
            if thePoopBank.canSendPoops(Int(timesToPoop.value)) {
                sendPoop(Int(timesToPoop.value))
            }
            else {
                showNoPoopsLeftAlert()
            }
        }
    }
    
    // Main fuction to trigger poop texts
    func sendPoop(numberOfPoopsToSend: Int) {
        print("Sending \(numberOfPoopsToSend) poops")
        triggerSendingUI(numberOfPoopsToSend)
        sendSMSMessage(cleanedUpNumber,numberOfPoopsToSend: numberOfPoopsToSend)
        thePoopBank.sendPoops(numberOfPoopsToSend)
        savePoopBank()
        updatePoopCountLabels()
        playFartSound(numberOfPoopsToSend)
    }
    
    func sendSMSMessage(number: String,numberOfPoopsToSend: Int){
        for _ in 1...numberOfPoopsToSend {
            let urlToSend = NSURL(string:"http://tellmewhich.com/poop.php?phone=" + number)
            let request = NSMutableURLRequest(URL: urlToSend!)
            request.HTTPMethod = "GET"
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request)
            task.resume()
        }
    }
    
    func triggerSendingUI(numberOfPoopsToSend: Int){
        poopButton.enabled = false
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.5
        animation.repeatCount = Float(numberOfPoopsToSend)
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(poopButton.center.x, poopButton.center.y - 3))
        animation.toValue = NSValue(CGPoint: CGPointMake(poopButton.center.x, poopButton.center.y + 3))
        poopButton.layer.addAnimation(animation, forKey: "position")
        numPoopsLabel.text = "pooping..."
        
        delayForSeconds(numberOfPoopsToSend) {
            self.numPoopsLabel.text = "You \u{1F4A9} \(self.firstName) \(self.lastName)"
            self.poopButton.enabled = true
            self.pickAFriendButton.setTitle("Pick a friend", forState: .Normal)
            self.lastName = ""
        }
        delayForSeconds(numberOfPoopsToSend+5) {self.numPoopsSliderUpdate()}
    }
    
    func playFartSound(numPoops: Int){
        for ii in 0...(numPoops-1){
            playSoundInSeconds("fart", ofType: "mp3", inSeconds: ii)
        }
        if(numPoops>1){
            playSoundInSeconds("flush", ofType: "mp3", inSeconds: numPoops)
        }
    }
    
    func delayForSeconds(delayInSeconds:Int, toExecute:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(Double(delayInSeconds) * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), toExecute)
    }
    
    func playSoundInSeconds(fileName:String,ofType:String,inSeconds:Int) {
        delayForSeconds(inSeconds) {
            do {
                self.audioPlayer =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: ofType)!))
                self.audioPlayer.play()
            } catch {
                print("Error")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePoopCountLabels()
        poopButton.adjustsImageWhenHighlighted = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
            return (documentsDirectory() as NSString).stringByAppendingPathComponent("userStats.plist")
    }
    
    required init?(coder aDecoder: NSCoder) {
        thePoopBank = poopBank()
        super.init(coder: aDecoder)
        loadPoopBank()
    }
    
    func savePoopBank() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(thePoopBank, forKey: "PoopBank")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadPoopBank() {
            let path = dataFilePath()
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            thePoopBank = unarchiver.decodeObjectForKey("PoopBank") as! poopBank
            unarchiver.finishDecoding()
            }
            }
    }
}