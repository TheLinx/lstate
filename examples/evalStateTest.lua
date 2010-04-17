require("state")
-- initialize our data table
data = {}
-- if there is a previous state, load it
local st = state.load("exampleEvalStateProgram")
if st then data = st end
-- print the variable
print("Stored table: "..state.serializetable(data))
-- store a new value
print("Input a table to be stored:")
data = assert(loadstring("return ("..io.read("*line")..")"))()
-- save the table
state.store("exampleEvalStateProgram", data)
