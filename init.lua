minetest.register_tool("superpick:pick", {
	description = "Super Pickaxe",
	inventory_image = "default_tool_mesepick.png^default_obsidian_shard.png",
	range = 11,
	groups = {not_in_creative_inventory = 1},
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level = 3,
		groupcaps = {
			unbreakable =   {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			dig_immediate = {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			fleshy =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			choppy =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			bendy =		{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			cracky =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			crumbly =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			snappy =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3}
		},
		damage_groups = {fleshy = 1000}
	}
})

minetest.register_privilege("superpick", {description = "Ability to wield the mighty admin pickaxe!"})

local function kill_node(pos, node, puncher)
	if puncher:get_wielded_item():get_name() == "superpick:pick" then
		if not minetest.check_player_privs(
				puncher:get_player_name(), {superpick = true}) then
			puncher:set_wielded_item("")
			minetest.log("action", puncher:get_player_name() ..
			" tried to use a Super Pickaxe!")
			return
		end

		local nn = minetest.get_node(pos).name
		if nn == "air" then return end
		minetest.log("action", puncher:get_player_name() ..
			" digs " .. nn ..
			" at " .. minetest.pos_to_string(pos) ..
			" using a Super Pickaxe!")
		local node_drops = minetest.get_node_drops(nn, "superpick:pick")
		for i=1, #node_drops do
			local add_node = puncher:get_inventory():add_item("main", node_drops[i])
			if add_node then minetest.add_item(pos, add_node) end
		end
		minetest.remove_node(pos)
		nodeupdate(pos)
	end
end

minetest.register_on_punchnode(function(pos, node, puncher)
	kill_node(pos, node, puncher)
end)

	minetest.after(0.01, function ()
		minetest.after(0.01, function ()
for node in pairs(minetest.registered_nodes) do
	local def = minetest.registered_nodes[node]
	for i in pairs(def) do
		if i == "on_punch" then

local rem = def.on_punch
local function new_on_punch(pos, node, puncher, pointed_thing)
	kill_node(pos, node, puncher)
	return rem(pos, node, puncher, pointed_thing)
end

minetest.override_item(node, {
	on_punch = new_on_punch
})
		end
	end
end
		end)
	end)

print("hi")  -- This doesn't print.
