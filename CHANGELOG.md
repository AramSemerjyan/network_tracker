## 0.0.1

* Initial release

## 0.0.2

* Add screenshots in README.md
* Fix issue with share file

## 0.1.0

* Ability to search inside requests
* Add comments

## 0.2.0

* Ability to filter requests by method and status
* Code improvements
* Improves UI to use `ValueListenableBuilder` instead `setState({})`
* Add `copy` button next to baseUrl to make it more clear url can be copied
* Replace back button with `CloseButton`

## 0.3.0

* Ability to edit request before repeat
* UI improvements

## 0.3.1

* Badge to show that request is repeated from app
* New filter to filter out repeated/ not repeated requests

## 0.3.2

* Fix analyze issue

## 0.3.3

* Show headers in request details page
* Fix issue with scroll on request details page
* Fix value conversion errors on `NetworkEditRequestScreen`
* export `NetworkRepeatRequestService` to give ability to set custom `DIO` client

## 0.4.0

* Add persistent request storage using `sqflite`
* Support multiple base URLs and selection in UI
* Improve request grouping logic to respect base URL context
* Remove `NetworkRepeatRequestService` from exports (moved under `NetworkRequestService`)
* Allow setting custom Dio client via `NetworkRequestService.setDioClient(...)`

## 0.5.0

* Add Internet Speed Test tool
* Add Network Info Panel displaying:
  * Local IP address
  * External IP address
  * Country
  * Timezone
* Add cURL Export feature to generate cURL command for any captured request
* Display Connection Type (Wi-Fi / Mobile / None) in the UI
* Minor UI tweaks

## 0.5.1

* Upgrade share_plus to v11.0.0 to align with latest dependency versions
* Updated README
* Added ability to select test file (e.g. 30MB, 70MB, 100MB) when running internet speed tests for more control over download size