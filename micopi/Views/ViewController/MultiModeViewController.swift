//
//  MultiModeViewController.swift
//  micopi
//
//  Created by michel@easy-target.org on 2017-03-06.
//  Copyright © 2017 Easy Target. All rights reserved.
//

import ContactsUI

class MultiModeViewController: ContactAccessViewController {
    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    enum Mode {
        case assign
        case reset
    }
    
    var mode: Mode!
    
    fileprivate var contacts: [MiContact]?
    
    fileprivate var isProcessing = false
    
    fileprivate var stopped = false
    
    fileprivate var imageFactory: ImageFactory?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = ColorPalette.backgroundGradient
        view.layer.insertSublayer(gradient, at: 0)
        
        informationLabel.text = ""
        
        continueButton.isHidden = true
        continueButton.isEnabled = false
        
        backButton.isHidden = true
        backButton.isEnabled = false
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        guard contacts.count > 0 else {
            let _ = navigationController?.popViewController(animated: true)
            return
        }
        
        self.contacts = [MiContact]()
        for contact in contacts {
            self.contacts!.append(MiContact(cn: contact))
        }
        
        if mode == .assign {
            showAssignMessage()
        } else if mode == .reset {
            showResetMessage()
        }
        
        continueButton.isHidden = false
        continueButton.isEnabled = true
        
        backButton.isHidden = false
        backButton.isEnabled = true
    }
    
    fileprivate func showAssignMessage() {
        let numberOfContacts = self.contacts!.count
        let imageNoun = numberOfContacts > 1 ? "images" : "image"
        informationLabel.text = "Please confirm that you would like to overwrite \(numberOfContacts) contact \(imageNoun)."
    }
    
    fileprivate func showResetMessage() {
        let numberOfContacts = self.contacts!.count
        let imageNoun = numberOfContacts > 1 ? "images" : "image"
        informationLabel.text = "Please confirm that you would like to delete \(numberOfContacts) contact \(imageNoun)."
    }
    
    @IBAction func onContinueButtonTouched(_ sender: Any) {
        if mode == .assign {
            startGeneratingAndAssigning()
        } else if mode == .reset {
            startResetting()
        }
    }
    
    @IBAction func onBackButtonTouched(_ sender: Any) {
        if isProcessing {
            stopProcessing()
        } else {
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func startGeneratingAndAssigning() {
        
        guard !isProcessing else {
            NSLog("MultiModeViewController: startProcessing(): ERROR: Already processing!")
            return
        }
        
        stopped = false
        continueButton.isHidden = true
        continueButton.isEnabled = false
        backButton.setTitle("Back", for: .normal)
        
        DispatchQueue.global().async {
            // Background thread
            
            self.isProcessing = true
            
            for contact in self.contacts! {
                if self.stopped {
                    self.isProcessing = false
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self.informationLabel.text = "Generating image for \(contact.displayName)."
                })
                self.imageFactory = ImageFactory.init(contact: contact)
                
                if let image = self.imageFactory?.generateInThread() {
                    if self.stopped {
                        self.isProcessing = false
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.informationLabel.text = "Assigning new image to \(contact.displayName)."
                    })
                    
                    let _ = ContactPictureWriter.assign(image, toContact: contact)
                } else {
                    NSLog("MultiModeViewController: startProcessing(): WARNING: No image generated for \(contact).")
                }
            }
            
            self.isProcessing = false
            self.showDoneMessage()
        }
        
    }
    
    fileprivate func startResetting() {
        guard !isProcessing else {
            NSLog("MultiModeViewController: startProcessing(): ERROR: Already processing!")
            return
        }
        
        stopped = false
        continueButton.isHidden = true
        continueButton.isEnabled = false
        backButton.setTitle("Back", for: .normal)

        DispatchQueue.global().async {
            // Background thread
            
            self.isProcessing = true
            
            for contact in self.contacts! {
                if self.stopped {
                    self.isProcessing = false
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self.informationLabel.text = "Deleting image of \(contact.displayName)."
                })
                
                let _ = ContactPictureWriter.delete(imageOfContact: contact)
            }
            
            self.isProcessing = false
            self.showDoneMessage()
        }
    }
    
    fileprivate func showDoneMessage() {
        
        let actionVerb = mode == .reset ? "Deleted" : "Assigned"
        let imageNoun = contacts!.count > 1 ? "images" : "image"
        informationLabel.text = "\(actionVerb) \(contacts!.count) \(imageNoun)."
        
        contacts = nil

        continueButton.isHidden = true
        continueButton.isEnabled = false
        backButton.setTitle("Back", for: .normal)
    }
    
    fileprivate func stopProcessing() {
        imageFactory?.stop()
        stopped = true
        
        informationLabel.text = "Canceled."
        backButton.setTitle("Back", for: .normal)
    }
}