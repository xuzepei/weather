//
//  ViewController.swift
//  Weather
//
//  Created by xuzepei on 2025/2/18.
//

import UIKit
import CoreLocation

class ViewController: BaseViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    let cellNibName = "TemperatureCell"
    let cellId = "temperature_cell"
    
    let chartCellNibName = "ChartCell"
    let chartCellId = "chart_cell"
    
    let temperatureCellHeight = 40.0
    let chartCellHeight = 300.0
    
    var locationManager: CLLocationManager? = CLLocationManager()
    var isRequestingLocation: Bool = false
    
    var refreshControl = UIRefreshControl()
    
    var weatherData:Dictionary<String, AnyObject>? = nil
    var weatherTimeDataArray = NSMutableArray()
    var nowIndex:Int = -1
    
    //Rrefresh timer, refresh the weather data every 5 min
    var timer: Timer? = nil
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Today Weather"
        self.navBar.titleLabel?.text = self.title
        
        setup()
    }
    
    func setup() {
        initTableView()

        startToRefreshData()
    }
    
    func initTableView() {
        
        let nib = UINib(nibName: cellNibName, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellId)
        
        let chartCellNib = UINib(nibName: chartCellNibName, bundle: nil)
        self.tableView.register(chartCellNib, forCellReuseIdentifier: chartCellId)
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        //refreshControl.tintColor = .clear
        tableView.addSubview(refreshControl)
        
        //self.tableView.reloadData()
    }
    
    @objc func refreshData() {
        self.tableView.reloadData()

        updateLocation()
    }
    
    
    func updateLocation() {
        
        //print("locationManager.authorizationStatus: \(locationManager?.authorizationStatus)")
        
        if  locationManager?.authorizationStatus != .notDetermined && locationManager?.authorizationStatus != .authorizedWhenInUse && locationManager?.authorizationStatus != .authorizedAlways {
            
            self.handleUpdateWeatherFailed()
            
            let delayInSeconds: Double = 1
            let dispatchTime = DispatchTime.now() + delayInSeconds
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                let errorMesg = "Cannot get current location. Need to allow locaction access in Settings."
                Tool.showAlert("Tip", message: errorMesg, rootVC: self)
            }

            return
        }
        
        
        if self.isRequestingLocation {
            return
        }
        self.isRequestingLocation = true

        if self.refreshControl.isRefreshing == false {
            self.hud?.hide(animated: false, afterDelay: 0)
            self.hud = MBProgressHUD.showAdded(to: view, animated: true)
        }

        locationManager?.stopUpdatingLocation()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // Request permission to access the user's location
        locationManager?.requestWhenInUseAuthorization()
        
        // Start updating the location
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Location: notDetermined")
        case .restricted, .denied:
            Tool.showAlert("Tip", message: "Cannot get current location. Need to allow locaction access in Settings.", rootVC: self)
            print("Location: restricted or .denied")
        case .authorizedWhenInUse:
            print("Location: authorizedWhenInUse")
        case .authorizedAlways:
            print("Location: authorizedAlways")
        @unknown default:
            print("Location: unknown status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.isRequestingLocation = false
        
        //self.hud?.hide(animated: false, afterDelay: 0)
        manager.stopUpdatingLocation()
        
        if let location = locations.first {
            updateLocationName(location: location)
            updateWeather(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        
        handleUpdateWeatherFailed()
    }

    
    func updateLocationName(location: CLLocation) {

        // Reverse geocode the location to get an address
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            
            guard let placemark = placemarks?.first else {
                print("Failed to get address for location: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Use the placemark's name property to get the location name
            let country = placemark.country ?? ""
            let state = placemark.administrativeArea ?? ""
            let city = placemark.locality ?? ""
            
            print("Country: \(country), State: \(state), City: \(city)")
            
            if !city.isEmpty {
                self.locationLabel.text = city
            } else if !state.isEmpty {
                self.locationLabel.text = state
            } else if !country.isEmpty {
                self.locationLabel.text = country
            }
            

        }
    }
    
    func updateWeather(location: CLLocation) {
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("latitude: \(latitude), longitude: \(longitude)")
        
        if Tool.shared.isNetworkReachable() == false {
            handleUpdateWeatherFailed()
            Tool.showToast(text: LS("No internet connection."), type: .Error)
            return
        }
        
        
        if isRequesting {
            return
        }
        
        self.isRequesting = true
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m"
        
        let request = HttpRequest()
        let b = request.get(urlString, resultBlock: { [weak self] dict in

            guard let self = self else {
                return
            }
            
            if let dict {
                debugPrint(dict)
                
                if let hourlyData = dict["hourly"] as? Dictionary<String, AnyObject> {
                    self.weatherData = hourlyData
                    handleUpdateWeatherSucceeded()
                }
            }

            handleUpdateWeatherFailed()
            return
            
        }, token: nil)
        
        if b == false {
            handleUpdateWeatherFailed()
        }
    }
    
    func handleUpdateWeatherSucceeded() {
        
        self.isRequesting = false
        
        DispatchQueue.main.async {
            self.hud?.hide(animated: false, afterDelay: 0)
            self.refreshControl.endRefreshing()
            
            self.weatherTimeDataArray.removeAllObjects()
            
            if let timeDataArray = self.weatherData?["time"] as? [String] {
                self.weatherTimeDataArray.addObjects(from: timeDataArray)
            }
            
            self.updateCurrentTemperature()
            
            self.tableView.reloadData()
        }
        
    }
    
    func handleUpdateWeatherFailed() {
        
        self.isRequesting = false
        
        DispatchQueue.main.async {
            self.hud?.hide(animated: false, afterDelay: 0)
            self.refreshControl.endRefreshing()
        }
    }
    
    func updateCurrentTemperature() {
        let temp = getCurrentTemperature()
        self.currentTemperatureLabel.text = temp.isEmpty ? "" : "  \(temp)°"
    }
    
    func getCurrentTemperature() -> String {
        // 获取当前的日期和时间
        let currentDate = Date()

        // 设置时区为 GMT
        let gmtTimeZone = TimeZone(identifier: "GMT")!

        // 创建一个日期格式化器
        let formatter = DateFormatter()
        formatter.timeZone = gmtTimeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:00"

        // 将当前时间格式化为 GMT 时间
        let currentGMTDate = formatter.string(from: currentDate)
        
        print("currentGMTDate: \(currentGMTDate)")
        
        
        for (index, dateStr) in self.weatherTimeDataArray.enumerated() {
            if let tempStr = dateStr as? String {
                if tempStr == currentGMTDate {
                    print("index: \(index)")
                    if let temperatureDataArray = self.weatherData?["temperature_2m"] as? [Any] {
                        if index < temperatureDataArray.count {
                            self.nowIndex = index
                            
                            if let temperatureNum = temperatureDataArray[index] as? NSNumber {
                                return String(temperatureNum.intValue)
                            }
                        }
                    }
                }
            }
        }
        
        return ""
    }
    
    func startToRefreshData() {
        
        self.timer?.invalidate()
        self.timer = nil
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 5*60, repeats: true) { timer in
            // This code will be executed every time the timer fires
            print("####Timer fired!")
            
            self.updateLocation()

        }

        // Start the timer
        self.timer?.fire()
    }
    
    
    func goToChartViewController() {
        let vc = ChartViewController()
        vc.weatherData = self.weatherData
        vc.nowIndex = self.nowIndex
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -
extension ViewController: UITableViewDataSource, UITableViewDelegate,  UIScrollViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if 0 == section {
            return min(weatherTimeDataArray.count, Tool.MAX_TIME_COUNT)
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if 0 == indexPath.section {
            return temperatureCellHeight
        } else {
            return chartCellHeight
        }
    }
    
    func getCellDataAtIndexPath(_ indexPath: IndexPath) -> (String, String)? {
        
        if 0 == indexPath.section {
            
            if nowIndex != -1 {
                
                var time = ""
                var temperature = ""
                
                let index = nowIndex + indexPath.row
                if index < self.weatherTimeDataArray.count {
                    if let temperatureDataArray = self.weatherData?["temperature_2m"] as? [Any] {
                        if index < temperatureDataArray.count {
                            
                            if let dateStr = self.weatherTimeDataArray[index] as? String {
                                time = Tool.convertGMTToLocalTime(gmtDateString: dateStr)
                                if indexPath.row == 0 {
                                    time = "Now"
                                }
                                
                                if let temperatureNum = temperatureDataArray[index] as? NSNumber {
                                    temperature = String(temperatureNum.intValue)
                                }
                                
                                return (time, temperature)
                            }
                        }
                    }

                }
            }
        }

        return nil
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var myCell: UITableViewCell? = nil
        if 0 == indexPath.section {
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? TemperatureCell
            {
                if let item = getCellDataAtIndexPath(indexPath) {
                    
                    cell.updateContent(data: item)
                }
                
                myCell = cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: chartCellId, for: indexPath) as? ChartCell
            {
                cell.updateContent(data: self.weatherData, nowIndex: self.nowIndex)
                myCell = cell
            }
        }

        myCell?.accessoryType = .none
        myCell?.selectionStyle = .none
        return myCell!
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        goToChartViewController()
    }

}

