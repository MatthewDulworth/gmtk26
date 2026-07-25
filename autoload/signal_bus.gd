extends Node

# player signals
signal player_died
signal player_damaged(damage: int)
signal player_fired_weapon(weaponType: WeaponData)
signal player_picked_up_item
signal player_switched_weapon

# enemy signals
signal enemy_damaged(damage: int)
signal enemy_died(enemyType: EnemyData)
signal enemy_spawned(enemyType: EnemyData)

# level signals
signal wave_started(wave: int)
signal wave_ended
signal weapon_drop_spawned
