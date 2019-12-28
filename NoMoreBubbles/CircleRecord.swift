//
//  CircleRecord.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 12/27/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

import Foundation

class CircleRecord: Hashable  {
    static func == (lhs: CircleRecord, rhs: CircleRecord) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }

    var circle: Circle
    var timestamp: Double

    public init(fromCircle: Circle, withTimestamp: Double) {
        circle = fromCircle
        timestamp = withTimestamp
    }
}
