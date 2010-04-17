require("state")
-- initialize our data table
data = {["foo"] = "bar", ["hai"] = 8}
table.insert(data, data) -- cyclic reference :o
-- save it
state.store("cyclicReferenceTable", data)
-- delete it
data = nil
-- load it
data = state.load("cyclicReferenceTable")
-- show it
print(state.serializeTable(data))
-- fax, rename it
-- oh wait
