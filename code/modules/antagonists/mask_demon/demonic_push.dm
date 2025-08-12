/datum/targetable/mask_demon/demonic_push
	name = "Demonic Push"
	desc = "Push all nearby mobs away from you with supernatural force."
	icon_state = "grasp"
	cooldown = 100 SECONDS
	targeted = 0
	target_nodamage_check = 0

	cast(mob/user)
		. = ..()
		// Get the demon from the abilityHolder system
		var/mob/living/intangible/mask_demon/demon

		if(istype(holder, /datum/abilityHolder))
			var/datum/abilityHolder/ah = holder
			demon = ah.owner
		else if(ismob(holder))
			demon = holder
		else
			return 0

		if(!istype(demon, /mob/living/intangible/mask_demon))
			return 0

		// Determine the center point for the push
		var/turf/center_turf

		if(demon.possessed_mask)
			// If possessing a mask, use the mask's location as center
			var/obj/item/clothing/mask/demonic_mask/mask = demon.possessed_mask

			// If mask is being worn, use the wearer's location
			if(ismob(mask.loc))
				var/mob/wearer = mask.loc
				center_turf = get_turf(wearer)
				boutput(wearer, "<span class='alert'>Dark energy surges through your mask!</span>")
			else
				// Mask is on the ground
				center_turf = get_turf(mask)
		else
			// Demon is not possessing anything, use its own location
			center_turf = get_turf(demon)

		if(!center_turf)
			boutput(demon, "<span class='alert'>Unable to determine location for push!</span>")
			return 0

		// Find all mobs in range and push them
		var/list/pushed_mobs = list()
		var/push_range = 5

		for(var/mob/living/target in range(push_range, center_turf))
			// Don't push the demon itself or the mask wearer if demon is possessing
			if(target == demon)
				continue
			if(demon.possessed_mask && demon.possessed_mask.loc == target)
				continue // Don't push the person wearing the possessed mask

			// Calculate direction to push
			var/turf/target_turf = get_turf(target)
			if(!target_turf || target_turf == center_turf)
				continue

			var/push_dir = get_dir(center_turf, target_turf)
			if(!push_dir)
				// If directly on top, pick a random direction
				push_dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

			// Push the target
			var/push_distance = max(1, push_range - get_dist(center_turf, target_turf) + 2)
			push_target(target, push_dir, push_distance)
			pushed_mobs += target

			// Damage and feedback
			target.TakeDamage("All", 10, 0) // 10 brute damage
			boutput(target, "<span class='alert'>You are violently pushed away by an unseen force!</span>")
			target.emote("scream")

		// Visual and audio effects
		for(var/turf/T in range(push_range, center_turf))
			var/obj/effects/sparks/sparks = new /obj/effects/sparks(T)
			sparks.New(3, 1, T)
			sparks.dispose()


		playsound(center_turf, 'sound/effects/bamf.ogg', 75, 1) // Adjust sound as needed

		// Feedback to demon
		if(pushed_mobs.len)
			boutput(demon, "<span class='notice'>You push [pushed_mobs.len] creatures away with demonic force!</span>")
		else
			boutput(demon, "<span class='notice'>No creatures nearby to push.</span>")

		return 1

// Helper proc to push a target in a direction
/datum/targetable/mask_demon/demonic_push/proc/push_target(mob/living/target, direction, distance)
	if(!target || !direction || distance <= 0)
		return

	var/turf/start_turf = get_turf(target)
	var/turf/end_turf = start_turf

	// Calculate end position
	for(var/i = 1 to distance)
		var/turf/next_turf = get_step(end_turf, direction)
		if(!next_turf || next_turf.density)
			break
		// Check for dense objects that would block movement
		var/blocked = 0
		for(var/atom/A in next_turf)
			if(A.density && A != target)
				blocked = 1
				break
		if(blocked)
			break
		end_turf = next_turf

	// Animate the push
	if(end_turf != start_turf)
		target.set_loc(end_turf)
		animate(target, pixel_x = 0, pixel_y = 0, time = 3) // Reset any pixel offsets

		// Knock them down if they were pushed far
		if(get_dist(start_turf, end_turf) >= 3)
			target.changeStatus("weakened", 20) // 2 seconds stunned
