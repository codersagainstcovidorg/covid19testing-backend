#!/bin/bash -u
# Capture parameters
# CURRENT_DATE_TIME="2020-07-06T2136"
CURRENT_DATE_TIME="${1:-"$(date +'%Y-%m-%d_%H%M')"}";
DESTINATION_BASE="${2:-"/Users/jorge/Downloads/COVID/All Data/ProductData/GISCorps"}"; 
ENTITIES_DESTINATION_BASE="${3:-"/Users/jorge/Downloads"}"; 

# Replace escaped characters
sed -i .bak -e 's/\\n/\\\\\n/g; s/\\t/\\\\\t/g; s/\\r/\\\\\r/g; s/\\b//g; s/\\"//g; s/\\\\7/\/7/g;' "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_filtered.jsonl.json" && rm "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_filtered.jsonl.json.bak"

max_retry=3
retry=0
# sleep 10 # Minimum time for connection to bastion

# make sure pg is ready to accept connections
sleep 5;
while [ ${retry} -lt ${max_retry} ]; do
  if [ pg_isready ]; then
      cat "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_filtered.jsonl.json" | psql -h localhost -d covid -U covid  -c "COPY data_ingest (data) FROM STDIN WITH (FORMAT text, NULL '');" -c "COPY entities TO STDOUT WITH (FORMAT csv, HEADER TRUE, NULL '');" > "${ENTITIES_DESTINATION_BASE}/entities.csv" # && \
      break;
  else
      (( retry = retry + 1 ))
      sleep 3
  fi
done
