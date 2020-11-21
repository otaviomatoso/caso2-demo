#!/usr/bin/env lua

-- curl -v -H "Content-Type: application/json" -X POST -d '{ "tag": "INTEGER_POINT_1", "value": "10" }' http://localhost:8080/mpa/tags
-- curl -v localhost:8080/mpa/tags/INTEGER_POINT_1
-- curl -v -H "Content-Type: application/json" -X POST -d '{ "diagram": "API-CTRL [Iniciar]", "operation": "start" }' http://localhost:8080/mpa/diagrams/
-- curl -v -H "Content-Type: application/json" -X POST -d '{ "diagram": "API-CTRL [Parar]", "operation": "stop" }' http://localhost:8080/mpa/diagrams/
-- curl -v localhost:8080/mpa/diagrams/API-CTRL%20[Iniciar]

--local oil = require "oil"

local restserver = require("restserver")
local server_rest = restserver:new():port(8081)

local tag_list = {}
local value = 0



-- local idl_addr = "C:/Users/AgBr/Desktop/sandbox-mpa/mpa/mpa-server.idl"
local idl_addr = "./mpa-server.idl"

-- local idl_addr = "C:/Users/AgBr/Desktop/demo/mpa-server.idl"
local corba_addr = "corbaloc::localhost:9090/"
-- local corba_addr = "corbaloc::150.162.12.79:9090/"
local corba_interface = "::MPA::Server::ServerManager"

function format_diagram_name(inputstr)
	res = string.gsub(inputstr, "%%20", " ")
	res = string.gsub(res, "%%91", "[")
	res = string.gsub(res, "%%93", "]")
	res = string.gsub(res, "%%22", "")
	res = string.gsub(res, "%%C3%%83%%C2%%A7", "ç")
	res = string.gsub(res, "%%C3%%83%%C2%%A3", "ã")
	return res
end


function mpa_set(tag, value)
	local oil = require "oil"

	print(pcall(oil.main, function()
		print("Iniciando ORB...")
		 orb = oil.init{}
		print("Registrando IDL...")
		--orb.TypeRepository.registry:register(unpack(idl))
		orb:loadidlfile(idl_addr)

		print("Instanciando Servidor...")
		 server = orb:newproxy(corba_addr, nil, corba_interface)
		print("Obtendo Interface de Monitoracao...")
		 monitor = server:_get_monitor()

		print("Realizando escrita.\n" .. tag .. " = " .. value)
		ret, err = monitor:setPointValue(tag, value)

	end))
end

function mpa_get(tag)
	local oil = require "oil"

	print(pcall(oil.main, function()
		print("Iniciando ORB...")
		orb = oil.init{}
		print("Registrando IDL...")
		--orb.TypeRepository.registry:register(unpack(idl))
		orb:loadidlfile(idl_addr)

		print("Instanciando Servidor...")
		server = orb:newproxy(corba_addr, nil, corba_interface)
		print("Obtendo Interface de Monitoracao...")
		monitor = server:_get_monitor()

		print("Realizando leitura...")
		ret, err = monitor:getPointValue(tag)
		print("Valor lido: ", tonumber(ret._anyval))
	end))
	return tonumber(ret._anyval)
end

function mpa_diagram_operation(diagrama, operation)
	local oil = require "oil"

	print(pcall(oil.main, function()
		print("Iniciando ORB...")
		orb = oil.init()
		print("Registrando IDL...")
		orb:loadidlfile(idl_addr)

		server = orb:newproxy(corba_addr, "synchronous", corba_interface)
		diagrams = server:_get_diagrams()
		diagram_list = diagrams:describeDiagrams()

		-- Altera status de diagramas aplicação

		for i, description in ipairs(diagram_list) do
			if description.isApplication then
				control = orb:narrow(description.diagram, "MPA::Diagrams::DiagramApplication")
				if description.id == diagrama then
						if operation == "start" then
							print("Iniciou diagrama " .. diagrama)
							control:start()
						elseif operation == "stop" then
							print("Parou diagrama " .. diagrama)
							control:stop()
						end
				end
			end
		end
	end))
end

function mpa_diagram_status(diagrama)
	local oil = require "oil"
	local result

	print(pcall(oil.main, function()
		print("Iniciando ORB...")
		orb = oil.init()
		print("Registrando IDL...")
		orb:loadidlfile(idl_addr)

		server = orb:newproxy(corba_addr, "synchronous", corba_interface)
		diagrams = server:_get_diagrams()
		diagram_list = diagrams:describeDiagrams()

		for i, description in ipairs(diagram_list) do
			if description.isApplication then
				control = orb:narrow(description.diagram, "MPA::Diagrams::DiagramApplication")
				if description.id == diagrama then
					print(description.status)
					result = description.status
				end
			end
		end
	end))
	return result
end

function mpa_all_diagram_status()
	local oil = require "oil"
	local diagram_status_list = {}

	print(pcall(oil.main, function()
		print("Iniciando ORB...")
		orb = oil.init()
		print("Registrando IDL...")
		orb:loadidlfile(idl_addr)

		server = orb:newproxy(corba_addr, "synchronous", corba_interface)
		diagrams = server:_get_diagrams()
		diagram_list = diagrams:describeDiagrams()
		for key, tuple in ipairs(diagram_list) do
			--print(tuple.name)
			table.insert(diagram_status_list, {tuple.name, tuple.status, tuple.threads})
        end
	end))
	return diagram_status_list
end


server_rest:add_resource("mpa", {

   { -- GET tag_list
      method = "GET",
      path = "/tags",
      produces = "application/json",
      handler = function()
         return restserver.response():status(200):entity(tag_list)
      end,
   },

   { -- set tag with value
      method = "POST",
      path = "/tags",
      consumes = "application/json",
      produces = "application/json",
      input_schema = {
         tag = { type = "string" },
		 value = { type = "string" },
      },
      handler = function(tuple_submission)
         print("Received tag: " .. tuple_submission.tag)
         print("Received value: " .. tuple_submission.value)

		 mpa_set(tuple_submission.tag, tuple_submission.value) -- register a new value for this tag on MPA

		 -- search in tag_list if the tag is already registered
		 local existent = 0
         for key, tuple in ipairs(tag_list) do
			if tuple_submission.tag == tag_list[key].tag then
               print("Tag already registered: replacing its value.\n\n")
			   existent = 1
			   tag_list[key].value = tuple_submission.value
            end
         end

		 if existent == 0 then
			print("Tag not registered yet: including in tag_list.\n\n")
			table.insert(tag_list, tuple_submission)
		 end


         local result = {
            tag = tuple_submission.tag,
			value = tuple_submission.value
         }
         return restserver.response():status(200):entity(result)
      end,
   },

   { -- get specific tag
      method = "GET",
      path = "/tags/{tag}",
      produces = "application/json",
      handler = function(_, tag)
		 tag = format_diagram_name(tag) 	--remove quotes from path
		 print(tag)
		 local result = mpa_get(tag)
		 --[[
         for _, name in ipairs(tag_list) do
            if name.tag == tag then
               --return restserver.response():status(200):entity(tonumber(name.value))
			   return restserver.response():status(200):entity(tonumber(result))
            end
         end]]
		 if result == nil then
			--print("*******************: " .. result)
			return restserver.response():status(404):entity("Tag not found.")
		 else
			return restserver.response():status(200):entity(tonumber(result))
		 end
      end,
   },

   { -- makes an operation on mpa diagram
      method = "POST",
      path = "/diagrams",
      consumes = "application/json",
      produces = "application/json",
      input_schema = {
         diagram = { type = "string" },
		 operation = { type = "string" },
      },
      handler = function(tuple_submission)
         print("Received diagram name: " .. tuple_submission.diagram)
         print("Received operation: " .. tuple_submission.operation)

		 mpa_diagram_operation(tuple_submission.diagram, tuple_submission.operation) -- faz a operacao no diagrama
		 return restserver.response():status(200):entity(true) -- retorna true
	  end,
   },


   { -- get all diagram status
      method = "GET",
      path = "/diagrams",
      produces = "application/json",
      handler = function()
		return restserver.response():status(200):entity(mpa_all_diagram_status())
	  end,
   },


   { -- get specific diagram status
      method = "GET",
      path = "/diagrams/{diagram}",
      produces = "application/json",
      handler = function(_, diagram)
		 diagram = format_diagram_name(diagram)
		 print("Received diagram name: " .. diagram)
		 local result = mpa_diagram_status(diagram)
		 if result == nil then
			--print("*******************: " .. result)
			return restserver.response():status(404):entity("Diagram not found.")
		 else
			return restserver.response():status(200):entity(result)
		 end
      end,
   },

})

-- This loads the restserver.xavante plugin
server_rest:enable("restserver.xavante"):start()
