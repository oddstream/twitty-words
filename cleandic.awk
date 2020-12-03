# cleandic.awk
# https://www.gnu.org/software/gawk/manual/gawk.html
# awk -f cleandic.awk input.txt > output.txt
# awk '{if (length($0) > 2) print $0}' input.txt > output.txt

BEGIN {
}
{
	if (length($0) > 2) print $0
}
END {
}
