local sched = require 'sched'
local socket = require 'socket'
local log = require('log')
local JSON = assert(loadfile "json.lua")()
local custom = require 'custom'

-- DO NOT CHANGE ANYTHING BELOW !!!

local LOGNAME = "IOCLIENT"
log.setlevel("DEBUG", "IOCLIENT")

local function run(contract)
	while true do
		local ip, err = socket.dns.toip(contract.name)
		if ip then
			log(LOGNAME, "DEBUG", "(%s) Dnsname resolved : %s", contract.name, ip)	
			local client = socket.tcp()
			client:settimeout(custom.TIMEOUT)
			client:connect(ip, contract.port)
			local recv,sent,age = client:getstats()
			if age <= custom.TIMEOUT then
				custom.handleRequest(contract, contract.request)
				local jsonRequest = JSON:encode(contract.request)
				log(LOGNAME, "DEBUG", "(%s) Request : %s", contract.name, jsonRequest)
				client:send(string.format("%s\r\n", jsonRequest))
				local data, err = client:receive()
				custom.handleResponse(contract, data, err)
				client:close()
			else
				log(LOGNAME, "ERROR", "(%s) Unable to connect to %s:%d, %fs", contract.name, ip, contract.port, age)	
			end
		else
			log(LOGNAME, "ERROR", "(%s) Dnsname resolving error : %s", contract.name, err)
		end
		sched.wait(custom.INTERVAL)
	end
end

local function main()
	for i=1,table.getn(custom.IO_CONTRACT) do
  		sched.run(run, custom.IO_CONTRACT[i])
  	end
  	sched.loop()
end

main()

