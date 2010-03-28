require("state")
-- initialize our data table
data = {aVariable = ""}
-- if there is a previous state, load it
local st = state.load("exampleStateProgram")
if st then data = st end
-- print the variable
print("Stored variable: "..data.aVariable)
-- store a new value
io.write("Input a value to be stored: ")
data.aVariable = io.read("*line")
-- save the table
state.store("exampleStateProgram", data)
