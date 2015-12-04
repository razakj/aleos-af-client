local log = require('log')
local modbus_lib = require 'modbus_lib'

-- TEMPLATE OF THIS FILE MUST REMAIN UNCHANGED HOWEVER IMPLEMENTATION OF INDIVIDUAL FUNCTIONS
-- SHALL BE CHANGED TO SUIT NEEDS OF INDIVIDUAL APPLICATIONS
local custom = {}

local LOGNAME = "IOCLIENT"
log.setlevel("DEBUG", "IOCLIENT")

custom.INTERVAL = 5 -- Interval between requests in seconds
custom.TIMEOUT = 7 -- Timeout for connection to IOCONTROL socket server

-- Request to be specified for each target device or can be even re-used depending on requirements.
custom.REQUEST = {
	authKey = "secret_key", -- Authentication key to establish communication with IOCONTROL server in target device
	get = { -- GX400 parameter GET request. List of available parameters can be found in devicetree.txt
		--"system.aleos.io.analog1.raw",
		--"system.aleos.io.relay1"
	},
	set = { -- GX400 parameter SET request. Not all the parameters are writable!
		--{name = "system.aleos.io.relay1", value = 0}
	},
	modbus = { -- List of target MODBUS devices.
		{
			address = "127.0.0.1", -- LOCAL IP address (from target device subnet) of modbus device
			port = 502, -- Modbus TCP port
			-- Types: holdingregister, inputregister, digitaloutput, digitalinput, long, float
			read = { -- List of READ requests for particular device. LONG and FLOAT ARE NOT SUPPORTED AT THE MOMENT !!!
				--{ type = "digitaloutput", address = 349, length = 1 },
				--{ type = "float", address = 9000, length = 64 }
			},
			write = { -- List of WRITE request for particular device.
				--{ type = "holdingregister", address = 1999, value = 1212 },
				--{ type = "digitaloutput", address = 720, value = 1 },
				--{ type = "digitaloutput", address = 721, value = 1 },
				--{ type = "digitaloutput", address = 722, value = 1 }
				--{ type = "long", address = 5000, value = 400000 }
			}
		}
	}
}

-- List of target devices to communicate with. Default IOCONTROL server port is 9889 and should not be changed.
-- Request defined above (unique for each device or shared) also must be defined!
custom.IO_CONTRACT = {
	{name = "192.168.8.1", request = custom.REQUEST, port = 8888}
}

-- Callback to handle received data
function custom.handleResponse(contract, res, err) 
	if not err then
		log(LOGNAME, "DEBUG", "(%s) Response : %s", contract.name, res)
	else
		log(LOGNAME, "ERROR", "(%s) Response : %s", contract.name, err)
	end
end

-- Callback to dynamically modify request if required (ie. Reading modbus registers for transfer)
--local commsCheck = false
function custom.handleRequest(contract, req)
	-- Init and read registers
	--modbus_lib.init("127.0.0.1", 502, 5, 5)
	--local aTest, err = modbus_lib.readHoldingRegister(51, 1)
	--local dTest, err = modbus_lib.readCoils(30)
	--commsCheck = not commsCheck
	if not err then
		if req.modbus[1] then
			local length = table.getn(req.modbus[1].write)
			for i=1, length do
				table.remove(req.modbus[1].write,i)
			end 
			req.modbus[1].write[1] = { type = "digitaloutput", address = 99, value = 1 }
			--local numberCheck
			--if commsCheck then
			--	numberCheck = 1
			--else
			--	numberCheck = 0
			--end
			--req.modbus[1].write[2] = { type = "digitaloutput", address = 99, value = numberCheck }
			--req.modbus[1].write[length+3] = { type = "digitaloutput", address = 31, value = dTest[2] }
			--req.modbus[1].write[length+4] = { type = "digitaloutput", address = 32, value = dTest[3] }
		end
	else
		log(LOGNAME, "ERROR", "(%s) Unable to read local modbus : %s", contract.name, err)			
	end
	--modbus_lib.close()
end

return custom