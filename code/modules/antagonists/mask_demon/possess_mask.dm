/datum/targetable/mask_demon/possess_mask
	name = "Possess Mask"
	desc = "Possess a nearby demonic mask to take control of it."
	icon_state = "possess"
	cooldown = 0
	targeted = 0
	target_nodamage_check = 0

	cast(mob/user)
		. = ..()
		var/mob/living/intangible/mask_demon/demon

		if(istype(holder, /datum/abilityHolder))
			var/datum/abilityHolder/ah = holder
			demon = ah.owner
		else if(ismob(holder))
			demon = holder
		else
			message_admins("DEBUG: Invalid holder type: [holder ? holder.type : "null"]")
			return 0

		if(!istype(demon, /mob/living/intangible/mask_demon))
			boutput(demon, "<span class='alert'>DEBUG: Owner is not a mask demon! Type: [demon ? demon.type : "null"]</span>")
			return 0

		boutput(demon, "<span class='notice'>DEBUG: Demon found, looking for masks...</span>")

		// Check if already possessing something
		if(demon.possessed_mask)
			boutput(demon, "<span class='alert'>You are already possessing a mask!</span>")
			return

		var/list/available_masks = list()

		// Look for masks in range, including worn ones
		for(var/obj/item/clothing/mask/demonic_mask/mask in range(7, demon)) // Reduced range for balance
			if(!mask.possessing_critter && !QDELETED(mask))
				available_masks += mask

		// Also check for masks being worn by nearby people
		for(var/mob/living/carbon/human/human in range(7, demon))
			if(human.wear_mask && istype(human.wear_mask, /obj/item/clothing/mask/demonic_mask))
				var/obj/item/clothing/mask/demonic_mask/worn_mask = human.wear_mask
				if(!worn_mask.possessing_critter && !QDELETED(worn_mask))
					available_masks += worn_mask

		if(!available_masks.len)
			boutput(demon, "<span class='alert'>No demonic masks nearby to possess!</span>")
			return

		var/obj/item/clothing/mask/demonic_mask/chosen_mask
		if(available_masks.len == 1)
			chosen_mask = available_masks[1]
		else
			chosen_mask = input(demon, "Which mask do you want to possess?", "Possess Mask") as null|anything in available_masks

		if(!chosen_mask || QDELETED(chosen_mask))
			return

		// Check if mask is still available (might have been possessed by another demon)
		if(chosen_mask.possessing_critter)
			boutput(demon, "<span class='alert'>That mask is already possessed!</span>")
			return

		// Possess the mask
		chosen_mask.possessing_critter = demon
		demon.possessed_mask = chosen_mask
		demon.set_loc(chosen_mask)
		demon.density = 0
		demon.mouse_opacity = 0
		demon.invisibility = INVIS_ALWAYS // Make completely invisible while possessing

		// If mask is being worn, notify the wearer
		if(chosen_mask.loc && ismob(chosen_mask.loc))
			var/mob/wearer = chosen_mask.loc
			boutput(wearer, "<span class='alert'>Your mask suddenly feels... different.</span>")

		boutput(demon, "<span class='notice'>You slip into the [chosen_mask.name], taking control of it!</span>")

		// Add any special effects or sounds here
