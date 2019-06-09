import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var goBtn: UIButton!
    
    @IBAction func goBtnDidPressed(_ sender: UIButton) {
        // Update text view
        responseTextView.text = "Requesting..."
        
        TDSwiftRequest.request(urlString: "http://localhost:3000", method: "POST", body: ["name": "Michael"], headers: ["key": "dhalckjclha"], timeOut: 10) { (data, response, error) in
            DispatchQueue.main.async {
                // Handle error
                if let error = error {
                    self.responseTextView.text = TDSwiftRequest.getRequestErrorMessage(error: error, response: response)
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
