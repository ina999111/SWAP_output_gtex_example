"""
This script creates a summary excel file from the individual (per sample per task) json files from a SWAMP run.
It reads each json file and gets score, time, reaction ids fluxes, and calculates number of reactions.
The dataframe is built from the tasklist and from the list of sample numbers as specified in the route optimisation options.
If not all task-sample combination ran, there will be empty spaces in the dataframe.
"""

import os
import pandas as pd
import json
from pathlib import Path
import time

df_tasklist = pd.read_excel(r"data\SWAP_input\tasklist_test_gtex.xlsx")

df_tasklist_clean = df_tasklist[['ID','DESCRIPTION','SHOULD FAIL']].dropna(how='all') # SOULD FAIL instead of SHOULD FAIL...

list_task_ids = list(df_tasklist_clean.loc[:,'ID'])


folder_results = r"data\SWAP_output"

# as specified in route optimisation options
list_samples = list(range(1,21))


processed_log = Path(r"data\SWAP_output/processed.txt")
already_done = set()
if processed_log.exists():
    with open(processed_log, "r") as f:
        already_done = set(line.strip() for line in f)

with open(r"data\SWAP_output/summary.jsonl", "a") as out_file, open(processed_log, 'a') as log_file:

    start = time.time()
    count = 0

    for task_id in list_task_ids:
        for sample in list_samples:
            name_json_file = f"results_Task_{'%03d' % task_id}_Sample{'%03d' % sample}_irr.json"
            path = os.path.join(folder_results, name_json_file)

            if str(path) in already_done:
                continue
            try:
                with open(path, "r") as file:
                    data = json.load(file)
                    out_file.write(json.dumps(data) + "\n")
                    out_file.flush()
                    log_file.write(str(path) + "\n")
                    log_file.flush()
                    count += 1
            except Exception as e:
                print(f"failed on {path}: {e}")

            elapsed_time = time.time() - start
            pct_done = count / (len(list_task_ids)*len(list_samples)) * 100
            pct_time = elapsed_time / (len(list_task_ids)*len(list_samples) * 0.669201) * 100

            print(f"{count} files ({pct_done:.1f}%) done, {pct_time:.1f} % of estimated time")


results = []
with open(r"data\SWAP_output/summary.jsonl") as file:
    for line in file:
        results.append(json.loads(line))

pd.DataFrame(results).to_csv(r"data\SWAP_output/summary.csv")

