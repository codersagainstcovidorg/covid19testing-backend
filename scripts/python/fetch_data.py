#!/usr/bin/env python
import os
import pandas as pd
import requests
import json
import csv
import jq
import time

# Get environment variables
DEST_BASE_DOWNLOADS = os.getenv('DEST_BASE_DOWNLOADS')
DEST_BASE_GISCORPS = os.getenv('DEST_BASE_GISCORPS')
DEST_BASE_USAFACTS = os.getenv('DEST_BASE_USAFACTS')

timestr = time.strftime("%Y-%m-%dT%H%M") # timestr = time.strftime("%Y-%m-%dT%H%M")

# GISCorps CSV (full, from url)
giscorps_raw_csv = {
    "src_name": 'GISCorps CSV (from url)',
    "src_path": 'https://opendata.arcgis.com/datasets/d7d10caf1cec43e0985cc90fbbcf91cb_0.csv',
    "src_path_type": "url",
    "src_format": 'csv',
    
    "dst_path": f'{DEST_BASE_GISCORPS}/Raw/{timestr}_giscorps.csv',
    "dst_path_type": "file",
    "dst_format": 'csv',
    "does_need_proc": False,
    "jqstr": None,
    "melt_params": None
}

# GISCorps JSON (full, from url)
giscorps_raw_json_full = {
    "src_name": 'GISCorps JSON (full, from url)',
    "src_path": 'https://services.arcgis.com/8ZpVMShClf8U8dae/arcgis/rest/services/TestingLocations_public/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json',
    "src_path_type": "url",
    "src_format": 'json',
    
    "dst_path": f'{DEST_BASE_GISCORPS}/Raw/json/{timestr}_giscorps.json',
    "dst_path_type": "file",
    "dst_format": 'json',
    "does_need_proc": False,
    "jqstr": None,
    "melt_params": None
}

# GISCorps JSON (filtered)
giscorps_raw_json_filtered = {
    "src_name": 'GISCorps JSON (filtered)',
    "src_path": 'https://services.arcgis.com/8ZpVMShClf8U8dae/arcgis/rest/services/TestingLocations_public/FeatureServer/0/query?where=1%3D1&outFields=OBJECTID,facilityid,name,fulladdr,municipality,agency,agencytype,phone,agencyurl,operhours,numvehicles,testcapacity,status,CreationDate,EditDate,drive_through,appt_only,referral_required,services_offered_onsite,call_first,virtual_screening,health_dept_url,State,GlobalID,data_source,county,red_flag,start_date,end_date,type_of_test,test_processing,fine_print&outSR=4326&f=json',
    "src_path_type": "url",
    "src_format": 'json',
    
    "dst_path": f'{DEST_BASE_GISCORPS}/Raw/json/{timestr}_giscorps_filtered.json',
    "dst_path_type": "file",
    "dst_format": 'json',
    "does_need_proc": False,
    "jqstr": None,
    "melt_params": None
}

# GISCorps JSONL (filtered) - this makes the line-delimited version
giscorps_proc_json_filtered = {
    "src_name": 'GISCorps JSONL (filtered)',
    "src_path": 'https://services.arcgis.com/8ZpVMShClf8U8dae/arcgis/rest/services/TestingLocations_public/FeatureServer/0/query?where=1%3D1&outFields=OBJECTID,facilityid,name,fulladdr,municipality,agency,agencytype,phone,agencyurl,operhours,numvehicles,testcapacity,status,CreationDate,EditDate,drive_through,appt_only,referral_required,services_offered_onsite,call_first,virtual_screening,health_dept_url,State,GlobalID,data_source,county,red_flag,start_date,end_date,type_of_test,test_processing,fine_print&outSR=4326&f=json',
    "src_path_type": "url",
    # "src_path": f'{DEST_BASE_GISCORPS}/Raw/json/{timestr}_giscorps_filtered.json',
    # "src_path_type": "file",
    "src_format": 'json',

    "dst_path": f'{DEST_BASE_GISCORPS}/proc/{timestr}_giscorps_filtered.jsonl.json',
    "dst_path_type": "file",
    "dst_format": 'jsonl',
    "does_need_proc": True,
    "jqstr": '.features[]',
    "melt_params": None
}

# GISCorps CSV for Big Query (filtered)
giscorps_proc_csv_filtered_bq = {
    "src_name": 'GISCorps CSV for Big Query (filtered)',
    "src_path": 'https://services.arcgis.com/8ZpVMShClf8U8dae/arcgis/rest/services/TestingLocations_public/FeatureServer/0/query?where=1%3D1&outFields=OBJECTID,facilityid,name,fulladdr,municipality,agency,agencytype,phone,agencyurl,operhours,numvehicles,testcapacity,status,CreationDate,EditDate,drive_through,appt_only,referral_required,services_offered_onsite,call_first,virtual_screening,health_dept_url,State,GlobalID,data_source,county,red_flag,start_date,end_date,type_of_test,test_processing,fine_print&outSR=4326&f=json',
    "src_path_type": "url",
    "src_format": 'json',
    "dst_path": f'{DEST_BASE_DOWNLOADS}/giscorps.csv',
    "dst_path_type": "file",
    "dst_format": 'csv',
    "does_need_proc": True,
    "jqstr": '[(.features[] | (.attributes + .geometry) | .["longitude"] = .x | .["latitude"] = .y | del(.x, .y))]',
    "melt_params": None
}

# USAFacts Cases Raw
usafacts_cases_raw_csv = {
    "src_name": 'USAFacts.org Cases Raw',
    "src_path": 'https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv',
    "src_path_type": "url",
    "src_format": 'csv',

    "dst_path": f'{DEST_BASE_USAFACTS}/Cases/Counties/USAFacts/{timestr}covid_confirmed_usafacts.csv',
    "dst_path_type": "file",
    "dst_format": 'csv',
    "does_need_proc": False,
    "jqstr": None,
    "melt_params": None
}

# USAFacts Cases Processed
usafacts_cases_proc_csv = {
    "src_name": 'USAFacts.org Cases Processed',
    "src_path": 'https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv',
    "src_path_type": "url",
    "src_format": 'csv',

    "dst_path": f'{DEST_BASE_DOWNLOADS}/covid_confirmed_usafacts.csv',
    "dst_path_type": "file",
    "dst_format": 'csv',
    "does_need_proc": True,
    "jqstr": None,
    "melt_params": {"id_vars": ['countyFIPS', 'County Name', 'State', 'stateFIPS'], "var_name": 'date', "value_name": 'count_covid_cases'}
}


# [giscorps_raw_csv, giscorps_raw_json_full, giscorps_raw_json_filtered, giscorps_proc_json_filtered, giscorps_proc_csv_filtered_bq]
url_list = [usafacts_cases_proc_csv]


def get_data(src: dict, dst_path_prefix: str = timestr):

  # Assign common/shared variables
  myHeaders = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36',
               'Referer': 'https://codersagainstcovid.org', 'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'}
  
  # Assign source-specific variables
  src_name = src["src_name"]
  src_path = src["src_path"]
  src_path_type = src["src_path_type"]
  src_format = src["src_format"]
  
  dst_path = src["dst_path"]
  dst_path_type = src["dst_path_type"]
  dst_format = src["dst_format"]
  does_need_proc = src["does_need_proc"]
  jqstr = src["jqstr"]
  melt_params = src["melt_params"]
  
  if src_path_type == 'file':
    # Open data if source is file
    with open(src_path, 'rb') as f:
      print(f'Reading `{src_name}` from `{src_path}` ...\n')
      f.read()
  elif src_path_type == 'url':
    print(f'Getting `{src_name}` from `{src_path}` ...\n')
    # Fetch the data
    src_connector = requests.get(src_path, headers=myHeaders)
    src_data = src_connector.content
    dst_data = json.dumps(src_data)
    
    if src_format == 'json':
      # src_data = json.loads(src_connector.content)
      # dst_data = json.dumps(src_data)
      
      # Transform data, if necessary
      if does_need_proc == True:
        dst_data = transform_data(src_name, src_data, src_format, dst_format, jqstr)  # .all()[0:3]
        
      
      # Write the value to its destination
      request_write(dst_data, dst_path, dst_path_type, dst_format, src_format)
      return
    elif src_format == 'csv':
      src_data = src_connector
      dst_data = src_data
        
      # Transform data, if necessary
      if does_need_proc == True:
        dst_data = transform_data(src_name, src_data, src_format, dst_format, jqstr, melt_params)
        # Write the value to its destination
        request_write(dst_data, dst_path, dst_path_type, dst_format,src_format)
      else:
        dst_data = src_data.content
        # Write the value to its destination
        request_write(dst_data, dst_path, dst_path_type, dst_format,src_format)
        
        # print(f'Writing to `{dst_path}` ...\n')
        # open(dst_path, 'wb').write(src_data.content)

        # print(f'SUCCESS | Done writing to `{dst_path}`\n')
        # return
      return
    else:
      print(f'ERROR | Unknown or unrecognized value for `src_path_type`: {src_path_type}')
      return
  # Display error
  else:
    print(f'ERROR | Unknown or unrecognized value for `src_path_type`: {src_path_type}')
    return    


def transform_data(src_name: str, src_data, src_format: str, dst_format: str, jqstr: str, melt_params: dict={}):
  # Transform data from json -> ???
  if src_format == 'json':
    # Re-shaping, converting, filtering, sorting, etc.
    if dst_format == 'csv':
      print(f'Transforming data: `{src_format}` -> `{dst_format}` ...')
      proc_jqstr = (jqstr if (len(jqstr) > 2) else '.') + \
          " | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[]"
          # " | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv"
          
      # Overwrite the variable assignment using the transformed result
      return jq.compile(proc_jqstr).input(src_data)
    
    elif dst_format.startswith('json'):
      print(f'Transforming data: `{src_format}` -> `{dst_format}` ...')
      proc_jqstr = (jqstr if (len(jqstr) > 2) else '.')
      # Overwrite the variable assignment using the transformed result
      return jq.compile(proc_jqstr).input(src_data)
    # Otherwise return the source data unchanged
    else:
      print(f'ERROR | Unknown or unrecognized transformation: `{src_format}` -> `{dst_format}`')
      return src_data
  # Transform data from csv -> ???
  elif src_format == 'csv':
    # Re-shaping, converting, filtering, sorting, etc.
    if dst_format == 'csv':
      if (len(melt_params.items()) > 0):
        id_vars = melt_params["id_vars"]
        var_name = melt_params["var_name"]
        value_name = melt_params["value_name"]
        
        print(f'Transforming data: `{src_format}` -> `{dst_format}` ...')
        # read the normalized data
        # data = urlopen(src_data.raw)
        df = pd.read_csv(src_data.all)

        # melt the normalized file
        le = pd.melt(df, id_vars=id_vars, var_name=var_name,
                    value_name=value_name)
        
        # apply filters
        if (src_name.lower.find('usafacts') != -1):
          le2 = le[~le.date.str.contains("Unnamed")]
          le2 = le2[~le2.countyFIPS != 0]
        else:
          le2 = le
        
        return le2
      else:
        print(f'ERROR | Unknown or unrecognized transformation: `{src_format}` -> `{dst_format}`')
        return src_data
    # Otherwise return the source data unchanged
    else:
      print(f'ERROR | Unknown or unrecognized transformation: `{src_format}` -> `{dst_format}`')
      return src_data
    
  # Otherwise return the source data unchanged
  else:
    print(f'ERROR | Unknown or unrecognized transformation: `{src_format}` -> `{dst_format}`')
    return src_data

def request_write(dst_data, dst_path: str, dst_path_type: str, dst_format: str, src_format: str=None):
  # Write the value to its destination
  if dst_path_type == 'file':      
    if dst_format == 'csv':
      if src_format == 'csv':
        print(f'Writing to `{dst_path}` ...\n')
        open(dst_path, 'wb').write(dst_data)
        print(f'SUCCESS | Done writing to `{dst_path}`\n')
        return
      else:
        print(f'Writing to `{dst_path}` ...\n')
        with open(dst_path, 'w', encoding='utf-8', newline='') as f:
          wr = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
          wr.writerows(dst_data)
        print(f'SUCCESS | Done writing to `{dst_path}`\n')
        return
    elif dst_format == 'json':
      print(f'Writing to `{dst_path}` ...\n')
      open(dst_path, 'w').write(dst_data)
      print(f'SUCCESS | Done writing to `{dst_path}`\n')
      return
    elif dst_format == 'jsonl':
      print(f'Writing to `{dst_path}` ...\n')
      with open(dst_path, 'w', encoding='utf-8', newline='') as f:
        f.writelines(dst_data.text())
      return 'SUCCESS | Done writing to `{dst_path}`\n'
    else:
      print(f'ERROR | Failed writing to `{dst_path}`: destination format `{dst_format}` not recognized\n')
      return
  else:
      print(f'ERROR | Failed writing to `{dst_path}`: destination type `{dst_path_type}` not recognized\n')
      return


for item in url_list:
  get_data(item)
