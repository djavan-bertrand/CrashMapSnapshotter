# CrashMapSnapshotter

## Purpose
The purpose of this repo is to show a bug in the MKMapSnapshotter: if the snapshotter function `start(completionHandler: @escaping MKMapSnapshotter.CompletionHandler)` issues an error in its `completionHandler`, then the snapshotter cannot be used anymore unless the device is rebooted.

What is happening is, after the first error, the completion handler is not called anymore.

## Content of the project
This project contains only one view controller: `ViewController`. This view controller contains a scroll view that displays a map snapshot. When zooming inside a snapshot, it gathers a better quality snapshot (i.e. same geographic area but snapshot image is bigger).<br/>
The first snapshot is get at a `low` quality (`892x713`). After zooming, the snapshot is get at a `high` quality (`4460x3565`).<br/>
To be sure to make the snapshotter crash, the `high` quality snapshot is a very big image.

There is a UILabel at the bottom of the screen to display the current quality and any error that happened.

## How to test

- Launch the app<br/>
  *A snapshot should be displayed, debug label should tell that the low quality is currently displayed.*
- Zoom in the snapshot<br/>
  *As the big quality cannot be loaded, the snapshotter will issue an error, this will be displayed in the debug label.*
- Kill the app and relaunch it.<br/>
  *This is to display the low quality again*

**=> The low quality snapshot won't load**. In fact, the `completionHandler` is not called.

🐛 In order to display the snapshot again, **you must reboot the device**. 😭

**Tested on:<br/>**
*Xcode 10.2, 10.3 ; iOS 12.3.1 (iPhone X)<br/>
Xcode 11 beta 4 ; iOS 13.0 (iPhone Xr)*
