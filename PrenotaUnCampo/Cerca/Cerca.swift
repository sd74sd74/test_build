//
//  Cerca.swift
//  PrenotaUnCampo
//
//  Created by Stefano Demattè on 02/11/2018.
//  Copyright © 2018 StefanoDemattè. All rights reserved.
//
import UIKit
import Foundation

class Cerca: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var iconMarker: UIImageView!
    @IBOutlet var iconSearch: UIImageView!
    @IBOutlet var iconWatch: UIImageView!
    
    @IBOutlet var fieldDove: UITextField!
    @IBOutlet var fieldCosa: UITextField!
    @IBOutlet var fieldQuando: UITextField!

    let datePicker = UIDatePicker()
    let datePickerContainer = UIView()

    let myYellowColor = UIColor(red: 255/255, green: 202/255, blue: 9/255, alpha: 1.0)
    
    var sportList: [Dictionary<String, Any>]!

    let sportPicker: UIPickerView = UIPickerView()
    let sportPickerContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.navigationBar.tintColor = UIColor.white
        iconMarker.image = iconMarker.image!.withRenderingMode(.alwaysTemplate)
        iconMarker.tintColor = myYellowColor
        iconSearch.image = iconSearch.image!.withRenderingMode(.alwaysTemplate)
        iconSearch.tintColor = myYellowColor
        iconWatch.image = iconWatch.image!.withRenderingMode(.alwaysTemplate)
        iconWatch.tintColor = myYellowColor
        
        fieldDove.attributedPlaceholder = NSAttributedString(string: "Inserisci la posizione", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        fieldCosa.attributedPlaceholder = NSAttributedString(string: "Scegli...", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        fieldQuando.attributedPlaceholder = NSAttributedString(string: "Quando...", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])

        self.getSportList()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == fieldDove {
            return true
        } else {
            fieldDove.resignFirstResponder()
            if textField == fieldQuando {
                self.showDatePicker()
            }
            if textField == fieldCosa {
                if self.sportList != nil && self.sportList.count > 0 {
                    self.showSportPicker()
                } else {
                    self.showAlert(myTitle: "ALERT", myMessage: "Non è stato possibile recuperare l'elenco degli sport\nSi prega rirovare")
                }
            }
            return false
        }
    }
    
    func showDatePicker(){
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval=30;
        datePickerContainer.frame = CGRect(x:0.0, y:self.view.frame.size.height-datePicker.frame.height, width:self.view.frame.size.width, height:datePicker.frame.height)
        datePickerContainer.backgroundColor = UIColor.lightGray
        datePickerContainer.addSubview(datePicker)

        let doneButton = UIButton()
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.addTarget(self, action:#selector(doneDatePicker), for: .touchUpInside)
        doneButton.frame = CGRect(x:datePickerContainer.frame.size.width-75, y:5.0, width:70.0, height:37.0)
        
        datePickerContainer.addSubview(doneButton)
        
        self.view.addSubview(datePickerContainer)
    }
    
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        fieldQuando.text = formatter.string(from: datePicker.date)
        datePickerContainer.removeFromSuperview()
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func actTrova(_ sender: Any) {
        if self.fieldDove.text == "" || self.fieldCosa.text == "" || self.fieldQuando.text == "" {
            self.showAlert(myTitle: "ALERT", myMessage: "Uno o più campi non sono stati compilati!")
        } else {
            UserDefaults.standard.set(self.fieldCosa.text, forKey: "myCosa")
            UserDefaults.standard.set(self.fieldQuando.text, forKey: "myQuando")
            self.performGoogleSearch(for: self.fieldDove.text!)
        }
    }
    
    func performGoogleSearch(for string: String) {
        UserDefaults.standard.set(0, forKey: "myLatitude")
        UserDefaults.standard.set(0, forKey: "myLongitude")

        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        let key = URLQueryItem(name: "key", value: "AIzaSyAn-tmMRedrQ-g8A7jWIioYBUY3cqhQuGc")
        let address = URLQueryItem(name: "address", value: string)
        components.queryItems = [key, address]
        
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                return
            }
            
            guard let json = try! JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                return
            }
            
            guard let results = json["results"] as? [[String: Any]],
                let geometry = results[0]["geometry"] as? [String:AnyObject],
                let location = geometry["location"] as? [String:Double],
                let lat = location["lat"],
                let lng = location["lng"],
                let status = json["status"] as? String,
                status == "OK"
                else{
                    self.showAlert(myTitle: "ALERT", myMessage: "Non è stato possibile trovare la posizione richiesta!\nSi prega rirovare")
                    return
            }
            if (lat == 0 && lng == 0) {
                self.showAlert(myTitle: "ALERT", myMessage: "Non è stato possibile trovare la posizione richiesta!\nSi prega rirovare")
            } else {
                UserDefaults.standard.set(lat, forKey: "myLatitude")
                UserDefaults.standard.set(lng, forKey: "myLongitude")
                self.continua()
            }

        }
        
        task.resume()
    }

    func getSportList() {
        
        let components = URLComponents(string: "https://www.prenotauncampo.it/rest/sports")!
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                return
            }
            
            guard let json = try! JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                return
            }

            guard let passDic = json["data"]!["list"] as? [[String:Any]]
                else{
                    self.showAlert(myTitle: "ALERT", myMessage: "Non è stato possibile recuperare l'elenco degli sport\nSi prega rirovare")
                    return
            }
            if (passDic.count == 0) {
                self.showAlert(myTitle: "ALERT", myMessage: "Non è stato possibile recuperare l'elenco degli sport\nSi prega rirovare")
            } else {
                self.sportList = passDic
                
            }
            
        }
        
        task.resume()
    }
    
    func showSportPicker(){
        sportPicker.dataSource = self
        sportPicker.delegate = self
        sportPickerContainer.frame = CGRect(x:0.0, y:self.view.frame.size.height-sportPicker.frame.height, width:self.view.frame.size.width, height:sportPicker.frame.height)
        sportPicker.frame.size.width = sportPickerContainer.frame.size.width-20
        sportPickerContainer.backgroundColor = UIColor.lightGray
        sportPickerContainer.addSubview(sportPicker)
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.addTarget(self, action:#selector(doneSportPicker), for: .touchUpInside)
        doneButton.frame = CGRect(x:sportPickerContainer.frame.size.width-75, y:5.0, width:70.0, height:37.0)
        
        sportPickerContainer.addSubview(doneButton)
        
        self.view.addSubview(sportPickerContainer)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sportList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.sportList[row]["name"] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        typeBarButton.title = array[row]["type1"] as? String
        self.sportPickerContainer.isHidden = false
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width-20
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    @objc func doneSportPicker(){
        fieldCosa.text = self.sportList[sportPicker.selectedRow(inComponent: 0)]["name"] as! String
        sportPickerContainer.removeFromSuperview()
        self.view.endEditing(true)
    }

    func continua() {
        OperationQueue.main.addOperation {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "riassunto") as! Riassunto
            self.navigationController?.pushViewController(newViewController, animated: true)
//            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    func showAlert(myTitle: String, myMessage: String) {
        // create the alert
        let alert = UIAlertController(title: myTitle, message: myMessage, preferredStyle: .alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}

