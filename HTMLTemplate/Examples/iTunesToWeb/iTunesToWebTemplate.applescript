(* Template object; generated by XTemplate library. Do not edit. *)--------- Loader compatibilityproperty __name__ : ""property __version__ : ""property __lv__ : 1.0--property ___controllerName : ""property ___autoLoad : false--on __load__(loader)	if ___autoLoad then installController(loader's loadComponent(___controllerName))end __load__-------property class : "Template"property parent : _makeNodeElements(missing value, objectName, {}, contentList, nullTxt)--property ___userInfo : {}property _XTemplateVersion : XTemplateVersionproperty _nullTxt : nullTxt -- used to concatenate list to string/Unicode text -- (note: 'lst as Unicode text' appears to be buggy in some or all versions of AS)-------on __getSelf()	return meend __getSelf--on ___render()	if __renderMe() then		return {__content()'s renderContent(), __renderElements()}	else		return _nullTxt	end ifend ___render-------on userInfo()	return ___userInfoend userInfo--on templateVersion()	return _XTemplateVersionend templateVersion-------on installController(ctrlScript)	script controllerInstaller -- visitor object		property _controllerScript : ctrlScript		--		on startNode(xo)			xo's ___setCtrlScript(a reference to _controllerScript)		end startNode		--		on endNode(xo)		end endNode	end script	___traverse(controllerInstaller)	returnend installController-------on renderTemplate(params)	try		copy me to templateCopy		templateCopy's ___callCtrlScript(params, missing value)		set oldTID to AppleScript's text item delimiters		set AppleScript's text item delimiters to _nullTxt		set txt to _nullTxt & templateCopy's ___render() -- thuggish concatenation		set AppleScript's text item delimiters to oldTID		return txt	on error eMsg number eNum		error "Couldn't renderTemplate: " & eMsg number eNum	end tryend renderTemplate