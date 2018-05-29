//
//  TimePickerViewController.swift
//  Dont Eat Alone
//
//  Created by Ayush Patel on 5/24/18.
//  Copyright © 2018 Dont Eat Alone. All rights reserved.
//

import UIKit

struct timeData{
    var text: String
    var isSelected: Bool
}

var chosen = [String]()

class TimePickerViewController: UIViewController {
    
    var times: [timeData] = []
//    var times: [String] = ["10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "10:45", "12:00", "12:15"]
    let breakfast_times = ["7:15", "7:30", "7:45", "8:00", "8:15", "8:30", "8:45", "9:00", "9:15", "9:30", "9:45", "10:00", "10:15", "10:30", "10:45", "11:00"]
    let lunch_times = ["11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "1:00", "1:15", "1:30", "1:45", "2:00", "2:15", "2:30","2:45", "3:00"]
    let dinner_times = ["4:15", "4:30", "4:45", "5:00", "5:15", "5:30", "5:45", "6:00", "6:15", "6:30", "6:45", "7:00", "7:15", "7:30","7:45", "8:00"]
    let late_times = ["4:15", "4:30", "4:45", "5:00", "5:15", "5:30", "5:45", "6:00", "6:15", "6:30", "6:45", "7:00", "7:15", "7:30","7:45", "8:00"]

  @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func backgroundButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
  override func viewDidLoad() {
        super.viewDidLoad()
    
        //format the popup view
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    if(MAIN_USER.accessUserInfo(type: "period") == "BR") {
        for i in 0...15
        {
            var time = timeData(text: breakfast_times[i], isSelected: false)
            times.append(time)
        }
    } else if(MAIN_USER.accessUserInfo(type: "period") == "LU") {
        for j in 0...15
        {
            var time = timeData(text: lunch_times[j], isSelected: false)
            times.append(time)
        }
    } else if(MAIN_USER.accessUserInfo(type: "period") == "DI") {
        for d in 0...15
        {
            var time = timeData(text: dinner_times[d], isSelected: false)
            times.append(time)
        }
    } else if(MAIN_USER.accessUserInfo(type: "period") == "LN") {
        for e in 0...15
        {
            var time = timeData(text: late_times[e], isSelected: false)
            times.append(time)
        }
    } else {
        print("No meal period selected")
    }
    
    }
  
  @IBAction func completeActionButton(_ sender: Any) {
    var temp = [String]()
    for i in 0...15 {
        if(times[i].isSelected) {
            temp.append(times[i].text)
        }
    }
    chosen = temp
        dismiss(animated: true, completion: nil)
  }
}

extension TimePickerViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "time", for: indexPath) as! TimePickerCollectionViewCell
        
        cell.timeLabel.layer.cornerRadius = 15
        cell.timeLabel.clipsToBounds = true
        cell.timeLabel.backgroundColor = UIColor.clear
        cell.timeLabel.textColor = UIColor.warmGrey
        
        cell.timeLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        cell.timeLabel.text = times[indexPath.row].text
        return cell
    }
}

extension TimePickerViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped")
        let cell = collectionView.cellForItem(at: indexPath) as! TimePickerCollectionViewCell
        
        if times[indexPath.row].isSelected == false{
            
            cell.timeLabel.backgroundColor = UIColor.twilightBlue
            cell.timeLabel.textColor = UIColor.white
            
            times[indexPath.row].isSelected = true
        }
        else{
            cell.timeLabel.backgroundColor = UIColor.clear
            cell.timeLabel.textColor = UIColor.warmGrey
            
            times[indexPath.row].isSelected = false
        }
    }
}