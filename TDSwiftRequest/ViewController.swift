import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var goBtn: UIButton!
    
    @IBAction func goBtnDidPressed(_ sender: UIButton) {
        // Update text view
        responseTextView.text = "Requesting..."
        
        TDSwiftRequest.request(urlString: "http://localhost:3000", method: "DELETE", body: ["name": [["a": 1], ["b": ["c": 3]]]], headers: ["key": "dhalckjclha"], timeOutInS: 3) { (data, response, error) in
            DispatchQueue.main.async {
                // Handle error
                if let error = error {
                    self.responseTextView.text = TDSwiftRequest.parseErrorMessage(error: error, response: response)
                    return
                }
                
                // Display response
                if let data = data {
                    self.responseTextView.text = String(describing: data)
                } else {
                    self.responseTextView.text = "No response found"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        responseTextView.text = "Standby"
    }
}
