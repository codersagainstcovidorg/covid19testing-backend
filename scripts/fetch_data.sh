#!/bin/bash -u
# Capture parameters
BASTION_ENVIRONMENT="${1:-"staging"}"; # if parameter is not received, use default
BASTION_PATH="${2:-"/Users/jorge/code/codersagainstcovidorg/infra/scripts/start-tunnel.sh"}";
DESTINATION_BASE="${3:-"/Users/jorge/Downloads/COVID/Data/ProductData/GISCorps"}"; 
ENTITIES_DESTINATION_BASE="${3:-"/Users/jorge/Downloads"}"; 
OBJECT_KEY="${4:-"features"}";
DB_NAME="${5:-"covid"}";



# Global parameters
CURRENT_DATE_TIME=$(date +'%Y-%m-%d_%H%M');

# Get the full CSV
curl --insecure --silent --show-error --location --create-dirs --request GET https://opendata.arcgis.com/datasets/d7d10caf1cec43e0985cc90fbbcf91cb_0.csv --output "${DESTINATION_BASE}/Raw/${CURRENT_DATE_TIME}_giscorps.csv"
  
# Get the full json
curl --insecure --silent --show-error --location --create-dirs --request GET "https://services.arcgis.com/8ZpVMShClf8U8dae/arcgis/rest/services/TestingLocations_public/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json" --output "${DESTINATION_BASE}/Raw/json/${CURRENT_DATE_TIME}_giscorps.json";

# Get the safe json
curl --insecure --silent --show-error --location --create-dirs  --request GET 'https://services.arcgis.com/8ZpVMShClf8U8dae/arcgis/rest/services/TestingLocations_public/FeatureServer/0/query?where=1%3D1&outFields=OBJECTID,facilityid,name,fulladdr,municipality,agency,agencytype,phone,agencyurl,operhours,numvehicles,testcapacity,status,CreationDate,EditDate,drive_through,appt_only,referral_required,services_offered_onsite,call_first,virtual_screening,health_dept_url,State,GlobalID,data_source,county,red_flag,start_date,end_date,type_of_test,test_processing,fine_print&outSR=4326&f=json' --output "${DESTINATION_BASE}/Raw/json/${CURRENT_DATE_TIME}_giscorps_safe.json";

# Use jq to parse the file and convert the result to line-delimited JSON (JSONL)
jq -c ".${OBJECT_KEY}[]" "${DESTINATION_BASE}/Raw/json/${CURRENT_DATE_TIME}_giscorps_safe.json" > "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_safe.jsonl.json"

# Replace escaped characters
sed -i .bak -e 's/\\n/\\\\\n/g; s/\\t/\\\\\t/g; s/\\r/\\\\\r/g; s/\\b//g; s/\\"//g; s/\\\\7/\/7/g;' "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_safe.jsonl.json" && rm "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_safe.jsonl.json.bak"

# Connect to bastion
$(eval "${BASTION_PATH} ${BASTION_ENVIRONMENT}") & \
echo $! > /tmp/my-app.pid &&

max_retry=3
retry=0
sleep 10 # Minimum time for connection to bastion

# make sure pg is ready to accept connections
echo "Waiting for *$BASTION_ENVIRONMENT* postgres"
sleep 5;
while [ ${retry} -lt ${max_retry} ]; do
  if [ pg_isready ]; then
      cat "${DESTINATION_BASE}/proc/${CURRENT_DATE_TIME}_giscorps_safe.jsonl.json" | psql -h localhost -d covid -U covid  -c "COPY data_ingest (data) FROM STDIN WITH (FORMAT text, NULL '');" && \
      psql -h localhost -d covid -U covid  -c "COPY entities TO STDOUT WITH (FORMAT csv, HEADER TRUE, NULL '');" > "${ENTITIES_DESTINATION_BASE}/entities.csv"
      break;
  else
      (( retry = retry + 1 ))
      sleep 3
  fi
done

# Clean up
echo "Terminating process PID $(cat /tmp/my-app.pid)"
kill $(cat /tmp/my-app.pid);
