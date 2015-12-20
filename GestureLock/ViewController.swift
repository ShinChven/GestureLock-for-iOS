//
//  ViewController.swift
//  GestureLock
//
//  Created by ShinChven Zhang on 15/4/1.
//  Copyright (c) 2015年 ShinChven Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PatternDelegate {

    func patternMatched() {
        print("patternMatched")
    }

    func patternMatchingFailed() {
        print("patternMatchingFailed")
    }

    func patternCreatingSuccessed() {
        print("patternCreatingSuccessed")
    }

    func patternCreatingFailed() {
        print("patternCreatingFailed")
    }

    func patternCreatingRecorded() {
        print("patternCreatingRecorded")
    }

    @IBOutlet weak var lock: UILockView!
    @IBAction func match(sender: AnyObject) {
        lock.action = UILockView.ACTION_MATCHING
    }

    @IBAction func record(sender: AnyObject) {
        lock.action = UILockView.ACTION_CREATING
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lock.patternDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

