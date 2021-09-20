//
//  Model.swift
//  TreeView-iOS
//
//  Created by Md. Shamiul Islam on 20/9/21.
//

import Foundation
struct Welcome: Codable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let id, displayName: String
    let level: Int
    let isExpanded: Bool
    let type: String
    let odus: [Odus]
}

// MARK: - Odus
struct Odus: Codable {
    let id, oduName: String
    let level: Int
    let type: String
    let rcGroups: [RCGroup]
}

// MARK: - RCGroup
struct RCGroup: Codable {
    let id, rcGroupID, rcGroupName, zoneName: String
    let assigned, isExpanded: Bool
    let level: Int
    let idus: [Idus]
}

// MARK: - Idus
struct Idus: Codable {
    let id, unitName, iduOnOf, type: String
}
