import UIKit.UIImage

class ContactImageEngine: NSObject {
    
    static let defaultImageSize = 1600.0
    var contactWrapper: ContactHashWrapper! {
        didSet {
            let hashValue = contactWrapper.hashValue
            randomNumberGenerator.startPoint = hashValue
            randomColorGenerator.randomNumberGenerator = randomNumberGenerator
            colorPalette.setColorsRandomly(
                randomColorGenerator: randomColorGenerator
            )
        }
    }
    var imageSize: Double = ContactImageEngine.defaultImageSize
    var cgImageSize: CGSize {
        get {
            return CGSize(width: CGFloat(imageSize), height: CGFloat(imageSize))
        }
    }
    var globalDispatchQueue = DispatchQueue.global()
    var mainDispatchQueue = DispatchQueue.main
    var backgroundColors: [ARGBColor] {
        get {
            return [
                .white,
                .white
//                colorPalette.color(randomNumber: randomNumberGenerator.int),
//                colorPalette.color(randomNumber: randomNumberGenerator.int)
            ]
        }
    }
    @IBOutlet var randomNumberGenerator: RandomNumberGenerator!
    @IBOutlet var randomColorGenerator: RandomColorGenerator!
    @IBOutlet var colorPalette: ARGBColorPalette!
    @IBOutlet var colorConverter: ARGBColorCGConverter!
    @IBOutlet var gradientDrawer: GradientCGDrawer!
    @IBOutlet var initialsDrawer: InitialsDrawer!
    @IBOutlet var foliageGenerator: FoliageCGGenerator!
    fileprivate var stopped = false
    
    func drawImageAsync(
        completionHandler: @escaping (UIImage) -> ()
    ) {
        globalDispatchQueue.async {
            // Background thread
            
            let generatedImage = self.generateAndDraw()
            
            self.mainDispatchQueue.async(execute: {
                    completionHandler(generatedImage)
                }
            )
        }
    }
    
    func stop() {
        stopped = true
    }
    
    func generateAndDraw() -> UIImage {
        stopped = false
        
        UIGraphicsBeginImageContext(cgImageSize)
        let context = UIGraphicsGetCurrentContext()!
        
        drawBackgroundInContext(context)
        generateFoliageInContext(
            context,
            color1: ARGBColor.black,
            color2: ARGBColor.black
        )
//        drawInitialsInContext(context)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return generatedImage
    }
    
    fileprivate func drawBackgroundInContext(
        _ context: CGContext
    ) {
        let cgBackgroundColors = colorConverter.cgColorsFromARGBColors(
            backgroundColors
        )
        gradientDrawer.drawColors(
            cgBackgroundColors,
            inContext: context,
            size: cgImageSize
        )
    }
    
    fileprivate func drawInitialsInContext(_ context: CGContext
    ) {
        let initials = contactWrapper.contact.initials
//        initialsDrawer.drawInitialsInImageContext(initials)
    }
    
    fileprivate func generateFoliageInContext(
        _ context: CGContext,
        color1: ARGBColor,
        color2: ARGBColor
    ) {
//        context.setStrokeColor(colorConverter.cgColorFromARGBColor(color1))
//        context.strokeEllipse(
//            in: CGRect(
//                x: CGFloat(200),
//                y: CGFloat(200),
//                width: 100, //maxCircleShapeSize,
//                height: 100 //maxCircleShapeSize
//            )
//        )
        foliageGenerator.setup(
            imageSize: imageSize,
            color1: color1,
            color2: color2
        )
        foliageGenerator.drawAndUpdate(context: context)
    }
}
