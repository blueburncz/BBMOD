bbmod_object_add_real(object_index, "Color");
Color = make_color_hsv(irandom(255), 255, 255);

bbmod_object_add_real(object_index, "Radius");
Radius = random_range(16, 32);

bbmod_object_add_bool(object_index, "Outline");
Outline = choose(true, false);
