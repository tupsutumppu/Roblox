-- // Autofarm made by #tupsutumppu ( made in mid 2023 )
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local FoodClerk = game:GetService("Workspace").WorkEnvironments["Nomburger_Food Clerk"]
local NPCFolder = FoodClerk.NPCs
local PathfindingService = game:GetService("PathfindingService")

local servecustomer = function(customer, orderlist)
   if customer and orderlist then
       local orderTable = {}
       for i = 1, #orderlist do
           orderTable[i] = tostring(orderlist[i])
       end
       local arguments = {[1] = customer, [2] = orderTable}
       ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Jobs"):WaitForChild("Food Clerk"):WaitForChild("Relays"):WaitForChild("TryOrder"):InvokeServer(unpack(arguments))
   end
end

local ClaimCustomer = function(customer)
   local FunctionalValues = customer:WaitForChild("FunctionalValues")
   repeat task.wait() until FunctionalValues:WaitForChild("CanOrder") and FunctionalValues.CanOrder.Value == true
   task.wait()
   ReplicatedStorage.Relays.Work.JobInteract:Fire("ClaimCustomer", customer)
end

for _,v in pairs(getgc()) do
   if type(v) == "function" and debug.getinfo(v).name == "SetupNPC" then
       local old; old = hookfunction(v, function(...)
           local args = {...}
           servecustomer(args[1], args[2])
           return old(...)
       end)
   end
end

NPCFolder.ChildAdded:Connect(function(NPC)
   ClaimCustomer(NPC)
end)

for _, NPC in pairs(NPCFolder:GetChildren()) do
  ClaimCustomer(NPC)
end
