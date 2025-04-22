@warning_ignore("unused_signal")
extends Node

#run signals
signal has_no_view
signal continue_button_pressed

#team leader screen signals
signal team_leader_selected
signal leader_selection_exited

#battle related signals
signal battle_entered
signal battle_rewards_exitted
signal battle_over
signal battle_lost
signal unit_died

#map signals
signal map_node_chosen(type: String)

#shop signals
signal shop_item_purchased
signal xp_purchased
signal exit_shop

#global unit signals
signal upgrade_unit
