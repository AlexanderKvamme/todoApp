//
//  NoteModel.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

/// MARK: Note
//class Note: NSObject, NSCoding {
//    
//    private let dateCreated  = Date()
//    private var text = ""
//    
//    // MARK: Initializers
//    
//    init(_ str: String) {
//        self.text = str
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        guard let noteID = aDecoder.decodeObject(forKey: "remoteID") as? NSNumber,
//            let noteText = aDecoder.decodeObject(forKey: "noteText") as? String
//            else { return nil }
//        self.init(noteText)
//    }
//    
//    // ARRK: - Methods
//    
//    func getText() -> String {
//        return text
//    }
//    
//    /// NSCoding
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(dateCreated, forKey: "dateCreated")
//        aCoder.encode(self.text, forKey: "noteText")
//    }
//    
//}
//
////  MARK: - Stub Extension
//
//extension Note {
//    func getStub() -> Note {
//        return Note("Remember to do the dishes")
//    }
//}

