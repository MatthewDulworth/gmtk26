extends Node

# player signals
signal player_died
signal player_damaged(current_health)
signal player_picked_up_item
signal player_switched_weapon
signal player_started_walking
signal player_stopped_walking
signal player_picked_up_feather

signal player_fired_weapon(weapon_data: WeaponData)
signal reloaded(active: bool)
signal started_reload(weapon_data: WeaponData)

# enemy signals
signal enemy_damaged(current_health)
signal enemy_died
signal enemy_spawned
signal enemy_attacked

# level signals
signal wave_started(wave: int)
signal wave_ended
signal item_spawned
