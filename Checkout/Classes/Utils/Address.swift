//
//  Address.swift
//  Checkout
//
//  Created by Sven Resch on 2016-06-03.
//  Copyright © 2017 Bambora Inc. All rights reserved.
//

import Foundation

public enum AddressType {
    case shipping
    case billing
}

public class Address : NSObject {
    public var name: String = ""
    public var street: String = ""
    public var city: String = ""
    public var province: String = ""
    public var postalCode: String = ""
    public var country: String = ""
}
