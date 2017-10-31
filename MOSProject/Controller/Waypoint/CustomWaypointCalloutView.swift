//
//  CustomWaypointCalloutView.swift
//  MOSProject
//
//  Created by Darko on 2017/10/30.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

let kArrowHeight: CGFloat = 10
let kPortraitMargin: CGFloat = 5
let kPortraitWidth: CGFloat = 64
let kPortraitHeight: CGFloat = 44

let kTitleWidth: CGFloat = 100
let kTitleHeight: CGFloat = 20

class CustomWaypointCalloutView: UIView {
    
    var image: UIImage?
    var title: String!
    var subTitle: String?
    
    var portraitView: UIImageView?
    var subtitleLabel: UILabel?
    var titleLabel: UILabel!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.draw(self.layer, in: UIGraphicsGetCurrentContext()!)
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        ctx.setLineWidth(2.0)
        ctx.setFillColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
        
        self.getDrawPath(context: ctx)
        ctx.fillPath()
    }
    
    func getDrawPath(context: CGContext) {
        let rrect: CGRect = self.bounds
        let radius: CGFloat = 6.0
        let minx: CGFloat = rrect.minX
        let midx: CGFloat = rrect.midX
        let maxx: CGFloat = rrect.maxX
        let miny: CGFloat = rrect.minY
        let maxy: CGFloat = rrect.maxY - kArrowHeight
        
        context.move(to: CGPoint(x: midx + kArrowHeight, y: maxy))
        context.addLine(to: CGPoint(x: midx, y: maxy + kArrowHeight))
        context.addLine(to: CGPoint(x: midx - kArrowHeight, y: maxy))
        
        context.addArc(tangent1End: CGPoint(x: minx, y: maxy), tangent2End: CGPoint(x: minx, y: miny), radius: radius)
        context.addArc(tangent1End: CGPoint(x: minx, y: minx), tangent2End: CGPoint(x: maxx, y: miny), radius: radius)
        context.addArc(tangent1End: CGPoint(x: maxx, y: miny), tangent2End: CGPoint(x: maxx, y: maxx), radius: radius)
        context.addArc(tangent1End: CGPoint(x: maxx, y: maxy), tangent2End: CGPoint(x: midx, y: maxy), radius: radius)

        context.closePath()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        self.portraitView = UIImageView(frame: CGRect(x: kPortraitMargin, y: kPortraitMargin, width: kPortraitWidth, height: kPortraitHeight))
        self.portraitView!.backgroundColor = UIColor.black
        self.addSubview(self.portraitView!)
        
        self.titleLabel = UILabel(frame: CGRect(x: kPortraitMargin * 2 + kPortraitWidth, y: kPortraitMargin, width: kTitleWidth, height: kTitleHeight))
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.text = "title"
        self.addSubview(self.titleLabel)
        
        self.subtitleLabel = UILabel(frame: CGRect(x: kPortraitMargin * 2 + kPortraitWidth, y: kCalloutHeight - kTitleHeight - kPortraitMargin - kArrowHeight, width: kTitleWidth, height: kTitleHeight))
        self.subtitleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.subtitleLabel?.textColor = UIColor.white
        self.subtitleLabel?.text = "subtitle"
        self.addSubview(self.subtitleLabel!)
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
        self.title = title
    }
    
    func setSubTitle(subTitle: String) {
        self.subtitleLabel?.text = subTitle
        self.subTitle = subTitle
    }
    
    func setImage(image: UIImage) {
        self.portraitView?.image = image
        self.image = image
    }
    
}
