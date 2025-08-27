import UIKit
import Alamofire

class TimeOutViewController: UIViewController {
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var loginItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginItem.setTitleTextAttributes([
            .foregroundColor: UIColor.red,
            .font: UIFont(name: "PSL Display", size: 28) ?? .systemFont(ofSize: 28)
        ], for: .normal)

        txtView.textColor = .black
        txtView.font = UIFont(name: "PSL Display", size: 28) ?? .systemFont(ofSize: 28)
        txtView.textAlignment = .center

        if !CustomerViewController.GlobalValiable.table_name.isEmpty {
            dropDbfTable()
        }
    }

    @IBAction func btnLogin(_ sender: Any) {
        // ถ้าใช้ Storyboard แนะนำ instantiate ด้วย identifier
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            // fallback ถ้าไม่ได้ใช้ storyboard
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    private func dropDbfTable() {
        // แนะนำใช้ https ถ้าเป็นไปได้ (หลีกเลี่ยง ATS issue)
        let url = "http://consign-ios.adda.co.th/KeyOrders/dropDbfTable.php"

        let parameters: Parameters = [
            "tbname": CustomerViewController.GlobalValiable.table_name
        ]

        AF.request(url, method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .response { [weak self] response in
                switch response.result {
                case .success:
                    print("dropDbfTable OK")
                    // ใช้งาน self ต่อถ้าต้องอัปเดต UI
                    _ = self
                case .failure(let error):
                    print("dropDbfTable error:", error)
                }
            }
    }
}

