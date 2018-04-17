//
//  Vibration.swift
//  todoApp
//
//  Created by Alexander K on 17/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import AudioToolbox.AudioServices

class VibrationController {

    static func vibrate() {
        let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(vibrate)
    }
}

