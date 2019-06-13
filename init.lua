minetest.register_craftitem("superpick:setter", {
	description = "Super Setter",
	inventory_image = "default_tool_steelpick.png^default_obsidian_shard.png",
	groups = {not_in_creative_inventory = 1},
	on_use = function(_, user, pointed_thing)
		if not minetest.check_player_privs(user, "superpick") then
			return {name = "default:pick_steel"}
		end

		local alt = false
		if user:get_player_control().sneak then
			alt = true
		end

		local p = pointed_thing.under
		local n = minetest.get_node(p)
		--if not minetest.registered_nodes[n.name] then
			minetest.remove_node(p)
			if not alt then
				minetest.check_for_falling(p)
			end
		--end
	end,
})

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

local function kill_node(pos, _, puncher)
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
		minetest.check_for_falling(pos)
	end
end

minetest.register_on_mods_loaded(function()
	for node in pairs(minetest.registered_nodes) do
		local def = minetest.registered_nodes[node]
		for i in pairs(def) do
			if i == "on_punch" then
				local rem = def.on_punch
				local function new_on_punch(pos, new_node, puncher, pointed_thing)
					kill_node(pos, new_node, puncher)
					return rem(pos, new_node, puncher, pointed_thing)
				end
				minetest.override_item(node, {
					on_punch = new_on_punch
				})
			end
		end
	end
end)
