//
//  MapViewController.swift
//  cobaapi
//
//  Created by bevan christian on 27/03/21.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel
class MapViewController: UIViewController ,MKMapViewDelegate,CLLocationManagerDelegate,FloatingPanelControllerDelegate{

    @IBOutlet var pencet: UITabBarItem!
    @IBOutlet var map: MKMapView!
    var locationManager :CLLocationManager!
    var curentLocation = ""
   // let restaurantData = RestaurantData()
    var cordinate = [String]()
    var lat:Double!
    var lng:Double!
    var resto = [restaurant]()
    var nama:String!
    var bintang:String!
    var alamat:String!
    var pin = [Anotate]()
    var gambar:UIImage!
    var simpan:FloatMapViewController!
    var lokasifull:String!
    var lokasiUser:String!
    

    var fpc:FloatingPanelController!
    override func viewDidLoad() {
        super.viewDidLoad()
         fpc = FloatingPanelController()
        fpc.delegate = self
        map.delegate = self
        guard let contentVC = storyboard?.instantiateViewController(identifier: "floatingmap") as? FloatMapViewController else{
            return
        }
        simpan = contentVC
        fpc.set(contentViewController: contentVC)
        let appearance = SurfaceAppearance()

        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 12
        shadow.spread = 8
        appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 12.0
        appearance.backgroundColor = .clear

        // Set the new appearance
        fpc.surfaceView.appearance = appearance

        fpc.preferredContentSize = CGSize(width: 100, height: 100)
        fpc.contentMode = .fitToBounds
      
        fpc.addPanel(toParent: self)
        fpc.panGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: 0.25) { [self] in
            fpc.move(to: .hidden, animated: true)
        }
        let tab = tabBarController as? TabbarViewController
        if let resto = try? tab?.restoran{
            for x in 0...resto.count-1{
                cordinate.append(contentsOf: resto[x].lokasiMap.components(separatedBy: ","))
                 lat = Double(cordinate[0])
                 lng = Double(cordinate[1])
                let london = Anotate(title: resto[x].nama, subtitle: String(resto[x].rating), coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),gambar: resto[x].gambarFinal,alamat: resto[x].address,lokasifull: resto[x].lokasiMap)
                pin.append(london)
                print(london)
                cordinate.removeAll()
             }
    
            map.addAnnotations(pin)
        }

    }
    
    
    
  
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Anotate else {return nil}
        let identifier = "capital"
        
        // ini untuk reuse karena anotation itu kayak table view
        var anotationview = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        // namun kadang bisa aja tidak ada yang di reuse karena belum diputer map e
        if anotationview == nil{
            //jika kosong maka harus dibuat anotate nya dengan custom anotate yang sudah dibuat jadi pin
            anotationview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //dan karena anotate nya ga ada button kita akan tambahin button untuk nampilin nama kotae
            anotationview?.canShowCallout = true
            // dan setelah callout ditampilin dikasih button aja dengan tipe detaildisclosure
            anotationview?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            // untuk button e gausa dikasih target kayak method untuk jalanin kalo setelah dipencet soale yang dipanggil itu calloutaccesorycontrolTapped
        }else{
            // kalo sudah ada ya anotate nya tinggal di update dengan yang baru
            anotationview?.annotation = annotation
        }
        
        return anotationview
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
     
       
    }
    // ini cuma dipanggil ketika ada lokasi baru
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ini dapetin lokasi user
        let userLocation = locations[0] as CLLocation
        // ini untuk nge center kamera
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        print(userLocation.coordinate.latitude)
        // ini kotake
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 100000, longitudinalMeters: 100000)
        map.setRegion(region, animated: true)
        
        let lat = String(userLocation.coordinate.latitude)
        let lng = String(userLocation.coordinate.longitude)
        lokasiUser = lat+","+lng
        
        // masukin pin ke user location
        
        let anotate : MKPointAnnotation = MKPointAnnotation()
        anotate.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        map.addAnnotation(anotate)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // ini request user
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            // method ini untuk mulai nyuruh oke start update location
            locationManager.startUpdatingLocation()
            
        }
    }
    
 

    /*func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
            return (newCollection.verticalSizeClass == .compact) ? LandscapePanelLayout() : FloatingPanelBottomLayout()
        }*/
    
    
    // jadi method ini ngasih tau anotate maan yang ditekan kepada view
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // di typecast ke customanotate kita supaya kalo anotate bawaan ga kedetect
        guard let capital = view.annotation as? Anotate else {return}
        // diambil judul dan simpenann
         nama = capital.title
         bintang = capital.subtitle
        alamat = capital.alamat
        gambar = capital.gambarFinal
        lokasifull = capital.lokasifull
        pindah()
    
        
        print("dipencet anotate")
        
    
    }
    
    
    func pindah() {
        UIView.animate(withDuration: 0.6) {
            self.fpc.move(to: .half, animated: true)
        }
        simpan.namaResto.text = nama
        simpan.alamatResto.text = alamat
        simpan.ratingResto.text = bintang
        simpan.gambar.image = gambar
        simpan.lokasi = lokasifull
        simpan.lokasiuser = lokasiUser
        //fpc.panGestureRecognizer.isEnabled = false
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

/*class LandscapePanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 69.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
            surfaceView.widthAnchor.constraint(equalToConstant: 291),
        ]
    }
}*/
