# aleos-af-client
Client solution for [Sierra Wireless](http://source.sierrawireless.com/) routers supporting [Aleos AF](http://source.sierrawireless.com/resources/airlink/aleos_af/aleos_af_home/) to communicate with [aleos-af-server](https://github.com/razakj/aleos-af-server)

## Overview
Application developed for Aleos AF enabled devices from Sierra Wireless to be used in conjunction with [aleos-af-server](https://github.com/razakj/aleos-af-server).

Typical example would be router-to-router(s) communication via cellular network.

## Architecture
Aleos-af-client is designed to communicate with multiple aleos-af-servers at the time and send request in periodic intervals configurable for each contract.

Request can differ for each contract however dynamic request handling (see below) can't be customized for each contract at the moment and is applied globaly.

In general the functionality is a bit limited at the moment as custom actions, formating and handling can't be scoped down to individual contracts.

Aleos-af-client consist of following modules
* Main module taking care of all the requests handling
* Custom module where individual requests are configured and customized per application
* Modbus communication library which can be used to communicate to a modbus device
* [JSON parser by Jeffrey Friedl](http://regex.info/blog/lua/json)

## API
For API reference please see [aleos-af-server](https://github.com/razakj/aleos-af-server#api) specification. Important thing to realize is that request object is defined as Lua object - not JSON. This is taken care of automatically before sending the request over.

## Custom module
All the application specific and custom logic shall be specific within custom module.

## custom.INTERVAL
Interval between requests in seconds.

## custom.TIMEOUT
Request timeout interval.

## custom.IO_CONTRACT
Contract is a connection definition to aleos-af-server. One application can handle several contracts at the same time defined in *custom module* via *custom.IO_CONTRACT*. Each contract consist of following
* name(*string*): Can be IP address or DNS name of target aleos-af-server
* request(*object*): Request object expected by the server. Please see example custom module and/or [aleos-af-server API](https://github.com/razakj/aleos-af-server#api) specification.
* port: Port the server is listening on.

## custom.handleResponse(contract, res, err)
* contract(*object*): Contract objet reference
* res(*string*): Result received from the server
* err(*string*): Error

## custom.handleRequest(contract, req)
This function is automatically called each time before the request is sent to the server so it can be dynamically adjusted if required. (ie. life values from a modbus device)
* contract(*object*): Contract objet reference
* req(*object*): Request object to be adjusted

## Credentials
* [Lua JSON parse](http://regex.info/blog/lua/json)
* [Aleos AF](http://source.sierrawireless.com/resources/airlink/aleos_af/aleos_af_home/)
