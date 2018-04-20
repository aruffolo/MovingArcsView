# MovingArcsMenu

[![Version](https://img.shields.io/cocoapods/v/MovingArcsMenu.svg?style=flat)](http://cocoapods.org/pods/MovingArcsMenu)
[![License](https://img.shields.io/cocoapods/l/MovingArcsMenu.svg?style=flat)](http://cocoapods.org/pods/MovingArcsMenu)
[![Platform](https://img.shields.io/cocoapods/p/MovingArcsMenu.svg?style=flat)](http://cocoapods.org/pods/MovingArcsMenu)

## Overview

MovingArcsMenu is a subclass of UIView, written in Swift, that creates a bottom right menu

![](ArcsViewOpen.PNG?raw=true "Arcs Screenshoot in 'A Complex Calc")

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* iOS 8
* Swift 4.0

## Installation

MovingArcsMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MovingArcsMenu'
```

## Usage

Add the view into the storyboard or create it from code, after you have a reference to it you should initialize its paramteters. In the example below appearence and tag for the buttons in the arcs are setted.
Tag are useful to tell which button has been tapped. Array of strings are passed to let the view import the images for the buttons inside the arcs

```Swift

let viewsOnExternalArc: ArcsButtonsNumber = .five
let viewsOnMiddleArc: ArcsButtonsNumber = .three

let tagsForButtonsInExternalArc: [Int] = [24, 28, 27, 25, 26]
let tagsForButtonsInMiddleArc: [Int] = [23, 22, 21]

do
{
  let tuple = (innerArcColor: deepMarineBlue, middleArcColor: deepMarineBlue, externalArcColor: deepMarineBlue, innerArcShadowColor: waterGreen, middleArcShadowColor: waterGreen, externalArcShadowColor: UIColor.black)
  try arcsView.initParameters(viewsOnExternalArc: viewsOnExternalArc,
  viewsOnMiddleArc: viewsOnMiddleArc,
  tagsForButtonsInExternalArc: tagsForButtonsInExternalArc,
  tagsForButtonsInMiddleArc: tagsForButtonsInMiddleArc,
  arcColors: tuple, buttonScale: 0.33,
  imagesForExternalArc: ["CloseIcon", "CloseIcon", "CloseIcon", "CloseIcon", "CloseIcon"],
  imagesForMiddleArc: ["CloseIcon", "CloseIcon", "CloseIcon"],
  imagesForInnerArc: ["CloseIcon"])
}
catch ArcsViewsError.viewsNUmberAndTagsNumberMismatch(let errorMessage)
{
  print(errorMessage)
}
catch
{
  print(error)
}

```

The view is opened or closed using the animation functions provided:

```Swift

@IBAction func showHideArcsAction(_ sender: UIButton)
{
  /// this one animate the opening animation of the arcs
  arcsView.start()
}

private lazy var viewsOnArcTapped: ((_ sneder: UITapGestureRecognizer) -> Void)? = { [unowned self] sender in
  /// this one closes the animation of the arcs
  self.arcsView.revertAnimations()
}

```



## Author

Antonio Ruffolo

## License

MovingArcsMenu is available under the MIT license. See the LICENSE file for more info.
