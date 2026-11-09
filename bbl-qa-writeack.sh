#!/bin/bash
output=src/bbl-qa-ack.sql
: > "$output"

while IFS= read -r y || [[ -n "$y" ]]; do
	y="${y#"${y%%[![:space:]]*}"}"
	y="${y%"${y##*[![:space:]]}"}"
	[[ -z "$y" ]] && continue
	printf 'insert into bbl_qa_ack values(%s);\n' "$y" >> "$output"
done < bbl-qa-ack.csv

echo "commit;" >> "$output"
echo "finished writing src/bbl-qa-ack.sql "
