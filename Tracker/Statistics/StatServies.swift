//
//  StatServies.swift
//  Tracker
//
//  Created by Ilya Nikitash on 3/2/25.
//
import Foundation

final class StatService: StatServiceProtocol {
    
    // MARK: - Properties
    
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    // MARK: - getStatistic
    
    func getStatistic() -> [StatModel] {
        let allTrackerRecord = trackerRecordStore.fetchAllRecords()
        let allCategories = trackerCategoryStore.fetchAllCategories()
        
        let bestPeriod = getBestPeriod(from: allTrackerRecord, allCategories: allCategories)
        let perfectDays = getPerfectDays(allCategories: allCategories, records: allTrackerRecord)
        let completedTrackers = getCompletedTrackersFrom(allTrackerRecord)
        let averageCompletedTrackers = getAverageCompletedTrackersFrom(allTrackerRecord)
        
        if
            bestPeriod == 0,
            perfectDays == 0,
            completedTrackers == 0,
            averageCompletedTrackers == 0
        {
            return []
        }
        
        return [
            StatModel(
                title: bestPeriod.description,
                description: NSLocalizedString("best_period", comment: "")
            ),
            StatModel(
                title: perfectDays.description,
                description: NSLocalizedString("ideal_days", comment: "")
            ),
            StatModel(
                title: completedTrackers.description,
                description: NSLocalizedString("trackers_completed", comment: "")
            ),
            StatModel(
                title: averageCompletedTrackers.description,
                description: NSLocalizedString("average_value", comment: "")
            ),
        ]
    }
}

private extension StatService {
    
    // MARK: - getCompletedTrackersFrom
    
    private func getCompletedTrackersFrom(_ allRecords: [TrackerRecordModel]) -> Int {
        Set(allRecords).count
    }
    
    // MARK: - getAverageCompletedTrackersFrom
    
    private func getAverageCompletedTrackersFrom(_ allRecords: [TrackerRecordModel]) -> Double {
        let groupedRecords = Dictionary(grouping: allRecords, by: { Calendar.current.startOfDay(for: $0.date) })
        let totalDays = groupedRecords.count
        let totalCompletedTrackers = allRecords.count
        
        guard totalDays > 0 else {
            return 0.0
        }
        let number = Double(totalCompletedTrackers) / Double(totalDays)
        return round(number * 100) / 100
    }
    
    // MARK: - getBestPeriod
    
    private func getBestPeriod(from allRecords: [TrackerRecordModel], allCategories: [TrackerCategoryModel]) -> Int {
        let allTrackers = allCategories.flatMap {
            $0.trackers
        }
        
        var maxStreak = 0
        
        for tracker in allTrackers {
            let allTrackersRecords = allRecords.filter {
                tracker.id == $0.id
            }.sorted { $0.date < $1.date }
            
            var currentStreak = 1
            
            if allTrackersRecords.count < 2 {
                maxStreak = max(maxStreak, currentStreak)
                continue
            }
            
            for i in 1..<allTrackersRecords.count {
                let previousDate = allTrackersRecords[i - 1].date
                let currentDate = allTrackersRecords[i].date
                
                if
                    let inSameDayAs = Calendar.current.date(byAdding: .day, value: 1, to: previousDate),
                    Calendar.current.isDate(currentDate, inSameDayAs: inSameDayAs)
                {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
            
            maxStreak = max(maxStreak, currentStreak)
        }
        
        return maxStreak
    }
    
    // MARK: - getPerfectDays
    
    private func getPerfectDays(allCategories: [TrackerCategoryModel], records allTrackerRecords: [TrackerRecordModel]) -> Int {
        let allTrackers = allCategories.flatMap {
            $0.trackers
        }
        
        guard !allTrackers.isEmpty && !allTrackerRecords.isEmpty else { return 0 }
        
        var completionsByDay: [Date: [UUID]] = [:]
        
        for record in allTrackerRecords {
            let calendar = Calendar.current
            let dateWithoutTime = calendar.startOfDay(for: record.date) 
            completionsByDay[dateWithoutTime, default: []].append(record.id)
        }
        
        var successfulDaysCount = 0
        
        for (date, completedTrackers) in completionsByDay {
            if let dayOfWeek = Calendar.current.dateComponents([.weekday], from: date).weekday {
                guard let day = Weekday(rawValue: dayOfWeek) else { continue }
                
                let notRegularEventForDate = allTrackers.filter { ($0.schedule).isEmpty }
                let trackersForDay = allTrackers.filter { ($0.schedule).contains(day) }
                
                let allCompleted = trackersForDay.allSatisfy { tracker in
                    return completedTrackers.contains(tracker.id)
                } && notRegularEventForDate.allSatisfy { tracker in
                    allTrackerRecords.contains(where: { $0.id == tracker.id })
                }
                
                if allCompleted && (!trackersForDay.isEmpty || !notRegularEventForDate.isEmpty) {
                    successfulDaysCount += 1
                }
            }
        }
        
        return successfulDaysCount
    }
}
