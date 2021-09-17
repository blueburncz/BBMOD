batchSign.start();

with (OSign)
{
	other.batchSign.add(other.modSign,
		matrix_build(x, y, z, 0, 0, image_angle, 50, 50, 50));
}

batchSign.finish();
batchSign.freeze();