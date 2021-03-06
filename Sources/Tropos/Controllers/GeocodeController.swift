import CoreLocation
import ReactiveObjCBridge
import ReactiveSwift
import Result

@objc(TRGeocodeController)
final class GeocodeController: NSObject {
    private let geocoder: Geocoder

    init(geocoder: Geocoder) {
        self.geocoder = geocoder
    }

    convenience override init() {
        self.init(geocoder: CLGeocoder())
    }

    func reverseGeocode(_ location: CLLocation) -> SignalProducer<CLPlacemark, CLError> {
        return SignalProducer { [geocoder] observer, lifetime in
            lifetime.observeEnded(geocoder.cancelGeocode)

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                switch (placemarks, error) {
                case let (placemarks?, nil):
                    observer.send(value: placemarks.first!)
                    observer.sendCompleted()
                case (nil, CLError.geocodeCanceled?):
                    observer.sendInterrupted()
                case let (nil, error?):
                    observer.send(error: error as! CLError)
                default:
                    fatalError()
                }
            }
        }
    }
}

extension GeocodeController {
    @objc func reverseGeocodeLocation(_ location: CLLocation) -> RACSignal<CLPlacemark> {
        return reverseGeocode(location).bridged
    }
}
