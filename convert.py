#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys, json

dire = sys.argv[1]

partys = []

def addResults(dico, code, name, data):
    res = {
      "code": code,
      "name": name,
      "registered": data["subscribedVoters"],
      "voters": data["totalVoters"],
      "blanks": data["blankVotes"],
      "nulls": data["nullVotes"],
      "boycotts": data.get("totalBoycotts", 0)
    }
    for party in data["resultsParty"]:
        if party["acronym"] not in partys:
            partys.append(party["acronym"])
        res[party["acronym"]] = party["votes"]
    dico.append(res)

results = {
  "2009": [],
  "2014": [],
}
for f in os.listdir(dire):
    if not f.startswith("results"):
        continue
    with open(os.path.join(dire, f)) as f:
        data = json.load(f)
    code = data["territoryKey"].replace("LOCAL-", "").lstrip("0")
    name = data["territoryFullName"]
    try:
        addResults(results["2009"], code, name, data["previousResults"])
    except:
        print >> sys.stderr, "WARNING No previousResults for %s in %s" % (name, f)
    addResults(results["2014"], code, name, data["currentResults"])

def formatt(x):
    if type(x) == unicode:
        return x.encode("utf-8")
    return str(x)

headers = ["code","name","registered","voters","blanks","nulls","boycotts"] + partys
for y in ["2009","2014"]:
    with open(os.path.join("data", "%s-%s.csv" % (y, dire)), "w") as f:
        print >> f, ",".join(headers)
        for res in results[y]:
            print >> f, ",".join([formatt(res.get(h, 0)) for h in headers])




