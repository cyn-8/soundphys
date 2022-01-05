# soundphys module

<br>

this is a module i made with the aim of improving the way sounds behave in roblox

it contains 5 features:

<ol>
<li><b>autodetection</b>: sounds can be automatically added to the script</li>
<li><b>obstruction</b>: sounds can be "obstructed" and dampened by baseparts (terrain may work as well, but it is untested)</li>
<li><b>water areas</b>: using baseparts as hitboxes, sounds that enter a water area will be dampened; if the camera enters, all sounds will be dampened</li>
<li><b>reverb areas</b>: also using baseparts as hitboxes, sounds that enter a reverb area will inherit the reverb values associated with it</li>
<li><b>distance falloff</b>: sounds can be dampened over distance rather than just fading out</li>
</ol>

<br>
<br>

[devforum post]()

[roblox asset](https://www.roblox.com/library/8371117554)

<br>

---

<br>

## things to remember

* localscript should be placed in starterplayerscripts to work as intended
* sounds cannot be added if they are not parented to a basepart or attachment
* starts to lag at about 5000 raycasts per second (# of active sounds × refresh rate)
  * sounds are not "active" when past max distance or when not playing

<br>

---

<br>

## settings

<br>

<h3>options</h3>

<code>refresh_rate</code>
<ul>
<li>how many times per second values will update internally (raycasts, area detection)</li>
<li>actual values are lerped every frame</li>
<li>default: <code>30</code></li>
</ul>

<code>ignore_player_sounds</code>
<ul>
<li>whether player sounds should be considered in autodetection or not</li>
<li>default: <code>false</code></li>
</ul>

<code>reverse_raycast</code>
<ul>
<li>direction of the sound obstruction raycasts</li>
<li>default: <code>false</code> (camera to sound)</li>
</ul>

<code>ignore_players</code>
<ul>
<li>whether the players' characters should be able to obstruct sound or not</li>
<li>default: <code>true</code></li>
</ul>

<code>ignore_materials</code>
<ul>
<li>whether the material of an obstructing basepart should be considered or not</li>
<li>default: <code>true</code></li>
</ul>

<code>min_size</code>
<ul>
<li>the minimum size in studs a basepart must be on each axis to obstruct sound</li>
<li>default: <code>1</code></li>
</ul>

<code>max_transparency</code>
<ul>
<li>the highest transparency value a basepart can have to obstruct sound</li>
<li>default: <code>0</code></li>
</ul>

<br>
<br>

<h3>enabled</h3>

whether each feature should be enabled or not

<ol>
<li><b>autodetection</b></li>
<li><b>obstruction</b></li>
<li><b>water areas</b></li>
<li><b>reverb areas</b></li>
<li><b>distance falloff</b></li>
</ol>

<br>
<br>

<h3>values</h3>

<code>lerp</code>
<ul>
<li>lerp alpha for a sound's eq and reverb values respectively</li>
<li>default: <code>{0.25, 0.1}</code></li>
</ul>

<code>default</code>
<ul>
<li>if a sound does not have an eq when it is added to the list of sound tables, one will be created with these values if ones were not specified</li>
<li>a sound's reverb will revert to these values when not inside a reverb area</li>
<li>default: <code>{eq = {0, 0, 0}, reverb = {0.1, 0, 0, 0, -80}}</code></li>
</ul>

<code>obstruction</code>
<ul>
<li>values to be subtracted from a sound's eq when it is obstructed</li>
<li>default: <code>{12, 6, 3}</code></li>
</ul>

<code>material</code>
<ul>
<li>index is the material's name</li>
<li>values to be additionally subtracted depending on the material of the obstructing basepart</li>
<li>values can be set to negative to add to the eq instead, or to the opposite of <code>obstruction</code> for no change at all</li>
<li>default: <code>{}</code></li>
</ul>

<code>water</code>
<ul>
<li>values to be subtracted from a sound's eq when it or the camera is inside a water area</li>
<li>default: <code>{21, 9, 0}</code></li>
</ul>

<code>falloff_scale</code>
<ul>
<li>values to be subtracted from a sound's eq depending on where the camera is between the sound's origin and its max distance</li>
<li>example: camera is halfway between -> half of these values are subtracted</li>
<li>default: <code>{80, 20, 5}</code></li>
</ul>

<br>

---

<br>

## functions

<br>

<h3>

```lua
autodetection(action, sounds)
```

###### only usable when autodetection feature is enabled

</h3>

<table>
	<tr><td><b>parameter</b></td><td><b>type</b></td><td><b>value</b></td></tr>
	<tr>
		<td>
			<code>action</code>
		</td>
		<td>string</td>
		<td>
			<code>"add_ignore"</code>
			<ul>
				<li>
					add <code>sounds</code> to the autodetection ignore list
				</li>
			</ul>
			<code>"remove_ignore"</code>
			<ul>
				<li>
					remove <code>sounds</code> from the autodetection ignore list
				</li>
			</ul>
		</td>
	</tr>
	<tr>
		<td>
			<code>sounds</code>
		</td>
		<td>table</td>
		<td>
			sound instances
			<br>
			<code>{sound, ...}</code>
		</td>
	</tr>
</table>

<br>
<br>

<h3>

```lua
obstruction(action, baseparts)
```

</h3>

###### only usable when obstruction feature is enabled

<table>
	<tr><td><b>parameter</b></td><td><b>type</b></td><td><b>value</b></td></tr>
	<tr>
		<td>
			<code>action</code>
		</td>
		<td>string</td>
		<td>
			<code>"add_ignore"</code>
			<ul>
				<li>
					add <code>baseparts</code> to the raycast ignore list for sound obstruction
				</li>
			</ul>
			<code>"remove_ignore"</code>
			<ul>
				<li>
					remove <code>baseparts</code> from the raycast ignore list for sound obstruction
				</li>
			</ul>
		</td>
	</tr>
	<tr>
		<td>
			<code>baseparts</code>
		</td>
		<td>table</td>
		<td>
			basepart instances
			<br>
			<code>{basepart, ...}</code>
		</td>
	</tr>
</table>

<br>
<br>

<h3>

```lua
sound_tables(action, sounds, data)
```

</h3>

###### only usable when autodetection feature is disabled

<table>
	<tr><td><b>parameter</b></td><td><b>type</b></td><td><b>value</b></td></tr>
	<tr>
		<td>
			<code>action</code>
		</td>
		<td>string</td>
		<td>
			<code>"add"</code>
			<ul>
				<li>
					create sound tables from <code>sounds</code> with optional base eq values (<code>data</code>)
				</li>
			</ul>
			<code>"remove"</code>
			<ul>
				<li>
					remove sound tables
				</li>
			</ul>
		</td>
	</tr>
	<tr>
		<td>
			<code>sounds</code>
		</td>
		<td rowspan="2">table</td>
		<td>
			sound instances
			<br>
			<code>{sound, ...}</code>
		</td>
	</tr>
	<tr>
		<td>
			<code>data</code> when<br><code>action = "add"</code>
		</td>
		<td>
			base eq values
			<br>
			<code>{high, mid, low}</code>
		</td>
	</tr>
</table>

<br>
<br>

<h3>

```lua
water_areas(action, baseparts, data)
```

###### only usable when water area feature is enabled

</h3>

<table>
	<tr><td><b>parameter</b></td><td><b>type</b></td><td><b>value</b></td></tr>
	<tr>
		<td>
			<code>action</code>
		</td>
		<td>string</td>
		<td>
			<code>"add"</code>
			<ul>
				<li>
					create water areas from <code>baseparts</code> with optional initial ignore list (<code>data</code>)
				</li>
			</ul>
			<code>"remove"</code>
			<ul>
				<li>
					remove water areas
				</li>
			</ul>
			<code>"add_ignore"</code>
			<ul>
				<li>
					add sounds (<code>data</code>) to water area ignore lists
				</li>
			</ul>
			<code>"remove_ignore"</code>
			<ul>
				<li>
					remove sounds (<code>data</code>) from water area ignore lists
				</li>
			</ul>
		</td>
	</tr>
	<tr>
		<td>
			<code>baseparts</code>
		</td>
		<td rowspan="3">table</td>
		<td>
			basepart instances
			<br>
			<code>{basepart, ...}</code>
		</td>
	</tr>
	<tr>
		<td>
			<code>data</code> when<br><code>action = "add"</code>
		</td>
		<td rowspan="2">
			sound instances
			<br>
			<code>{sound, ...}</code>
		</td>
	</tr>
	<tr>
		<td>
			<code>data</code> when<br><code>action = "ignore_add", "ignore_remove"</code>
		</td>
	</tr>
</table>

<br>
<br>

<h3>

```lua
reverb_areas(action, baseparts, data)
```

###### only usable when reverb area feature is enabled

</h3>

<table>
	<tr><td><b>parameter</b></td><td><b>type</b></td><td><b>value</b></td></tr>
	<tr>
		<td>
			<code>action</code>
		</td>
		<td>string</td>
		<td>
			<code>"add"</code>
			<ul>
				<li>
					create reverb areas from <code>baseparts</code> and <code>data</code>
				</li>
			</ul>
			<code>"remove"</code>
			<ul>
				<li>
					remove reverb areas
				</li>
			</ul>
			<code>"add_ignore"</code>
			<ul>
				<li>
					add sounds (<code>data</code>) to reverb area ignore lists
				</li>
			</ul>
			<code>"remove_ignore"</code>
			<ul>
				<li>
					remove sounds (<code>data</code>) from reverb area ignore lists
				</li>
			</ul>
		</td>
	</tr>
	<tr>
		<td>
			<code>baseparts</code>
		</td>
		<td rowspan="3">table</td>
		<td>
			basepart instances
			<br>
			<code>{basepart, ...}</code>
		</td>
	</tr>
	<tr>
		<td>
			<code>data</code> when<br><code>action = "add"</code>
		</td>
		<td>
			<a href="#reverb_area"><code>reverb_area</code></a> (only the table)
		</td>
	</tr>
	<tr>
		<td>
			<code>data</code> when<br><code>action = "ignore_add", "ignore_remove"</code>
		</td>
		<td>
			sound instances
			<br>
			<code>{sound, ...}</code>
		</td>
	</tr>
</table>

<br>

<h3>

```lua
run()
```

</h3>

<br>

<h3>

```lua
stop()
```

</h3>

<br>

---

<br>

## objects

<br>

<h3><code>sound_table</code></h3>

```lua
[sound] = {
	-- eq values
	[1] = number, -- initial high
	[2] = number, -- initial mid
	[3] = number, -- initial low
	[4] = number, -- high
	[5] = number, -- mid
	[6] = number, -- low
	
	-- reverb values
	[7] = number, -- decay
	[8] = number, -- density
	[9] = number, -- diffusion
	[10] = number, -- dry gain
	[11] = number -- wet gain
}
```

<br>

<h3><code>water_area</code></h3>

```lua
[basepart] = {
	-- ignore list
	[sound] = true,
	...
}
```

<br>

<h3><code><a name="reverb_area">reverb_area</a></code></h3>

```lua
[basepart] = {
	[1] = {
		-- values
		[1] = number, -- decay
		[2] = number, -- density
		[3] = number, -- diffusion
		[4] = number, -- dry gain
		[5] = number -- wet gain
	},
	
	[2] = {
		-- ignore list
		[sound] = true,
		...
	}
}
```
