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
	// Track the possessing demon
	var/mob/living/intangible/mask_demon/possessing_demon = null

	Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
		// Only allow movement if possessed by a demon and not being worn
		if(possessing_demon && !ismob(loc))
			var/turf/new_turf = NewLoc
			if(isturf(new_turf))
				var/moved = ..(new_turf, Dir, step_x, step_y)
				if(moved)
					possessing_demon.set_loc(src)
					return 1
			return 0
		return ..(NewLoc, Dir, step_x, step_y)

	Entered(atom/movable/O)
		..()
		if(istype(O, /mob/living/intangible/mask_demon))
			possessing_demon = O

	Exited(atom/movable/O)
		..()
		if(O == possessing_demon)
			possessing_demon = null

	// Relay movement from demon to mask
	proc/relay_movement(dir)
		if(possessing_demon && !ismob(loc))
			var/turf/new_turf = get_step(loc, dir)
			if(isturf(new_turf))
				if(Move(new_turf, dir))
					possessing_demon.set_loc(src)
					return 1
		return 0

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
	desc = "A demonic dark creature with glowing red eyes."
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

/mob/living/intangible/mask_demon
	Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(istype(loc, /obj/item/clothing/mask/demonic_mask))
			var/obj/item/clothing/mask/demonic_mask/mask = loc
			// Only move if mask is not worn
			if(!ismob(mask.loc))
				var/moved = ..(NewLoc, Dir, step_x, step_y)
				if(moved)
					mask.set_loc(src.loc) // Move mask to demon's new location
					return 1
				return 0
		return ..(NewLoc, Dir, step_x, step_y)


	proc/detach_mask_from_wearer(obj/item/I) //remove from the attached items list and deregister signals
		src.attached_objs.Remove(I)


	resist()
		if(possessed_mask && ismob(possessed_mask.loc))
			var/mob/living/carbon/human/wearer = possessed_mask.loc
			if(wearer.wear_mask == possessed_mask)
				detach_mask_from_wearer(wearer)
				possessed_mask.set_loc(get_turf(wearer))
				boutput(src, "<span class='notice'>You successfully break free!</span>")
				boutput(wearer, "<span class='alert'>Your mask suddenly tears itself from your face!</span>")
				playsound(get_turf(wearer), 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				wearer.TakeDamage("head", 5, 0)
				wearer.wear_mask = null
				wearer.update_clothing() // Update the visual
				wearer.update_face() // Update the inventory slot specifically
				src.set_loc(get_turf(wearer)) // Move demon to the turf where the mask was removed
				qdel(possessed_mask) // Clean up the mask object because otherwise this eldritch code won't work
				var/turf/T = get_turf(src)
				var/obj/item/clothing/mask/demonic_mask/new_mask = new /obj/item/clothing/mask/demonic_mask(T)
				src.set_loc(new_mask)
				possessed_mask = new_mask // Update the possessed mask reference







	verb/detach_mask()
		set name = "Detach Mask"
		set category = "Abilities"

		if(!possessed_mask)
			boutput(src, "<span class='alert'>You are not possessing any mask!</span>")
			return

		var/mob/living/carbon/human/wearer = possessed_mask.loc
		if(!wearer)
			boutput(src, "<span class='alert'>The mask is not currently worn by anyone!</span>")
			return


		detach_mask_from_wearer(wearer)
		possessed_mask.set_loc(get_turf(wearer))

		boutput(src, "<span class='notice'>You detach the mask from [wearer.name]!</span>")
		boutput(wearer, "<span class='notice'>Your mask is detached from your face!</span>")

		src.set_loc(get_turf(wearer)) // Move demon to the turf where the mask was removed


/datum/abilityHolder/mask_demon
	tabName = "Mask Demon"

	New(mob/owner)
		..()
		addAbility(/datum/targetable/mask_demon/possess_mask)





