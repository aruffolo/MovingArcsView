//
//  AnimationsFactory.swift
//  MovingArcsMenu
//
//  Created by Ruffolo Antonio on 20/04/2018.
//

import UIKit

public enum AnimationDirection: Int
{
  case positive = 1
  case negative = -1
}

public final class AnimationsFactory
{
  public static func createFadeInAnimation(duration: CFTimeInterval) -> CABasicAnimation
  {
    let anim = CABasicAnimation(keyPath: "opacity")
    anim.duration = duration
    anim.fromValue = 0.0
    anim.toValue = 1.0
    anim.fillMode = kCAFillModeForwards
    anim.isRemovedOnCompletion = false
    
    return anim
  }
  
  public static func createFadeOutAnimation(duration: CFTimeInterval) -> CABasicAnimation
  {
    let anim = CABasicAnimation(keyPath: "opacity")
    anim.duration = duration
    anim.fromValue = 1.0
    anim.toValue = 0.0
    anim.fillMode = kCAFillModeForwards
    anim.isRemovedOnCompletion = false
    
    return anim
  }
}

