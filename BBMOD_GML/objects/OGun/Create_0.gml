event_inherited();

// Ammo given to the player when picked up.
ammo = irandom_range(3, 6);

OnPickUp = function (_other) {
	_other.ammo += ammo;
};
