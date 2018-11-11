# Badger Map

This iOS application uses ARKit + CoreLocation framework to generate an AR view of the campus of UW-Madison. It displays labels representing several buildings, which also displays some descriptions of the building when clicked. It also provides ways of navigation to these buildings. 

## Requirements

ARKit requires iOS 11, and supports the following devices:
- iPhone X (Recommended)
- iPhone 6S and upwards
- iPhone SE
- iPad (2017)
- All iPad Pro models

iOS 11 can be downloaded from Apple’s Developer website.

## Usage

 ARKit + CoreLocation framework is required to import this application to your iOS device through XCode. 
 
[Be sure to read the section on True North calibration.](#true-north-calibration)

### Setting up using CocoaPods
1. Add to your podfile:

`pod 'ARCL'`

2. In Terminal, navigate to your project folder, then:

`pod update`

`pod install`

3. Add `NSCameraUsageDescription` and `NSLocationWhenInUseUsageDescription` to plist with a brief explanation (see demo project for an example)

### Setting up manually
1. Add all files from the `ARKit+CoreLocation/Source` directory to your project.
2. Import ARKit, SceneKit, CoreLocation and MapKit.
3. Add `NSCameraUsageDescription` and `NSLocationWhenInUseUsageDescription` to plist with a brief explanation (see demo project for an example)

### Quick start guide
To place a pin over a building, for example Canary Wharf in London, we’ll use the main class that ARCL is built around - `SceneLocationView`.

First, import ARCL and CoreLocation, then declare SceneLocationView as a property:

```
import ARCL
import CoreLocation

class ViewController: UIViewController {
  var sceneLocationView = SceneLocationView()
}
```

You should call `sceneLocationView.run()` whenever it’s in focus, and `sceneLocationView.pause()` if it’s interrupted, such as by moving to a different view or by leaving the app.

```
override func viewDidLoad() {
  super.viewDidLoad()

  sceneLocationView.run()
  view.addSubview(sceneLocationView)
}

override func viewDidLayoutSubviews() {
  super.viewDidLayoutSubviews()
  
  sceneLocationView.frame = view.bounds
}
```

After we’ve called `run()`, we can add our coordinate. ARCL comes with a class called `LocationNode` - an object within the 3D scene which has a real-world location along with a few other properties which allow it to be displayed appropriately within the world. `LocationNode` is a subclass of SceneKit’s `SCNNode`, and can also be subclassed further. For this example we’re going to use a subclass called `LocationAnnotationNode`, which we use to display a 2D image within the world, which always faces us:

```
let coordinate = CLLocationCoordinate2D(latitude: 51.504571, longitude: -0.019717)
let location = CLLocation(coordinate: coordinate, altitude: 300)
let image = UIImage(named: "pin")!

let annotationNode = LocationAnnotationNode(location: location, image: image)
```

By default, the image you set should always appear at the size it was given, for example if you give a 100x100 image, it would appear at 100x100 on the screen. This means distant annotation nodes can always be seen at the same size as nearby ones. If you’d rather they scale relative to their distance, you can set LocationAnnotationNode’s `scaleRelativeToDistance` to `true`.

```
sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
```

There are two ways to add a location node to a scene - using `addLocationNodeWithConfirmedLocation`, or `addLocationNodeForCurrentPosition`, which positions it to be in the same position as the device, within the world, and then gives it a coordinate.

So that’s it. If you set the frame of your sceneLocationView, you should now see the pin hovering above Canary Wharf.

## Going Forward

This program now is only fully functional on iPhone X. A reset button cannot be displayed on other devices at this point. We are also trying to implement AR navigation where AR arrows are used for direction. This application has a great potential of what it can do and we would like to improve it beyond its boundary. 

## Thanks

ARKit + CoreLocation fram work available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
