#!/bin/bash
rm src/bbl-qa-ack.sql
# strip any windows line separators
dos2unix bbl-qa.csv
# ensure an empty line at the end of the csv
echo >> bbl-qa-ack.csv
cat bbl-qa-ack.csv | while read y
do
echo "insert into bbl_qa_ack values($y); " >> src/bbl-qa-ack.sql
done
echo "commit;" >> src/bbl-qa-ack.sql 
echo "finished writing src/bbl-qa-ack.sql "
