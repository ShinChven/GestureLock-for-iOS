//
//  UILockView.swift
//  GestureLock
//
//  Created by ShinChven Zhang on 15/4/1.
//  Copyright (c) 2015年 ShinChven Zhang. All rights reserved.
//

import UIKit

class UILockView: UIView {

    let btnCount = 9
    let btnW: CGFloat = 74.0
    let btnH: CGFloat = 74.0
    let viewY: CGFloat = 300.0
    let columnCount: Int = 3
    let isDrawingTrackAllowed = true
    var unlockResultDelegate: UnlockResultDelegate?
    static let ACTION_CREATING = 1
    static let ACTION_MATCHING = 2
    var action = UILockView.ACTION_MATCHING

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

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point: CGPoint = pointWithTouch(touches)
        if let btn = buttonWithPoint(point) {
            if btn.selected == false {
                btn.selected = true
                self.selectedButtons.append(btn)
            }
            self.setNeedsDisplay()
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point: CGPoint = pointWithTouch(touches)
        if let btn = buttonWithPoint(point) {
            if btn.selected == false {
                btn.selected = true
                self.selectedButtons.append(btn)
            }
            self.setNeedsDisplay()
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dispatch_async(dispatch_get_main_queue(), {

            if self.action == UILockView.ACTION_MATCHING {
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
                            self.unlockResultDelegate!.unlockSuccessed()
                        } else {
                            self.unlockResultDelegate!.unlockFailed()
                        }

                    } else {
                        self.unlockResultDelegate!.unlockFailed()
                    }
                } else {
                    self.unlockResultDelegate!.unlockFailed()
                }
            }else if self.action == UILockView.ACTION_CREATING {
                var pattern = Array<Int>()
                for var i = 0; i < self.selectedButtons.count; i++ {
                    let btn = self.selectedButtons[i]
                    let tag = btn.tag
                    pattern.append(tag)
                }
                LockUtil.savePattern(pattern)

            }



            NSThread.sleepForTimeInterval(2)
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

            UIColor.brownColor().setStroke()

            path.stroke()
        }


    }

}

protocol UnlockResultDelegate {
    func unlockSuccessed()

    func unlockFailed()
}

