import re

with open("/Users/charankumarreddychintha/Documents/Python_scripting/log_analysis_regression_reports/log/simv3.log", "r") as fh:
    log_content = fh.read() #read entire content as a string instead of object. you can also use line by line
    error = re.search("UVM_ERROR\s*:\s*(\d+)", log_content)
    fatal = re.search("UVM_FATAL\s*:\s*(\d+)", log_content)

    if error: 
        err_count = int(error.group(1))
        print("Error Count:", err_count)
    if fatal:
        fatal_count = int(fatal.group(1))
        print("Fatal Count: ", fatal_count)

#condition for failure detection
if err_count > 0 or fatal_count > 0:
    print("Test Failed")
else:
    print("Test Passed")

