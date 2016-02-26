//
//  ImageFactory.swift
//  micopi
//
//  Created by Michel on 22/02/16.
//  Copyright © 2016 Easy Target. All rights reserved.
//

import UIKit

class ImageFactory {
    
    static let recommendedImageSize: CGFloat = 1600
    
    let contact: MiContact
    
    let imageSize: CGFloat
    
    init(contact: MiContact, imageSize: CGFloat) {
        self.contact = contact
        self.imageSize = imageSize
    }
    
    weak var context: CGContext?
    
    var rgb = CGColorSpaceCreateDeviceRGB()
    
    func generateImage() -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize.init(width: imageSize, height: imageSize))
        
        context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, CGRectMake(0, 0, imageSize, imageSize))
        
        // The background colour is based on the initial character of the Display Name.
        if let firstChars = contact.displayName?.characters, let firstChar = firstChars.first {
            let displayedInitials: String
            
            if let secondChar = contact.cn.familyName.characters.first {
                displayedInitials = String(firstChar) + String(secondChar)
            } else if let secondChar = contact.cn.middleName.characters.first {
                displayedInitials = String(firstChar) + String(secondChar)
            } else {
                displayedInitials = String(firstChar)
            }
            
            let secondColor = ColorCollection.color(contact.md5[15]).CGColor
            let gradientColors = [
                ColorCollection.color(firstChar.hashValue).CGColor,
                secondColor
            ]
            let backgroundGradient = CGGradientCreateWithColors(
                rgb,
                gradientColors,
                [0.0, 0.66]
            )
            
            CGContextDrawLinearGradient(
                context,
                backgroundGradient,
                CGPoint(x: imageSize / 2, y: 0),
                CGPoint(x: imageSize / 2, y: imageSize),
                CGGradientDrawingOptions(rawValue: 0)
            )
            paintInitialsCircle(displayedInitials, fillColor: secondColor)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        context = nil
        
        return newImage
    }
    
    // MARK: - Pixel Matrix
    
    private func paintPixelMatrix() {
        
//        let color1 = ColorCollection.color(contact.md5[0])
        let color2 = ColorCollection.color(contact.md5[1])
        let color3 = ColorCollection.color(contact.md5[2])
        
//        let numberOfSquares = (contact.md5[2] % 6) + 4
        let numberOfSquares = 9
        
        let sideLength = imageSize / CGFloat(numberOfSquares)
        
        var md5Index = 2
        for y in 0 ..< numberOfSquares {
            for x in 0 ..< numberOfSquares {
                
                if ++md5Index >= 15 {
                    md5Index = 0
                }
                
                if ImageFactory.isOddParity(contact.md5[md5Index]) {
//                    paintPixelSquare(
//                        color1,
//                        alpha: 50,
//                        x: x,
//                        y: y,
//                        sideLength: sideLength
//                    )
                    
                    if x % 3 == 0 {
                        paintPixelSquare(
                            color2,
                            alpha: 155 - contact.md5[md5Index] % 100,
                            x: 4,
                            y: y,
                            sideLength: sideLength
                        )
                    }
                    if x % 2 == 0 {
                        paintPixelSquare(
                            color3,
                            alpha: 155 - contact.md5[md5Index] % 100,
                            x: 3,
                            y: y,
                            sideLength: sideLength
                        )
                    }
                }
            }
        }
    }
    
    private static func isOddParity(value: Int) -> Bool {
        var bb = value;
        var bitCount = 0;
        
        for _ in 0 ..< 16 {
            if (bb & 1) != 0 {
                bitCount++
            }
            bb >>= 1
        }
        
        return (bitCount & 1) != 0;
    }
    
    private func paintPixelSquare(
        color: UIColor,
        alpha: Int,
        x: Int,
        y: Int,
        sideLength: CGFloat
    ) {
        let offsetX = CGFloat(x) * sideLength
        let offsetY = CGFloat(y) * sideLength
        
        if (alpha > 0 && alpha < 255) {
            let percentageAlpha = CGFloat(alpha) / 255
            CGContextSetFillColorWithColor(
                context,
                color.colorWithAlphaComponent(percentageAlpha).CGColor
            );
        } else {
            CGContextSetFillColorWithColor(context, color.CGColor);
        }
        
        CGContextFillRect(context, CGRectMake(offsetX, offsetY, sideLength, sideLength));
    }
    
    // MARK: - Plates
    
    private func paintPlates() {
        var angleOffset = CGFloat(0)
        
        var width = (CGFloat(contact.md5[7] * contact.md5[8]) / imageSize) * (imageSize * 1.7)
        
        let smallestWidth = CGFloat(imageSize / 300) * CGFloat(contact.md5[9])

        var numberOfShapes = 3
        if let displayName = contact.displayName {
            numberOfShapes = displayName.characters.count
            if numberOfShapes < 3 {
                numberOfShapes = 3
            } else if numberOfShapes > 9 {
                numberOfShapes = 10
            }
        }
        
        let paintPolygon: Bool
        var numberOfEdges = 0
        
        if (contact.md5[10] % 4) > 0 {
            paintPolygon = true
            if !contact.cn.nickname.isEmpty {
                numberOfEdges = contact.cn.nickname.characters.count
            } else if !contact.cn.givenName.isEmpty {
                numberOfEdges = contact.cn.givenName.characters.count
            }
            
            if numberOfEdges < 3 {
                numberOfEdges = 3
            } else if numberOfEdges > 10 {
                numberOfEdges = 10
            }
        } else {
            paintPolygon = false
        }
        
        let extraDividend = CGFloat(contact.md5[11])
        
        var x = CGFloat(imageSize / 3)
        var y = x
        var md5Index = 0
        var movement: Int
        var floatMovement: CGFloat
        
        let alpha = CGFloat(0.7)
        
        enableShadows()
        
        for i in 0 ..< numberOfShapes{
            if ++md5Index > 15 {
                md5Index = 0
            }
            
            movement = contact.md5[md5Index] + i * 3
            floatMovement = CGFloat(movement)
            
            switch movement % 6 {
            case 0:
                x += floatMovement
                y -= floatMovement * 2
            case 1:
                x -= floatMovement * 2
                y += floatMovement
            case 2:
                x += floatMovement * 2
            case 3:
                y += floatMovement * 3
            case 4:
                x -= floatMovement * 2
                y -= floatMovement
            default:
                x -= floatMovement
                y -= floatMovement * 2
            }
            
            if paintPolygon {
                if numberOfEdges == 4 && movement % 3 == 0 {
                    paintRoundedSquare(
                        ColorCollection.color(contact.md5[md5Index], alpha: alpha).CGColor,
                        x: x,
                        y: y,
                        width: width
                    )
                } else {
                    angleOffset += extraDividend / floatMovement
                    
                    self.paintPolygon(
                        ColorCollection.color(contact.md5[md5Index], alpha: alpha).CGColor,
                        angleOffset: angleOffset,
                        numberOfEdges: numberOfEdges,
                        centerX: x,
                        centerY: y,
                        width: width
                    )
                }
            } else {
                paintCircle(
                    ColorCollection.color(contact.md5[md5Index], alpha: alpha).CGColor,
                    x: x,
                    y: y,
                    diameter: width * 1.5
                )
            }
            
            if width < smallestWidth {
                width *= 1.3
            } else {
                width *= 0.6
            }
        }
    }
    
    private func paintRoundedSquare(color: CGColor, x: CGFloat, y: CGFloat, width: CGFloat) {
        let path = UIBezierPath(
            roundedRect: CGRectMake(x, y, width, width),
            cornerRadius: imageSize / 50
        )
        
        CGContextAddPath(context, path.CGPath)
        CGContextSetFillColorWithColor(context, color);
        CGContextFillPath(context)
    }
    
    let floatingDoublePi = CGFloat(M_PI_2)
    
    private func paintPolygon(
        color: CGColor,
        angleOffset: CGFloat,
        numberOfEdges: Int,
        centerX: CGFloat,
        centerY: CGFloat,
        width: CGFloat
    ) {
        
        var angle: CGFloat
        var x: CGFloat
        var y: CGFloat
        
        var path = CGPathCreateMutable()
        
        for edge in 0 ..< numberOfEdges {
            angle = floatingDoublePi * CGFloat(edge / numberOfEdges)
            x = centerX + width * cos(angle + angleOffset)
            y = centerY + width * sin(angle + angleOffset)
            if edge == 0 {
                CGPathMoveToPoint(path, nil, x, y)
            } else {
                CGPathAddLineToPoint(path, nil, x, y)
            }
        }
        
        CGContextAddPath(context, path)
        CGContextSetFillColorWithColor(context, color);
        CGContextFillPath(context)
    }
    
    // MARK: - Initials Circle
    
    private func paintInitialsCircle(initials: String, fillColor: CGColor) {
        
        // Use Palette colour based on first character minus specific values,
        // so that background and circle colour are based on the initials but not the same.
        
        let radius = imageSize * 0.4
        
        let diameter = radius * 2
        let circlePosition = (imageSize - diameter) / 2
        paintCircle(
            fillColor,
            x: circlePosition,
            y: circlePosition,
            diameter: diameter
        )
        
//        paintInitialsArc(radius)
        
        let attributes = [
            NSFontAttributeName : UIFont.systemFontOfSize(imageSize * pow(0.66, CGFloat(initials.characters.count))),
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        let stringSize = initials.sizeWithAttributes(attributes)
        
        initials.drawInRect(
            CGRectMake(
                (imageSize - stringSize.width) / 2,
                (imageSize - stringSize.height) / 2,
                stringSize.width,
                stringSize.height
            ),
            withAttributes: attributes
        )
    }
    
    private func paintInitialsArc(radius: CGFloat) {
        let thickness = CGFloat(imageSize) / 50
        
        let startAngleOffset = Double(contact.md5[5] % 5)
        let endAngleOffset = Double(contact.md5[6] % 4) - 7.0
        
        CGContextAddArc(
            context,
            imageSize / 2,
            imageSize / 2,
            radius,
            CGFloat(-M_PI / (4.0 + startAngleOffset)),
            CGFloat(-11.0 * M_PI / (4.0 + endAngleOffset)),
            1
        );
        
        CGContextSetLineWidth(context, thickness);
        CGContextSetLineCap(context, CGLineCap.Round);
        // Then we can ask Core Graphics to replace the path with a stroked version:
        CGContextReplacePathWithStrokedPath(context);
        
//        enableShadows()
        
        CGContextBeginTransparencyLayer(context, nil)
        
        let gradientColors = [
            ColorCollection.color(contact.md5[15]).CGColor,
            ColorCollection.color(contact.md5[4]).colorWithAlphaComponent(0.2).CGColor
        ]
        let gradient = CGGradientCreateWithColors(
            rgb,
            gradientColors,
            [0.0, 1.0]
        )
        
        // We also need to figure out a start point and an end point for the gradient.
        // We'll use the path bounding box:
        let bbox = CGContextGetPathBoundingBox(context);
        let start = bbox.origin;
        let end = CGPointMake(CGRectGetMaxX(bbox), CGRectGetMaxY(bbox));
        
        CGContextClip(context)
        
        CGContextDrawLinearGradient(context, gradient, start, end, CGGradientDrawingOptions(rawValue: 0))
        
        CGContextEndTransparencyLayer(context)
    }
    
    // MARK: - Frequently Used Shapes
    
    private func paintCircle(color: CGColor, x: CGFloat, y: CGFloat, diameter: CGFloat) {
        CGContextSetFillColorWithColor(context, color);
        
        CGContextFillEllipseInRect(
            context,
            CGRectMake(
                x,
                y,
                diameter,
                diameter
            )
        )
    }
    
    // MARK: - Shadow Settings
    
    var enabledShadows = false
    
    private func enableShadows() {
        if !enabledShadows {
            let thickness = CGFloat(imageSize) / 50
            CGContextSetShadowWithColor(
                context,
                CGSizeMake(0, thickness / 2),
                thickness / 2,
                UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
            )
            
            enabledShadows = true
        }
    }
    
}