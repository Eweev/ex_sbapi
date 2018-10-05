# Changelog
All notable changes to this project will be documented in this file.

## [0.1.23] - 2018-10-04
- Add GET Customer Profile Mobile Number Site Configuration
- Add POST Customer Profile Mobile Number Site Configuration

## [0.1.22] - 2018-09-17
- Extend timeout of put and post requests for slow requests

## [0.1.21] - 2018-09-14
- Clarify errors returned for easier debugging

## [0.1.20] - 2018-08-30
- Add Custom Shipping method management
- Add Email Alteration webhook management
- Now compatible with Elixir 1.7

## [0.1.19] - 2018-08-06
- Add POST to set app settings

## [0.1.18] - 2018-07-29
- Change Timeout for get request for 10 seconds

## [0.1.17] - 2018-07-28
- Add POST Customer Profile
- Add PUT order to add customer profile

## [0.1.16] - 2018-07-06
- Add support for the new buy link functionality

## [0.1.15] - 2018-06-26
- Rely on the state parameter to get the websiteURL for the oAuth2 Token generation

## [0.1.14] - 2018-05-25
- Add support for the user account email verification endpoint

## [0.1.13] - 2018-04-09
- Add redirection to product when user adds to cart

## [0.1.12] - 2018-03-30
### Added
- Add a new endpoint to support user-edit
- Support order-query to get all orders that are issued on a specific date
- Add option on get_address to get the active addresses by using "uuid && active"

## [0.1.11] - 2018-03-14
### Added 
- Generate login link

## [0.1.10] - 2018-03-06
### Added 
- Set product_redirections 

## [0.1.9] - 2018-03-02
### Bugfix when setting Process as verified

## [0.1.8] - 2018-02-26
### BugFix for PUT and GET requests
### Updated order request from uid to uuid

## [0.1.7] - 2018-02-16
### Progress 
- GET Customer Profile
- GET country list
- Centralized error handling

## [0.1.6] - 2018-02-15
### Enhancement on error handling

## [0.1.5] - 2018-02-15
### Manage Request protection with grace period

## [0.1.4] - 2018-02-10
### Fix Bugs
- Update Elixir to 1.6

## [0.1.3] - 2018-02-01
### Added
- Check if there is any restrection mode set on your Shopbuilder Website
- Set your own restriction mode

## [0.1.2] - 2018-01-29
### Added
- Get hashed payload

## [0.1.1] - 2018-01-25
### Added
- Get list of available events to subscribe
- Subscribe to any events
- Subscribe to all events
- Unsubscribe from a specific event
- Get user roles that are available on Shopbuilder

## [0.1.0] - 2018-01-16
### Added
- Get access token from Shopbuilder
- Authorization of access token
- Handeling API requests "GET", "POST", "PUT" and "Delete"
- Get Address from Shopbuilder
- Get a specific Order from Shopbuilder
- Get Payment Options that are valid on Shopbuilder
- Get Shipping Options that are valid on Shopbuilder
- Add email to customer profile 
- Add shipping option to the order
- Add payment option to the order
- Add coupon to the order





