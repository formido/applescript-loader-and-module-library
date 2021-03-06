property __name__ : "Table"
property __version__ : "0.4.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property __ColumnClasses : missing value
property __Sort : missing value
property __Filter : missing value
property __FieldNamesConstructor : missing value

on __load__(loader)
	tell loader
		set __Filter to loadComponent("Filter")
		set __ColumnClasses to loadComponent("ColumnClasses")
		set __Sort to loadComponent("Sort")
		set __FieldNamesConstructor to loadComponent("FieldNamesConstructor")
	end tell
end __load__

----------------------------------------------------------------------
--mark -
--mark constructors<B

on newRowIndexServices()
	script --rowIndexServices
		property _rowIDList : {} -- an index in this list contains the unique rowID for that item
		property _rowIDToIndexConversionList : {} -- a unique row ID --> an index in this list; the value stored there is the actual row index
		--
		property _rowIndicesList : {} -- list of indices {1,2,3,...}; feed a copy of this into matchRow's rowIndices when searching all records
		-------
		--row lookups
		on getAllRowIDs()
			return items of _rowIDList
		end getAllRowIDs
		--
		on getAllRowIndices()
			return items of _rowIndicesList
		end getAllRowIndices
		--
		on countRows()
			return count _rowIndicesList
		end countRows
		--
		on doesRowExist(rowID)
			return _rowIDList contains rowID
		end doesRowExist
		-------
		on rowIDToIndex(rowID) -- get a row's index based on its unique ID
			set rowIndex to _rowIDToIndexConversionList's item rowID
			if rowIndex is missing value then error "Row ID " & rowID & " doesn't exist."
			return rowIndex
		end rowIDToIndex
		--
		on rowIndexToID(rowIndex) -- get a row's unique ID for based on its index
			return _rowIDList's item rowIndex --TO DO: will this require out-of-bounds error trapping?
		end rowIndexToID
		-------
		on convertRowIDsToRowIndices(rowIDsList)
			set newList to {}
			repeat with eachRowID in rowIDsList
				set newList's end to rowIDToIndex(eachRowID's contents)
			end repeat
			return newList
		end convertRowIDsToRowIndices
		--
		on convertRowIndicesToRowIDs(rowIndicesList)
			set newList to {}
			repeat with eachRowIndex in rowIndicesList
				set newList's end to rowIndexToID(eachRowIndex's contents)
			end repeat
			return newList
		end convertRowIndicesToRowIDs
		
		on recursiveRowIndicesToRowIDs(rowIndicesList)
			set newList to {}
			repeat with eachRowIndex in rowIndicesList
				if eachRowIndex's contents's class is list then
					set newList's end to recursiveRowIndicesToRowIDs(eachRowIndex's contents)
				else
					set newList's end to rowIndexToID(eachRowIndex's contents)
				end if
			end repeat
			return newList
		end recursiveRowIndicesToRowIDs
		
		----------------------------
		----------------------------
		
		on __addIndexForRow()
			set _rowIDList's end to (count _rowIDToIndexConversionList) + 1
			set _rowIDToIndexConversionList's end to count _rowIDList -- (pinch a suitable value from a non-obvious source)
			set _rowIndicesList's end to (count _rowIndicesList) + 1
			--
			return _rowIDList's last item
		end __addIndexForRow
		--
		on __deleteIndexForRow(rowIndex, rowID)
			set _rowIDList's item rowIndex to missing value
			set _rowIDList to _rowIDList's integers
			--
			--disable the deleted rowID and reduce all subsequent rowID values by 1
			set _rowIDToIndexConversionList's item rowID to missing value
			repeat with x from rowID to count _rowIDToIndexConversionList
				_rowIDToIndexConversionList's item x
				if result's class is integer then set _rowIDToIndexConversionList's item x to result - 1
			end repeat
			--
			try
				set _rowIndicesList to _rowIndicesList's items 1 thru -2
			on error number -1728
				set _rowIndicesList to {}
			end try
			return
		end __deleteIndexForRow
	end script
end newRowIndexServices

----------------------------------------------------------------------

on newBaseObj()
	script
		on __getRowAsString(rowIndex, convertTabsTo, convertReturnsTo, rowList) -- (for export table as string)
			return rowList as string
		end __getRowAsString
		-------
		on getRow(rowIndex, rowList)
			return rowList
		end getRow
		--
		on setRow(rowIndex, rowList)
			return
		end setRow
		--
		on __importTextRow(rowString)
			return
		end __importTextRow
		--
		on addRow(rowList)
			return
		end addRow
		--
		on deleteRow(rowIndex, rowID)
			return
		end deleteRow
	end script
end newBaseObj

-------

on newColumnObj(nextColumnObj, fieldName, fieldIndex, columnClass)
	script
		property _nextColumnObj : nextColumnObj
		--
		property _fieldName : fieldName
		property _fieldIndex : fieldIndex
		property _realVal : {}
		property _val : a reference to _realVal -- gives some speed improvement when getting values
		property _classObj : __ColumnClasses's getClassObj(columnClass)
		----------------------------
		--tableImport
		on __importTextRow(rowString)
			set _realVal's end to _classObj's coerceItem(rowString's text item _fieldIndex)
			_nextColumnObj's __importTextRow(rowString)
		end __importTextRow
		----------------------------
		--used by tableExport
		on _quickFindAndReplace(theString, fromString, toString)
			set tempList to theString's text items --(note: potential stack overflow, but very unlikely in practice so no error handling provided)
			set AppleScript's text item delimiters to toString
			set theString to tempList as string
			set AppleScript's text item delimiters to fromString
			theString
		end _quickFindAndReplace
		
		on __getRowAsString(rowIndex, convertTabsTo, convertReturnsTo, rowList)
			set valAsString to _classObj's coerceToString(_realVal's item rowIndex)
			if valAsString contains tab then set valAsString to _quickFindAndReplace(valAsString, tab, convertTabsTo)
			if valAsString contains return then set valAsString to _quickFindAndReplace(valAsString, return, convertReturnsTo)
			set rowList's end to valAsString
			_nextColumnObj's __getRowAsString(rowIndex, convertTabsTo, convertReturnsTo, rowList)
		end __getRowAsString
		----------------------------
		--row manipulations
		on addRow(rowList)
			set newvalue to rowList's item _fieldIndex
			tell _classObj to classCheck(newvalue, _fieldName)
			set _realVal's end to newvalue
			_nextColumnObj's addRow(rowList)
		end addRow
		--
		on deleteRow(rowIndex, rowID)
			set _val's item rowIndex to missing value
			tell _classObj to set _realVal to classDelete(_realVal)
			_nextColumnObj's deleteRow(rowIndex, rowID)
		end deleteRow
		-------
		on getRow(rowIndex, rowList)
			set rowList's end to _val's item rowIndex
			_nextColumnObj's getRow(rowIndex, rowList)
		end getRow
		--
		on setRow(rowIndex, rowList)
			set _val's item rowIndex to rowList's item _fieldIndex
			_nextColumnObj's setRow(rowIndex, rowList)
		end setRow
		----------------------------
		--column manipulations
		on getColumn()
			return _realVal
		end getColumn
		--
		on setColumn(columnList)
			if (count columnList) is not (count _realVal) then error "Incorrect number of rows."
			set _realVal to columnList
		end setColumn
		----------------------------
		--field manipulations
		on getCell(rowIndex)
			return _val's item rowIndex
		end getCell
		--
		on setCell(rowIndex, newvalue)
			tell _classObj to classCheck(newvalue, _fieldName)
			set _val's item rowIndex to newvalue
		end setCell
	end script
end newColumnObj

-------

on newTopObj(topColumnObj, rowIndexServicesObj, fieldNameList, columnObjList)
	script Table
		property parent : rowIndexServicesObj
		property _dbSortModule : __Sort
		property _dbFilterModule : __Filter
		property _topColumnObj : topColumnObj
		property class : "Table"
		property _fieldNameList : fieldNameList
		--
		property _fieldNamesObj : __FieldNamesConstructor's newFieldNamesObj(fieldNameList's reverse)
		property _columnObjList : columnObjList
		--
		on getFieldNames()
			_fieldNameList
		end getFieldNames
		--
		on countColumns()
			count _fieldNameList
		end countColumns
		----------------------------
		--table import
		on importText(tableString) -- (tab-delim only)
			if tableString's class is not string then error "Not a (text) table."
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to return
			repeat with n from 1 to count tableString's text items
				set rowString to tableString's text item n
				set AppleScript's text item delimiters to tab
				if (count rowString's text items) is not countColumns() then
					if rowString is not "" then error "Row " & n & "has incorrect number of columns." -- skip empty rows
				else
					_topColumnObj's __importTextRow(rowString)
					__addIndexForRow()
				end if
				set AppleScript's text item delimiters to return
			end repeat
			set AppleScript's text item delimiters to oldTID
			return
		end importText
		--
		on importList(tableList)
			if tableList's class is not list then error "Not a (list) table."
			set expectedColumnCount to countColumns()
			repeat with n from 1 to count tableList
				set theRow to tableList's item n
				if theRow's class is not list then
					error "Not a (sub)list."
				else if (count theRow) is not expectedColumnCount then
					error "Sublist " & n & " has incorrect number of items."
				else
					addRow(theRow)
				end if
			end repeat
			return
		end importList
		----------------------------
		--table export
		on exportText(convertTabsTo, convertReturnsTo)
			if (convertTabsTo contains return) or (convertTabsTo contains tab) then error "Bad convertTabsTo parameter (contains return/tab characters)."
			if (convertReturnsTo contains return) or (convertReturnsTo contains tab) then error "Bad convertReturnsTo parameter (contains return/tab characters)."
			--
			set tableList to {}
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to tab
			repeat with rowIndex from 1 to countRows()
				set tableList's end to _topColumnObj's __getRowAsString(rowIndex, convertTabsTo, convertReturnsTo, {})
			end repeat
			set AppleScript's text item delimiters to return
			set tableString to tableList as string
			set AppleScript's text item delimiters to oldTID
			return tableString
		end exportText
		--
		on exportList()
			set tableList to {}
			repeat with x from 1 to countRows()
				_topColumnObj's getRow(x, {})
				set tableList's end to result
			end repeat
			return tableList
		end exportList
		----------------------------
		--row manipulations
		on addRow(rowList)
			if countColumns() is not (count rowList) then error "List is wrong length."
			_topColumnObj's addRow(rowList)
			__addIndexForRow()
			return result
		end addRow
		--
		on deleteRow(rowID)
			set rowIndex to rowIDToIndex(rowID)
			_topColumnObj's deleteRow(rowIndex, rowID)
			__deleteIndexForRow(rowIndex, rowID)
			return
		end deleteRow
		-------
		on getRow(rowID)
			rowIDToIndex(rowID)
			_topColumnObj's getRow(result, {})
		end getRow
		--
		on setRow(rowID, rowList)
			if countColumns() is not (count rowList) then error "List is wrong length."
			rowIDToIndex(rowID)
			_topColumnObj's setRow(result, rowList)
		end setRow
		----------------------------
		--column manipulations
		on getColumn(fieldName)
			tell _columnObjList's item (_fieldNamesObj's getIndex(fieldName)) to getColumn()
		end getColumn
		--
		on setColumn(fieldName, columnList)
			tell _columnObjList's item (_fieldNamesObj's getIndex(fieldName)) to setColumn(columnList)
		end setColumn
		----------------------------
		--field manipulations
		on getCell(rowID, fieldName)
			set rowIndex to rowIDToIndex(rowID)
			tell _columnObjList's item (_fieldNamesObj's getIndex(fieldName)) to getCell(rowIndex)
		end getCell
		--
		on setCell(rowID, fieldName, newvalue)
			set rowIndex to rowIDToIndex(rowID)
			tell _columnObjList's item (_fieldNamesObj's getIndex(fieldName)) to setCell(rowIndex, newvalue)
		end setCell
		----------------------------
		--FILTER/SORT
		on _getRows(rowIDs)
			if rowIDs's class is list then --(must be a list of rowIDs)
				convertRowIDsToRowIndices(rowIDs)
			else --(if anything else, get all rows)
				getAllRowIndices()
			end if
		end _getRows
		-------
		on filterRows(rowIDs, filterRequestsList)
			_getRows(rowIDs)
			tell _dbFilterModule to filterRows(me, result, filterRequestsList)
			convertRowIndicesToRowIDs(result)
		end filterRows
		--
		on sortRows(rowIDs, sortRequestsList)
			_getRows(rowIDs)
			tell _dbSortModule to sortRows(me, result, sortRequestsList)
			recursiveRowIndicesToRowIDs(result)
		end sortRows
		--
		on filterAndSortRows(rowIDs, filterRequestsList, sortRequestsList)
			_getRows(rowIDs)
			tell _dbFilterModule to filterRows(me, result, filterRequestsList)
			tell _dbSortModule to sortRows(me, result, sortRequestsList)
			recursiveRowIndicesToRowIDs(result)
		end filterAndSortRows
		----------------------------
	end script
	return Table
end newTopObj

----------------------------

property linefeed : ASCII character 10

----------------------------
----------------------------
--mark - 
--mark public constructor<B

--paramList is a list of records of form {name:..., class:...}
on makeTable(paramList)
	set theObj to newBaseObj()
	set fieldNameList to {}
	set columnObjList to {}
	considering case, diacriticals, expansion, hyphens, punctuation and white space
		repeat with fieldNumber from (count paramList) to 1 by -1
			set fieldName to paramList's item fieldNumber's name
			if fieldName's class is not string then
				error "Field name must be a string"
			else if fieldName contains linefeed or fieldName contains return then
				error "Illegal return/linefeed characters found in fieldName: " & fieldName
			else if fieldName is in fieldNameList then
				error "Duplicate fieldName: " & fieldName
			end if
			set fieldNameList's beginning to fieldName
			set theObj to newColumnObj(theObj, fieldName, fieldNumber, (paramList's item fieldNumber & {class:string})'s class)
			set columnObjList's end to result
		end repeat
	end considering
	return newTopObj(theObj, newRowIndexServices(), fieldNameList, columnObjList)
end makeTable
