//
//  PhoneNotificationsViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import UserNotifications

final class PhoneNotificationsViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var dailyPickerView: UIPickerView!
    @IBOutlet weak var weeklyPickerView: UIPickerView!
    @IBOutlet weak var noRemindersLabel: UILabel!
    
    @IBOutlet weak var saveChangesButton: RoundedButton!
    
    // MARK: - Properties
    var dailyPickerViewData = [[String]]()
    var weeklyPickerViewData = [[String]]()
    
    var weekday: Int = 0
    var hour   : Int = 1
    var minute : Int = 0

    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = Constants.Color.primary
        dailyPickerView.isHidden  = false
        weeklyPickerView.isHidden = true

        // Setup the picker views
        dailyPickerView.delegate    = self
        dailyPickerView.dataSource  = self
        
        weeklyPickerView.delegate   = self
        weeklyPickerView.dataSource = self
        
        // Set up the no reminders label
        noRemindersLabel.isHidden = true
        noRemindersLabel.adjustsFontSizeToFitWidth = true
        
        // Set the data for the weekly picker view and daily picker view
        weeklyPickerViewData.append(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
        
        dailyPickerViewData.append(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"])
        weeklyPickerViewData.append(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"])
        
        dailyPickerViewData.append(["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
                                    "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
                                    "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
                                    "30", "31", "32", "33", "34", "35", "36", "37", "38", "39",
                                    "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
                                    "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"])
        
        weeklyPickerViewData.append(["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
                                     "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
                                     "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
                                     "30", "31", "32", "33", "34", "35", "36", "37", "38", "39",
                                     "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
                                     "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"])
        
        dailyPickerViewData.append(["AM", "PM"])
        weeklyPickerViewData.append(["AM", "PM"])
        
        // Select appropriate starting rows so that the picker views have their hours and minutes set to 1:00
        dailyPickerView.selectRow(5004, inComponent: 0, animated: false)
        dailyPickerView.selectRow(4980, inComponent: 1, animated: false)
        
        weeklyPickerView.selectRow(5004, inComponent: 1, animated: false)
        weeklyPickerView.selectRow(4980, inComponent: 2, animated: false)
        
        // Setup the save changes button
        saveChangesButton.backgroundColor    = Constants.Color.primary
        
    }

}

// MARK: - Segmented Control Methods
extension PhoneNotificationsViewController {
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        // Show the daily picker view if "Daily" is selected
        if segmentedControl.selectedSegmentIndex == 0 {
            dailyPickerView.isHidden  = false
            weeklyPickerView.isHidden = true
            noRemindersLabel.isHidden = true
        }
        // Show the weekly picker view if "Weekly is selected"
        else if segmentedControl.selectedSegmentIndex == 1 {
            dailyPickerView.isHidden  = true
            weeklyPickerView.isHidden = false
            noRemindersLabel.isHidden = true
        }
        else {
            dailyPickerView.isHidden  = true
            weeklyPickerView.isHidden = true
            noRemindersLabel.isHidden = false
        }
        
    }
    
}

// MARK: - Picker View Methods
extension PhoneNotificationsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        // If "Daily" is selected then return components for Hour, Minute, AM/PM
        if pickerView == dailyPickerView {
            return 3
        }
        // If "Weekly" is selected, then return components for Weekday, Hour, Minute AM/PM
        else {
            return 4
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        // If the dailyPickerView...
        if pickerView == dailyPickerView {
            
            // Loop the hour and minute components
            if component == 0 || component == 1 {
                return 10000
            }
            
            return dailyPickerViewData[component].count
            
        }
        // If the weeklyPickerView...
        else {
            
            // Loop the hour and minute components
            if component == 1 || component == 2 {
                return 10000
            }
            
            return weeklyPickerViewData[component].count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        // Create a label
        var label: UILabel
        
        // If the view can be cast as a label, let the label be the view
        if let view = view as? UILabel {
            label = view
        }
        // Otherwise, create a new label
        else {
            label = UILabel()
        }
        
        // If on the daily picker view...
        if pickerView == dailyPickerView {
            label.text = String(dailyPickerViewData[component][row % dailyPickerViewData[component].count])
            
            if component == 0 {
                label.textAlignment = .right
            }
            else {
                label.textAlignment = .center
            }
            
        }
        // If on the weekly picker view
        else if pickerView == weeklyPickerView {
            label.text = String(weeklyPickerViewData[component][row % weeklyPickerViewData[component].count])
            
            if component == 1 {
                label.textAlignment = .right
            }
            else {
                label.textAlignment = .center
            }
            
        }
    
        label.adjustsFontSizeToFitWidth = true
        
        // Return the created label
        return label
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        // Give the picker views a row height of 30
        return 30
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // If the dailyPickerView...
        if pickerView == dailyPickerView {
            // Match the segment in the other picker view
            weeklyPickerView.selectRow(row, inComponent: component + 1, animated: false)
            
            if component == 0      { hour   = (row % 12) + 1}
            else if component == 1 { minute = row % 60      }
            
            // Add 12 to the hour if PM
            if dailyPickerView.selectedRow(inComponent: 2) == 1 && hour <= 12 { hour += 12 }
            
        }
        else {
            
            // Match the segment in the other picker view
            if component != 0 { dailyPickerView.selectRow(row, inComponent: component - 1, animated: false) }
            
            if component == 0      { weekday = row + 1}
            else if component == 1 { hour   = (row % 12) + 1}
            else if component == 2 { minute = row % 60      }
            
            // Add 12 to the hour if PM
            if weeklyPickerView.selectedRow(inComponent: 3) == 1 && hour <= 12 { hour += 12 }
            
        }
        
        if hour == 24 { hour = 0 }
        
    }
    
}

// MARK: - Save Changes Button Methods
extension PhoneNotificationsViewController {
    
    @IBAction func saveChangesButtonTapped(_ sender: UIButton) {
        
        // Create a daily notification
        if segmentedControl.selectedSegmentIndex == 0 {
            NotificationService.createTimedNotification(hour: hour, minute: minute, repeats: true)
        }
        // Create a weekly notification
        else if segmentedControl.selectedSegmentIndex == 1 {
            NotificationService.createTimedNotification(weekday: weekday, hour: hour, minute: minute, repeats: true)
        }
        else {
            NotificationService.removeTimedNotification()
        }
        
        // Show that the process was successful
        ProgressService.successAnimation(text: "Successfully Chenged Your Notification Settings")
        
        // Navigate back to the settings page
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
