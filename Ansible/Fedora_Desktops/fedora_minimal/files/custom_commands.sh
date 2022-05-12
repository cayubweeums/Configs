#!/bin/bash
## Run source ~/Documents/Scripts/custom_bash_commands.sh anytime changes are made to this file

## Toggles vpn on or off depending on the output of sudo wg show
function vpn(){ 
	class=wg-quick
	name=peer2
	if [[ $(sudo wg show) ]]; then
		echo "~~  Toggling VPN OFF  ~~"
		newstate=down
	else
		echo "~~  Toggling VPN ON  ~~"
		newstate=up	
	fi
		sudo "$class" "$newstate" "$name"
}
