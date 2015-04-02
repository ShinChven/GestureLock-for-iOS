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
    let btnW:CGFloat = 74.0
    let btnH:CGFloat = 74.0
    let viewY:CGFloat = 300.0
    let columnCount:Int = 3
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addButtons()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        addButtons()
    }
    
    func addButtons(){
        var height:CGFloat=0
        for var i = 0; i < self.btnCount; i++ {
            var btn:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            btn.userInteractionEnabled = false
            btn.setImage(UIImage(named: "gesture_node_normal"), forState: UIControlState.Normal)
            btn.setImage(UIImage(named: "gesture_node_highlighted"), forState: UIControlState.Selected)
            
            var row = i / self.columnCount
            var column = i % self.columnCount
            
            // margin
            var margin:CGFloat = ( self.frame.size.width - (CGFloat(self.columnCount) * self.btnW) ) / ( CGFloat(self.columnCount)+1.0 )
            //            // x
            var btnX:CGFloat = margin + CGFloat(column) * (self.btnW + margin)
            var btnY:CGFloat = CGFloat(row) * (btnW + margin)
            btn.frame = CGRectMake(btnX, btnY, self.btnW, self.btnH)
            height = btnH + btnY
            
            self.addSubview(btn)
            
        }
        self.frame = CGRectMake(0, self.viewY, UIScreen.mainScreen().bounds.width, height)
    }
    
    func pointWithTouch(touches:NSSet) -> CGPoint {
        var touch:UITouch = touches.anyObject() as UITouch
        var point:CGPoint = touch.locationInView(self)
        return point
    }
    
    func buttonWithPoint(point:CGPoint) -> UIButton? {
        for var i=0; i<self.subviews.count; i++ {
            var btn:UIButton =  self.subviews[i] as UIButton
            if CGRectContainsPoint(btn.frame, point) {
                //println("\(i)")
                return btn
            }
        }
        return nil
    }
    
    var selectedButtons:Array<UIButton> = Array<UIButton>()
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var point:CGPoint = pointWithTouch(touches)
        if var btn = buttonWithPoint(point) {
            if btn.selected==false {
                btn.selected=true
                self.selectedButtons.append(btn)
            }
            self.setNeedsDisplay()
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var point:CGPoint = pointWithTouch(touches)
        if var btn = buttonWithPoint(point) {
            if btn.selected==false {
                btn.selected=true
                self.selectedButtons.append(btn)
            }
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        dispatch_async(dispatch_get_main_queue(), {
            NSThread.sleepForTimeInterval(2)
            for var i = 0; i<self.selectedButtons.count; i++ {
                self.selectedButtons[i].selected=false
            }
            self.selectedButtons.removeAll(keepCapacity: false)
            self.setNeedsDisplay()
        })
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    override func drawRect(rect: CGRect) {
        if self.selectedButtons.count==0{
            return
        }
        
        var path:UIBezierPath = UIBezierPath()
        path.lineWidth = 8
        path.lineJoinStyle = kCGLineJoinRound
        
        for var i = 0; i < self.selectedButtons.count; i++ {
            var btn = self.selectedButtons[i]
            if i == 0 {
                path.moveToPoint(btn.center)
            }else{
                path.addLineToPoint(btn.center)
            }
        }
        
        UIColor.brownColor().setStroke()
        
        path.stroke()
        
    }
    
    
    
    
    
    
}

