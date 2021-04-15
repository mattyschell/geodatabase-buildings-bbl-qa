#!/bin/bash
rm src/bbl-qa-ack.sql
# strip any windows line separators
dos2unix bbl-qa.csv
# this works regardless of newlines at eof
# two newlines eof still a problem 
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "insert into bbl_qa_ack values($LINE); " | tr -d '\r' >> src/bbl-qa-ack.sql
done < bbl-qa-ack.csv
echo "commit;" >> src/bbl-qa-ack.sql 
echo "finished writing src/bbl-qa-ack.sql "
