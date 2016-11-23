#!/bin/bash
file_name="$1"

sed 's/},{/},\n{/g' $file_name > temp.yml
sed '/^[{]"start"[:]14[0-9]*,.*,$/d' temp.yml > temp2.yml
perl -pe 's/},\n/},/' temp2.yml > $file_name
