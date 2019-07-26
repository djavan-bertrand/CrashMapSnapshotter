//
//  ViewController.swift
//  TestApp
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    /// Quality of the image to provide
    enum Quality: CustomStringConvertible {
        /// High quality
        case high
        /// Low quality
        case low

        var description: String {
            switch self {
            case .high: return "high"
            case .low:  return "low"
            }
        }

        fileprivate var zoomValue: CGFloat {
            switch self {
            case .high: return 5.0
            case .low:  return 1.0
            }
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var qualityLabel: UILabel!

    private var currentQuality = Quality.low

    private var mapRect: MKMapRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never

        let corners = [
            CLLocationCoordinate2D(latitude: 48.86902670562927, longitude: 2.313831340704411),
            CLLocationCoordinate2D(latitude: 48.8683048314518, longitude: 2.3132453683057292),
            CLLocationCoordinate2D(latitude: 48.869139447805274, longitude: 2.310869070810895),
            CLLocationCoordinate2D(latitude: 48.869861309942024, longitude: 2.31145504320952)
        ]
        var mapRect = MKMapRect.null
        corners.forEach {
            mapRect = mapRect.union(MKMapRect(origin: MKMapPoint($0), size: MKMapSize(width: 0, height: 0)))
        }
        self.mapRect = mapRect
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displaySatelliteImage(quality: .low)
    }

    private func displaySatelliteImage(quality: Quality) {
        currentQuality = quality

        let options = MKMapSnapshotter.Options()
        options.mapRect = mapRect
        options.mapType = .satellite
        options.size = CGSize(width: 892 * quality.zoomValue,
                              height: 713 * quality.zoomValue)

        let snapshotter = MKMapSnapshotter(options: options)
        qualityLabel.text = "fetching \(quality)"
        snapshotter.start { [weak self] snapshot, error in
            switch (snapshot, error) {
            case let (snapshot?, _):
                self?.imageView.image = snapshot.image
                self?.qualityLabel.text = "Quality = \(quality)"
            case let (_, error?):
                self?.qualityLabel.text = "Error: \(error.localizedDescription)"
            case (.none, .none):
                // this should not happen
                self?.qualityLabel.text = "Error"
            }
        }
    }

    @IBAction func reload(_ sender: Any) {
        displaySatelliteImage(quality: .low)
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // If the threshold is passed, fetch a better quality.
        // The best quality will be kept even if we unzoom.
        if currentQuality != .high && scrollView.zoomScale > 1.9 {
            displaySatelliteImage(quality: .high)
        }
    }
}
