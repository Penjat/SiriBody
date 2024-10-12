import UIKit

var greeting = "Hello, playground"




func findClosestRotation(targetYaw: Double, currentYaw: Double) -> Double {
    let difference = targetYaw - currentYaw
    let shortestAngle = atan2(sin(difference), cos(difference))
    return shortestAngle
}

findClosestRotation(targetYaw: -3.10, currentYaw: 3.10)
findClosestRotation(targetYaw: 3.10, currentYaw: -3.10)


