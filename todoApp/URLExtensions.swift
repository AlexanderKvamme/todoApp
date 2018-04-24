//
//  URLExtensions.swift
//  todoApp
//
//  Created by Alexander K on 23/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation


extension URL {
    enum sounds {
        enum note {
            static let _1 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Note1", ofType: "wav")!)
            static let _2 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Note2", ofType: "wav")!)
            static let _3 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Note3", ofType: "wav")!)
            static let _4 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Note4", ofType: "wav")!)
            static let _5 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Note5", ofType: "wav")!)
        }
        
        enum done {
            static let _1 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Done1", ofType: "wav")!)
            static let _2 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Done2", ofType: "wav")!)
            static let _5 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Done5", ofType: "wav")!)
            static let _8 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Done8", ofType: "wav")!)
            static let _9 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Done9", ofType: "wav")!)
        }
        
        enum error {
            static let _2 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Error2", ofType: "wav")!)
            static let _3 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Error3", ofType: "wav")!)
        }
        
        enum notification {
            static let _4 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Notification4", ofType: "wav")!)
            static let _8 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Notification8", ofType: "wav")!)
            static let _12 = URL(fileURLWithPath: Bundle.main.path(forResource: "Peak_Notification12", ofType: "wav")!)
        }
    }
}
