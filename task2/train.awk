BEGIN {
	srand(seed);
	i = 0
	j = 0
	limit = rows * train / 100
}
{
	if (FNR == 1) {
		print $0 > "test.csv";
		print $0 > "train.csv";
	}
	else {
		if (rand() < train/100 && i < limit) {
			print $0 > "train.csv";
			i++;
		}
		else {
			if (j < rows - limit)
			{
				print $0 > "test.csv";
				j++;
			}
			else
				print $0 > "train.csv";
		}
	}
}
