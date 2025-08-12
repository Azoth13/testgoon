/// Super simple CC. Short-ranged elecflash.
/datum/targetable/mask_demon/elecflash
	name = "Flash"
	desc = "Charge up and release a burst of power around yourself, blasting nearby creatures back and disorienting them."
	icon_state = "flash"
	cooldown = 10 SECONDS


	cast(atom/target)
		. = ..()
		elecflash(src, 1, 1)









