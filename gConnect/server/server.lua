Citizen.CreateThread(function()
    while true do
	if Config.MessageId ~= nil and Config.MessageId ~= '' then
		UpdateStatusMessage()
	else
		DeployStatusMessage()
		break
	end

	Citizen.Wait(60000*Config.UpdateTime)
    end
end)

function DeployStatusMessage()
	local footer = nil

	if Config.Use24hClock then
		footer = os.date('Data: %d/%m/%Y  |  Hora: %H:%M')
	else
		footer = os.date('Data: %d/%m/%Y  |  Hora: %I:%M %p')
	end

	if Config.Debug then
		print('Deplying Status Message ['..footer..']')
	end

	local embed = {
		{
			["color"] = Config.EmbedColor,
			["title"] = "**Implantando mensagem de status**",
			["description"] = 'Copie o ID desta mensagem e coloque-o em Config e reinicie o script!',
			["footer"] = {
				["text"] = footer,
			},
		}
	}

	PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({
		embeds = embed, 
	}), { ['Content-Type'] = 'application/json' })
end

function UpdateStatusMessage()
	local players = #GetPlayers()
	local maxplayers = GetConvarInt('sv_maxclients', 0)
	local footer = nil
	local minutos = Config.UpdateTime
	local connect = Config.Connect

	if Config.Use24hClock then
		footer = os.date(' %d/%m/%Y | Hora: %H:%M | Atualização a cada ' ..minutos.. ' minutos')
	else
		footer = os.date(' %d/%m/%Y | Hora: %I:%M %p | Atualização a cada ' ..minutos.. ' minutos')
	end

	if Config.Debug then
		print('Atualizando mensagem de status ['..footer..']')
	end

	local message = json.encode({
		embeds = {
			{
			["title"] = '**'..Config.ServerName..'**\n',
			["color"] = Config.EmbedColor,
			["thumbnail"] = {
				["url"] = Config.WebhookIcon,
			},
			["footer"] = {
				["text"] = footer ,
			},
				["fields"]= {
					{
				      ["name"]= "> 🕹️  Players",
				      ["value"]= '```\n ['..players..' / '..maxplayers..'] ```',
				      ["inline"]= true
				    },
				    {
				      ["name"]= "> 📡  Status",
				      ["value"]= '```\n [ONLINE]```',
				      ["inline"]= true
				    },
				    {
				      ["name"]= "> Connect FiveM",
				      ["value"]= '```connect '..connect..'```'
				    },
				},
			}
		}
	})

	PerformHttpRequest(Config.Webhook..'/messages/'..Config.MessageId, function(err, text, headers) 
		if Config.Debug then
			print('[DEBUG] err=', err)
			print('[DEBUG] text=', text)
		end
	end, 'PATCH', message, { ['Content-Type'] = 'application/json' })
end