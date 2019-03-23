AxRide
======
> iOS App; Taking passengers to destination

## Overview
Simple Taxi App that user can request ride to nearby drivers
### Main Features
- Basic features  
Signup, Login, Profile, Setting, ...

#### 1. User POV
- Set location and destination on the map  
- Send request to nearby drivers  
- Draw routes on the map when ride has made
- Messaging with driver  

#### 2. Driver POV
- Accept or decline incoming ride request  
- Draw routes on the map when ride has made
- Messaging with user  
 
## Techniques 
Main language: Swift 4.0
  
### 1. UI Implementation  
- Implementing view controllers with individual xib interface  
- TableView cell and CollectionView cell should be implemented independent xib file  
  - Register nib for table view cell  
``UITableView.register()``  
- Showing map using [Google Maps](https://developers.google.com/maps/documentation/ios-sdk/intro)  
``GMSCoordinateBounds`` is used to show multiple points in one screen  
- Adding border to view programmatically  
```swift
func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
    // the height of view may change, so we use autoresizing
    let border = UIView(frame: CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width))
    border.backgroundColor = color
    border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    self.addSubview(border)
}
```

### 2. Function Implementation
- Getting location using ``CLLocationManager()``  
``locationManager.startUpdatingLocation()``  
- Google Firebase for backend  
  - [GeoFire](https://github.com/firebase/geofire-objc) for location saving & querying  
- Push notification using Firebase Clound Messaging(FCM)
  - [Sending push notification from App](https://firebase.google.com/docs/cloud-messaging/send-message) for message feature

#### 2.1 Data flow & use
##### - Request a ride  
- Add data record to *requests* table	
{userId} / orderData  
- Add marks to *accepts* table  
{driverId} / {userId} / "request"

##### - Driver accepted the request  
- Remove data from *requests* table  
- Remove marks from *accepts* table  
- Add data to *picked* table  
{userId} / orderData  
{driverId} / orderData

##### - Arrived destination
- Add data to *arrived* table  
{userId} / {driverId} / true

##### - Fee Paid
- Add data to *bookhistories* table  
{userId} / orderData  
{driverId} / orderData  
- Remove data from *arrived* table  
- Remove data from *picked* table

#### 2.2 Rest APIs  
##### Stripe Payment Setup
- /api/ephemeral_keys  
Gets Stripe ephemeral key  
- /api/createCustomStripe  
Creates Stripe cusomer Id for user  
- /connectStripe?email=mail address  
Web url getting Stripe accound Id for driver

##### Payment
- /api/order  
Sending payment from user to driver

##### Stripe APIs
- ~~[Get Card List]~~  
[https://stripe.com/docs/api/cards/list](https://stripe.com/docs/api/cards/list)  
  - Problems  
Result object is ``source`` when added in Android and ``card`` when added in iOS version  
- Get All Sources for card list  
[https://api.stripe.com/v1/customers/{customerId}/sources](https://api.stripe.com/v1/customers/{customerId}/sources)  
Card list in User Profile page
- Create a Card  
[https://stripe.com/docs/api/cards/create](https://stripe.com/docs/api/cards/create)  
Add card in User Profile page

#### 2.3 Stripe iOS Integration
- [``STPPaymentMethodsViewController``](https://stripe.com/docs/mobile/ios/custom#stppaymentmethodsviewcontroller)  
Cards and Bank Accounts page in Settings
- [``STPAddCardViewController``](https://stripe.com/docs/mobile/ios/custom#stpaddcardviewcontroller)  
Add card in User Profile page

#### 2.4 Db structure
```
|
+-- addresses
|  |
|  +-- {userId}
|     |
|     +-- {id}
|
+-- bookhistories
|  |
|  +-- {userId (driver)}
|  |  |
|  |  +-- {orderId}
|  |
|  +-- {userId (user)}
|     |
|     +-- {orderId}
|
+-- driverstatus
|  |
|  +-- {userId}
|
+-- messages
|  |
|  +-- {userId (sender)}
|  |  |
|  |  +-- {userId (receiver)}
|  |     |
|  |     +-- {id}
|  |
|  +-- {userId (receiver)}
|     |
|     +-- {userId (sender)}
|        |
|        +-- {id}
|
+-- picked
|  |
|  +-- {userId (driver)}
|  |
|  +-- {userId (user)}
|
+-- rates
|  |
|  +-- {userId}
|     |
|     +-- {id}
|
+-- users
   |
   +-- {id}
```

### 3. Code tricks  
#### Custom fonts with propotional font size to screen size  
```swift
label.font = ARTextHelper.exoBold(size: width / widthDesign * 30)
```  
#### Methods with completion callback using closures  
```swift  
func readFromDatabase(withId: String, completion: @escaping((Any?)->())) {
}
```  
#### Delegate in Swift  
``PopupDelegate`` in *UserWaitPopup.swift*  
```swift
protocol PopupDelegate: Any {
    func onClosePopup(_ sender: Any?)
}
``` 
#### Common module  
- ``PaymentMethodHelper`` & ``ARPaymentMethodDelegate``  
Common pages for Stripe Payment Setup  
- ``PhotoViewHelper`` & ``ARUpdateImageDelegate``  
Added ``tag`` for multiple photo controls in a page

### 4. Third-Party Libraries
- [IHKeyboardAvoiding](https://github.com/IdleHandsApps/IHKeyboardAvoiding) v4.2  
  - Sign in page  
- [GeoFire](https://github.com/firebase/geofire-objc) v1.1.3  
Searching drivers when request a ride  
- [EmptyDataSet-Swift](https://github.com/Xiaoye220/EmptyDataSet-Swift) v4.0.5  
TableView / CollectionView with empty notice  
- [KMPlaceholderTextView](https://github.com/MoZhouqi/KMPlaceholderTextView) v1.3.0  
TextView in report page  
- [Cosmos](https://github.com/evgenyneu/Cosmos) v16.0  
Rate star control  
  - Rate stars in driver profile page  
- FBSDKCoreKit v4.34.0  
Facebook Login  
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) v4.1.0  
Parse response JSON from Google API  
- [Toast-Swift](https://github.com/scalessec/Toast-Swift) v3.0.1  
Showing error info &states

#### Google Maps v2.7.0
- [GoogleMaps](https://developers.google.com/maps/documentation/ios-sdk/intro)  
- [GooglePlaces](https://developers.google.com/places/ios-sdk/intro)  
- [Place Autocomplete](https://developers.google.com/places/ios-sdk/autocomplete)  
Customer home page  
- [PlacePicker](https://developers.google.com/places/ios-sdk/placepicker)  
- [Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix)  
Get distance between two points to calculate fee 

#### [Google Firebase](https://github.com/firebase/firebase-ios-sdk) v5.0.1  
- Firebase Auth  
- Firebase Database  
- Firebase Storage  
- Firebase Messaging  

## Need to Improve
Add and update features