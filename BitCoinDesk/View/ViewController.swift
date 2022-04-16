//
//  ViewController.swift
//  BitCoinDesk
//
//  Created by Mac on 13/04/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var contents: [Content] = []
    private var pointEntries: [PointEntry] = []
    
    // For foreground fetch data
    private var timer = Timer()
    
    // For get user location
    private var locationManager: CLLocationManager!
    private var currentUserLocation: UserLocation? = nil
    
    // For current selected currency code
    private var selectedCurrencyCode = "USD"
    
    lazy var presenter: MainPresenter = {
        return MainPresenter.init(delegate: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTitleLabel()
        setupCustomTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupForegroundRefreshTimer()
        setupUsersLocationServicesAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
    }
    
    private func setupTitleLabel() {
        self.titleLabel.text = "Bitcoin Price Index \n \(Date().toString(format: "EEE, dd MMM yyyy"))"
    }
    
    private func setupLastUpdateLabel(todayCharts: [Chart]) {
        if let createdAt = todayCharts.last?.createdAt {
            self.lastUpdateLabel.text = "Last sync on \(Date(timeIntervalSince1970: createdAt).toString(format: "EEE, dd MMM yyyy HH:mm:ss"))"
        }
    }
        
    private func setupForegroundRefreshTimer() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: Configuration.Time.refreshTime, repeats: true, block: { [weak self] _ in
            self?.loadingView.isHidden = false
            self?.presenter.fetchCurrentPriceFromAPI()
        })
    }
    
    private func setupUsersLocationServicesAuthorization() {
        // Check if user has authorized to use Location Services
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                // This is the first and the ONLY time you will be able to ask the user for permission
                setupUserCurrentLocation()
                break
            case .restricted, .denied:
                // Disable location features
                showManualLocationPermission()
                checkLatestChartOnDatabase()
                break
            case .authorizedWhenInUse, .authorizedAlways:
                // Enable features that require location services here.
                setupUserCurrentLocation()
                break
            @unknown default:
                break
            }
        }
    }
    
    func showManualLocationPermission() {
        let alert = UIAlertController(title: "Allow Location Access", message: "BitCoinDesk needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func setupUserCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func checkLatestChartOnDatabase() {
        let charts = presenter.fetchDataFromCoreDataDB()
        
        if charts.isEmpty {
            
            DispatchQueue.main.async { [weak self] in
                self?.loadingView.isHidden = false
            }
           
            presenter.fetchCurrentPriceFromAPI()
        }
        else {
            let todayCharts = presenter.deletePastDataFromCoreDataDB(charts: charts)
            self.contents = presenter.generateContent(charts: todayCharts, currencyCode: selectedCurrencyCode)
            self.pointEntries = presenter.generatePointEntry(charts: todayCharts, currencyCode: selectedCurrencyCode)
            
            DispatchQueue.main.async { [weak self] in
                self?.setupLastUpdateLabel(todayCharts: todayCharts)
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupCustomTableViewCell() {
        self.tableView.register(UINib(nibName: "ChartTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "chartTableViewCell")
        self.tableView.register(UINib(nibName: "ContentTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "contentTableViewCell")
    }
    
    // MARK: - Button Action
    @IBAction private func didTapRefreshButton() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView.isHidden = false
        }
        
        presenter.fetchCurrentPriceFromAPI()
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0:
            self.selectedCurrencyCode = "USD"
                break;
            case 1:
            self.selectedCurrencyCode = "GBP"
                break;
            case 2:
            self.selectedCurrencyCode = "EUR"
                break;
            default:
            self.selectedCurrencyCode = "USD"
                break;
        }
        
        let charts = presenter.fetchDataFromCoreDataDB()
        let todayCharts = presenter.deletePastDataFromCoreDataDB(charts: charts)
        self.contents = presenter.generateContent(charts: todayCharts, currencyCode: selectedCurrencyCode)
        self.pointEntries = presenter.generatePointEntry(charts: todayCharts, currencyCode: selectedCurrencyCode)
    
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.loadingView.isHidden = true
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !locations.isEmpty {
            let userLocation: CLLocation = locations[0] as CLLocation
            let latitude = userLocation.coordinate.latitude
            let longitude = userLocation.coordinate.longitude
            print("user latitude = \(latitude)")
            print("user longitude = \(longitude)")
            manager.stopUpdatingLocation()
            currentUserLocation = UserLocation()
            currentUserLocation?.latitude = latitude
            currentUserLocation?.longitude = longitude
        }
        manager.stopUpdatingLocation()
        checkLatestChartOnDatabase()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - MainPresenterDelegate
extension ViewController: MainPresenterDelegate {
    func didFailedFetchCurrentPriceFromAPI() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView.isHidden = true
        }
    }
    
    func didSuccessFetchCurrentPriceFromAPI(currentPrice: CurrentPriceModel) {
           
        let context = AppDelegate.instance.sharedContext()
        let defaultLocation = UserLocation(latitude: 0, longitude: 0)
        var location: Location? = nil
      
        if let newCurrentUserLocation = self.currentUserLocation {
            location = Location.create(newCurrentUserLocation, context)
        }
        else {
            location = Location.create(defaultLocation, context)
        }
        
        let usd = currentPrice.bpi?.usd ?? Currency()
        let eur = currentPrice.bpi?.eur ?? Currency()
        let gbp = currentPrice.bpi?.gbp ?? Currency()
        let priceUSD = Price.create(usd, context)
        let priceGBP = Price.create(gbp, context)
        let priceEUR = Price.create(eur, context)
        
        let _ = Chart.create(currentPrice, location!, priceGBP, priceUSD, priceEUR, context)
        
        try? context.save()
       
        let charts = presenter.fetchDataFromCoreDataDB()
        let todayCharts = presenter.deletePastDataFromCoreDataDB(charts: charts)
        self.contents = presenter.generateContent(charts: todayCharts, currencyCode: selectedCurrencyCode)
        self.pointEntries = presenter.generatePointEntry(charts: todayCharts, currencyCode: selectedCurrencyCode)
        
        DispatchQueue.main.async { [weak self] in
            self?.setupTitleLabel()
            self?.setupLastUpdateLabel(todayCharts: todayCharts)
            self?.tableView.reloadData()
            self?.loadingView.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Configuration.TableView.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Section 0 render chart view, Section 1 render price
        if section == 0 {
            return Configuration.TableView.chartNumberOfRow
        }
        return self.contents.count > Configuration.TableView.maximumRow ? Configuration.TableView.maximumRow : self.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chartTableViewCell", for: indexPath) as! ChartTableViewCell
            cell.bind(pointEntries)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as! ContentTableViewCell
            let content = self.contents[indexPath.row]
            cell.bind(content, indexPath: indexPath)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension UIViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Configuration.TableView.chartRowHeight
        }
        return Configuration.TableView.contentRowHeight
    }
}
