# iNav UW
### About
iNav UW is an indoor navigation system, similar to applications like Google Maps but for buildings rather than roads. Currently, as the app is in its very early stages of development, only one floor of a building is mapped. This region is the second floor of  [1410 Engineering Dr, Madison, WI, 53706](https://www.google.com/maps/place/1410+Engineering+Dr,+Madison,+WI+53706/data=!4m2!3m1!1s0x8807acc6682f240d:0x99fc566a0bbbd155?ved=2ahUKEwj59Nj0o_3eAhVB6oMKHYdQCiEQ8gEwAHoECAAQAQ).

### How to Build
System requirements:
* Mac OSX with High Sierra or later
* A working [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) installation (follow the link for install instructions)
* XCode version 9.4.1 or later

Build Instructions:
* Download the [Testing](https://github.com/nicholasspiroff/iNav-UW/tree/Testing) branch of this repository
* Navigate to the downloaded folder in Terminal and install dependencies:
```sh
$ cd ~/Downloads/iNav-UW-Testing
$ pod install
```
* Open the "iNav UW.xcworkspace" file to build the app on either the XCode Simulator or your physcial device
* NOTE: For the app's wayfinding and positioning features to work, you must install to a physical device and run in the mapped region, the second floor of [1410 Engineering Dr, Madison, WI, 53706](https://www.google.com/maps/place/1410+Engineering+Dr,+Madison,+WI+53706/data=!4m2!3m1!1s0x8807acc6682f240d:0x99fc566a0bbbd155?ved=2ahUKEwj59Nj0o_3eAhVB6oMKHYdQCiEQ8gEwAHoECAAQAQ). This is due to limitations in location spoofing and the fact that our SDK of choice is not open source.

### Credits
Developed by:
* Nick Spiroff
* Joe Schwartz
* Aiden Song
* Andrew Lindstrom
* Justin Leinbach
* Zhaoyin Qin
* Cory Burich
* Tej Lunani

### Contact Us
For further questions, please email one of our developers at spiroff@wisc.edu.