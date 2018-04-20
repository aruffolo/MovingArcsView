//
//  ViewController.swift
//  MovingArcsMenu
//
//  Created by aruffolo on 04/20/2018.
//  Copyright (c) 2018 aruffolo. All rights reserved.
//

import UIKit
import MovingArcsMenu

class ViewController: UIViewController
{
  @IBOutlet weak var arcsView: MovingArcsView!
  
  private let deepMarineBlue = UIColor(red: 1 / 255, green: 0 / 255, blue: 49 / 255, alpha: 1.0)
  private let waterGreen = UIColor(red: 45 / 255, green: 182 / 255, blue: 166 / 255, alpha: 1.0)
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    initArcsView()
    setArcsViewCallbacks()
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func initArcsView()
  {
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
  }

  private func setArcsViewCallbacks()
  {
    arcsView.animationsFinishedCallback = self.arcsAnimationsFinishedCallback
    arcsView.viewsOnArcHasBeenTapped = self.viewsOnArcTapped
  }
  
  private lazy var arcsAnimationsFinishedCallback: () -> Void = { [unowned self] in
    print("Arcs view animation is finished")
    self.arcsView.resetVariables()
  }
  
  private lazy var viewsOnArcTapped: ((_ sneder: UITapGestureRecognizer) -> Void)? = { [unowned self] sender in
    print("Button in external arc has been tapped, tag: \(sender.view!.tag)")
    
    self.arcsView.revertAnimations()
  }
  
  @IBAction func showHideArcsAction(_ sender: UIButton)
  {
    arcsView.start()
  }
}

