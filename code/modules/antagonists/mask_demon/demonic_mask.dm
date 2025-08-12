// The demonic mask item
/obj/item/clothing/mask/demonic_mask
	name = "demonic mask"
	desc = "A carved mask with menacing features."
	icon = 'icons/obj/clothing/item_masks.dmi'
	icon_state = "burnedcultmask"
	body_parts_covered = HEAD
	cant_self_remove = TRUE
	cant_other_remove = TRUE
	var/mob/living/critter/small_animal/possessing_critter = null

/datum/antagonist/mask_demon
	id = ROLE_DEMONMASK
	display_name = "demon mask"


	/// The ability holder of this arcfiend, containing their respective abilities. We also use this for tracking power, at the moment.
	var/datum/abilityHolder/mask_demon/ability_holder

	New()
		..()
		var/datum/targetable/mask_demon/possess_mask/possess = new()
		possess.holder = src
		// abilities += possess


	give_equipment()
		var/datum/abilityHolder/mask_demon/M = src.owner.current.get_ability_holder(/datum/abilityHolder/mask_demon)
		if (!M)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/mask_demon)
		else
			src.ability_holder = M
		src.ability_holder.addAbility(/datum/targetable/mask_demon/possess_mask)
		src.ability_holder.addAbility(/datum/targetable/mask_demon/elecflash)
		src.ability_holder.addAbility(/datum/targetable/mask_demon/demonic_push)




// Simple critter that can possess the mask
/mob/living/intangible/mask_demon
	name = "Poet of Flame"
	desc = "A small, dark creature with glowing red eyes."
	icon = 'icons/mob/mob.dmi'
	icon_state = "wraith"

	var/list/abilities = list()
	var/obj/item/clothing/mask/demonic_mask/possessed_mask = null
	var/datum/abilityHolder/mask_demon/ability_holder

	New()
		..()
		ability_holder = new /datum/abilityHolder/mask_demon(src)
		var/datum/targetable/mask_demon/possess_mask/possess = new()
		possess.holder = src  // This is crucial!
		abilities += possess
		//update_abilities() // Make sure UI updates


	Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(possessed_mask)
			return move_possessed_mask(NewLoc, Dir, step_x, step_y)
		else
			return ..()

		// Handle movement while possessing a mask
	proc/move_possessed_mask(NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(!possessed_mask)
			return 0

		var/turf/new_turf = NewLoc
		if(!isturf(new_turf))
			return 0

		// Check if mask is currently being worn
		if(ismob(possessed_mask.loc))
			var/mob/living/carbon/human/wearer = possessed_mask.loc

			// Force the mask to detach from the wearer
			if(wearer.wear_mask == possessed_mask)
				wearer.wear_mask = null
				possessed_mask.set_loc(get_turf(wearer))

				// Visual and audio feedback
				boutput(wearer, "<span class='alert'>Your mask suddenly tears itself from your face!</span>")
				wearer.visible_message("<span class='alert'>[wearer]'s mask rips itself off their face!</span>")
				playsound(get_turf(wearer), 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)

				// Minor damage from violent removal
				wearer.TakeDamage("head", 5, 0)

		// Move the mask to the new location
		if(possessed_mask.Move(new_turf, Dir, step_x, step_y))
			// Update demon's location to match the mask
			set_loc(possessed_mask)
			return 1
		else
			return 0

	// Add this somewhere to test if masks exist
	verb/debug_find_masks()
		set name = "Find Mask"
		set category = "Abilities"
		for(var/obj/item/clothing/mask/demonic_mask/mask in world)
			boutput(usr, "Found mask: [mask] at [mask.loc]")

	verb/possess_nearby_mask()
		set name = "Possess Mask"
		set category = "Abilities"

		var/list/available_masks = list()

		// Look for masks in range, including worn ones
		for(var/obj/item/clothing/mask/demonic_mask/mask in range(1, src))
			if(!mask.possessing_critter)
				available_masks += mask

		// Also check for masks being worn by nearby people
		for(var/mob/living/carbon/human/human in range(1, src))
			if(human.wear_mask && istype(human.wear_mask, /obj/item/clothing/mask/demonic_mask))
				var/obj/item/clothing/mask/demonic_mask/worn_mask = human.wear_mask
				if(!worn_mask.possessing_critter)
					available_masks += worn_mask

		if(!available_masks.len)
			boutput(src, "<span class='alert'>No demonic masks nearby to possess!</span>")
			return

		var/obj/item/clothing/mask/demonic_mask/chosen_mask
		if(available_masks.len == 1)
			chosen_mask = available_masks[1]
		else
			chosen_mask = input("Which mask do you want to possess?", "Possess Mask") as null|anything in available_masks

		if(!chosen_mask)
			return

		// Possess the mask
		chosen_mask.possessing_critter = src
		src.loc = chosen_mask
		src.density = 0
		src.mouse_opacity = 0

		boutput(src, "<span class='notice'>You slip into the [chosen_mask.name], taking control of it!</span>")

		// If the mask is being worn, notify the wearer
		if(ishuman(chosen_mask.loc))
			var/mob/living/carbon/human/wearer = chosen_mask.loc
			if(wearer.wear_mask == chosen_mask)
				boutput(wearer, "<span class='alert'>You feel something slip into your mask!</span>")



		// // Add to action bar if client exists
		// if(client)
		// 	for(var/datum/action/ability in abilities)
		// 		ability.equip(src)




/datum/abilityHolder/mask_demon
	tabName = "Mask Demon"

	New(mob/owner)
		..()
		addAbility(/datum/targetable/mask_demon/possess_mask)




// 	setup_healths()
// 		add_hh_robot(src.health_brute, src.health_brute)


// // // The demonic mask item
// // /obj/item/clothing/mask/demonic_mask
// // 	name = "demonic mask"
// // 	desc = "A carved mask with menacing features."
// // 	icon = 'icons/obj/clothing/item_masks.dmi'
// // 	icon_state = "burnedcultmask"
// // 	body_parts_covered = HEAD
// // 	var/mob/living/critter/small_animal/possessing_critter = null

// // // Simple critter that can possess the mask
// // /mob/living/critter/small_animal/mask_demon
// // 	name = "shadow imp"
// // 	desc = "A small, dark creature with glowing red eyes."
// // 	icon = 'icons/misc/bee.dmi'
// // 	icon_state = "petbee"
// // 	ai_type = null
// // 	health_brute = 400
// // 	health_brute_vuln = 0.1
// // 	blood_id = "oil"





// // 	setup_healths()
// // 		add_hh_robot(src.health_brute, src.health_brute)



// // 	var/list/abilities = list()

// // 	New()
// // 		..()
// // 		// Add abilities properly to the abilities list and HUD
// // 		add_ability(/datum/targetable/mask_demon/possess_mask)
// // 		add_ability(/datum/targetable/mask_demon/elecflash)

// 	proc/add_ability(datum/targetable/ability_type)
// 		var/datum/targetable/ability = new ability_type(src)
// 		abilities += ability
// 		ability.holder = src
// 		if(client)
// 			client.screen += ability






// // Possess Mask ability
// /datum/targetable/mask_demon
// 	icon = 'icons/mob/spell_buttons.dmi'
// 	// icon_State = "border"
// 	cooldown = 0
// 	last_cast = 0
// 	targeted = 0
// 	target_anything = 0
// 	//screen_loc = "NORTH,WEST"  // Position on screen

// 	New(mob/owner)
// 		..()
// 		holder = owner

// /datum/targetable/mask_demon/possess_mask
// 	name = "Possess Mask"
// 	desc = "Slip into a nearby demonic mask to control it."
// 	icon_state = "border"
// 	cooldown = 50 // 5 second cooldown

// 	/datum/action/bar/icon/mask_demon/possess_mask
// 	name = "Possess Mask"
// 	desc = "Slip into a nearby demonic mask to control it."
// 	icon_state = "possession"
// 	cooldown = 50 // 5 second cooldown

// 	proc/cast(mob/user)
// 		if (..())
// 			return 1

// 		var/mob/living/critter/small_animal/mask_demon/demon = user
// 		if(!istype(demon))
// 			return 1

// 		var/list/available_masks = list()

// 		// Look for masks in range, including worn ones
// 		for(var/obj/item/clothing/mask/demonic_mask/mask in range(1, demon))
// 			if(!mask.possessing_critter)
// 				available_masks += mask

// 		// Also check for masks being worn by nearby people
// 		for(var/mob/living/carbon/human/human in range(1, demon))
// 			if(human.wear_mask && istype(human.wear_mask, /obj/item/clothing/mask/demonic_mask))
// 				var/obj/item/clothing/mask/demonic_mask/worn_mask = human.wear_mask
// 				if(!worn_mask.possessing_critter)
// 					available_masks += worn_mask

// 		if(!available_masks.len)
// 			boutput(demon, "<span class='alert'>No demonic masks nearby to possess!</span>")
// 			return 1

// 		var/obj/item/clothing/mask/demonic_mask/chosen_mask
// 		if(available_masks.len == 1)
// 			chosen_mask = available_masks[1]
// 		else
// 			chosen_mask = input("Which mask do you want to possess?", "Possess Mask") as null|anything in available_masks

// 		if(!chosen_mask)
// 			return 1

// 		// Possess the mask
// 		chosen_mask.possessing_critter = demon
// 		demon.loc = chosen_mask
// 		demon.density = 0
// 		demon.mouse_opacity = 0

// 		boutput(demon, "<span class='notice'>You slip into the [chosen_mask.name], taking control of it!</span>")

// 		// If the mask is being worn, notify the wearer
// 		if(ishuman(chosen_mask.loc))
// 			var/mob/living/carbon/human/wearer = chosen_mask.loc
// 			if(wearer.wear_mask == chosen_mask)
// 				boutput(wearer, "<span class='alert'>You feel something slip into your mask!</span>")

// 		return 0

// /datum/action/bar/private/poss
// 	duration = 0.75 SECONDS
// 	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ACT
// 	///how far to knock mobs away from ourselves
// 	var/target_dist = 7
// 	///how fast to throw affected mobs away
// 	var/throw_speed = 1
// 	/// particle reference, just used to toggle the effects on and off
// 	var/particles/P
// 	/// the distance our attack reaches from us at the center
// 	var/area_of_effect = 2
// 	/// power of our elecflash, this maxes out at 6
// 	var/elec_flash_power = 4

// /datum/targetable/arcfiend/elecflash
// 	name = "Flash"
// 	desc = "Charge up and release a burst of power around yourself, blasting nearby creatures back and disorienting them."
// 	icon_state = "flash"
// 	cooldown = 10 SECONDS
// 	pointCost = 25

// 	cast(atom/target)
// 		. = ..()
// 		playsound(holder.owner, 'sound/effects/power_charge.ogg', 100)
// 		actions.start(new/datum/action/bar/private/flash(), src.holder.owner)



// /datum/action/bar/private/flash
// 	duration = 0.75 SECONDS
// 	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ACT
// 	///how far to knock mobs away from ourselves
// 	var/target_dist = 7
// 	///how fast to throw affected mobs away
// 	var/throw_speed = 1
// 	/// particle reference, just used to toggle the effects on and off
// 	var/particles/P
// 	/// the distance our attack reaches from us at the center
// 	var/area_of_effect = 2
// 	/// power of our elecflash, this maxes out at 6
// 	var/elec_flash_power = 4

// 	onStart()
// 		. = ..()
// 		P = owner.GetParticles("arcfiend")
// 		if (!P) // only need to create this on the mob once
// 			owner.UpdateParticles(new/particles/arcfiend, "arcfiend")
// 			P = owner.GetParticles("arcfiend")
// 		P.spawning = initial(P.spawning)

// 	onEnd()
// 		. = ..()
// 		elecflash(owner, area_of_effect, elec_flash_power)
// 		for (var/mob/living/L in viewers(area_of_effect, owner))
// 			if (isobserver(L) || isintangible(L))
// 				continue
// 			var/turf/T = get_ranged_target_turf(L, get_dir(owner, L), target_dist)
// 			if (T)
// 				var/falloff = GET_DIST(owner, L)
// 				L.throw_at(T, target_dist - falloff, throw_speed)

// 	onDelete()
// 		P.spawning = 0
// 		. = ..()





// // Simple critter that can possess the mask






// // 	setup_healths()
// // 		add_hh_robot(src.health_brute, src.health_brute)



// //Simple critter that can possess the mask






// // // The demonic mask item
// // // /obj/item/clothing/mask/demonic_mask
// // // 	name = "demonic mask"
// // // 	desc = "A carved mask with menacing features."
// // // 	icon = 'icons/obj/clothing/item_masks.dmi'
// // // 	icon_state = "burnedcultmask"
// // // 	body_parts_covered = HEAD
// // // 	var/mob/living/critter/small_animal/possessing_critter = null

// // // 	verb/possess_mask()
// // // 		set name = "Possess Mask"
// // // 		set category = "Object"
// // // 		set src in range(1)  // Changed from view to range so it works when worn

// // // 		var/mob/living/critter/small_animal/critter = usr
// // // 		if(!istype(critter))
// // // 			return

// // // 		if(possessing_critter)
// // // 			boutput(critter, "<span class='alert'>This mask is already possessed!</span>")
// // // 			return

// // // 		// Transfer the critter into the mask
// // // 		possessing_critter = critter
// // // 		critter.loc = src
// // // 		critter.density = 0
// // // 		critter.mouse_opacity = 0

// // // 		boutput(critter, "<span class='notice'>You slip into the mask, taking control of it!</span>")

// // // // Simple critter that can possess the mask
// // // /mob/living/critter/small_animal/mask_demon
// // // 	name = "shadow imp"
// // // 	desc = "A small, dark creature with glowing red eyes."
// // // 	icon = 'icons/misc/bee.dmi'
// // // 	icon_state = "petbee"
// // // 	density = 1
// // // 	ai_type = null
// // // 	health_brute = 400
// // // 	health_brute_vuln = 0.1
// // // 	blood_id = "oil"





// // // 	setup_healths()
// // // 		add_hh_robot(src.health_brute, src.health_brute)

// // //----------------------------------------------------------------------------------------

// // // The demonic mask item
// // /obj/item/clothing/mask/demonic_mask
// // 	name = "demonic mask"
// // 	desc = "A carved mask with menacing features."
// // 	desc = "A carved mask with menacing features."
// // 	icon = 'icons/obj/clothing/item_masks.dmi'
// // 	body_parts_covered = HEAD
// // 	var/mob/living/critter/small_animal/possessing_critter = null

// // 	verb/possess_mask()
// // 		set name = "Possess Mask"
// // 		set category = "Object"
// // 		set src in range(1)  // Changed from view to range so it works when worn

// // 		var/mob/living/critter/small_animal/critter = usr
// // 		if(!istype(critter))
// // 			return

// // 		if(possessing_critter)
// // 			boutput(critter, "<span class='alert'>This mask is already possessed!</span>")
// // 			return

// // 		// Transfer the critter into the mask
// // 		possessing_critter = critter
// // 		critter.loc = src
// // 		critter.density = 0
// // 		critter.mouse_opacity = 0

// // 		boutput(critter, "<span class='notice'>You slip into the mask, taking control of it!</span>")

// // 		// If the mask is being worn, notify the wearer
// // 		if(ishuman(loc))
// // 			var/mob/living/carbon/human/wearer = loc
// // 			if(wearer.wear_mask == src)
// // 				boutput(wearer, "<span class='alert'>You feel something slip into your mask!</span>")

// // // Simple critter that can possess the mask
// // /mob/living/critter/small_animal/mask_demon
// // 	name = "shadow imp"
// // 	desc = "A small, dark creature with glowing red eyes."
// // 	icon = 'icons/misc/bee.dmi'
// // 	icon_state = "petbee"
// // 	density = 1
// // 	ai_type = null
// // 	health_brute = 400
// // 	health_brute_vuln = 0.1
// // 	blood_id = "oil"





// // 	setup_healths()
// // 		add_hh_robot(src.health_brute, src.health_brute)
