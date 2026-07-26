extends Node

# player signals
signal player_died
signal player_damaged(current_health)
signal player_picked_up_item
signal player_switched_weapon
signal player_started_walking(player)
signal player_stopped_walking(player)
signal player_picked_up_feather

signal player_fired_weapon(weapon_data: WeaponData)
signal reloaded(active: bool)
signal started_reload(weapon_data: WeaponData)

# enemy signals
signal enemy_damaged(current_health)
signal enemy_died(enemy)
signal enemy_spawned
signal enemy_attacked
signal enemy_stopped_walking(enemy)
signal enemy_started_walking(enemy)

# level signals
signal wave_started(wave: int)
signal wave_ended
signal item_spawned
