import re
import os
import pandas as pd

def parse_log_file(log_file):
    try:
        with open(log_file, "r") as fh:
            for each_line in fh:
                error = re.search("UVM_ERROR\s*:\s*(\d+)")
                fatal = re.search("UVM_FATAL\s*:\s*(\d+)")

                if error:
                    err_count = int(error.group(1))
                if fatal:
                    fatal_count = int(fatal.group(1))
        if err_count == 0 and fatal_count == 0:
            status = "PASS"
        else:
            status = "FAIL"
        print(f"file: {log_file}, Error_count: {err_count}, Fatal_count: {fatal_count}, Status: {status}")

        return err_count, fatal_count, status
    except Exception as e:
        print(f"Error reading the file {log_file}: {e}")
        return 0, 0, "ERROR"
    
def process_log_directory(log_directory):
    data = []
    for each_file in os.listdir(log_directory):
        file = os.path.join(log_directory, each_file)
        if os.isfile(file):
            err_count, fatal_count, status = parse_log_file(file)
            data.append([each_file, err_count, fatal_count, status])

    return data

def generate_csv_report(log_data, csv_file="log_analysis.csv"):
    df = pd.DataFrame(log_data, columns=["FILE_NAME", "ERROR_COUNT", "FATAL_COUNT", "STATUS"])
    df.to_csv(csv_file, index=False)
    print(f"CSV report generated successfully at : {csv_file}")

def generate_excel_report(log_data, excel_file="log_analysis.xlsx"):
    df = pd.DataFrame(log_data, columns=["FILE_NAME", "ERROR_COUNT", "FATAL_COUNT", "STATUS"])
    df.to_excel(excel_file, index=False)
    print(f"Excel report is generated successfully at : {excel_file}")

LOG_DIR = "/Users/charankumarreddychintha/Documents/Python_scripting/log_analysis_regression_reports/log"
data_log = process_log_directory(LOG_DIR)
generate_csv_report(data_log)
generate_excel_report(data_log)
