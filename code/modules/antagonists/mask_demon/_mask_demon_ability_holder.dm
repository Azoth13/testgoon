#define MAX_ARCFIEND_POINTS 2500

/// The ability holder used for arcfiends. Comes with no abilities on its own.
/datum/abilityHolder/mask_demon
	usesPoints = TRUE
	regenRate = 0
	tabName = "Demonic Mask"


ABSTRACT_TYPE(/datum/targetable/mask_demon)
/datum/targetable/mask_demon
	name = "base arcfiend ability (you should never see me)"
	icon = 'icons/mob/arcfiend.dmi'
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/mask_demon

	/// Whether or not this ability can be cast from inside of things (locker, voltron, etc.)
	var/container_safety_bypass = FALSE

	castcheck(atom/target)
		var/area/A = get_area(holder.owner)
		if (A.sanctuary)
			boutput(holder.owner, SPAN_ALERT("You cannot use your abilities in a sanctuary."))
			return FALSE
		var/mob/living/M = src.holder.owner
		if (!can_act(M) && target != holder.owner) // we can self cast while incapacitated
			boutput(holder.owner, SPAN_ALERT("Not while incapacitated."))
			return FALSE
		return TRUE

	cast(atom/target)
		. = ..()
		// updateButtons is already called automatically in the parent ability's tryCast
		src.holder.updateText()


