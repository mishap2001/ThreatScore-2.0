#!/bin/bash

###############################################################
# ThreatScore 2.0
# Author: Michael Pritsert
# GitHub: https://github.com/mishap2001
# LinkedIn: https://www.linkedin.com/in/michael-pritsert-8168bb38a
# License: MIT License
###############################################################

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
BOLD='\e[1m'
ENDCOLOR='\e[0m'

echo -e "${GREEN}${BOLD}"
cat << "EOF"
 _______ _                    _     _____
|__   __| |                  | |   / ____|
   | |  | |__  _ __ ___  __ _| |_ | (___   ___ ___  _ __ ___
   | |  | '_ \| '__/ _ \/ _` | __| \___ \ / __/ _ \| '__/ _ \
   | |  | | | | | |  __/ (_| | |_  ____) | (_| (_) | | |  __/
   |_|  |_| |_|_|  \___|\__,_|\__||_____/ \___\___/|_|  \___|

                     ThreatScore 2.0
EOF
echo -e "${ENDCOLOR}"

function APPS()
{
for app in curl jq ; do
if command -v "$app" >/dev/null; then
	echo -e "${GREEN}${BOLD}$app: installed ${ENDCOLOR}"
else
	echo -e "${RED}${BOLD}$app: NOT installed, installing now...${ENDCOLOR}"
	case "$app" in
		curl)
		sudo apt-get update && sudo apt-get install -y curl
		;;
	
		jq)
		sudo apt-get update && sudo apt-get install -y jq
		;;
	
	esac	
fi
done	
}

function CONF()
{
if [ ! -f .ThreatScore.conf ]; then
read -s -p "[*] Enter your VirusTotal API Key: " VT_API
read -s -p "[*] Enter your MalwareBazaar API Key: " MB_API
read -s -p "[*] Enter your OTX (AlienVault) API Key: " OTX_API
echo
echo -e "${CYAN}${BOLD}[*] Cloudflare credentials:${ENDCOLOR}"
read -s -p "    Account ID: " CF_ACCOUNT_ID
read -s -p "    API Token: " CF_TOKEN
echo
read -s -p "[*] Enter your urlscan.io API Key: " URLSCAN_API
read -s -p "[*] Enter your ThreatYeti API Key: " TY_API
read -s -p "[*] Enter your IPInfo API Key: " IPINFO_API
read -s -p "[*] Enter your AbuseIPDB API Key: " ABUSEIPDB_API
read -s -p "[*] Enter your OpenAI API Key: " OPENAI_API_KEY
read -s -p "[*] Enter your Gemini API Key: " GEMINI_API_KEY
read -s -p "[*] Enter your Telegram Bot Token: " BOT_TOKEN
read -s -p "[*] Enter your Telegram Chat ID: " CHAT_ID
echo "BOT_TOKEN=$BOT_TOKEN" > .ThreatScore.conf
echo "CHAT_ID=$CHAT_ID" >> .ThreatScore.conf
echo "VT_API=\"$VT_API\"" >> .ThreatScore.conf
echo "MB_API=\"$MB_API\"" >> .ThreatScore.conf
echo "OTX_API=\"$OTX_API\"" >> .ThreatScore.conf
echo "CF_ACCOUNT_ID=\"$CF_ACCOUNT_ID\"" >> .ThreatScore.conf
echo "CF_TOKEN=\"$CF_TOKEN\"" >> .ThreatScore.conf
echo "URLSCAN_API=\"$URLSCAN_API\"" >> .ThreatScore.conf
echo "TY_API=\"$TY_API\"" >> .ThreatScore.conf
echo "IPINFO_API=\"$IPINFO_API\"" >> .ThreatScore.conf
echo "ABUSEIPDB_API=\"$ABUSEIPDB_API\"" >> .ThreatScore.conf
echo "OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> .ThreatScore.conf
echo "GEMINI_API_KEY=\"$GEMINI_API_KEY\"" >> .ThreatScore.conf

chmod 600 .ThreatScore.conf
echo -e "${GREEN}${BOLD}[+] API keys saved to .ThreatScore.conf${ENDCOLOR}"
fi

source .ThreatScore.conf

if [ -z "$OPENAI_API_KEY" ]; then
  read -p "[*] Enter your OpenAI API Key: " OPENAI_API_KEY
  echo "OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> .ThreatScore.conf
  chmod 600 .ThreatScore.conf
fi

if [ -z "$GEMINI_API_KEY" ]; then
  read -p "[*] Enter your Gemini API Key: " GEMINI_API_KEY
  echo "GEMINI_API_KEY=\"$GEMINI_API_KEY\"" >> .ThreatScore.conf
  chmod 600 .ThreatScore.conf
fi

}

function MENU()
{
while true; do
echo
echo -e "${YELLOW}${BOLD}-------------------------------------------------------------${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}                       Scan Options${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}-------------------------------------------------------------${ENDCOLOR}"
echo
echo -e "${MAGENTA}${BOLD}[1]${ENDCOLOR} Check IP"
echo -e "${MAGENTA}${BOLD}[2]${ENDCOLOR} Check Domain"
echo -e "${MAGENTA}${BOLD}[3]${ENDCOLOR} Check URL"
echo -e "${MAGENTA}${BOLD}[4]${ENDCOLOR} Check Hash"
echo -e "${MAGENTA}${BOLD}[5]${ENDCOLOR} EXIT" 
echo
echo -ne "${BOLD}Choose an option to continue${ENDCOLOR}"
echo
printf "${YELLOW}${BOLD}Choice:${ENDCOLOR} "; read scan_choice
echo
case "$scan_choice" in
	1) IP ;;
	2) DOMAIN ;;
	3) URL ;;
	4) HASH ;;
	5) echo; echo -e "${RED}${BOLD}EXITING...${ENDCOLOR}"; sleep 0.5; exit ;;
	*) echo -e "${RED}${BOLD}Invalid input${ENDCOLOR}"
	   echo -e "${RED}${BOLD}Choose from the available options${ENDCOLOR}"
	   echo
	;;
esac
done		
}

function IP()
{
[ -z "$ip" ] && { if [ -z "$ip" ]; then
  printf "${GREEN}${BOLD}Enter IP:${ENDCOLOR} "
  read ip
fi; }
if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    ip_type="IPv4"
elif [[ "$ip" == *:* ]]; then
    ip_type="IPv6"
else
    echo -e "${RED}${BOLD}Invalid IP${ENDCOLOR}"
    return
fi

echo -e "${BOLD}IP Type:${ENDCOLOR} ${CYAN}$ip_type${ENDCOLOR}"
response_info=$(curl -s "https://api.ipinfo.io/lite/$ip?token=$IPINFO_API")
ip_in=$(echo "$response_info" | jq -r '.ip')
as_name=$(echo "$response_info" | jq -r '.as_name')
countrycode_in=$(echo "$response_info" | jq -r '.country_code')
country_in=$(echo "$response_info" | jq -r '.country')
continent_in=$(echo "$response_info" | jq -r '.continent')
continentcode_in=$(echo "$response_info" | jq -r '.continent_code')
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}IPinfo Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}IP:${ENDCOLOR} $ip_in
${BOLD}Routing Domain:${ENDCOLOR} $as_name
${BOLD}Country:${ENDCOLOR} ${country_in}, $countrycode_in
${BOLD}Continent:${ENDCOLOR} ${continent_in}, $continentcode_in"  

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
response_vt=$(curl -s -H "x-apikey: $VT_API" "https://www.virustotal.com/api/v3/ip_addresses/$ip")
ip_vt=$(echo "$response_vt" | jq -r '.data.id')
reputation=$(echo "$response_vt" | jq -r '.data.attributes.reputation')
vt_malicious=$(API_VALUE "$(echo "$response_vt" | jq -r '.data.attributes.last_analysis_stats.malicious // empty')" "N/A")
vt_suspicious=$(echo "$response_vt" | jq -r '.data.attributes.last_analysis_stats.suspicious')
vote_malicious=$(echo "$response_vt" | jq -r '.data.attributes.total_votes.malicious')
vote_harmless=$(echo "$response_vt" | jq -r '.data.attributes.total_votes.harmless')
asn=$(echo "$response_vt" | jq -r '.data.attributes.asn')
as_owner=$(echo "$response_vt" | jq -r '.data.attributes.as_owner')
country_vt=$(echo "$response_vt" | jq -r '.data.attributes.country')
network=$(echo "$response_vt" | jq -r '.data.attributes.network')
rdap_type=$(echo "$response_vt" | jq -r '.data.attributes.rdap.type')
rdap_country=$(echo "$response_vt" | jq -r '.data.attributes.rdap.country')

echo -e "${BOLD}IP:${ENDCOLOR} $ip_vt
${BOLD}VT malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}
${BOLD}VT suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}
${BOLD}Reputation:${ENDCOLOR} ${MAGENTA}$reputation${ENDCOLOR}
${BOLD}Community votes:${ENDCOLOR} malicious=$vote_malicious harmless=$vote_harmless
${BOLD}ASN:${ENDCOLOR} $asn
${BOLD}Owner:${ENDCOLOR} $as_owner
${BOLD}Country:${ENDCOLOR} $country_vt
${BOLD}Network:${ENDCOLOR} $network
${BOLD}RDAP type:${ENDCOLOR} $rdap_type"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ VirusTotal search complete"

response_adb=$(curl -s \
  -G https://api.abuseipdb.com/api/v2/check \
  --data-urlencode "ipAddress=$ip" \
  --data-urlencode "maxAgeInDays=90" \
  -H "Key: $ABUSEIPDB_API" \
  -H "Accept: application/json")

ip_adb=$(echo "$response_adb" | jq -r '.data.ipAddress')
is_public=$(echo "$response_adb" | jq '.data.isPublic')
ip_version=$(echo "$response_adb" | jq '.data.ipVersion')
is_whitelisted=$(echo "$response_adb" | jq '.data.isWhitelisted')
abuse_score=$(echo "$response_adb" | jq '.data.abuseConfidenceScore')
country_adb=$(echo "$response_adb" | jq -r '.data.countryCode')
usage_type=$(echo "$response_adb" | jq -r '.data.usageType')
isp=$(echo "$response_adb" | jq -r '.data.isp')
domain=$(echo "$response_adb" | jq -r '.data.domain')
hostnames=$(echo "$response_adb" | jq -r '.data.hostnames | join(", ")')
is_tor=$(echo "$response_adb" | jq '.data.isTor')
total_reports=$(echo "$response_adb" | jq '.data.totalReports')
distinct_users=$(echo "$response_adb" | jq '.data.numDistinctUsers')
last_reported=$(echo "$response_adb" | jq -r '.data.lastReportedAt')
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}AbuseIPDB Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}IP:${ENDCOLOR} $ip_adb"
echo -e "${BOLD}Is Public:${ENDCOLOR} $is_public"
echo -e "${BOLD}IP Version:${ENDCOLOR} $ip_version"
echo -e "${BOLD}Whitelisted:${ENDCOLOR} $is_whitelisted"
echo -e "${BOLD}Abuse Score:${ENDCOLOR} ${RED}$abuse_score${ENDCOLOR}"
echo -e "${BOLD}Country:${ENDCOLOR} $country_adb"
echo -e "${BOLD}Usage Type:${ENDCOLOR} $usage_type"
echo -e "${BOLD}ISP:${ENDCOLOR} $isp"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}Hostnames:${ENDCOLOR} $hostnames"
echo -e "${BOLD}Is TOR:${ENDCOLOR} ${MAGENTA}$is_tor${ENDCOLOR}"
echo -e "${BOLD}Total Reports:${ENDCOLOR} $total_reports"
echo -e "${BOLD}Distinct Users:${ENDCOLOR} $distinct_users"
echo -e "${BOLD}Last Reported:${ENDCOLOR} $last_reported"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ AbuseIPDB search complete"

echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

if [[ "$ip_type" == "IPv6" ]]; then
    OTX_TYPE="IPv6"
else
    OTX_TYPE="IPv4"
fi

RESP=$(curl -s "https://otx.alienvault.com/api/v1/indicators/$OTX_TYPE/$ip/general" \
  -H "X-OTX-API-KEY: $OTX_API")

IP_ADDR=$(printf '%s' "$RESP" | jq -r '.indicator // "N/A"')
REPUTATION=$(printf '%s' "$RESP" | jq -r '.reputation // 0')
ASN=$(printf '%s' "$RESP" | jq -r '.asn // "N/A"')
COUNTRY=$(printf '%s' "$RESP" | jq -r '.country_name // "N/A"')
CITY=$(printf '%s' "$RESP" | jq -r '.city // "N/A"')
PULSES=$(printf '%s' "$RESP" | jq -r '.pulse_info.count // 0')
TOP_TAGS=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[].tags[]?' 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr | head -10 | awk '{$1=$1; print}')
RECENT_PULSES=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[]?.name' 2>/dev/null | head -10)
PARSE_OTX_PULSES "$RESP"

echo -e "${BOLD}IP:${ENDCOLOR} $IP_ADDR"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$PULSES${ENDCOLOR}"
echo -e "${BOLD}Reputation:${ENDCOLOR} ${MAGENTA}$REPUTATION${ENDCOLOR}"
echo -e "${BOLD}ASN:${ENDCOLOR} $ASN"
echo -e "${BOLD}Location:${ENDCOLOR} $CITY, $COUNTRY"

if [ "$PULSES" -gt 0 ]; then
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi

echo -e "${BOLD}Top tags:${ENDCOLOR}"
[ -n "$TOP_TAGS" ] && echo "$TOP_TAGS" || echo "None"

echo -e "${BOLD}Recent pulse names:${ENDCOLOR}"
[ -n "$RECENT_PULSES" ] && echo "$RECENT_PULSES" || echo "None"

[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ OTX search complete"

SUMMARY="Type: IP
Object: $ip

Infrastructure:
country=$country_in
country_code=$countrycode_in
continent=$continent_in
asn=$asn
asn_owner=$as_owner
ipinfo_as_name=$as_name
network=$network
provider_or_isp=$isp
domain=$domain
hostnames=$hostnames

VirusTotal:
malicious=$vt_malicious
suspicious=$vt_suspicious
reputation=$reputation
community_votes_malicious=$vote_malicious

AbuseIPDB:
abuse_score=$abuse_score
reports=$total_reports
distinct_users=$distinct_users
tor=$is_tor
last_reported=$last_reported
usage_type=$usage_type
whitelisted=$is_whitelisted

OTX:
pulses=$PULSES
top_tags=$TOP_TAGS
recent_pulses=$RECENT_PULSES
official_pulses=$OFFICIAL_PULSES
community_pulses=$COMMUNITY_PULSES
"
}

function DOMAIN()
{
[ -z "$domain" ] && { if [ -z "$domain" ]; then
  printf "${GREEN}${BOLD}Enter Domain:${ENDCOLOR} "
  read domain
fi; }
[[ "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] || { echo -e "${RED}${BOLD}Invalid domain${ENDCOLOR}"; return; }

response_vt_domain=$(curl -s \
  -H "x-apikey: $VT_API" \
  "https://www.virustotal.com/api/v3/domains/$domain")

vt_malicious=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.malicious')
vt_suspicious=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.suspicious')
vt_harmless=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.harmless')
vt_undetected=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.undetected')
reputation=$(echo "$response_vt_domain" | jq '.data.attributes.reputation')
votes_malicious=$(echo "$response_vt_domain" | jq '.data.attributes.total_votes.malicious')
votes_harmless=$(echo "$response_vt_domain" | jq '.data.attributes.total_votes.harmless')
categories=$(echo "$response_vt_domain" | jq -r '.data.attributes.categories | to_entries[]? | .value' 2>/dev/null)
creation_date=$(echo "$response_vt_domain" | jq '.data.attributes.creation_date')
tld=$(echo "$response_vt_domain" | jq -r '.data.attributes.tld')
echo	
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}VT malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}"
echo -e "${BOLD}VT suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}"
echo -e "${BOLD}VT harmless:${ENDCOLOR} ${GREEN}$vt_harmless${ENDCOLOR}"
echo -e "${BOLD}VT undetected:${ENDCOLOR} ${CYAN}$vt_undetected${ENDCOLOR}"
echo -e "${BOLD}Reputation:${ENDCOLOR} ${MAGENTA}$reputation${ENDCOLOR}"
echo -e "${BOLD}Votes:${ENDCOLOR} malicious=$votes_malicious harmless=$votes_harmless"
echo -e "${BOLD}Categories:${ENDCOLOR} $categories"
echo -e "${BOLD}TLD:${ENDCOLOR} $tld"
echo -e "${BOLD}Creation date:${ENDCOLOR} $creation_date"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ VirusTotal search complete"
	
response_urlscan_domain=$(curl -s -G "https://urlscan.io/api/v1/search/" --data-urlencode "q=domain:$domain" -H "API-Key: $URLSCAN_API" | jq)
total=$(echo "$response_urlscan_domain" | jq '.total')
tag=$(echo "$response_urlscan_domain" | jq -r '.results[0].task.tags[0] // "none"')
last_scan=$(echo "$response_urlscan_domain" | jq -r '.results[0].task.time // "null"')
ip=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.ip // "null"')
server=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.server // "null"')
asnname=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.asnname // "null"')
title=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.title // "null"')
status=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.status // "null"')	
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}urlscan.io Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}Results Found:${ENDCOLOR} $total"
echo -e "${BOLD}Tag:${ENDCOLOR} $tag"
echo -e "${BOLD}Last Scan:${ENDCOLOR} $last_scan"
echo -e "${BOLD}IP:${ENDCOLOR} $ip"
echo -e "${BOLD}Server:${ENDCOLOR} $server"
echo -e "${BOLD}ASN:${ENDCOLOR} $asnname"
echo -e "${BOLD}Title:${ENDCOLOR} $title"
echo -e "${BOLD}Status:${ENDCOLOR} $status"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ urlscan.io search complete"

level=$(curl -s -X POST -H "Content-Type: application/json" \
-d "{\"hostname\":\"$domain\",\"license\":\"$TY_API\",\"version\":1,\"sections\":[\"popularity\"]}" \
https://api.alphamountain.ai/intelligence/hostname | jq -r '
    if (.summary.high_risk|length>0) then "high"
    elif (.summary.mid_risk|length>0) then "mid"
    elif (.summary.low_risk|length>0) then "low"
    else "none"
    end')
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}ThreatYeti Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}Risk Level:${ENDCOLOR} ${MAGENTA}$level${ENDCOLOR}"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ ThreatYeti search complete"

echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
RESP=$(curl -s \
  -H "X-OTX-API-KEY: $OTX_API" \
  "https://otx.alienvault.com/api/v1/indicators/domain/$domain/general")

if ! echo "$RESP" | jq empty 2>/dev/null; then
  echo -e "${RED}${BOLD}OTX returned invalid response${ENDCOLOR}"
  echo "$RESP"
  return
fi
DOMAIN=$(printf '%s' "$RESP" | jq -r '.indicator // "N/A"')
TYPE=$(printf '%s' "$RESP" | jq -r '.type // "N/A"')
PULSES=$(printf '%s' "$RESP" | jq -r '.pulse_info.count // 0')
SECTIONS=$(printf '%s' "$RESP" | jq -r '.sections // [] | join(", ")')
PULSE_NAMES=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[]?.name' 2>/dev/null)
TAGS=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[].tags[]?' 2>/dev/null | sort -u)
REFS=$(printf '%s' "$RESP" | jq -r '.pulse_info.references[]?' 2>/dev/null | sort -u)
PARSE_OTX_PULSES "$RESP"

echo -e "${BOLD}Domain:${ENDCOLOR} $DOMAIN"
echo -e "${BOLD}Type:${ENDCOLOR} $TYPE"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$PULSES${ENDCOLOR}"
if [[ "$PULSES" =~ ^[0-9]+$ ]] && [ "$PULSES" -gt 0 ]; then
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi
echo -e "${BOLD}Sections:${ENDCOLOR} $SECTIONS"

echo -e "${BOLD}Pulse names:${ENDCOLOR}"
[ -n "$PULSE_NAMES" ] && echo "$PULSE_NAMES"

echo -e "${BOLD}Tags:${ENDCOLOR}"
[ -n "$TAGS" ] && echo "$TAGS"

echo -e "${BOLD}References:${ENDCOLOR}"
[ -n "$REFS" ] && echo "$REFS"

[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ OTX search complete"

SUMMARY="Type: Domain
Object: $domain

Infrastructure:
resolved_ip=$ip
server=$server
asn=$asnname
tld=$tld
creation_date=$creation_date
page_title=$title
http_status=$status

VirusTotal:
malicious=$vt_malicious
suspicious=$vt_suspicious
harmless=$vt_harmless
undetected=$vt_undetected
reputation=$reputation
votes_malicious=$votes_malicious
votes_harmless=$votes_harmless
categories=$categories

urlscan:
results_found=$total
tag=$tag
last_scan=$last_scan
ip=$ip
server=$server
asn=$asnname
title=$title
status=$status

ThreatYeti:
risk_level=$level

OTX:
pulses=$PULSES
type=$TYPE
sections=$SECTIONS
pulse_names=$PULSE_NAMES
tags=$TAGS
references=$REFS
official_pulses=$OFFICIAL_PULSES
community_pulses=$COMMUNITY_PULSES
"
}

function URL()
{
if [ -z "$url" ]; then
  printf "${GREEN}${BOLD}Enter URL:${ENDCOLOR} "
  read url
fi

[[ "$url" =~ ^https?:// ]] || {
  echo -e "${RED}${BOLD}Invalid URL${ENDCOLOR}"
  return
}

URL="$url"
echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

SCAN_ID=$(curl -s -X POST "https://www.virustotal.com/api/v3/urls" \
  -H "x-apikey: $VT_API" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "url=$URL" | jq -r '.data.id')

while true; do
  RESP=$(curl -s "https://www.virustotal.com/api/v3/analyses/$SCAN_ID" \
    -H "x-apikey: $VT_API")

  STATUS=$(printf '%s' "$RESP" | jq -r '.data.attributes.status')

  [ "$STATUS" = "completed" ] && break
  sleep 2
done

vt_malicious=$(echo "$RESP" | jq '.data.attributes.stats.malicious')
vt_suspicious=$(echo "$RESP" | jq '.data.attributes.stats.suspicious')
vt_harmless=$(echo "$RESP" | jq '.data.attributes.stats.harmless')
vt_undetected=$(echo "$RESP" | jq '.data.attributes.stats.undetected')

echo -e "${BOLD}Malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}"
echo -e "${BOLD}Suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}"
echo -e "${BOLD}Harmless:${ENDCOLOR} ${GREEN}$vt_harmless${ENDCOLOR}"
echo -e "${BOLD}Undetected:${ENDCOLOR} ${CYAN}$vt_undetected${ENDCOLOR}"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ VirusTotal search complete"

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}   Cloudflare Scan${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

SCAN_RESPONSE=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/urlscanner/v2/scan" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" \
  --data "$(jq -n --arg url "$url" '{url:$url, visibility:"public"}')")

SCAN_ID=$(echo "$SCAN_RESPONSE" | jq -r '.uuid // .result.uuid // empty')

if [ -z "$SCAN_ID" ] || [ "$SCAN_ID" = "null" ]; then
  echo -e "${RED}${BOLD}Cloudflare scan failed (no ID)${ENDCOLOR}"
  echo "$SCAN_RESPONSE" | jq 2>/dev/null || echo "$SCAN_RESPONSE"
  [ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "⚠️ Cloudflare scan failed, continuing to OTX..."

  DOMAIN="N/A"
  IP="N/A"
  COUNTRY="N/A"
  ASN="N/A"
  MALICIOUS="N/A"
  REQUESTS="N/A"
  EXTERNAL="N/A"
else

  attempts=0

  while true; do
    RESP=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/urlscanner/v2/result/$SCAN_ID" \
      -H "Authorization: Bearer $CF_TOKEN")

    STATUS=$(echo "$RESP" | jq -r '.task.status // .result.task.status // .status // empty' 2>/dev/null)

    [ "$STATUS" = "finished" ] && break
    [ "$STATUS" = "complete" ] && break
    [ "$STATUS" = "completed" ] && break

    ((attempts++))
    if ((attempts >= 20)); then
      echo -e "${RED}${BOLD}Cloudflare scan timeout${ENDCOLOR}"
      [ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "⚠️ Cloudflare scan timeout, continuing to OTX..."
      break
    fi

    sleep 2
  done

  if ! echo "$RESP" | jq empty >/dev/null 2>&1; then
    echo -e "${RED}${BOLD}Cloudflare returned invalid JSON${ENDCOLOR}"
    echo "$RESP"

    DOMAIN="N/A"
    IP="N/A"
    COUNTRY="N/A"
    ASN="N/A"
    MALICIOUS="N/A"
    REQUESTS="N/A"
    EXTERNAL="N/A"
  else
    DOMAIN=$(echo "$RESP" | jq -r '.page.domain // .result.page.domain // "N/A"')
    IP=$(echo "$RESP" | jq -r '.page.ip // .result.page.ip // "N/A"')
    COUNTRY=$(echo "$RESP" | jq -r '.page.country // .result.page.country // "N/A"')
    ASN=$(echo "$RESP" | jq -r '.page.asnname // .result.page.asnname // "N/A"')
    MALICIOUS=$(echo "$RESP" | jq -r '
      if (.success == false or .result.success == false) then "N/A"
      elif (.verdicts.overall.malicious // .result.verdicts.overall.malicious // false) then "YES"
      else "NO"
      end')
    REQUESTS=$(echo "$RESP" | jq -r '(.data.requests // .result.data.requests // []) | length')
    EXTERNAL=$(echo "$RESP" | jq -r '(.lists.linkDomains // .result.lists.linkDomains // []) | join(", ")')
  fi
fi

echo -e "${BOLD}Domain:${ENDCOLOR} $DOMAIN"
echo -e "${BOLD}IP:${ENDCOLOR} $IP"
echo -e "${BOLD}Country:${ENDCOLOR} $COUNTRY"
echo -e "${BOLD}ASN:${ENDCOLOR} $ASN"

if [ "$MALICIOUS" = "YES" ]; then
  echo -e "${BOLD}Malicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
elif [ "$MALICIOUS" = "NO" ]; then
  echo -e "${BOLD}Malicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
else
  echo -e "${BOLD}Malicious:${ENDCOLOR} ${YELLOW}${BOLD}N/A${ENDCOLOR}"
fi

echo -e "${BOLD}Requests:${ENDCOLOR} $REQUESTS"
echo -e "${BOLD}External:${ENDCOLOR} $EXTERNAL"

[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ Cloudflare search complete"

echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
ENCODED_URL=$(jq -rn --arg x "$url" '$x|@uri')
RESP=$(curl -s "https://otx.alienvault.com/api/v1/indicators/url/$ENCODED_URL/general" \
  -H "X-OTX-API-KEY: $OTX_API")
URL_VALUE=$(echo "$RESP" | jq -r '.indicator // "N/A"')
PULSES=$(echo "$RESP" | jq -r '.pulse_info.count // 0')
TOP_TAGS=$(echo "$RESP" | jq -r '.pulse_info.pulses[].tags[]?' 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr | head -10 | awk '{$1=$1; print}')
RECENT_PULSES=$(echo "$RESP" | jq -r '.pulse_info.pulses[]?.name' 2>/dev/null | head -10)
PARSE_OTX_PULSES "$RESP"

echo -e "${BOLD}URL:${ENDCOLOR} $URL_VALUE"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$PULSES${ENDCOLOR}"

if [ "$PULSES" -gt 0 ]; then
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi

echo -e "${BOLD}Top tags:${ENDCOLOR}"
if [ -n "$TOP_TAGS" ]; then
  echo "$TOP_TAGS"
else
  echo "None"
fi

echo -e "${BOLD}Recent pulse names:${ENDCOLOR}"
if [ -n "$RECENT_PULSES" ]; then
  echo "$RECENT_PULSES"
else
  echo "None"
fi

vt_malicious=${vt_malicious:-0}
vt_suspicious=${vt_suspicious:-0}
abuse_score=${abuse_score:-0}
PULSES=${PULSES:-0}

[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ OTX search complete"

SUMMARY="Type: URL
Object: $url

Infrastructure:
domain=$DOMAIN
ip=$IP
country=$COUNTRY
asn=$ASN
external_domains=$EXTERNAL

VirusTotal:
malicious=$vt_malicious
suspicious=$vt_suspicious
harmless=$vt_harmless
undetected=$vt_undetected

Cloudflare:
domain=$DOMAIN
ip=$IP
country=$COUNTRY
asn=$ASN
malicious=$MALICIOUS
requests=$REQUESTS
external_domains=$EXTERNAL

OTX:
url=$URL_VALUE
pulses=$PULSES
top_tags=$TOP_TAGS
recent_pulses=$RECENT_PULSES
official_pulses=$OFFICIAL_PULSES
community_pulses=$COMMUNITY_PULSES
"
}

function HASH()
{
[ -z "$hash" ] && { if [ -z "$hash" ]; then
  printf "${GREEN}${BOLD}Enter Hash (MD5/SHA-1/SHA-256):${ENDCOLOR} "
  read hash
fi }
if [[ $hash =~ ^[a-fA-F0-9]{32}$ ]]; then
    hash_type="md5"
elif [[ $hash =~ ^[a-fA-F0-9]{40}$ ]]; then
    hash_type="sha1"
elif [[ $hash =~ ^[a-fA-F0-9]{64}$ ]]; then
    hash_type="sha256"
else
    echo -e "${RED}${BOLD}Unsupported hash type (only MD5 / SHA1 / SHA256 are supported)${ENDCOLOR}"
    return
fi
echo -e "${BOLD}Detected hash type:${ENDCOLOR} ${CYAN}$hash_type${ENDCOLOR}"

# VirusTotal

response_vt_file=$(curl -s \
-H "x-apikey: $VT_API" \
"https://www.virustotal.com/api/v3/files/$hash")

vt_malicious=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.malicious')
vt_suspicious=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.suspicious')
vt_harmless=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.harmless')
vt_undetected=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.undetected')

md5=$(echo "$response_vt_file" | jq -r '.data.attributes.md5')
sha1=$(echo "$response_vt_file" | jq -r '.data.attributes.sha1')
sha256=$(echo "$response_vt_file" | jq -r '.data.attributes.sha256')

type=$(echo "$response_vt_file" | jq -r '.data.attributes.type_description')
size=$(echo "$response_vt_file" | jq '.data.attributes.size')

threat_label=$(echo "$response_vt_file" | jq -r '.data.attributes.popular_threat_classification.suggested_threat_label')
threat_type=$(echo "$response_vt_file" | jq -r '.data.attributes.popular_threat_classification.popular_threat_category[0].value // "N/A"' 2>/dev/null)
tags=$(echo "$response_vt_file" | jq -r '[.data.attributes.tags[]?] | join(", ")')

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Hash:${ENDCOLOR} $hash"
echo -e "${BOLD}Type:${ENDCOLOR} $type"
echo -e "${BOLD}Size:${ENDCOLOR} $size"
echo -e "${BOLD}MD5:${ENDCOLOR} $md5"
echo -e "${BOLD}SHA1:${ENDCOLOR} $sha1"
echo -e "${BOLD}SHA256:${ENDCOLOR} $sha256"
echo -e "${BOLD}VT malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}"
echo -e "${BOLD}VT suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}"
echo -e "${BOLD}VT harmless:${ENDCOLOR} ${GREEN}$vt_harmless${ENDCOLOR}"
echo -e "${BOLD}VT undetected:${ENDCOLOR} ${CYAN}$vt_undetected${ENDCOLOR}"
echo -e "${BOLD}Threat:${ENDCOLOR} $threat_type"
echo -e "${BOLD}Family:${ENDCOLOR} $threat_label"
echo -e "${BOLD}Tags:${ENDCOLOR} ${tags:-N/A}"
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ VirusTotal search complete"

# MalwareBazaar

response_mb=$(curl -s https://mb-api.abuse.ch/api/v1/ \
  -H "Auth-Key: $MB_API" \
  -d "query=get_info&hash=$hash")

mb_status=$(echo "$response_mb" | jq -r '.query_status')

mb_sha256=$(echo "$response_mb" | jq -r '.data[0].sha256_hash // "N/A"')
mb_sha1=$(echo "$response_mb" | jq -r '.data[0].sha1_hash // "N/A"')
mb_md5=$(echo "$response_mb" | jq -r '.data[0].md5_hash // "N/A"')

mb_file_name=$(echo "$response_mb" | jq -r '.data[0].file_name // "N/A"')
mb_file_type=$(echo "$response_mb" | jq -r '.data[0].file_type // "N/A"')
mb_size=$(echo "$response_mb" | jq -r '.data[0].file_size // "N/A"')

mb_signature=$(echo "$response_mb" | jq -r '.data[0].signature // "N/A"')
mb_tags=$(echo "$response_mb" | jq -r '[.data[0].tags[]?] | join(", ") // "N/A"')

mb_first_seen=$(echo "$response_mb" | jq -r '.data[0].first_seen // "N/A"')

mb_anyrun_verdict=$(echo "$response_mb" | jq -r '.data[0].vendor_intel["ANY.RUN"][0].verdict // "N/A"')
mb_triage_family=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.Triage.malware_family // "N/A"')
mb_rl_status=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.ReversingLabs.status // "N/A"')
mb_rl_name=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.ReversingLabs.threat_name // "N/A"')
mb_fs_verdict=$(echo "$response_mb" | jq -r '.data[0].vendor_intel["FileScan-IO"].verdict // "N/A"')
mb_kaspersky_verdict=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.Kaspersky.verdict // "N/A"')
mb_kaspersky_detection=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.Kaspersky.detections[0] // "N/A"')

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}   MalwareBazaar${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

if [ "$mb_status" = "ok" ]; then
  echo -e "${BOLD}Hash:${ENDCOLOR} $hash"
  echo -e "${BOLD}File name:${ENDCOLOR} $mb_file_name"
  echo -e "${BOLD}Type:${ENDCOLOR} $mb_file_type"
  echo -e "${BOLD}Size:${ENDCOLOR} $mb_size"
  echo -e "${BOLD}MD5:${ENDCOLOR} $mb_md5"
  echo -e "${BOLD}SHA1:${ENDCOLOR} $mb_sha1"
  echo -e "${BOLD}SHA256:${ENDCOLOR} $mb_sha256"
  echo -e "${BOLD}Signature:${ENDCOLOR} $mb_signature"
  echo -e "${BOLD}Tags:${ENDCOLOR} $mb_tags"
  echo -e "${BOLD}First seen:${ENDCOLOR} $mb_first_seen"
  echo -e "${BOLD}ANY.RUN verdict:${ENDCOLOR} $mb_anyrun_verdict"
  echo -e "${BOLD}Triage family:${ENDCOLOR} $mb_triage_family"
  echo -e "${BOLD}ReversingLabs:${ENDCOLOR} $mb_rl_status"
  echo -e "${BOLD}ReversingLabs threat:${ENDCOLOR} $mb_rl_name"
  echo -e "${BOLD}FileScan verdict:${ENDCOLOR} $mb_fs_verdict"
  echo -e "${BOLD}Kaspersky verdict:${ENDCOLOR} $mb_kaspersky_verdict"
  echo -e "${BOLD}Kaspersky detection:${ENDCOLOR} $mb_kaspersky_detection"
else
  echo -e "${RED}${BOLD}No results found${ENDCOLOR}"
fi
[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ MalwareBazaar search complete"

# OTX

response_otx=$(curl -s \
  -H "X-OTX-API-KEY: $OTX_API" \
  "https://otx.alienvault.com/api/v1/indicators/file/$hash/general")

pulse_count=$(echo "$response_otx" | jq -r '.pulse_info.count // 0')
indicator=$(echo "$response_otx" | jq -r '.indicator // "N/A"')
type=$(echo "$response_otx" | jq -r '.type // "N/A"')
type_title=$(echo "$response_otx" | jq -r '.type_title // "N/A"')

pulse_name=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].name // "N/A"')
pulse_desc=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].description // "N/A"')
pulse_created=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].created // "N/A"')
pulse_modified=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].modified // "N/A"')
pulse_author=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].author.username // "N/A"')
pulse_tags=$(echo "$response_otx" | jq -r '[.pulse_info.pulses[0].tags[]?] | join(", ") // "N/A"')
pulse_ref=$(echo "$response_otx" | jq -r '.pulse_info.references[0] // "N/A"')
PARSE_OTX_PULSES "$response_otx"

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Hash:${ENDCOLOR} $indicator"
echo -e "${BOLD}Type:${ENDCOLOR} $type"
echo -e "${BOLD}Type title:${ENDCOLOR} $type_title"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$pulse_count${ENDCOLOR}"
echo -e "${BOLD}Pulse name:${ENDCOLOR} $pulse_name"
echo -e "${BOLD}Description:${ENDCOLOR} $pulse_desc"
echo -e "${BOLD}Author:${ENDCOLOR} $pulse_author"
echo -e "${BOLD}Tags:${ENDCOLOR} $pulse_tags"
echo -e "${BOLD}Reference:${ENDCOLOR} $pulse_ref"
echo -e "${BOLD}Created:${ENDCOLOR} $pulse_created"
echo -e "${BOLD}Modified:${ENDCOLOR} $pulse_modified"

[ -n "$CURRENT_CHAT_ID" ] && send_telegram "$CURRENT_CHAT_ID" "✅ OTX search complete"

SUMMARY="Type: Hash
Object: $hash
Hash type: $hash_type

VirusTotal:
malicious=$vt_malicious
suspicious=$vt_suspicious
harmless=$vt_harmless
undetected=$vt_undetected
file_type=$type
size=$size
threat_type=$threat_type
family=$threat_label
tags=$tags

MalwareBazaar:
status=$mb_status
file_name=$mb_file_name
file_type=$mb_file_type
size=$mb_size
signature=$mb_signature
tags=$mb_tags
first_seen=$mb_first_seen
anyrun_verdict=$mb_anyrun_verdict
triage_family=$mb_triage_family
reversinglabs_status=$mb_rl_status
reversinglabs_threat=$mb_rl_name
filescan_verdict=$mb_fs_verdict
kaspersky_verdict=$mb_kaspersky_verdict
kaspersky_detection=$mb_kaspersky_detection

OTX:
pulses=$pulse_count
indicator=$indicator
type=$type_title
pulse_name=$pulse_name
description=$pulse_desc
author=$pulse_author
tags=$pulse_tags
reference=$pulse_ref
created=$pulse_created
modified=$pulse_modified
official_pulses=$OFFICIAL_PULSES
community_pulses=$COMMUNITY_PULSES
"
}

function send_telegram()
{
local chat_id="$1"
local text="$2"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${chat_id}" \
    --data-urlencode "text=${text}" >/dev/null
}

function API_VALUE()
{
  local value="$1"
  local fallback="$2"

  if [ -z "$value" ] || [ "$value" = "null" ]; then
    echo "$fallback"
  else
    echo "$value"
  fi
}

function PARSE_OTX_PULSES()
{
local otx_resp="$1"

OFFICIAL_PULSES=$(printf '%s' "$otx_resp" | jq -r '
.pulse_info.pulses[]? |
select((.author_name // .author.username // "") == "AlienVaultLabs") |
"- " + (.name // "Unnamed pulse")
' 2>/dev/null)

COMMUNITY_PULSES=$(printf '%s' "$otx_resp" | jq -r '
.pulse_info.pulses[]? |
select((.author_name // .author.username // "") != "AlienVaultLabs") |
"- " + (.name // "Unnamed pulse") + " (" + ((.author_name // .author.username // "unknown")) + ")"
' 2>/dev/null)

OFFICIAL_PULSES=${OFFICIAL_PULSES:-None}
COMMUNITY_PULSES=${COMMUNITY_PULSES:-None}
}

function CSV_LOG_RESULT()
{
  local type="$1"
  local ioc="$2"
  local ai_result="$3"
  local csv_file="ThreatScore_results.csv"
  local timestamp
  local verdict

  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  verdict=$(echo "$ai_result" | awk '
    BEGIN { found=0 }
    /^Verdict:/ { found=1; next }
    found && NF {
      print
      exit
    }
  ' | tr '[:lower:]' '[:upper:]')

  if echo "$verdict" | grep -qi "malicious\|high"; then
    verdict="HIGH"
  elif echo "$verdict" | grep -qi "suspicious\|medium\|moderate"; then
    verdict="MEDIUM"
  elif echo "$verdict" | grep -qi "low"; then
    verdict="LOW"
  elif echo "$verdict" | grep -qi "clean\|benign"; then
    verdict="CLEAN"
  else
    verdict="UNKNOWN"
  fi

  if [ ! -f "$csv_file" ]; then
    echo "Timestamp,Type,IOC,Verdict" > "$csv_file"
  fi

  printf '"%s","%s","%s","%s"\n' "$timestamp" "$type" "$ioc" "$verdict" >> "$csv_file"
}

function GEMINI_OSINT()
{
  local obj="$1"
  local response
  local text
  local queries
  local sources
  local api_error

  response=$(curl -s --max-time 40 \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg obj "$obj" '
    {
      contents: [
        {
          parts: [
            {
              text:
                "Use Google Search grounding to find cybersecurity OSINT for this IOC:\n\n" +
                "\"" + $obj + "\"\n\n" +

                "Look for real-world threat activity:\n" +
                "- phishing or credential theft\n" +
                "- malware delivery or payload staging\n" +
                "- fake CAPTCHA / pastejacking / PowerShell chains\n" +
                "- malicious redirects\n" +
                "- C2 or botnet infrastructure\n" +
                "- brute force / password spraying\n" +
                "- scanning / exposed-service probing\n" +
                "- sandbox analysis findings\n" +
                "- malware family names\n" +
                "- infrastructure role\n" +
                "- security researcher or threat-intel references\n\n" +

                "Rules:\n" +
                "- factual only\n" +
                "- no unsupported speculation\n" +
                "- provide detailed technical OSINT findings\n" +
                "- include malware families, infection chains, infrastructure role, and attacker behavior if grounded evidence exists\n" +
                "- summarize grounded evidence from public sources\n" +
                "- distinguish confirmed evidence from weak correlations\n" +
                "- include relevant sandbox or malware-analysis findings if available\n" +
                "- avoid generic wording\n" +
                "- if no reliable public OSINT exists, state that clearly"
            }
          ]
        }
      ],
      tools: [
        {
          google_search: {}
        }
      ]
    }')")

  api_error=$(echo "$response" | jq -r '.error.message // empty' 2>/dev/null)

  if [ -n "$api_error" ]; then
    echo "Gemini API error: $api_error"
    return
  fi

  text=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // empty' 2>/dev/null)

  queries=$(echo "$response" | jq -r '.candidates[0].groundingMetadata.webSearchQueries[]?' 2>/dev/null)

  sources=$(echo "$response" | jq -r '
    .candidates[0].groundingMetadata.groundingChunks[]?.web.title
  ' 2>/dev/null | sort -u)

  if [ -z "$text" ]; then
    text="No reliable public OSINT found or Gemini returned no text."
  fi

  echo "$text"

  if [ -n "$queries" ]; then
    echo
    echo "Google searches performed:"
    echo "$queries"
  fi

  if [ -n "$sources" ]; then
    echo
    echo "Grounding sources:"
    echo "$sources"
  fi
}

function AI_ANALYZE()
{
  local type="$1"
  local obj="$2"
  local summary="$3"

  case "$type" in
    IP)
      AI_ANALYZE_IP "$obj" "$summary"
      ;;
    URL|DOMAIN|domain)
      AI_ANALYZE_URL_DOMAIN "$type" "$obj" "$summary"
      ;;
    HASH)
      AI_ANALYZE_HASH "$obj" "$summary"
      ;;
    *)
      AI_ANALYZE_GENERIC "$type" "$obj" "$summary"
      ;;
  esac
}

function AI_CALL_OPENAI()
{
  local system_prompt="$1"
  local user_prompt="$2"

  RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg system_prompt "$system_prompt" \
      --arg user_prompt "$user_prompt" '
      {
        model: "gpt-5.5",
        messages: [
          { role: "system", content: $system_prompt },
          { role: "user", content: $user_prompt }
        ]
      }'
    )")

  AI_TEXT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

  if [ "$AI_TEXT" = "null" ] || [ -z "$AI_TEXT" ]; then
    echo "AI analysis failed. Raw error:
$(echo "$RESPONSE" | jq -r '.error.message')"
  else
    echo "$AI_TEXT"
  fi
}

function AI_ANALYZE_IP()
{
  local obj="$1"
  local summary="$2"

  local system_prompt="You are a senior SOC analyst. Analyze IP IOCs as abusive infrastructure. Be direct, operational, and concise."

  local user_prompt="Analyze this IP IOC.

Type: IP
Target: $obj

Collected intelligence:
$summary

Rules:
- final answer must be no longer than about 1800 characters
- no long paragraphs
- no generic wording
- no unsupported speculation
- include infrastructure context only if available
- focus on behavior, not provider/company attribution
- repeated abuse reports, honeypots, scanning, brute force, or probing are strong evidence
- lack of actor attribution must not weaken strong behavioral evidence
- mention community-only OTX only if relevant

Output exactly:

Verdict:
<one line: malicious/suspicious/low risk + operational role>

Infrastructure:
<one line: country, ASN/provider, VPS/cloud/proxy/VPN context if available>

Why:
<1-2 short lines with strongest evidence>

Associated activity:
<1-2 lines: scanning/bruteforce/probing/abuse/etc>

Likely behavior:
<1-2 lines: how the IP is probably used>

Exploit pattern:
<1 line: targeted services/pattern, or no specific exploit>

Threat attribution:
<1 line only>

Action:
<2-3 concise SOC actions>"

  AI_CALL_OPENAI "$system_prompt" "$user_prompt"
}

function AI_ANALYZE_URL_DOMAIN()
{
  local type="$1"
  local obj="$2"
  local summary="$3"

  local system_prompt="You are a senior SOC analyst. Analyze URL/domain IOCs as phishing, malware delivery, redirect, staging, or C2 infrastructure. Be direct, operational, and concise."

  local user_prompt="Analyze this URL/domain IOC.

Type: $type
Target: $obj

Collected intelligence:
$summary

Rules:
- final answer must be no longer than about 1800 characters
- no long paragraphs
- no generic wording
- no unsupported speculation
- include infrastructure context only if available
- focus on operational use: phishing, fake CAPTCHA, pastejacking, malware staging, redirects, credential theft, C2, exfiltration
- include hosting country, ASN/provider, server, suspicious TLD, or disposable infrastructure only when supported
- sandbox/OSINT/VT evidence can outweigh lack of OTX
- include malware family or infection chain only if supported
- avoid repeating the same evidence

Output exactly:

Verdict:
<one line: malicious/suspicious/low risk + operational role>

Infrastructure:
<one line: hosting country, ASN/provider, server/TLD/redirect context if available>

Why:
<1-2 short lines with strongest evidence>

Associated activity:
<1-2 lines: phishing/malware/staging/redirects/etc>

Likely behavior:
<1-2 lines: attacker workflow>

Exploit pattern:
<1 line: phishing/fake CAPTCHA/pastejacking/loader/redirect/no clear exploit>

Threat attribution:
<1 line only>

Action:
<2-3 concise SOC actions>"

  AI_CALL_OPENAI "$system_prompt" "$user_prompt"
}

function AI_ANALYZE_HASH()
{
  local obj="$1"
  local summary="$2"

  local system_prompt="You are a senior malware triage analyst. Analyze file hashes by file behavior, detections, packing, evasion, execution role, and endpoint response. Be direct and concise."

  local user_prompt="Analyze this hash IOC.

Type: HASH
Target: $obj

Collected intelligence:
$summary

Rules:
- final answer must be no longer than about 1800 characters
- no long paragraphs
- no generic wording
- no unsupported speculation
- focus on file role: loader/dropper/trojan/DLL/installer/PUA/unknown
- VT detections, MalwareBazaar, sandbox behavior, packing, anti-debug, suspicious tags, and file traits can support the verdict
- absence from MB/OTX does not make suspicious files benign
- distinguish generic AV labels from confirmed family

Output exactly:

Verdict:
<one line: malicious/suspicious/low risk + file role>

Why:
<1-2 short lines with strongest evidence>

Associated activity:
<1-2 lines: malware/PUA/loader/adware/etc>

Likely behavior:
<1-2 lines: expected file behavior>

Exploit pattern:
<1 line: delivery/execution pattern or no clear exploit>

Threat attribution:
<1 line only>

Action:
<2-3 concise SOC actions>"

  AI_CALL_OPENAI "$system_prompt" "$user_prompt"
}

function AI_ANALYZE_GENERIC()
{
  local type="$1"
  local obj="$2"
  local summary="$3"

  local system_prompt="You are a senior SOC analyst. Be concise and operational."

  local user_prompt="Analyze this IOC.

Type: $type
Target: $obj

Collected intelligence:
$summary

Keep final answer under about 1800 characters.

Output exactly:

Verdict:
Why:
Associated activity:
Likely behavior:
Exploit pattern:
Threat attribution:
Action:"

  AI_CALL_OPENAI "$system_prompt" "$user_prompt"
}
function detect_type()
{
local input="$1"

if [[ "$input" =~ ^https?:// ]]; then
    echo "URL"
elif [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "IP"
elif [[ "$input" == *:* && "$input" =~ ^[0-9a-fA-F:]+$ ]]; then
    echo "IP"
elif [[ "$input" =~ ^[a-fA-F0-9]{32}$ || "$input" =~ ^[a-fA-F0-9]{40}$ || "$input" =~ ^[a-fA-F0-9]{64}$ ]]; then
    echo "HASH"
elif [[ "$input" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "DOMAIN"
else
    echo "UNKNOWN"
fi
}

function process_scan()
{
local obj="$1"
local chat_id="$2"

CURRENT_CHAT_ID="$chat_id"
SUMMARY=""

TYPE=$(detect_type "$obj")

case "$TYPE" in
    IP)
        ip="$obj"
        domain=""
        url=""
        hash=""
        send_telegram "$chat_id" "🌐 Scan received: IP $ip"
        IP
        ;;
    DOMAIN)
        domain="$obj"
        ip=""
        url=""
        hash=""
        send_telegram "$chat_id" "🌍 Scan received: Domain $domain"
        DOMAIN
        ;;
    URL)
        url="$obj"
        ip=""
        domain=""
        hash=""
        send_telegram "$chat_id" "🔗 Scan received: URL $url"
        URL
        ;;
    HASH)
        hash="$obj"
        ip=""
        domain=""
        url=""
        send_telegram "$chat_id" "🧬 Scan received: Hash $hash"
        HASH
        ;;
    *)
        send_telegram "$chat_id" "❌ Unsupported object. Send an IP, domain, URL, MD5, SHA1, or SHA256 hash."
        return
        ;;
esac

send_telegram "$chat_id" "✅ All threat-intel sources complete"
send_telegram "$chat_id" "🌐 Searching external OSINT..."

OSINT=$(GEMINI_OSINT "$obj")

send_telegram "$chat_id" "✅ External OSINT search complete"
send_telegram "$chat_id" "🧠 Sending results to AI for analysis..."

SUMMARY="$SUMMARY

Google OSINT:
$OSINT"

AI_RESULT=$(AI_ANALYZE "$TYPE" "$obj" "$SUMMARY")

CSV_LOG_RESULT "$TYPE" "$obj" "$AI_RESULT"

send_telegram "$chat_id" "🤖 ThreatScore AI Analysis

Type: $TYPE
Target: $obj

$AI_RESULT
"

CURRENT_CHAT_ID=""
}

function listen_telegram()
{
offset=0

echo
echo -e "${GREEN}${BOLD}[*] ThreatScore Telegram listener started${ENDCOLOR}"
echo -e "${CYAN}${BOLD}[*] Send an IP, domain, URL, or hash to your Telegram bot.${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}[*] Press CTRL+C to stop.${ENDCOLOR}"

while true; do
    UPDATES=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?timeout=30&offset=${offset}")

    count=$(echo "$UPDATES" | jq '.result | length' 2>/dev/null)

    if [ "$count" = "0" ] || [ -z "$count" ]; then
        continue
    fi

    while read -r update; do
        update_id=$(echo "$update" | jq -r '.update_id')
        chat_id=$(echo "$update" | jq -r '.message.chat.id // empty')
        text=$(echo "$update" | jq -r '.message.text // empty')

        offset=$((update_id + 1))

        [ -z "$chat_id" ] && continue
        [ -z "$text" ] && continue

        if [ -n "$CHAT_ID" ] && [ "$chat_id" != "$CHAT_ID" ]; then
            send_telegram "$chat_id" "⛔ Unauthorized chat."
            continue
        fi

        process_scan "$text" "$chat_id"

    done < <(echo "$UPDATES" | jq -c '.result[]?')
done
}

APPS
CONF
listen_telegram
