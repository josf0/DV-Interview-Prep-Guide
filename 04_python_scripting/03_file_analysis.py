# Open the text file in read mode using the 'with' statement.
# This ensures the file will be properly closed after reading.
with open('data.txt', 'r') as file:
    # Read all lines from the file and store them in a list called 'lines'.
    # Each line is a string representing one row from the file.
    lines = file.readlines()

# The first line (lines[0]) contains the header row with column names.
# 'strip()' removes any leading/trailing whitespace or newline characters.
header_line = lines[0].strip()

# 'split()' splits the header line into individual column names.
# By default, split() uses any whitespace (space, tab) as the separator.
columns = header_line.split()

# Find the index (position) of the column named 'id' in the header.
# 'index()' returns the first index where the specified value is found.
id_index = columns.index('id')

# Create an empty list to store the indexes of all columns that start with 'metal_'
metal_indexes = []

# 'enumerate()' allows us to loop through a list and get both the index (i)
# and the value (col_name) at the same time.
for i, col_name in enumerate(columns):
    # Check if the column name starts with the string 'metal_'
    # 'startswith()' returns True if the string starts with the specified prefix.
    if col_name.startswith('metal_'):
        # If it's a metal column, add its index to the list
        metal_indexes.append(i)

# Use a list comprehension to get the names of all 'metal_' columns using their indexes
# and print them.
print("Found metal columns:", [columns[i] for i in metal_indexes])
print()  # Print an empty line for spacing

# Now process each line of data (skip the first line since it's the header)
for line in lines[1:]:
    # Remove any extra whitespace or newline characters from the line
    # and split it into a list of values (just like we did for the header)
    values = line.strip().split()

    # Get the ID value from the row using the index we found earlier
    row_id = values[id_index]

    # Print the ID for this row
    print("ID:", row_id)

    # Loop through all indexes of metal_* columns and print their values
    for i in metal_indexes:
        # Get the name of the metal column (e.g., metal_iron)
        metal_name = columns[i]
        # Get the actual value from the row at the corresponding column index
        metal_value = values[i]
        # Print the metal column name and its value, indented for readability
        print(f"  {metal_name}: {metal_value}")

    # Print an empty line between each row for better formatting
    print()




#Example input file : 
# id metal_iron metal_gold metal_silver temperature
# 1   5.2        0.3        2.1         98.6
# 2   6.0        0.1        2.5         99.1
# 3   5.5        0.0        2.0         97.9


#sample output:

# Found metal columns: ['metal_iron', 'metal_gold', 'metal_silver']

# ID: 1
#   metal_iron: 5.2
#   metal_gold: 0.3
#   metal_silver: 2.1

# ID: 2
#   metal_iron: 6.0
#   metal_gold: 0.1
#   metal_silver: 2.5

# ID: 3
#   metal_iron: 5.5
#   metal_gold: 0.0
#   metal_silver: 2.0