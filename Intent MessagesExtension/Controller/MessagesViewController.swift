//
//  MessagesViewController.swift
//  Intent MessagesExtension
//
//  Created by Grant Sheen on 3/1/22.
//

import UIKit
import Messages

class MyCell: UITableViewCell {
    
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var index = -1
    var parent = MessagesViewController()
    
//    func loadViews() {
//        print("load images called")
//        paperPlaneButton.setImage(UIImage(named: "paperplane"), for: .normal)
//    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if textField.text != "" {
            V.intentions[index] = "n:" + textField.text!
        }
    }
    @IBAction func checkBoxButtonPressed(_ sender: UIButton) {
        V.intentions[index] = V.intentions[index].toggleChecked()
        parent.myTableView.reloadData()
    }

    
}

class MessagesViewController: MSMessagesAppViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
        
    @IBOutlet weak var addButtonTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        V.intentions = ["n:"]
        
        requestPresentationStyle(.expanded)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if V.intentions == ["n:"] { return }
        
        createMessage()
        requestPresentationStyle(.compact)
        
//        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
//        let intentionsSetVC = storyboard.instantiateViewController(withIdentifier: "intentionsSetController") as! IntentionsSetController
//        present(intentionsSetVC, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        V.intentions.append("n:")
        myTableView.reloadData()
        resetAddButtonTopConstraint()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return V.intentions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCell
        let intention = V.intentions[indexPath.row]
        print("intention is ", intention, V.intentions, indexPath.row)
        cell.textField.text = intention.getMessage()
//        cell.loadViews()
//        cell.checkMark.image = UIImage(named: "CheckBox")
        
//        cell.checkBoxButton.imageView?.contentMode = .scaleAspectFit
//        cell.checkBoxButton.contentVerticalAlignment = .fill
//        cell.checkBoxButton.contentHorizontalAlignment = .fill
//        cell.checkBoxButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        if intention.getChecked() == true {
//            cell.checkBoxButton.setTitle("✅", for: .normal)
            cell.checkBoxButton.setImage(UIImage(named: "CheckBoxChecked"), for: .normal)
            cell.checkBoxButton.imageView?.layer.transform = CATransform3DMakeScale(1.18, 1.18, 1.18)
        } else {
//            cell.checkBoxButton.setTitle("⬜", for: .normal)
            cell.checkBoxButton.setImage(UIImage(named: "CheckBox"), for: .normal)
            cell.checkBoxButton.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
        }
        cell.index = indexPath.row
        cell.parent = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func createMessage() {
        
        let session = MSSession()
        let message = MSMessage.init(session: session)
        
        var messageContent = ""
        for intention in V.intentions {
            messageContent += intention.getChecked() ? "✅" : "⬜"
            messageContent += intention.getMessage()
            messageContent += "\n"
        }
        let layout = MSMessageTemplateLayout()
        layout.caption = "My Intentions (\(V.intentions.getCheckedCount())/\(V.intentions.count))"
        layout.subcaption = messageContent

        message.layout = layout
        message.url = createUrl(intentions: V.intentions)
        
        self.activeConversation?.insert(message, completionHandler: nil)
    }
    
    func createUrl(intentions: [String]) -> URL {
        var components = URLComponents()
        let intentionsQueryItem = URLQueryItem(name: "intentions", value: V.intentions.stringify())
        components.queryItems = [intentionsQueryItem]
        
        return components.url!
    }
    
    func createStringFromURL(url: URL) -> String {
        print("URL PASSED IN IS ", url)
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("The message contains an invalid URL")
        }
        if let queryItems = components.queryItems {
            let intentions = queryItems[0].value!
            return intentions
        }
        
        return "something in createStringFromURL messed up"
    }
    
    func resetAddButtonTopConstraint() {
        print("top constraint is ", addButtonTopConstraint.constant)
        addButtonTopConstraint.constant = 80.5 + CGFloat(44*(V.intentions.count-1))
        print("new constraint is ", addButtonTopConstraint.constant)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            V.intentions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        myTableView.reloadData()
        resetAddButtonTopConstraint()
    }
        

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        requestPresentationStyle(.expanded)
        
        print("creating string from url: ", conversation, conversation.selectedMessage, conversation.selectedMessage?.url)
        
        if conversation.selectedMessage?.url != nil {
            let url = createStringFromURL(url: (conversation.selectedMessage?.url)!)
            V.intentions = url.unStringify()
            resetAddButtonTopConstraint()
        }
        myTableView.reloadData()
        
//        print("the URL is ", conversation.selectedMessage?.url, conversation, conversation.selectedMessage)
//        print("URL is ", url)
//        print("unStringified URL is ", url.unStringify())
        
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }


}
