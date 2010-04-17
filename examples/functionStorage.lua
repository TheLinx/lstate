require("state")
-- initialize our data table
data = {}
-- if there is a previous state, load it
st = state.load("functionStorage")
if st then
    -- run the function
    print(st.myFunc())
end
-- store a new value
print("Create a function to be stored: (terminate with EOF character)")
data.myFunc = loadstring("return "..io.read("*all"))()
-- save the table
state.store("functionStorage", data)
