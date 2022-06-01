#!/usr/bin/env python3
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description: A script to automate the process of setting up New Relic alerts
#
# Notes:
# 	- Enter API key and json file name outside of script
#	- If no json file is given, default is used
#	- Commit to https://github.com/dogsbodytech/workstation-tools/
#	- Write wiki documentation

import requests
import json
import itertools
from requests.structures import CaseInsensitiveDict

# Defines the required New Relic API links
CHANNEL_URL = "https://api.newrelic.com/v2/alerts_channels.json"
POLICY_URL = "https://api.newrelic.com/v2/alerts_policies.json"
CONDITIONS_URL = "https://infra-api.newrelic.com/v2/alerts/conditions"

# Headers must be case insensitive for the request commands below
headers = CaseInsensitiveDict()
headers["Api-Key"] = ""
headers["Content-Type"] = "application/json"

# Opens and converts the New Relic json config into a python dictionary
DATA_FILE = open('NR-alert-config.json',)
DATA = json.load(DATA_FILE)

# Function to test if the API commands were successful and print the error message if they weren't
def response(x, y):
	if x.status_code == 201 or x.status_code == 200:
		print(f"{y} was successfully created!")
	else:
		print(f"Failed to create {y}...please see error below:\n")
		print(x.text)
		print("\n")

CHANNEL_INFO = requests.get(CHANNEL_URL, headers=headers).json()
POLICY_INFO = requests.get(POLICY_URL, headers=headers).json()
CONDITIONS_INFO = requests.get(CONDITIONS_URL, headers=headers).json() 

# Creates the alert notification channels and policy by converting the dictionary back into json

if "Awab Email Test" not in str(CHANNEL_INFO):
	EMAIL_CHANNEL = requests.post(CHANNEL_URL, headers=headers, json=DATA['EMAIL'])
	response(EMAIL_CHANNEL, y="EMAIL CHANNEL")
else:
	print("Awab Email Test channel already exists in this NewRelic account")

if "Dogsbody Pushover" not in str(CHANNEL_INFO):
	PUSHOVER_CHANNEL = requests.post(CHANNEL_URL, headers=headers, json=DATA['PUSHOVER'])
	response(PUSHOVER_CHANNEL, y="PUSHOVER CHANNEL")
else:
	print("Dogsbody Pushover channel already exists in this NewRelic account")

if "Alert Dogsbody - TEST" not in str(POLICY_INFO):
	POLICY_OBJECT = requests.post(POLICY_URL, headers=headers, json=DATA['POLICY'])
	response(POLICY_OBJECT, y="POLICY")
else:
	print("Alert Dogsbody - TEST policy already exists in this NewRelic account")

# Converts the notification channel/policy data from json into a dictionary to allow extraction of the ID's into variables for the next request
POLICY_INFO = requests.get(POLICY_URL, headers=headers).json()
CHANNEL_INFO = requests.get(CHANNEL_URL, headers=headers).json()

for a in POLICY_INFO.values():
	for b in a:
		if b['name'] == "Alert Dogsbody - TEST":
			POLICY_ID = b['id']

for c in CHANNEL_INFO.values():
	for d in c:
		if d == 'channel.policy_ids':
			break
		elif d['name'] == "Awab Email Test":
			EMAIL_CHANNEL_ID = d['id']
		elif d['name'] == "Dogsbody Pushover":
			PUSHOVER_CHANNEL_ID = d['id']

# Adds the ID's into the main dictionary
ALL_CONFIGS = []
for config in DATA:
	if config not in ("EMAIL", "PUSHOVER", "POLICY"):
		DATA[config]['data']['policy_id'] = POLICY_ID
		ALL_CONFIGS += [config]

# Creates a new list without any conditions that already exist in NewRelic
NEW_CONFIGS = []
for i, o in zip(["High CPU", "High Disk", "Disk Space", "Memory Usage", "Host"], ALL_CONFIGS):
	if i not in str(CONDITIONS_INFO):
		NEW_CONFIGS += [o]
	else:
		print(f"The {i} condition already exists in this NewRelic account")

# Creates the infrastructure conditions and assigns it to the previously created policy
for condition in NEW_CONFIGS:
	name = condition
	condition = requests.post(CONDITIONS_URL, headers=headers, json=DATA[condition])
	response(condition, y=f"{name} INFRASTRUCTURE CONDITION")

# Attaches both notifications channels to the policy
POLICY_CHANNEL_URL = f"https://api.newrelic.com/v2/alerts_policy_channels.json?policy_id={POLICY_ID}&channel_ids={EMAIL_CHANNEL_ID},{PUSHOVER_CHANNEL_ID}"
POLICY_CHANNEL = requests.put(POLICY_CHANNEL_URL, headers=headers)
response(POLICY_CHANNEL, y="POLICY CHANNEL LINK")

