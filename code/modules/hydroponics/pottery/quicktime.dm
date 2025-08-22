/datum/action/bar/private/quicktime
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/active_duration = 1 SECOND
	var/active_duration_start = null
	var/obj/actions/bar/active_duration_bar = null
	var/active = FALSE

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
		src.onEnd()
	else
		src.interrupt(INTERRUPT_ALWAYS)


/obj/item/device/radio/signaler/test_object/var/datum/action/bar/private/quicktime/action_bar = null
/obj/item/device/radio/signaler/test_object/send_signal()
	if (!src.action_bar)
		src.action_bar = actions.start(new /datum/action/bar/private/quicktime, usr)
		return

	src.action_bar.trigger()
	src.action_bar = null
