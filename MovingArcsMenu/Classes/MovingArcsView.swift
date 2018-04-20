//
//  MovingArcsView.swift
//  MovingArcsMenu
//
//  Created by Ruffolo Antonio on 20/04/2018.
//

import UIKit

public enum ArcsButtonsNumber: Int
{
  case five = 5
  case four = 4
  case three = 3
  case two = 2
  case one = 1
}

public enum ArcsViewsError: Error
{
  case viewsNUmberAndTagsNumberMismatch(String)
}

// tip to rember, the line that is being drawned around the path is at the center of the bezier arc radius
public class MovingArcsView: UIView
{
  private var viewsOnExternalArc: ArcsButtonsNumber = .four
  private var viewsOnMiddleArc: ArcsButtonsNumber = .three
  
  private var tagsForButtonsInExternalArc: [Int] = [0, 1, 2, 3]
  private var tagsForButtonsInMiddleArc: [Int] = [4, 5, 6]
  private var tagsForButtonsInInnerArc: [Int] = [-1]
  
  var externalArc: CAShapeLayer = CAShapeLayer()
  var centralArc: CAShapeLayer = CAShapeLayer()
  var innerArc: CAShapeLayer = CAShapeLayer()
  
  private let duration: CFTimeInterval = 0.5
  private var buttonSize: CGFloat = 30
  private var buttonScale: CGFloat = 0.3
  
  private var sideLength: CGFloat!
  private var arcsCenter: CGPoint!
  private var arcWidth: CGFloat!
  private var externalRadius: CGFloat!
  private var middleRadius: CGFloat!
  private var innerRadius: CGFloat!
  private var externalAngleSlice: CGFloat!
  private var middleAngleSlice: CGFloat!
  
  private var viewsInExternalArc: ViewsInArcData!
  private var viewsInMiddleArc: ViewsInArcData!
  private var viewsInInnerArc: ViewsInArcData!
  
  private var imagesForExternalArc: [String] = []
  private var imagesForMiddleArc: [String] = []
  private var imagesForInnerArc: [String] = []
  
  // here I store the position that each view on the external arc view should have when the animation
  // finishes
  private var externalViewPositions: [String: (UIView, CGPoint)] = [:]
  private var middleViewPositions: [String: (UIView, CGPoint)] = [:]
  private var innerViewsPositions: [String: (UIView, CGPoint)] = [:]
  
  private let externalPathAnimKey = "externalArcOrigin"
  private let middlePathAnimKey = "middleArcOrigin"
  private let innerPathAnimKey = "innerArcOrigin"
  private let reverseAnimationFinished = "reverseAnimation"
 
  /// closure to be assigned if the client want to know when the animation is completed
  public var animationsFinishedCallback: (() -> Void)?
  /// closure to be assigned by the client if it wants to know which button has been pressed
  public var viewsOnArcHasBeenTapped: ((_ sender: UITapGestureRecognizer) -> Void)?

  private var innerArcColor: UIColor = UIColor.black
  private var middleArcColor: UIColor = UIColor.darkGray
  private var externalArcColor: UIColor = UIColor.gray
  
  private var innerArcShadowColor: UIColor = UIColor.blue
  private var middleArcShadowColor: UIColor = UIColor.blue
  private var externalArcShadowColor: UIColor = UIColor.blue
  
  private var startAnimationIsInProgress: Bool = false
  private var reverseAnimationIsInProgress: Bool = false
  
  public typealias ArcColors = (innerArcColor: UIColor, middleArcColor: UIColor, externalArcColor: UIColor, innerArcShadowColor: UIColor, middleArcShadowColor: UIColor, externalArcShadowColor: UIColor)
  
  /// Fucntion needed to inject dependencies into the view. The view must now the tag of each button in each arc, the image to place in each button, the scale of the buttons etc.
  ///
  /// - Parameters:
  ///   - viewsOnExternalArc: enum to provide how many view must be placed into the external arc, max advised is five
  ///   - viewsOnMiddleArc: enum to tell how many views must be placed into the middle arc, max advised is four
  ///   - tagsForButtonsInExternalArc: array of tags for the buttons to be placed into the external arc. Tags are useful to tell which button has been tapped
  ///   - tagsForButtonsInMiddleArc: array of tags for the buttons to be placed into the middle arc
  ///   - arcColors: tupla containint the colors for: inner arc, middle arc, external arc and respective shadows
  ///   - buttonScale: the scale to be applied on the button inside each arc relative to the arc width
  ///   - imagesForExternalArc: array of strings containing the images that will be used for each button in the external arc
  ///   - imagesForMiddleArc: array of string to load the images that will be used for each button in the middle arc
  ///   - imagesForInnerArc: array of strings to load the image that will be used for each button in the inner arc
  /// - Throws: throws expeptions when the number of buttons in each arc is not consistent with the number of tag provided
  public func initParameters(viewsOnExternalArc: ArcsButtonsNumber, viewsOnMiddleArc: ArcsButtonsNumber, tagsForButtonsInExternalArc: [Int], tagsForButtonsInMiddleArc: [Int],
                             arcColors: ArcColors, buttonScale: CGFloat, imagesForExternalArc: [String], imagesForMiddleArc: [String], imagesForInnerArc: [String]) throws
  {
    if viewsOnExternalArc.rawValue != tagsForButtonsInExternalArc.count || viewsOnMiddleArc.rawValue != tagsForButtonsInMiddleArc.count
    {
      throw ArcsViewsError.viewsNUmberAndTagsNumberMismatch("Make sure that arcs number and number of tags passed are equal")
    }
    
    if viewsOnExternalArc.rawValue != imagesForExternalArc.count || viewsOnMiddleArc.rawValue != imagesForMiddleArc.count || imagesForInnerArc.count != 1
    {
      throw ArcsViewsError.viewsNUmberAndTagsNumberMismatch("Make sure that arcs number and the number of images passed on each arc is equal")
    }
    
    self.tagsForButtonsInExternalArc = tagsForButtonsInExternalArc
    self.tagsForButtonsInMiddleArc = tagsForButtonsInMiddleArc
    
    self.viewsOnExternalArc = viewsOnExternalArc
    self.viewsOnMiddleArc = viewsOnMiddleArc
    
    self.innerArcColor = arcColors.innerArcColor
    self.middleArcColor = arcColors.middleArcColor
    self.externalArcColor = arcColors.externalArcColor
    
    self.innerArcShadowColor = arcColors.innerArcShadowColor
    self.middleArcShadowColor = arcColors.middleArcShadowColor
    self.externalArcShadowColor = arcColors.externalArcShadowColor
    
    self.imagesForExternalArc = imagesForExternalArc
    self.imagesForMiddleArc = imagesForMiddleArc
    self.imagesForInnerArc = imagesForInnerArc
    
    self.buttonScale = buttonScale
  }
  
  override public func layoutSubviews()
  {
    // nothing to do here for now
  }
  
  override public func didMoveToWindow()
  {
    // nothing to do here for now
  }
  
  public func start()
  {
    if !startAnimationIsInProgress
    {
      startAnimationIsInProgress = true
      setConstants()
      animateInnerArc()
      animateCentralArc()
      animateExternalArc()
      
      animateViewsInExternalArc(viewsOnArc: viewsOnExternalArc, radius: externalRadius, angleSlice: externalAngleSlice)
      animateViewsInMiddleArc(viewsOnArc: viewsOnMiddleArc, radius: middleRadius, angleSlice: middleAngleSlice)
      animateViewsInInternalArc(viewsOnArc: .one, radius: innerRadius, angleSlice: innerRadius)
    }
  }
  
  public func revertAnimations()
  {
    if !reverseAnimationIsInProgress
    {
      reverseAnimationIsInProgress = true
      revertArcUpAnimation(arc: externalArc)
      revertArcDownAnimation(arc: centralArc)
      revertArcUpAnimation(arc: innerArc)
      
      if viewsInExternalArc != nil
      {
        removeViewFromArc(viewsInArcData: viewsInExternalArc, radius: externalRadius, clockwise: true)
        removeViewFromArc(viewsInArcData: viewsInMiddleArc, radius: middleRadius, clockwise: false)
        removeViewFromArc(viewsInArcData: viewsInInnerArc, radius: innerRadius, clockwise: true)
      }
    }
  }
  
  private func setConstants()
  {
    arcsCenter = CGPoint(x: bounds.size.width, y: bounds.size.height)
    sideLength = min(bounds.size.width, bounds.size.height)
    arcWidth = sideLength / 3
    buttonSize = arcWidth * buttonScale
    innerRadius = sideLength - arcWidth * 5 / 2
    middleRadius = sideLength - arcWidth * 3 / 2
    externalRadius = sideLength - arcWidth / 2
    externalAngleSlice = CGFloat(90) / CGFloat(viewsOnExternalArc.rawValue)
    middleAngleSlice = CGFloat(90) / CGFloat(viewsOnMiddleArc.rawValue)
  }
  
  private func animateViewsInExternalArc(viewsOnArc: ArcsButtonsNumber, radius: CGFloat, angleSlice: CGFloat)
  {
    viewsInExternalArc = createViewsInArcData(viewsOnArc: viewsOnArc, radius: radius, angleSlice: angleSlice, images: imagesForExternalArc)
    addTagsAndTapRecognizerToViewsInArc(viewsInArc: viewsInExternalArc, tags: tagsForButtonsInExternalArc)
    storeViewsFinalPositions(viewsInArcData: viewsInExternalArc, viewPositions: &externalViewPositions)
    addViewToArc(viewsInArcData: viewsInExternalArc, pathAnimKey: externalPathAnimKey, radius: externalRadius, clockwise: true, addFadeAnimation: false)
  }
  
  private func animateViewsInMiddleArc(viewsOnArc: ArcsButtonsNumber, radius: CGFloat, angleSlice: CGFloat)
  {
    viewsInMiddleArc = createViewsInArcData(viewsOnArc: viewsOnArc, radius: radius, angleSlice: angleSlice, images: imagesForMiddleArc)
    addTagsAndTapRecognizerToViewsInArc(viewsInArc: viewsInMiddleArc, tags: tagsForButtonsInMiddleArc)
    storeViewsFinalPositions(viewsInArcData: viewsInMiddleArc, viewPositions: &middleViewPositions)
    addViewToArc(viewsInArcData: viewsInMiddleArc, pathAnimKey: middlePathAnimKey, radius: middleRadius, clockwise: false, addFadeAnimation: false)
  }
  
  private func animateViewsInInternalArc(viewsOnArc: ArcsButtonsNumber, radius: CGFloat, angleSlice: CGFloat)
  {
    viewsInInnerArc = createViewsInArcData(viewsOnArc: viewsOnArc, radius: radius, angleSlice: angleSlice, images: imagesForInnerArc)
    addTagsAndTapRecognizerToViewsInArc(viewsInArc: viewsInInnerArc, tags: tagsForButtonsInInnerArc)
    storeViewsFinalPositions(viewsInArcData: viewsInInnerArc, viewPositions: &innerViewsPositions)
    addViewToArc(viewsInArcData: viewsInInnerArc, pathAnimKey: innerPathAnimKey, radius: innerRadius, clockwise: true, addFadeAnimation: true)
  }
  
  private func addTagsAndTapRecognizerToViewsInArc(viewsInArc: ViewsInArcData, tags: [Int])
  {
    for (view, tag) in zip(viewsInArc.views, tags)
    {
      view.tag = tag
      addGestureRecognizerTopViewInArc(view: view)
    }
  }
  
  private func addGestureRecognizerTopViewInArc(view: UIView)
  {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapArrived))
    view.addGestureRecognizer(tap)
  }
  
  @objc private func tapArrived(sender: UITapGestureRecognizer)
  {
    self.viewsOnArcHasBeenTapped?(sender)
  }
  
  private func storeViewsFinalPositions(viewsInArcData: ViewsInArcData, viewPositions: inout [String: (UIView, CGPoint)])
  {
    for view in viewsInArcData.views
    {
      let s = "x: \(view.frame.origin.x), y: \(view.frame.origin.y)"
      viewPositions[s] = (view, view.frame.origin)
    }
  }
  
  private func addViewToArc(viewsInArcData: ViewsInArcData, pathAnimKey: String, radius: CGFloat, clockwise: Bool, addFadeAnimation: Bool)
  {
    let offSetWidth = UIScreen.main.bounds.size.width
    
    var delay = 0.0
    let delta = duration / CFTimeInterval(viewsInArcData.angles.count)
    var count: CFTimeInterval = 1.0
    
    var speed: CGFloat = 0.0
    var ii = viewsInArcData.angles.count
    let arrays = clockwise ? zip(viewsInArcData.angles, viewsInArcData.angles.indices).reversed().reversed() : zip(viewsInArcData.angles, viewsInArcData.angles.indices).reversed()
    for (angle, index) in arrays
    {
      let anim = createEnteringAnimationForButtonInArc(endAngle: angle, clockwise: clockwise, radius: radius)
      let fadeInAnim = AnimationsFactory.createFadeInAnimation(duration: 0.4)
      
      if ii == viewsInArcData.angles.count
      {
        let angle = clockwise ? viewsInArcData.angles[index] : 90 - viewsInArcData.angles[index]
        speed = calculateSpeedOfViewInArc(angle: angle, time: CGFloat(duration))
      }
      else
      {
        let angle = clockwise ? viewsInArcData.angles[index] : 90 - viewsInArcData.angles[index]
        let time2 = calculateTimeFoViewInArc(angle: angle, speed: speed)
        anim.duration = CFTimeInterval(time2)
      }
      
      count = count + 1.0
      ii = ii - 1
      
      anim.beginTime = CACurrentMediaTime() + delay
      //fadeInAnim.beginTime = CACurrentMediaTime() + delay
      delay += delta
      
      addSubview(viewsInArcData.views[index])
      
      let s = "x: \(viewsInArcData.views[index].frame.origin.x), y: \(viewsInArcData.views[index].frame.origin.y)"
      // save the origin the view should have
      anim.setValue(s, forKey: pathAnimKey)
      anim.delegate = self
      
      // moving it offscreen cos the animation is going
      viewsInArcData.views[index].frame.origin = CGPoint(x: -offSetWidth, y: viewsInArcData.views[index].frame.origin.y)
      viewsInArcData.views[index].layer.add(anim, forKey: nil)
      if addFadeAnimation
      {
        viewsInArcData.views[index].layer.add(fadeInAnim, forKey: nil)
      }
      viewsInArcData.views[index].layer.opacity = 1.0
    }
  }
  
  private func removeViewFromArc(viewsInArcData: ViewsInArcData, radius: CGFloat, clockwise: Bool)
  {
    var delay = 0.0
    let delta = duration / CFTimeInterval(viewsInArcData.angles.count)
    var count: CFTimeInterval = 1.0
    var ii = viewsInArcData.angles.count
    var speed: CGFloat = 0.0
    let arrays = clockwise ? zip(viewsInArcData.angles, viewsInArcData.angles.indices).reversed() : zip(viewsInArcData.angles, viewsInArcData.angles.indices).reversed().reversed()
    for (angle, index) in arrays
    {
      let anim = createExitAnimationForButtonInArc(endAngle: angle, clockwise: clockwise, radius: radius)
      let fadeOutAnim = AnimationsFactory.createFadeOutAnimation(duration: 0.1)

      if ii == viewsInArcData.angles.count
      {
        let angle = clockwise ? 90 - viewsInArcData.angles[index] : viewsInArcData.angles[index]
        speed = calculateSpeedOfViewInArc(angle: angle, time: CGFloat(duration))
      }
      else
      {
        let angle = clockwise ? 90 - viewsInArcData.angles[index] : viewsInArcData.angles[index]
        let time2 = calculateTimeFoViewInArc(angle: angle, speed: speed)
        anim.duration = CFTimeInterval(time2)
      }
      
      count = count + 1.0
      ii = ii - 1
      
      if index == arrays.count - 1
      {
        anim.setValue("stop", forKey: reverseAnimationFinished)
        anim.delegate = self
      }
      
      anim.beginTime = CACurrentMediaTime() + delay
      delay += delta
      
      viewsInArcData.views[index].layer.add(anim, forKey: nil)
      viewsInArcData.views[index].layer.add(fadeOutAnim, forKey: nil)
      viewsInArcData.views[index].layer.opacity = 0.0
    }
  }
  
  private func createViewsInArcData(viewsOnArc: ArcsButtonsNumber, radius: CGFloat, angleSlice: CGFloat, images: [String]) -> ViewsInArcData
  {
    var views: [UIView] = []
    var angles: [CGFloat] = []
    var origins: [CGPoint] = []
    var topRightArcAngle: CGFloat = calculateTopRightArcAngleFrom(buttonsNumber: viewsOnArc, angleSlice: angleSlice)
    for i in 0..<viewsOnArc.rawValue
    {
      let view = createViewForArc(angle: topRightArcAngle, radius: radius, image: images[i])
      angles.append(topRightArcAngle)
      views.append(view)
      origins.append(view.frame.origin)
      topRightArcAngle -= angleSlice
    }
    
    return ViewsInArcData(views: views, angles: angles, origins: origins)
  }
  
  /// Views are added starting from the top right of the arc, this function calculates the top-rightest angle
  /// where the view will be positioned.
  /// It count from the middle ang goes up
  private func calculateTopRightArcAngleFrom(buttonsNumber: ArcsButtonsNumber, angleSlice: CGFloat) -> CGFloat
  {
    let isEven = buttonsNumber.rawValue % 2 == 0
    let end = buttonsNumber.rawValue / 2
    var start: CGFloat = 45
    if isEven
    {
      start = 45 - angleSlice / 2
    }
    for _ in 0..<end
    {
      start += angleSlice
    }
    
    return start
  }
  
  private func createViewForArc(angle: CGFloat, radius: CGFloat, image: String) -> UIView
  {
    let origin = createOriginFrom(radius: radius, angle: angle)
    let frame = CGRect(x: origin.x, y: origin.y, width: buttonSize, height: buttonSize)
    let view = UIView(frame: frame)
    view.addSubview(addImageToView(size: view.frame.size, image: image))
    
    //print("Angle arrived: \(angle)")
    return view
  }
  
  private func addImageToView(size: CGSize, image: String) -> UIImageView
  {
    //let im = UIImage(named: "ArcsIcon")!
    let im = UIImage(named: image)!
    let imv = UIImageView(image: im)
    imv.contentMode = .scaleAspectFit
    imv.layer.minificationFilter = kCAFilterTrilinear
    imv.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    return imv
  }
  
  private func createOriginFrom(radius: CGFloat, angle: CGFloat ) -> CGPoint
  {
    let radiansAngle = toRadians(angle)
    let xOrigin = bounds.size.width - cos(radiansAngle) * radius - buttonSize / 2
    let yOrigin = bounds.size.height - sin(radiansAngle) * radius - buttonSize / 2
    
    //print("x:\(xOrigin), y: \(yOrigin)")
    
    return CGPoint(x: xOrigin, y: yOrigin)
  }
  
  private func createEnteringAnimationForButtonInArc(endAngle: CGFloat, clockwise: Bool, radius: CGFloat) -> CAKeyframeAnimation
  {
    let appleAngle: CGFloat = endAngle + 180
    let startAngle: CGFloat = clockwise ? 180 : 270
    let path = createArcPathFromCenter(startAngle: startAngle, endAngle: appleAngle, radius: radius, clockwise: clockwise)
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.path = path
    animation.calculationMode = kCAAnimationPaced
    animation.duration = duration
    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
    animation.fillMode = kCAFillModeForwards
    animation.isRemovedOnCompletion = false
    
    return animation
  }
  
  private func createExitAnimationForButtonInArc(endAngle: CGFloat, clockwise: Bool, radius: CGFloat) -> CAKeyframeAnimation
  {
    let appleAngle: CGFloat = endAngle + 180
    let endAngle: CGFloat = clockwise ? 180 : 270
    let path = createArcPathFromCenter(startAngle: appleAngle, endAngle: endAngle, radius: radius, clockwise: !clockwise)
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.path = path
    animation.calculationMode = kCAAnimationPaced
    animation.duration = duration
    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
    animation.fillMode = kCAFillModeForwards
    animation.isRemovedOnCompletion = false
    
    return animation
  }
  
  public func animateExternalArc()
  {
    let arc = createExternaArcLayer()
    addShadowToArc(layer: arc, color: externalArcShadowColor)
    
    self.layer.insertSublayer(arc, at: 0)
    
    self.externalArc = arc
    
    let anim = createCircleUpAnimation()
    self.externalArc.add(anim, forKey: nil)
  }
  
  private func createGradientLayer() -> CAGradientLayer
  {
    let gradient = CAGradientLayer()
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
    
    gradient.colors = [UIColor.blue, UIColor.yellow].map { return $0.cgColor }
    let locations: [NSNumber] = [0.2, 0.8]
    gradient.locations = locations
    
    return gradient
  }
  
  private func createExternaArcLayer() -> CAShapeLayer
  {
    let shape = CAShapeLayer()
    shape.path = createArcPathFromCenter(startAngle: 270.0, endAngle: 180.0, radius: externalRadius, clockwise: false)
    shape.fillColor = UIColor.clear.cgColor
    shape.strokeColor = externalArcColor.cgColor
    shape.lineWidth = arcWidth
    shape.lineJoin = kCALineJoinMiter
    
    return shape
  }
  
  public func revertArcUpAnimation(arc: CALayer)
  {
    let anim = revertCircleUpAnimation()
    arc.add(anim, forKey: nil)
  }
  
  public func revertArcDownAnimation(arc: CALayer)
  {
    let anim = revertCircleDownAnimation()
    arc.add(anim, forKey: nil)
  }
  
  public func animateCentralArc()
  {
    let arc = createCentralArcLayer()
    addShadowToArc(layer: arc, color: middleArcShadowColor)
    
    self.layer.insertSublayer(arc, at: 0)
    
    self.centralArc = arc
    
    let anim = createCircleDownAnimation()
    self.centralArc.add(anim, forKey: nil)
  }
  
  private func createCentralArcLayer() -> CAShapeLayer
  {
    let arcShape = CAShapeLayer()
    arcShape.path = createArcPathFromCenter(startAngle: 270.0, endAngle: 180.0, radius: middleRadius, clockwise: false)
    arcShape.fillColor = UIColor.clear.cgColor
    arcShape.strokeColor = middleArcColor.cgColor
    arcShape.lineWidth = arcWidth
    arcShape.lineJoin = kCALineJoinMiter
    
    return arcShape
  }
  
  private func animateInnerArc()
  {
    let arc = createInnerArc()
    addShadowToArc(layer: arc, color: innerArcShadowColor)
    
    self.layer.insertSublayer(arc, at: 0)
    self.innerArc = arc
    
    let anim = createCircleUpAnimation()
    self.innerArc.add(anim, forKey: nil)
  }
  
  private func createInnerArc() -> CAShapeLayer
  {
    let shape = CAShapeLayer()
    shape.path = createArcPathFromCenter(startAngle: 270.0, endAngle: 180.0, radius: innerRadius, clockwise: false)
    shape.fillColor = UIColor.clear.cgColor
    shape.strokeColor = innerArcColor.cgColor
    shape.lineWidth = arcWidth
    shape.lineJoin = kCALineJoinMiter
    
    return shape
  }
  
  private func addShadowToArc(layer: CALayer, color: UIColor)
  {
    layer.shadowColor = color.cgColor
    layer.shadowRadius = 20
    layer.shadowOpacity = 0.8
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    layer.shadowOffset = CGSize(width: -2.0,  height: -2.0)
  }
  
  private func createCircleUpAnimation() -> CABasicAnimation
  {
    // tip: this goes up, if I want it to go down I must use strokeEnd and inver the to and from values
    let anim = CABasicAnimation(keyPath: "strokeStart")
    anim.duration = duration
    anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
    anim.fromValue = 1.0
    anim.toValue = 0.0
    
    return anim
  }
  
  private func revertCircleUpAnimation() -> CABasicAnimation
  {
    // tip: this goes up, if I want it to go down I must use strokeEnd and inver the to and from values
    let anim = CABasicAnimation(keyPath: "strokeStart")
    anim.duration = duration
    anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
    anim.fromValue = 0.0
    anim.toValue = 1.0
    anim.fillMode = kCAFillModeForwards
    anim.isRemovedOnCompletion = false
    
    return anim
  }
  
  private func createCircleDownAnimation() -> CABasicAnimation
  {
    let anim = CABasicAnimation(keyPath: "strokeEnd")
    anim.duration = duration
    anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
    anim.fromValue = 0.0
    anim.toValue = 1.0
    
    return anim
  }
  
  private func revertCircleDownAnimation() -> CABasicAnimation
  {
    let anim = CABasicAnimation(keyPath: "strokeEnd")
    anim.duration = duration
    anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
    anim.fromValue = 1.0
    anim.toValue = 0.0
    anim.fillMode = kCAFillModeForwards
    anim.isRemovedOnCompletion = false
    
    return anim
  }
  
  private func createArcPathFromCenter(startAngle: CGFloat, endAngle: CGFloat, radius: CGFloat, clockwise: Bool) -> CGPath
  {
    let radStartAngle = toRadians(CGFloat(startAngle))
    let radEndAngle = toRadians(CGFloat(endAngle))
    
    let path = UIBezierPath(arcCenter: arcsCenter,
                            radius: radius,
                            startAngle: radStartAngle,
                            endAngle: radEndAngle,
                            clockwise: clockwise)
    return path.cgPath
  }
  
  private func toRadians(_ deg: CGFloat) -> CGFloat
  {
    return deg * CGFloat.pi / 180
  }
  
  public func resetVariables()
  {
    removeViewsInArc(viewsInArc: viewsInInnerArc)
    removeViewsInArc(viewsInArc: viewsInMiddleArc)
    removeViewsInArc(viewsInArc: viewsInExternalArc)
    
    self.innerArc.removeFromSuperlayer()
    self.centralArc.removeFromSuperlayer()
    self.externalArc.removeFromSuperlayer()
    
    self.innerArc = CAShapeLayer()
    self.centralArc = CAShapeLayer()
    self.externalArc = CAShapeLayer()
    
    viewsInInnerArc = nil
    viewsInMiddleArc = nil
    viewsInExternalArc = nil
    
    innerViewsPositions.removeAll()
    middleViewPositions.removeAll()
    externalViewPositions.removeAll()
  }
  
  private func removeViewsInArc(viewsInArc: ViewsInArcData?)
  {
    guard let data = viewsInArc else { return }
    
    for view in data.views
    {
      view.removeFromSuperview()
    }
  }
  
  private func calculateSpeedOfViewInArc(angle: CGFloat, time: CGFloat) -> CGFloat
  {
    return angle / time
  }
  
  private func calculateTimeFoViewInArc(angle: CGFloat, speed: CGFloat) -> CGFloat
  {
    return angle / speed
  }
}

extension MovingArcsView: CAAnimationDelegate
{
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
  {
    if let name = anim.value(forKey: externalPathAnimKey) as? String
    {
      startAnimationIsInProgress = false
      if let viewOrigin = externalViewPositions[name]
      {
        viewOrigin.0.frame.origin = viewOrigin.1
        viewOrigin.0.layer.removeAllAnimations()
      }
    }
    if let name = anim.value(forKey: middlePathAnimKey) as? String
    {
      if let viewOrigin = middleViewPositions[name]
      {
        viewOrigin.0.frame.origin = viewOrigin.1
        viewOrigin.0.layer.removeAllAnimations()
      }
    }
    if let name = anim.value(forKey: innerPathAnimKey) as? String
    {
      if let viewOrigin = innerViewsPositions[name]
      {
        viewOrigin.0.frame.origin = viewOrigin.1
        viewOrigin.0.layer.removeAllAnimations()
      }
    }
    
    if anim.value(forKey: reverseAnimationFinished) != nil
    {
      reverseAnimationIsInProgress = false
      animationsFinishedCallback?()
    }
  }
}

