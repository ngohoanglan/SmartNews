//
//  RealmExtension.swift
//  VietNamNewspapers
//
//  Created by Ngo Lan on 22/09/2021.
//  Copyright © 2021 admin. All rights reserved.
//
import UIKit
import Foundation
 
import RealmSwift

extension Realm {
    func writeRealmAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}
