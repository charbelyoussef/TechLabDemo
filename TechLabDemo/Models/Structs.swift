//
//  ViewController.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit

class Structs: NSObject {
    
    struct Food {
        var categoryName:String?
        var receipes:[Receipe]?
    }
    
    struct Receipe {
        var name:String?
        var imageurl:String?
        var timetoprepare:String?
        var smalldescription:String?
        var ingredients:NSArray?
        var steps:NSArray?
    }
}
