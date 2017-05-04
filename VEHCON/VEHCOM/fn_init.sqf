Areacontrol_fnc = { //Find relative direction to vehicle
	private ["_veh","_object","_reldir"];
	_veh = _this select 0; //vehicle script caller
	_object = _this select 1;
	_reldir = _veh getRelDir _object; //relative direction bis_function
	_reldir;
};

SpeedControl_fnc = {
	private ["_veh","_distance","_objects","_object","_reldir","_VelObj","_VelVeh","_dist"];
	_veh = _this select 0;;
	_distance = _this select 1;
	_objects = [];
	_veh limitSpeed 9999; //Watch the effect of this command.
	_objects = nearestObjects [_veh, ["LandVehicle"], _distance];//find all vehicles within distance x
	_objects = _objects - [_veh]; // Remove self vehicle
		
	if (!isnull (_objects select 0)) then {//make sure vehicle exists
		_object = (_objects select 0);//choose closest vehicle
		_reldir = [_veh,_object] call Areacontrol_fnc;
		
		if (_reldir<20 || _reldir>340) then { //only look at vehicle front (40 degree)
			//systemchat format ["Veh: %1 - Obj: %2",speed  _veh,speed _object];
			_VelObj = speed _object;
			_VelVeh = speed _veh;
			
			if (_VelObj >= 0 || _VelVeh*0.4 < _VelObj) then {//stopped vehicle and slow vehicle are ignored i.e overtake them
				_dist = _veh distance _object;
				if (_dist < _distance) then {
					_veh limitSpeed (_VelObj*0.9); //too close to vehicle front slow down
				}else {
					_veh limitSpeed _VelObj; //Match vehicle front speed
				};			
			} else {
				_veh limitSpeed 999; 
			};
			
		};
		//systemchat format ["%1",_reldir];	
	};
};


[] spawn {
	while {true} do {
		sleep 2; //delay 2 second is perfect with opposed vehicles
		{
			if (_x isKindOf "LandVehicle" && !(isnull driver _x)) then { //vehicle is landvehicle and driver present (else vehicle not moving and can be ignored)
				[_x,30] spawn SpeedControl_fnc;
			};
		} foreach vehicles;
	};
};
hint "VEHCOM initilized";
