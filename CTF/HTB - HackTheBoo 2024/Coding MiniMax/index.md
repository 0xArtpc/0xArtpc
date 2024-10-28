# Coding MiniMax

Python code

```bash
# Read the entire line of input as a string
input_string = input()

# Split the input string into a list of strings
numbers_str = input_string.split()

# Convert each string in the list to a float
l = [float(num) for num in numbers_str]

# Find the lowest and highest numbers
lowest_number = min(l)
highest_number = max(l)

# Print the results without parentheses
print(lowest_number)
print(highest_number)
```
