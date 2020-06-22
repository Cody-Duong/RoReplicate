local RoReplicateUtility = require(script.Parent.RoReplicateUtility)
local Section = require(script.Parent.Section)


RoReplicateBaseClass = {}
RoReplicateBaseClass.__index = RoReplicateBaseClass


--[[ 
- Creates a new RoReplicateBaseClass.
- @param pluginName - string
- @param pluginInfo - DockWidgetPluginGuiInfo
- @return self - RoReplicateBaseClass
--]]
function RoReplicateBaseClass.new(pluginName, pluginInfo)
	assert(type(pluginName)=="string", "RoReplicateBase.new - Parameter 1 is not a string")
	assert(getmetatable(pluginInfo)==getmetatable(DockWidgetPluginGuiInfo.new()), "RoReplicateBase.new - Parameter 2 is not a DockWidgetPluginGuiInfo")
	
	local self = {}
	setmetatable(self, RoReplicateBaseClass)
	
	local frame = Instance.new("Frame")
	RoReplicateUtility:SyncBackgroundColor3(frame)
	frame.Size = UDim2.new(1,0,1,0)
	--frame. I have no idea where this mutilated code came from. todo fix?
	self._frame = frame
	
	local arraySect = {}
	self._sections = arraySect
	
	self._pluginName = pluginName
	self._tempPluginInfo = pluginInfo
	
	self._sizeMin = UDim2.new(0,0,0,0)
	self._sizeMax = UDim2.new(0,0,0,0)
	
	local topFrame = Instance.new("Frame", frame)
	topFrame.Size = UDim2.new(1,0,0,23)
	topFrame.Position = UDim2.new(0,0,0,0)
	topFrame.BorderSizePixel = 1
	RoReplicateUtility:SyncBorderColor3(topFrame)
	RoReplicateUtility:SyncTitlebar(topFrame)
	
	--TODO topFrame uiListLayout
	
	local sectionFrame = Instance.new("Frame", frame)
	sectionFrame.Size = UDim2.new(1,0,0,99)
	sectionFrame.Position = UDim2.new(0,0,0,23)
	sectionFrame.BackgroundTransparency = .5
	sectionFrame.ZIndex = 0
	self._sectionFrame = sectionFrame
	
	
	local uiListLayout = Instance.new("UIListLayout", sectionFrame)
	uiListLayout.Padding = UDim.new(0,0)
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	
	return self
end


--[[
- Adds section(s) to the RoReplicateBaseClass.
- @param ... - Section Class(es)
--]]
function RoReplicateBaseClass:AddSections(...)
	local arg = {...}
	for i=1, #arg do
		assert(getmetatable(arg[i])==getmetatable(Section.new("","")), "RoReplicateBaseClass:AddSection - Parameter "..i.." is not a SectionClass")
		arg[i]:GetFrame().Parent = self._sectionFrame
		if not pcall(function()
				self._sections = table.insert(self._sections, #self._sections+1, arg[i])
			end)
		then
			local arraySect = {arg[i]}
			self._sections = arraySect
		end
	end
end


--[[
- Removes section(s) to the RoReplicateBaseClass.
- @parma ... - Section Class(es)
--]]
function RoReplicateBaseClass:RemoveSections(...)
	local arg = {...}
	for i=1, #arg do
		assert(getmetatable(arg[i])==getmetatable(Section.new("","")), "RoReplicateBaseClass:AddSection - Parameter "..i.." is not a SectionClass")
		arg[i]:GetFrame().Parent = nil
		if not pcall(function()
				self._sections = table.remove(self._sections, table.find(self._sections, arg[i]))
			end)
		then
			local arraySect = {}
			self._sections = arraySect
		end
	end
end 


--[[
- This method is executed last, it returns the plugin for the user to run.
- Due to some complications with how plugins are handled, it is required to pass the info back, and they run it themselves.
- Unfortunately, plugin is not a recognized enumerator outside of a plugin class
- @return tuple - string, DockWidgetPluginGuiInfo.new()
]]
function RoReplicateBaseClass:ReturnPlugin()
	self:_UpdateSize()
	
	local dWPGI = DockWidgetPluginGuiInfo.new(
		self._tempPluginInfo.InitialDockState,
	  	self._tempPluginInfo.InitialEnabled,
		self._tempPluginInfo.InitialEnabledShouldOverrideRestore,
		self._sizeMin.X.Offset,
		self._sizeMin.Y.Offset, 
		self._sizeMin.X.Offset,
		self._sizeMin.Y.Offset
	)
	
	return self._pluginName, dWPGI
end


--[[
- This method properly initializes everything afterwards (all it does it parent all the parts of the plugin back onto itself)
- @actualP = plugin:CreateDockWidgetPluginGui
--]]
function RoReplicateBaseClass:PluginRun(actualP)
	self._frame.Parent = actualP
end


--[[
- Internal use
--]]
function RoReplicateBaseClass:_UpdateSize()
	local total = 0 --TODO
	
	local _x = 0 --#of sections * amount of widgets in each + divider size
	local TEMP = 1 --TODO <- remove this ugly thing
	
	self._sizeMin = UDim2.new(TEMP, _x, 0, 122) --height is 96-100 pixels at 1920x1080, will have to recalculate for other displays
	
	self._sizeDef = UDim2.new(TEMP, _x, 0, 122)
end


return RoReplicateBaseClass
