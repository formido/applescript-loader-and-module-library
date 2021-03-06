property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Table : missing value

on __load__(loader)
	set _Table to loader's loadLib("Table")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())


set myTable to _Table's makeTable({{name:"userName", class:string}, {name:"accountNumber", class:integer}})

set t to {{"mary", 3124}, {"bob", 1412}, {"joe", 4753}}

--getting/setting

log myTable's getFieldNames() --> {"userName", "accountNumber"}

myTable's importList(t)

log myTable's getColumn("userName") --> {"mary", "bob", "joe"}
log myTable's getRow(2) --> {"bob", 1412}

myTable's setCell(2, "accountNumber", 2673)
log myTable's getCell(2, "accountNumber") --> 2673

log myTable's addRow({"jan", 9893}) --> 4


--sorting/filtering

property sortNames : {fieldName:"userName", reverseOrder:false, groupResults:false}

script getAccountsOver3000
	property fieldName : "accountNumber"
	on eval(cellValue)
		cellValue > 3000
	end eval
end script

log myTable's filterRows("*", {getAccountsOver3000}) --> {1, 3, 4}
log myTable's sortRows({1, 3, 4}, {sortNames}) --> {4, 3, 1}

-- get names of users after filtering and sorting

repeat with eachID in {4, 3, 1}
	log myTable's getCell(eachID, "userName")
end repeat
--> "jan"
--> "joe"
--> "mary"