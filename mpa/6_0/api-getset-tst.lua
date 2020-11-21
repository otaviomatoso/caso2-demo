local oil = require "oil"

local idl = require "mpa.server.idl"

print(pcall(oil.main, function()
	print("Iniciando ORB...")
	local orb = oil.init{}
	print("Registrando IDL...")
	orb.TypeRepository.registry:register(unpack(idl))

	print("Instanciando Servidor...")
	local server = orb:newproxy("corbaloc::150.162.12.79:9090/", nil, "::MPA::Server::ServerManager")
	print("Obtendo Interface de Monitoração...")
	local monitor = server:_get_monitor()

	print("Realizando escrita...")
	ret, err = monitor:setPointValue("INTEGER_POINT_1", 3)

	print("Realizando leitura...")
	ret, err = monitor:getPointValue("INTEGER_POINT_1")
	print("Valor lido:", ret._anyval)

	print("Finalizando teste...")
	monitor = nil
	orb:shutdown()
end))
