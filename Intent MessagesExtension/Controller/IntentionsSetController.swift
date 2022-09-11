//
//  IntentionsSetController.swift
//  Intent MessagesExtension
//
//  Created by Grant Sheen on 3/2/22.
//

import UIKit
import Messages

class IntentionsSetController: MSMessagesAppViewController {

    @IBOutlet weak var myIntentionsListLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadIntentionsLabel()
    }
    
    func loadIntentionsLabel() {
        var labelText = ""
        for intention in V.intentions {
            labelText += intention
            labelText += "\n\n"
        }
        myIntentionsListLabel.text = labelText
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        createMessage()
    }
    
    func createMessage() {
        print("creating message...")
        let layout = MSMessageTemplateLayout()
        layout.caption = "Josh's Intentions:"
        layout.subcaption = myIntentionsListLabel.text!

        let message = MSMessage()
        message.layout = layout

        self.activeConversation?.insertText("hallo", completionHandler: nil)
    }
    


}
