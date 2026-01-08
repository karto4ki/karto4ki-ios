//
//  CodeStackView.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 03.01.2026.
//

import UIKit

final class CodeStackView: UIView {
    private var stackView: UIStackView = UIStackView()
    private var textFields: [UITextField] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func getCodeFromTextFields() -> String {
        var code: String = ""
        
        for field in textFields {
            guard let text = field.text, !text.isEmpty else {
                print("Empty text field found")
                return code
            }
            code.append(text)
        }
        print(code)
        return code
    }
    
    private func configure() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        for i in 0..<6 {
            let textField = UITextField()
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            textField.layer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
            textField.textColor = Colors.lilicBAB6FD
            textField.layer.cornerRadius = 15
            textField.textAlignment = .center
            textField.font = UIFont.systemFont(ofSize: 24)
            textField.keyboardType = .numberPad
            textField.delegate = self
            textField.tag = i
            stackView.addArrangedSubview(textField)
            textFields.append(textField)
        }
        
        addSubview(stackView)
        stackView.pin(to: self)
    }
}

extension CodeStackView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !isOnlyDigitsInString(string)
            { return false }
        
        if string.count > 1 {
            pasteString(string)
            return false
        }
        
        if !isInputDigitsOrDeleting(textField, string) {
            return false
        }
        
        if string.isEmpty {
            handleDelete(textField)
        } else {
            handleInput(textField, string)
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
    
    private func pasteString(_ string: String) {
        
        for field in textFields {
            field.text = ""
        }
        
        putOneCharacterInOneField(string)
        setLastTextFieldAsResponder(string)
        
        if areAllTextFieldsFilled() {
            sendRequestToInteractor()
        }
    }
    
    private func handleDelete(_ textField: UITextField) {
        if textField.tag > 0 {
            clearCell(textField.tag)
            setPreviousTextFieldAsResponder(textField)
        } else if textField.tag == 0 {
            clearCell(textField.tag)
        }
    }
    
    private func isInputDigitsOrDeleting(_ textField: UITextField, _ string: String) -> Bool {
        guard let _ = textField.text, string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil || string.isEmpty else {
            return false
        }
        return true
    }
    
    private func handleInput(_ textField: UITextField, _ string: String) {
        textField.text = string
        
        moveToNextTextField(textField)
        
        if areAllTextFieldsFilled() {
            sendRequestToInteractor()
        }
    }
    
    private func moveToNextTextField(_ textField: UITextField) {
        let nextTag = textField.tag + 1
        if nextTag < textFields.count {
            textFields[nextTag].becomeFirstResponder()
        }
    }
    
    private func clearCell(_ textFieldTag: Int) {
        textFields[textFieldTag].text = ""
    }
    
    private func setPreviousTextFieldAsResponder(_ textField: UITextField) {
        let prevTag = textField.tag - 1
        textFields[prevTag].becomeFirstResponder()
    }
    
    private func isOnlyDigitsInString(_ string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        return true
    }
    
    private func putOneCharacterInOneField(_ string: String) {
        for (index, char) in string.enumerated() {
            if index < textFields.count {
                textFields[index].text = String(char)
            }
        }
    }
    
    private func areAllTextFieldsFilled() -> Bool {
        for field in textFields {
            if field.text?.isEmpty == true {
                return false
            }
        }
        return true
    }
    
    private func setLastTextFieldAsResponder(_ string: String) {
        if string.count <= textFields.count {
            textFields[string.count - 1].becomeFirstResponder()
        } else {
            textFields.last?.becomeFirstResponder()
        }
    }
    
    private func sendRequestToInteractor() {
    }
}

