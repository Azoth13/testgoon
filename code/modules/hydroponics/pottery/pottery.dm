/datum/action/bar/private/quicktime
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/active_duration = 1 SECOND
	var/active_duration_start = null
	var/obj/actions/bar/active_duration_bar = null
	var/active = FALSE
	var/crafting_progress = 0
	var/target_progress = 100


/datum/action/bar/private/quicktime/New()
	src.active_duration_start = rand(1, src.duration - src.active_duration)
	. = ..()


	SPAWN(src.active_duration_start)
		if (QDELETED(src) || (src.state != ACTIONSTATE_RUNNING))
			return

		src.updateBar()

	SPAWN(src.active_duration_start + src.active_duration)
		if (QDELETED(src) || (src.state != ACTIONSTATE_RUNNING))
			return

		src.updateBar()

/datum/action/bar/private/quicktime/updateBar(animate = TRUE)
	. = ..()

	if (src.duration <= 0 || isnull(src.bar))
		return

	var/done = src.time_spent()
	if ((done < src.active_duration_start) || (done >= (src.active_duration_start + src.active_duration)))
		if (src.active_duration_bar && src.active)
			animate(src.active_duration_bar, flags = ANIMATION_END_NOW)
			src.active = FALSE

		return

	src.active = TRUE
	var/remain = max(0, (src.active_duration + src.active_duration_start) - done)
	var/complete = clamp((done - src.active_duration_start) / src.active_duration, 0, 1)

	var/scaled_active_duration = src.active_duration / src.duration
	var/scaled_position = (30 * src.active_duration_start / src.duration) - 15

	if (!src.active_duration_bar)
		src.active_duration_bar = new /obj/actions/bar
		src.active_duration_bar.color = src.color_success
		src.active_duration_bar.transform = matrix(scaled_active_duration * complete, 0, scaled_position + (15 * scaled_active_duration * complete), 0, 1, 0)

		src.bar.vis_contents += active_duration_bar

	if (animate)
		animate(src.active_duration_bar, transform = matrix(scaled_active_duration, 0, scaled_position + (15 * scaled_active_duration), 0, 1, 0), time = remain)
	else
		animate(src.active_duration_bar, flags = ANIMATION_END_NOW)

/datum/action/bar/private/quicktime/proc/trigger()
	if (QDELETED(src) || (src.state != ACTIONSTATE_RUNNING))
		return

	if (src.active)
		stop_crafting(current_user, "success")
		boutput(current_user, "<span class='success'>Perfect timing!</span>")
		src.onEnd()
	else
		src.interrupt(INTERRUPT_ALWAYS)
		stop_crafting(current_user, "failure")
		boutput(current_user, "<span class='alert'>You messed up the clay!</span>")

	show_progress()



/obj/item/device/radio/signaler/test_object/var/datum/action/bar/private/quicktime/action_bar = null
/obj/item/device/radio/signaler/test_object/send_signal()
	if (!src.action_bar)
		src.action_bar = actions.start(new /datum/action/bar/private/quicktime, usr)
		return

	src.action_bar.trigger()
	src.action_bar = null

//NOTE:
//So, originally there was a "stability" value that decreases over time and with mistakes, the idea is to reach the target progress, (say, hiting the correct timiming 3 times)
//upon success you would get the item, failing any of the three bars will result in a fail for now, should be easier to implement to test
//But I'm unsure on how to implement the trigger() proc provide a success when hit correctly, and cannot pass the user?
//Do note that my mental lucidity with complex things like code is currently not very high, so I had to make a heavy use of AI, and this may be a simple problem
//that I'm not figuring out.

/obj/machinery/pottery_wheel/
	var/datum/action/bar/private/quicktime/action_bar = null
	name = "pottery wheel"
	desc = "A spinning wheel for shaping clay. Use Help=bowls, Disarm=glasses, Grab=vases."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "ice_creamer1"
	anchored = 1
	density = 1

	var/mob/current_user = null
	var/pottery_type = null
	var/crafting_progress = 0
	// var/target_progress = 100
	// var/stability = 50
	// var/max_stability = 100
	var/crafting_active = FALSE
	var/crafting_timer_active = 0
	var/action_bar_active = FALSE
	// var/ab_sweet_from = 0   //old action bar timing vars
	// var/ab_sweet_to = 0

/obj/machinery/pottery_wheel/attack_hand(mob/user)
	if(current_user && current_user != user)
		boutput(user, "<span class='alert'>[current_user] is already using the pottery wheel.</span>")
		return

	if(!crafting_active)
		start_crafting(user)
	else if(action_bar_active)
		action_bar.trigger()
	else
		boutput(user, "<span class='notice'>Wait for the next timing phase...</span>")

/obj/machinery/pottery_wheel/proc/start_crafting(mob/user)
	switch(user.a_intent)
		if("help")  pottery_type = "bowl"
		if("disarm") pottery_type = "glass"
		if("grab")  pottery_type = "vase"
		else return

	current_user = user
	crafting_active = TRUE
	crafting_main_loop()


	user.visible_message("<span class='notice'>[user] starts working the pottery wheel.</span>")

	crafting_timer_active = 1


/obj/machinery/pottery_wheel/proc/crafting_main_loop()
	while(crafting_active && current_user && crafting_timer_active)
		sleep(10) // 1 sec
		if(prob(20)) stability--
		if(stability <= 0)
			stop_crafting(current_user, "failure")
			break

// /obj/machinery/pottery_wheel/proc/start_action_bar_challenge()
// 	if(!crafting_active || !current_user) return
// 	if(crafting_progress >= target_progress) return stop_crafting(current_user, "success")

// 	action_bar_active = TRUE

	// // var/duration = 30
	// var/window_open_ds = rand(8, 20)
	// var/window_len_ds  = rand(6, 10)

	// ab_sweet_from = world.time + window_open_ds
	// ab_sweet_to   = ab_sweet_from + window_len_ds

	// Change our custom indicator's color during sweet spot
	if (!src.action_bar)
		src.action_bar = actions.start(new /datum/action/bar/private/quicktime, usr)
		return


	var/now = world.time
	var/success = (action_bar.active_duration_start <= now && now <= (action_bar.active_duration_start + action_bar.active_duration))

	if(success)
		crafting_progress += rand(15, 25)
		stability = min(max_stability, stability + rand(2, 5))
		boutput(current_user, "<span class='success'>Perfect timing!</span>")
	else
		stop_crafting(current_user, "failure")
		boutput(current_user, "<span class='alert'>You messed up the clay!</span>")

	show_progress()

	if(stability <= 0) return stop_crafting(current_user, "failure")
	if(crafting_progress >= target_progress) return stop_crafting(current_user, "success")

	spawn(15) start_action_bar_challenge()

/obj/machinery/pottery_wheel/proc/action_bar_timeout()
	action_bar_active = FALSE
	if(current_user)
		crafting_progress += rand(2, 6)
		stability -= rand(5, 10)
		boutput(current_user, "<span class='alert'>You hesitated too long!</span>")
		show_progress()

	if(stability <= 0) return stop_crafting(current_user, "failure")
	if(crafting_active && current_user) spawn(15) start_action_bar_challenge()

/obj/machinery/pottery_wheel/proc/_actionbar_finished(mob/user, obj/machinery/pottery_wheel/W)
	if(!W || W != src) return
	if(!user || user.loc != src.loc)
		return stop_crafting(user, "failure")

	if(crafting_active)
		action_bar_timeout()

/datum/action/bar/private/quicktime/proc/show_progress()
	if(current_user)
		boutput(current_user, "<span class='notice'>Progress: [crafting_progress]/[target_progress], Stability: [stability]/[max_stability]</span>")

/datum/action/bar/private/quicktime/proc/stop_crafting(mob/user, result)
	// crafting_active = FALSE
	// crafting_timer_active = 0
	// action_bar_active = FALSE

	if(result == "success")
		user.visible_message("<span class='success'>[user] finishes a [pottery_type]!</span>")
		new /obj/item/pottery/[pottery_type](src.loc)
	else
		user.visible_message("<span class='alert'>[user] ruins the clay!</span>")

	current_user = null





// Pottery items, Placeholder sprites
/obj/item/pottery
	icon = 'icons/obj/kitchen.dmi'
	w_class = 2

/obj/item/pottery/bowl
	name = "ceramic bowl"
	desc = "A handcrafted ceramic bowl. Perfect for holding food or liquids."
	icon_state = "bowl"

/obj/item/pottery/glass
	name = "ceramic glass"
	desc = "A handcrafted ceramic drinking glass. It has a rustic charm to it."
	icon_state = "bowl"
	var/amount_per_transfer_from_this = 10
	var/volume = 30

/obj/item/pottery/vase
	name = "ceramic vase"
	desc = "A handcrafted ceramic vase. It would look nice with some flowers in it."
	icon_state = "bowl"
	w_class = 3

/obj/item/pottery/failed
	name = "ruined clay"
	desc = "A collapsed lump of clay. This pottery attempt didn't go so well."
	icon_state = "rice-0"








