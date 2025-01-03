//
//  NewTrackerViewControllerDelegate.swift
//  Tracker
//
//  Created by Ilya Nikitash on 12/25/24.
//
import Foundation

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didTabCreateButton(categoryTitle: String, trackerToAdd: TrackerModel)
    func didTabCancelButton()
}
