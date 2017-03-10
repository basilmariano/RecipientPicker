//
//  ViewController.swift
//  RecepientPicker
//
//  Created by Panfilo Mariano on 3/9/17.
//  Copyright © 2017 Panfilo Mariano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var recipientBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var recipientBarView: UIView!
    
    fileprivate var content: [String] = [String]()
    fileprivate let cellHeight: CGFloat = 23.0
    fileprivate let minRecipientBarHeight: CGFloat = 50.0
    fileprivate let maxRecipientBarHeight: CGFloat = 75.0
    fileprivate var indexReadyToDelete: IndexPath?
    fileprivate var isUpdatingContent = false
    fileprivate var textFieldText = " "
    
    //MARK:  View life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        /*
            Add Shadow to the BarView
         */
        recipientBarView.layer.shadowColor = UIColor.black.cgColor
        recipientBarView.layer.shadowOffset = CGSize(width: 0, height: 1)
        recipientBarView.layer.shadowOpacity = 0.5
        recipientBarView.layer.shadowRadius = 1.0
        recipientBarView.clipsToBounds = false
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    
    //MARK:  Fileprivate Functions
    fileprivate func updateCollectionViewHeight() {
        
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        if contentHeight <= minRecipientBarHeight {
            if contentHeight <= minRecipientBarHeight / 2 {
                /*
                    Move the contentOffset to center
                 */
                let scrollViewCenterOffset =  -((collectionView.bounds.height / 2_) - (cellHeight / 2))
                UIView.animate(withDuration: 0.2, animations: {
                    self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y:scrollViewCenterOffset)
                })
            } else {
                recipientBarHeightConstraint.constant = min(minRecipientBarHeight, collectionView.collectionViewLayout.collectionViewContentSize.height)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.layoutIfNeeded()
                    self.recipientBarView.layoutIfNeeded()
                })
            }
        } else {
            recipientBarHeightConstraint.constant = min(maxRecipientBarHeight, collectionView.collectionViewLayout.collectionViewContentSize.height)
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.layoutIfNeeded()
                self.recipientBarView.layoutIfNeeded()
            })
            
            
            let indexPath = IndexPath(row: collectionView.numberOfItems(inSection: 0) - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .init(rawValue: 0), animated: true)
        }
    }
    
    fileprivate func insertNewRecipeint(_ recipient: String) {
        
        if isUpdatingContent == true || recipient.characters.count == 1 {
            return
        }
        
        collectionView.performBatchUpdates({ [weak self] in
            guard let weakSelf = self else { return }
            
            weakSelf.textFieldText = " "
            weakSelf.content.append(recipient)
            let indexPath = IndexPath(row: weakSelf.collectionView.numberOfItems(inSection: 0) - 1, section: 0)
            weakSelf.collectionView.insertItems(at: [indexPath])
            weakSelf.isUpdatingContent = true

        }) {  [weak self] (finished) in
            guard let weakSelf = self else { return }
            weakSelf.isUpdatingContent = false
            weakSelf.updateCollectionViewHeight()
        }
    }
    
    fileprivate func deleteRecipient(_ indexPath: IndexPath) {
        
        if isUpdatingContent == true || content.count == 0  {
            return
        }
        
        collectionView.performBatchUpdates({ [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.isUpdatingContent = true
            weakSelf.content.removeLast()
            weakSelf.collectionView.deleteItems(at: [indexPath])
        }) {  [weak self] (finished) in
            guard let weakSelf = self else { return }
     
            weakSelf.updateCollectionViewHeight()       
            weakSelf.indexReadyToDelete = nil
            weakSelf.isUpdatingContent = false
        }
    }
}

//MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == content.count {
            let textFieldCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCollectionViewCell
            textFieldCell.textField.returnKeyType = .next
            textFieldCell.textField.delegate = self
            
            return textFieldCell
        }
        
        let recipientCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipientCell", for: indexPath)
        let lbl = recipientCell.viewWithTag(1) as! UILabel
        lbl.text = content[indexPath.row]
        
        recipientCell.backgroundColor = UIColor.blue
        if let indexReadyToDelete = indexReadyToDelete {
            if indexPath.row == indexReadyToDelete.row {
               recipientCell.backgroundColor = UIColor.red
            }
        }
        
        return recipientCell
        
    }
}

//MARK: UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (content.isEmpty) {
            let initialWidthForTextfield: CGFloat = 100.0
            return CGSize(width: initialWidthForTextfield, height: cellHeight)
        } else {
            
            if indexPath.row == content.count {
                let string = textFieldText
                let font = UIFont.systemFont(ofSize: 14)
                let width = string.width(withConstrainedHeight: cellHeight, font: font)
                return CGSize(width: width + 33, height: cellHeight)
            } else {
                let string = content[indexPath.row]
                let font = UIFont.systemFont(ofSize: 14)
                let width = string.width(withConstrainedHeight: cellHeight, font: font)
                return CGSize(width: width + 33, height: cellHeight)
            }
        }
        
        /*
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            
            let initialWidthForTextfield: CGFloat = 100.0
            
            let textFieldCell = collectionView.cellForItem(at: indexPath)
            if let textFieldCell = textFieldCell {
                let textField  = textFieldCell.viewWithTag(1) as! UITextField
                
                let width = textField.text!.width(withConstrainedHeight: cellHeight, font: UIFont.systemFont(ofSize: 14)) + 30
                
                return CGSize(width: max(initialWidthForTextfield, width), height: cellHeight)
            }
            
            return CGSize(width: initialWidthForTextfield, height: cellHeight)
           
        } else {
            let string = content[indexPath.row]
            let font = UIFont.systemFont(ofSize: 14)
            let width = string.width(withConstrainedHeight: cellHeight, font: font)
            return CGSize(width: width + 33, height: cellHeight)

        }
         */
        //return indexPath.row % 3 == 0 ? CGSize(width: 100, height: 23) : CGSize(width: 150, height: 23)
        //return CGSize(width: 100, height: 23)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

//MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldText = textField.text!
        insertNewRecipeint(textField.text!)
        
        /*
         Make sure to clear the TextField value after insertion
         
         NOTE: Textfield default value is  " ", we dont want to make the text empty bec. 
         "func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool" function will never be called if trying to click BackScpace if the  textField.text is empty
         */
        textField.text = " "
        textFieldText = textField.text!
        
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
 
        var isBackSpace = false
        
        if (range.length == 1 && string.isEmpty){
            isBackSpace = true
        } else {
            /* 
                Canceled the delete
             */
            if let _ = indexReadyToDelete {
                let indexPath = IndexPath(row: collectionView.numberOfItems(inSection: 0) - 2, section: 0)
                let textFieldCell = collectionView.cellForItem(at: indexPath)
                textFieldCell?.backgroundColor = UIColor.blue
                indexReadyToDelete = nil
            }
        }
        
        /*
         Note: im comparing it to 1 bec. all content will walways start with char " " (e.g) " 09154871557", to fix the isBackSpace issue when textField is empty it will not call "shouldChangeCharactersIn" function
         */
        if textField.text?.characters.count == 1 && isBackSpace == true {
            
            if let indexReadyToDelete = indexReadyToDelete {
                deleteRecipient(indexReadyToDelete)
            } else {
                
                //Nothing to delete later
                if content.count == 0 {
                    return false
                }
                
                //Planning to delete the contact Yet
                let indexPath = IndexPath(row: collectionView.numberOfItems(inSection: 0) - 2, section: 0)
                
                indexReadyToDelete = indexPath
                
                let textFieldCell = collectionView.cellForItem(at: indexPath)
                textFieldCell?.backgroundColor = UIColor.red
            }
            
            return false
        } else {
            /*
                if used comma "," it will automatically convert the text as recipient
             */
            if string == "," {
                textFieldText = textField.text!
                insertNewRecipeint(textField.text!)
                
                /*
                 Make sure to clear the TextField value after insertion
                 
                 NOTE: Textfield default value is  " ", we dont want to make the text empty bec.
                 "func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool" function will never be called if trying to click BackScpace if the  textField.text is empty
                 */
                textField.text = " "
                textFieldText = textField.text!
            } else {
                let nsString = NSString(string: textField.text!)
                let newText = nsString.replacingCharacters(in: range, with: string)
                textFieldText = newText
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
        
        
        
        return true
    }
    
}

extension String {

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let contentString = self as NSString
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = contentString.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.width
    }
}
