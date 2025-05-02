import re
import os
import pandas as pd

def parse_log_file(log_file_path):
    err_count = 0
    fatal_count = 0
    try: 
        with open(log_file_path, "r") as fh:
            for file in fh:
                error = re.search("UVM_ERROR\s*:\s*(\d+)", file)
                fatal = re.search("UVM_FATAL\s*:\s*(\d+)", file)
            
                if error:
                    err_count = int(error.group(1))
                if fatal:
                    fatal_count = int(fatal.group(1))
        
        if err_count == 0 and fatal_count == 0:
            status = "PASS"
        else:
            status = "FAIL"
        print(f"parsed: {log_file_path}, Error: {err_count}, Fatal: {fatal_count}, status: {status}")
        return err_count, fatal_count, status
    except Exception as e:
        print(f"Error reading {log_file_path}: {e}")
        return 0, 0, "ERROR"

def generate_csv_report(log_directory, csv_file="log_analysis.csv"):
    data = []

    for each_file in os.listdir(log_directory):  # iterate through the log directory
        file = os.path.join(log_directory, each_file)  # absolute file path

        if os.path.isfile(file):  # check if it is a file not a dir
            err_count, fatal_count, status = parse_log_file(file)
            data.append([each_file, err_count, fatal_count, status])

    df = pd.DataFrame(data, columns=["FILE_NAME", "ERROR_COUNT", "FATAL_COUNT", "STATUS"])
    df.to_csv(csv_file, index=False)

    print(f"CSV report generated successfully at: {csv_file}")
    return data

def generate_excel_report(log_data, excel_file = "log_analysis.xlsx"):
    df = pd.DataFrame(log_data, columns=["FILE_NAME", "ERROR_COUNT", "FATAL_COUNT", "STATUS"])
    df.to_excel(excel_file, index=False)

    print(f"Excel report is generated: {excel_file}")


LOG_DIR = "/Users/charankumarreddychintha/Documents/Python_scripting/log_analysis_regression_reports/log"
data = generate_csv_report(LOG_DIR)
generate_excel_report(data)
