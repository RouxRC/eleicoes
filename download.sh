#!/bin/bash

function download {
  if ! test -s "$2"; then
    curl -sL "$1" > "$2"
    sleep 0.2
  fi
}

download http://www.eleicoes.mai.gov.pt/europeias2014/static-data/territory-children/TERRITORY-CHILDREN-LOCAL-500000.json distritos-codes.json

mkdir -p distritos concelhos freguesias data

cat distritos-codes.json | sed 's/},{/\n/g' | sed 's/^.*:"LOC/LOC/' | sed 's/["}]\]\?//g' | while read l; do
  echo "WORKING on distrito $l"
  download http://www.eleicoes.mai.gov.pt/europeias2014/static-data/territory-results/TERRITORY-RESULTS-$l-EUR.json distritos/results-$l.json
  download http://www.eleicoes.mai.gov.pt/europeias2014/static-data/territory-children/TERRITORY-CHILDREN-$l.json concelhos/codes-$l.json
done

cat concelhos/codes* | sed 's/},{/\n/g' | sed 's/]\[/\n/g' | sed 's/^.*:"LOC/LOC/' | sed 's/["}]\]\?//g' | while read l; do
  echo "WORKING on concelho $l"
  download http://www.eleicoes.mai.gov.pt/europeias2014/static-data/territory-results/TERRITORY-RESULTS-$l-EUR.json concelhos/results-$l.json
  download http://www.eleicoes.mai.gov.pt/europeias2014/static-data/territory-children/TERRITORY-CHILDREN-$l.json freguesias/codes-$l.json
done

cat freguesias/codes* | sed 's/},{/\n/g' | sed 's/]\[/\n/g' | sed 's/^.*:"LOC/LOC/' | sed 's/["}]\]\?//g' | while read l; do
  echo "WORKING on freguesia $l"
  download http://www.eleicoes.mai.gov.pt/europeias2014/static-data/territory-results/TERRITORY-RESULTS-$l-EUR.json freguesias/results-$l.json
done

./convert.py distritos 2> errors.txt
./convert.py concelhos 2>> errors.txt
./convert.py freguesias 2>> errors.txt
