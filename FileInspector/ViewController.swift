//
//  ViewController.swift
//  FileInspector
//
//  Created by hayk on 24.08.2021.
//

import UIKit

let validColor = UIColor.clear.cgColor
let invalidColor = UIColor.red.cgColor

let truePhone = "+79697120001"
let truePassword = "Swift5"

class ViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var sexControl: UISegmentedControl!
    @IBOutlet weak var notificationsStack: UIStackView!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparationOfView()
        addKeyboardGestures()
        switchToAuthorizationMode()
        addDemoLoginButton()
    }
    
    // MARK: Demo Login
    
    func addDemoLoginButton() {
        
        let screenSize = UIScreen.main.bounds.size
        let buttonHeight: CGFloat = 30
        let buttonWidth: CGFloat = screenSize.width * 0.8
        let buttonX = (screenSize.width - buttonWidth)/2
        let buttonY = screenSize.height * 0.9
        
        let button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight))
        button.setTitle("Демонстрационный вход", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(demoLogin), for: .touchUpInside)
        view.addSubview(button)
    }
    
    // MARK: Actions
    
    @objc func demoLogin() {
        login(isDemo: true)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        guard let name = nameField.text,
              let phone = phoneField.text,
              let password = passwordField.text
        else { return }
        
        let isNameValid =
            name.count >= 3 &&
            name.count <= 20 &&
            !name.containsOtherThan(.letters) &&
            name.isCapitalized()
        
        let isPhoneValid1 =
            phone.count == 11 &&
            phone.first == "8" &&
            !phone.containsOtherThan(.nums)
            
        let isPhoneValid2 =
            phone.count == 12 &&
            phone.prefix(2) == "+7" &&
            !String(phone.suffix(10)).containsOtherThan(.nums)
        
        let isPhoneValid = isPhoneValid1 || isPhoneValid2
        
        let isPasswordValid =
            password.count > 5 &&
            password.containsUppercase() &&
            password.containsLowercase() &&
            password.containsOtherThan(.letters) &&
            password.containsOtherThan(.nums)
        
        nameField.layer.borderColor = isNameValid ? validColor : invalidColor
        phoneField.layer.borderColor = isPhoneValid ? validColor : invalidColor
        passwordField.layer.borderColor = isPasswordValid ? validColor : invalidColor
        
        if isNameValid && isPhoneValid {
            
            let fields = """
                name: \(name)
                phone: \(phone)
                age: \(Int(ageSlider.value))
                sex: \(sexControl.titleForSegment(at: sexControl.selectedSegmentIndex)!)
                mailing: \(notificationsSwitch.isOn ? "Yes" : "No")
            """
            
            print(fields)
        }
        
        if isPhoneValid && isPasswordValid {
            if phone == truePhone && password == truePassword {
                login(isDemo: false)
            } else {
                presentAlert(withTitle: "Ошибка",
                             message: "Неверный логин или пароль")
            }
        }
    }
    
    func login(isDemo: Bool) {
        
        if !isDemo {
            UserDefaults.standard.set(true, forKey: authKey)
        }
        
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    @IBAction func ageSliderAction(_ sender: UISlider) {
        ageLabel.text = "Возраст: \(Int(sender.value))"
    }
    
    // MARK: Service
    
    func preparationOfView() {
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .blue
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        ageSlider.value = 34
        
        nameField.setValidBorder()
        phoneField.setValidBorder()
        passwordField.setValidBorder()
    }
    
    func switchToAuthorizationMode() {
        
        nameField.isHidden = true
        ageLabel.isHidden = true
        ageSlider.isHidden = true
        sexControl.isHidden = true
        notificationsStack.isHidden = true
        
        titleLabel.text = "Авторизация"
        loginButton.setTitle("Войти", for: .normal)
        passwordField.isHidden = false
    }
    
    // MARK: Keyboard
    
    func addKeyboardGestures() {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
}

extension String {
    
    enum Chars: String {
        case letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        case nums = "0123456789"
    }
    
    func containsOtherThan(_ chars: Chars) -> Bool {
        let set = CharacterSet(charactersIn: chars.rawValue)
        return self.rangeOfCharacter(from: set.inverted) != nil
    }
    
    func isCapitalized() -> Bool {
        return self == self.capitalized
    }
    
    func containsUppercase() -> Bool {
        return self != self.lowercased()
    }
    
    func containsLowercase() -> Bool {
        return self != self.uppercased()
    }
}

extension UITextField {
    func setValidBorder() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        self.layer.borderColor = validColor
    }
}

extension UIViewController {
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
