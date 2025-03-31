
/obj/machinery/mechworld_machine
	name = "Mechworld Machine"
	desc = "A machine to create contraptions in the cyberspace."
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "mechworld"
	density = 1
	var/turf/initial_turf = null
	var/network = LANDMARK_VR_MECH
	var/datum/allocated_region/region = null
	var/region_type = /datum/mapPrefab/allocated/mechworld
	// var/area/current_area = null
	var/area/exit_point = null

	New(mob/M)
		. = ..()
		var/datum/mapPrefab/allocated/prefab = get_singleton(src.region_type)
		src.region = prefab.load()
		logTheThing(LOG_DEBUG, usr, "<b>[src.name]</b>: Got bottom left corner [log_loc(src.region.bottom_left)]")
		for(var/turf/T as anything in landmarks[LANDMARK_VR_MECH])
			if(region.turf_in_region(T))
				initial_turf = T
				break


/obj/machinery/mechworld_machine/attack_hand(var/mob/user)

	src.add_fingerprint(user)
	user.network_device = src
	Station_VNet.Enter_Vspace(user, src,src.network)
	//user.set_loc(initial_turf)
	//var/area/current_area = get_area(user)
	// if(istype(current_area, /area/sim/mechworld_area))
	// 	user.set_loc(exit_point)
	// else
	// 	exit_point = user.loc
	// 	user.set_loc(initial_turf)

/obj/item/cursor
	name = "cursor"
	desc = "A cursor to interact with the cyberspace."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "cursor"
	var/icons = list("comps")
	var/selectedtype
	var/list/comps = list(
		"Payment Component" = /obj/item/mechanics/cashmoney,
		"Flush Component" = /obj/item/mechanics/flushcomp,
		"Thermal Printer" = /obj/item/mechanics/thprint,
		"Paper Scanner" = /obj/item/mechanics/pscan,
		"Trip Laser" = /obj/item/mechanics/triplaser,
		"Hand Scanner" = /obj/item/mechanics/hscan,
		"Graviton Accelerator" = /obj/item/mechanics/accelerator,
		"Tesla Coil" = /obj/item/mechanics/zapper,
		"Delay Component" = /obj/item/mechanics/pausecomp,
		"AND Gate" = /obj/item/mechanics/andcomp,
		"OR Gate" = /obj/item/mechanics/orcomp,
		"WiFi Splitter" = /obj/item/mechanics/wifisplit,
		"Regex Replace" = /obj/item/mechanics/regreplace,
		"Regex Find" = /obj/item/mechanics/regfind,
		"Signal Checker" = /obj/item/mechanics/sigcheckcomp,
		"Dispatcher" = /obj/item/mechanics/dispatchcomp,
   		"Signal Builder" = /obj/item/mechanics/sigbuilder,
		"Relay Component" = /obj/item/mechanics/relaycomp,
		"Buffer Component" = /obj/item/mechanics/buffercomp,
		"File Component" = /obj/item/mechanics/filecomp,
		"WiFi Component" = /obj/item/mechanics/wificomp,
		"Selection Component" = /obj/item/mechanics/selectcomp,
		"Toggle Component" = /obj/item/mechanics/togglecomp,
		"Teleporter Component" = /obj/item/mechanics/telecomp,
		"LED Component" = /obj/item/mechanics/ledcomp,
		"Microphone Component" = /obj/item/mechanics/miccomp,
		"Synthesizer Component" = /obj/item/mechanics/synthcomp,
		"Pressure Sensor" = /obj/item/mechanics/trigger/pressureSensor,
		"Button" = /obj/item/mechanics/trigger/button,
		"Button Panel" = /obj/item/mechanics/trigger/buttonPanel,
		"Gun Component" = /obj/item/mechanics/gunholder,
		"E-Gun Component" = /obj/item/mechanics/gunholder/recharging,
		"Instrument Player" = /obj/item/mechanics/instrumentPlayer,
		"Math Component" = /obj/item/mechanics/math,
		"Counter" = /obj/item/mechanics/counter,
		"Clock" = /obj/item/mechanics/clock,
		"Sign" = /obj/item/mechanics/message_sign
	)

	attack_self(mob/user as mob)
		var/newtype = tgui_input_list(message="What to deploy?", title="Components", items=comps)
		if(newtype)
			var/selected_path = comps[newtype] // Get the component path from the selected name
			selectedtype = selected_path
			boutput(user, SPAN_NOTICE("Now deploying '[newtype]' ([selectedtype])."))

	pixelaction(atom/target, params, mob/user)
		var/turf/T = target
		if (!istype(T))
			T = get_turf(T)
		if (selectedtype != null)
			new selectedtype(T)

// /obj/item/connection_tool
// 	name = "Connection Tool"
// 	desc = "A tool to connect, organize and anchor components."
// 	icon = 'icons/obj/items/device.dmi'
// 	icon_state = "multitool_green"
// 	tool_flags = TOOL_PULSING


// //Multitool Functionality
// /obj/item/device/multitool/afterattack(atom/target, mob/user , flag)
// 	. = ..()
// 	get_and_return_netid(target,user)

// /obj/item/marking_tool
// 	name = "Connection Tool"
// 	desc = "A tool to connect and anchor components."
// 	icon = 'icons/obj/items/device.dmi'
// 	icon_state = "markerlight1"
// 	var/static/list/c_symbol = list("Arrow North", "Arrow East", "Arrow South", "Arrow West")
// 	var/selected_arrow =
// 		var/list/colors = list(
// 	"Red" = "#FF0000",
// 	"Green" = "#00FF00",
// 	"Blue" = "#0000FF",
// 	"Yellow" = "#FFFF00",
// 	"White" = "#FFFFFF",
// 	"Black" = "#000000"
// 	)

// 	var/selected_color = "#FFFFFF" // Default color




