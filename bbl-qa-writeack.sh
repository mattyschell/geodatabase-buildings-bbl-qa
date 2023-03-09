#!/bin/bash
rm src/bbl-qa-ack.sql
# strip any windows line separators
dos2unix bbl-qa-ack.csv
# this is badly written 
# bbl-qa-ack.csv should not have an empty line at the end
# then this echo will put a blank line there
# remove this echo and the last ID doesnt get written to SQL
# but add a line to bbl-qa-ack.csv and run this echo
# and we get an insert values(); which will error.  
# todo: Do better 
echo >> bbl-qa-ack.csv
cat bbl-qa-ack.csv | while read y
do
echo "insert into bbl_qa_ack values($y); " >> src/bbl-qa-ack.sql
done
echo "commit;" >> src/bbl-qa-ack.sql 
echo "finished writing src/bbl-qa-ack.sql "
