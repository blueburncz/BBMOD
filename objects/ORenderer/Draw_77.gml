var _scale = 1 / application_surface_scale;
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0, c_white, 1);

switch (mode_current)
{
case EMode.Normal:
	draw_text(0, 32, "with (instances) {}");
	break;

case EMode.Static:
	draw_text(0, 32, "Static batch");
	break;

case EMode.Dynamic:
	draw_text(0, 32, "Dynamic batch");
	break;
}