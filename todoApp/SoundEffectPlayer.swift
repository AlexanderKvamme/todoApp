//
//  SoundEffectPlayer.swift
//  todoApp
//
//  Created by Alexander K on 23/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

/// Used to play soundeffects in NoteTable
protocol SoundEffectPlayer: class {
    func play(songAt url: URL)
}

