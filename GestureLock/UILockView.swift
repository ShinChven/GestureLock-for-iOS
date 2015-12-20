//
//  UILockView.swift
//  GestureLock
//
//  Created by ShinChven Zhang on 15/4/1.
//  Copyright (c) 2015年 ShinChven Zhang. All rights reserved.
//

import UIKit

class UIPatternLockView: UIView {

    let btnCount = 9
    let btnW: CGFloat = 74.0
    let btnH: CGFloat = 74.0
    let viewY: CGFloat = 300.0
    let columnCount: Int = 3
    let isDrawingTrackAllowed = true
    var patternDelegate: PatternDelegate?
    static let ACTION_CREATING = 1
    static let ACTION_MATCHING = 2
    var action = UIPatternLockView.ACTION_MATCHING
    var matched = true
    var isTouchingAllowed = true


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addButtons()
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        addButtons()
    }

    /**
    * init buttons
    */
    func addButtons() {
        var height: CGFloat = 0
        for var i = 0; i < self.btnCount; i++ {
            let btn: UIButton = UIButton(type: .Custom) as UIButton
            btn.tag = i
            btn.userInteractionEnabled = false
            btn.setImage(UIImage(named: "gesture_node_normal"), forState: UIControlState.Normal)

            if isDrawingTrackAllowed {
                btn.setImage(UIImage(named: "gesture_node_highlighted"), forState: UIControlState.Selected)
            }

            let row = i / self.columnCount
            let column = i % self.columnCount

            // margin
            let margin: CGFloat = (self.frame.size.width - (CGFloat(self.columnCount) * self.btnW)) / (CGFloat(self.columnCount) + 1.0)
            //            // x
            let btnX: CGFloat = margin + CGFloat(column) * (self.btnW + margin)
            let btnY: CGFloat = CGFloat(row) * (btnW + margin)
            btn.frame = CGRectMake(btnX, btnY, self.btnW, self.btnH)
            height = btnH + btnY

            self.addSubview(btn)

        }
        self.frame = CGRectMake(0, self.viewY, UIScreen.mainScreen().bounds.width, height)
    }

    func pointWithTouch(touches: NSSet) -> CGPoint {
        let touch: UITouch = touches.anyObject() as! UITouch
        let point: CGPoint = touch.locationInView(self)
        return point
    }

    /**
    * finding if I am touching any buttons
    */
    func buttonWithPoint(point: CGPoint) -> UIButton? {
        for var i = 0; i < self.subviews.count; i++ {
            let btn: UIButton = self.subviews[i] as! UIButton
            if CGRectContainsPoint(btn.frame, point) {
                //println("\(i)")
                return btn
            }
        }
        return nil
    }

    var selectedButtons: Array<UIButton> = Array<UIButton>()

    var pointOfTouch: CGPoint?

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouchingAllowed {
            matched = true
            pointOfTouch = pointWithTouch(touches)
            if let btn = buttonWithPoint(pointOfTouch!) {
                if btn.selected == false {
                    btn.selected = true
                    self.selectedButtons.append(btn)
                }
                self.setNeedsDisplay()
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouchingAllowed {
            pointOfTouch = pointWithTouch(touches)
            if let btn = buttonWithPoint(pointOfTouch!) {
                if btn.selected == false {
                    btn.selected = true
                    self.selectedButtons.append(btn)
                }

            }
            self.setNeedsDisplay()
        }
    }

    func matching() {
        let pattern = LockUtil.readPattern()
        if pattern != nil {
            if pattern!.count == self.selectedButtons.count {
                var check = true
                for var i = 0; i < self.selectedButtons.count; i++ {
                    let btn = self.selectedButtons[i]
                    let tag = btn.tag
                    if pattern![i] != tag {
                        check = false
                        break
                    }
                }

                if check {
                    self.patternDelegate!.patternMatched()
                    self.matched = true
                } else {
                    self.patternDelegate!.patternMatchingFailed()
                    self.matched = false
                }

            } else {
                self.patternDelegate!.patternMatchingFailed()
                self.matched = false
            }
        } else {
            self.patternDelegate!.patternMatchingFailed()
        }
        self.setNeedsDisplay()
    }

    var recording: Array<Int> = []

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTouchingAllowed {
            dispatch_async(dispatch_get_main_queue(), {
                self.isTouchingAllowed = false
                if self.action == UIPatternLockView.ACTION_MATCHING {
                    self.matching()
                } else if self.action == UIPatternLockView.ACTION_CREATING {
                    self.recordingPattern()
                }

                // show
                self.pointOfTouch = nil
                self.setNeedsDisplay()
            })


        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            () -> Void in
            self.isTouchingAllowed = true
            for var i = 0; i < self.selectedButtons.count; i++ {
                self.selectedButtons[i].selected = false
            }
            self.selectedButtons.removeAll(keepCapacity: false)
            self.setNeedsDisplay()
        })
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }

    func recordingPattern() {
        if self.recording.count > 0 {
            var checked = true

            if self.recording.count > 0 {
                if self.recording.count == self.selectedButtons.count {
                    for var i = 0; i < self.selectedButtons.count; i++ {
                        if self.selectedButtons[i].tag != recording[i] {
                            checked = false
                            break
                        }
                    }
                } else {
                    checked = false
                }
            } else {
                checked = false
            }

            if checked {
                LockUtil.savePattern(self.recording)
                self.patternDelegate!.patternCreatingSuccessed()
            } else {
                self.matched = false
                self.patternDelegate!.patternCreatingFailed()
                self.recording.removeAll(keepCapacity: false)
            }

        } else {
            for var i = 0; i < self.selectedButtons.count; i++ {
                let btn = self.selectedButtons[i]
                let tag = btn.tag
                self.recording.append(tag)
            }
            self.patternDelegate!.patternCreatingRecorded()
        }
    }


    override func drawRect(rect: CGRect) {
        if isDrawingTrackAllowed {

            if self.selectedButtons.count == 0 {
                return
            }

            let path: UIBezierPath = UIBezierPath()
            path.lineWidth = 8
            path.lineJoinStyle = CGLineJoin.Round

            for var i = 0; i < self.selectedButtons.count; i++ {
                let btn = self.selectedButtons[i]
                if i == 0 {
                    path.moveToPoint(btn.center)
                } else {
                    path.addLineToPoint(btn.center)
                }
            }

            if pointOfTouch != nil {
                path.addLineToPoint(pointOfTouch!)
            }

            if self.matched {
                UIColor.brownColor().setStroke()
            } else {
                UIColor.redColor().setStroke()
            }

            path.stroke()
        }


    }

}

protocol PatternDelegate {
    func patternMatched()

    func patternMatchingFailed()

    func patternCreatingSuccessed()

    func patternCreatingFailed()

    func patternCreatingRecorded()
}

class LockUtil {

    static let KEY_PATTERN = "pattern"

    static func savePattern(pattern: Array<Int>) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(pattern, forKey: KEY_PATTERN)
    }

    static func readPattern() -> Array<Int>? {
        let defaults = NSUserDefaults.standardUserDefaults()
        var pattern: Array<Int>?
        pattern = defaults.objectForKey(KEY_PATTERN) as? Array<Int>
        return pattern
    }
}

