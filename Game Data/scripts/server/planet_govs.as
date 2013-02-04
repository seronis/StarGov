const string@ strOre = "Ore", strWorkers = "Workers";
const string@ strFood = "Food", strGoods = "Guds", strLuxuries = "Luxs";
const string@ strDisableCivilActs = "disable_civil_acts", strDoubleLabor = "double_pop_labor", strIndifferent = "forever_indifferent";
const string@ actShortWorkWeek = "work_low", actForcedLabor = "work_forced";

const string@ strAlertWReq = "plalert_wreq";
const string@ strAdjTime_Guds = "t_GudLux_Adjusted";

const double million = 1000000.0;

const float baseWorkRate = 0.5f, workPopulationLevel = float(60.0 * million), workMoodImpact = 2.f;

import float getRate(float val, float max, float deadRate) from "Economy";


const string@	str_Science="Science",		str_EnergyPhysics="EnergyPhysics",
	str_Materials="Materials",				str_ParticlePhysics="ParticlePhysics",
	str_Gravitics="Gravitics",				str_WarpPhysics="WarpPhysics",
	str_Metallurgy="Metallurgy",			str_Chemistry="Chemistry",
	str_Economics="Economics",				str_Sociology="Sociology",
	str_Biology="Biology",					str_BeamWeapons="BeamWeapons",
	str_Shields="Shields",					str_Stealth="Stealth",
	str_ProjWeapons="ProjWeapons",			str_Missiles="Missiles",
	str_Engines="Engines",					str_ShipConstruction="ShipConstruction",
	str_Nanotech="Nanotech",				str_ShipSystems="ShipSystems",
	str_Cargo="Cargo",						str_Computers="Computers",
	str_Sensors="Sensors",					str_Armor="Armor",
	str_MegaConstruction="MegaConstruction";


//when executed, will analyze an empires current tech levels and buffer those level
//	values to empire state variables for more thread friendly read-only access.
void pushTechLvls( Empire@ emp ) {
	ResearchWeb web;
	web.prepare(emp);
	
	const string[] techNames = {  str_Science
		, str_EnergyPhysics		, str_Materials		, str_ParticlePhysics
		, str_Gravitics			, str_WarpPhysics	, str_Metallurgy
		, str_Chemistry			, str_Economics		, str_Sociology
		, str_Biology			, str_BeamWeapons	, str_Shields
		, str_Stealth			, str_ProjWeapons	, str_Missiles
		, str_Engines			, str_Nanotech		, str_ShipConstruction
		, str_ShipSystems		, str_Cargo			, str_Computers
		, str_Sensors			, str_Armor			, str_MegaConstruction
		};
	
	//TODO: consider a more proper tech tree walk that doesnt require knowing
	//	all of the tech names in advance.
	
	for( uint loop = 0; loop < techNames.length(); ++loop ) {
		if( web.isTechVisible(techNames[loop]) ) {
			float tlvl = web.getItem(techNames[loop]).level;
			emp.setStat( techNames[loop], tlvl );
		} else {
			emp.setStat( techNames[loop], 0 );
		}
	}
	return;
}

//thread lock friendly tech level assessment
void popTechLvls( Empire@ emp, bldVals &out rlvl ) {
	rlvl.SetAll(-1);
	rlvl.gcap = 1;
	rlvl.pcap = 1;
	rlvl.city = max(1.00, emp.getStat(str_Sociology));
	rlvl.farm = max(0.75, emp.getStat(str_Biology));
	rlvl.metl = max(1.00, emp.getStat(str_Metallurgy));
	rlvl.elec = rlvl.metl;
	rlvl.advp = rlvl.metl;
	rlvl.yard = max(1.00, emp.getStat(str_ShipConstruction));
	rlvl.port = max(1.00, emp.getStat(str_Economics));
	rlvl.crgo = max(1.00, emp.getStat(str_Cargo));
	rlvl.scif = max(1.00, emp.getStat(str_Science));
	rlvl.good = rlvl.port;
	rlvl.luxr = rlvl.port;
	rlvl.fuel = max(1.00, emp.getStat(str_Chemistry));
	rlvl.ammo = max(1.00, emp.getStat(str_ProjWeapons));
}

const float tickPeriod = 30.0f;
float lastTick = 0.f;
void tick(float tDelta) {
	if(gameTime - lastTick > tickPeriod) {
		uint cnt = getEmpireCount();
		for (uint i = 0; i < cnt; ++i) {
			Empire@ emp = getEmpire(i);
			pushTechLvls(emp);
		}
		lastTick += tickPeriod;
	}
}

enum popMode {
	PM_Normal,
	PM_Work_Slow,
	PM_Work_Hard
};

class bldVals {
	float gcap;
	float pcap;
	float city;
	float farm;
	float metl;
	float elec;
	float advp;
	float yard;
	float port;
	float crgo;
	float scif;
	float good;
	float luxr;
	float fuel;
	float ammo;
	float bnkr;
	float shld;
	float cann;
	float lasr;
	float peng;
	
	void Copy( const bldVals& in rhs ) {
		gcap = rhs.gcap;
		pcap = rhs.pcap;
		city = rhs.city;
		farm = rhs.farm;
		metl = rhs.metl;
		elec = rhs.elec;
		advp = rhs.advp;
		yard = rhs.yard;
		port = rhs.port;
		crgo = rhs.crgo;
		scif = rhs.scif;
		good = rhs.good;
		luxr = rhs.luxr;
		fuel = rhs.fuel;
		ammo = rhs.ammo;
		bnkr = rhs.bnkr;
		shld = rhs.shld;
		cann = rhs.cann;
		lasr = rhs.lasr;
		peng = rhs.peng;
	}
	
	void SetAll( float rhs ) {
		gcap = rhs;
		pcap = rhs;
		city = rhs;
		farm = rhs;
		metl = rhs;
		elec = rhs;
		advp = rhs;
		yard = rhs;
		port = rhs;
		crgo = rhs;
		scif = rhs;
		good = rhs;
		luxr = rhs;
		fuel = rhs;
		ammo = rhs;
		bnkr = rhs;
		shld = rhs;
		cann = rhs;
		lasr = rhs;
		peng = rhs;
	}
	
	void print( string@ msg ) {
		error( "---------- " + msg );
		error( "- gcap: " + gcap + " pcap: " + pcap + " city: " + city + " farm: " + farm );
		error( "- metl: " + metl + " elec: " + elec + " advp: " + advp + " yard: " + yard );
		error( "- port: " + port + " crgo: " + crgo + " scif: " + scif + " bnkr: " + bnkr );
		error( "- good: " + good + " luxr: " + luxr + " fuel: " + fuel + " ammo: " + ammo );
		error( "- shld: " + shld + " cann: " + cann + " lasr: " + lasr + " peng: " + peng );
		error( "- " );
	}
};

//vanilla building definitions
const subSystemDef@ bld_gcap = null;
const subSystemDef@ bld_pcap = null;
const subSystemDef@ bld_city = null;
const subSystemDef@ bld_farm = null;
const subSystemDef@ bld_metl = null;
const subSystemDef@ bld_elec = null;
const subSystemDef@ bld_advp = null;
const subSystemDef@ bld_yard = null;
const subSystemDef@ bld_port = null;
const subSystemDef@ bld_crgo = null;
const subSystemDef@ bld_scif = null;
const subSystemDef@ bld_good = null;
const subSystemDef@ bld_luxr = null;
const subSystemDef@ bld_fuel = null;
const subSystemDef@ bld_ammo = null;
const subSystemDef@ bld_bnkr = null;
const subSystemDef@ bld_shld = null;
const subSystemDef@ bld_cann = null;
const subSystemDef@ bld_lasr = null;
const subSystemDef@ bld_peng = null;

//workers required to activate building
const float wreq_city =        0;
const float wreq_metl =  8000000;
const float wreq_elec =  6000000;
const float wreq_advp =  4000000;
const float wreq_farm =  6000000;
const float wreq_scif =  6000000;
const float wreq_good =  8000000;
const float wreq_luxr =  4000000;
const float wreq_port =  6000000;
const float wreq_yard = 12000000;
const float wreq_crgo =  1000000;
const float wreq_fuel =  6000000;
const float wreq_ammo =  6000000;
const float wreq_bnkr =        0;
const float wreq_shld =        0;
const float wreq_cann =  3000000;
const float wreq_lasr =  3000000;
const float wreq_peng = 12000000;


//adjustable settings
float lvlcurve = 1.4f;
float clvlcurve = 1.2f;
float pref_WorkPopMult = 1.0f;
float pref_TradeMult = 1.0f;
float basefac = 0;
float pref_ResGenMult = 0.167f;

void init_consts() {
	@bld_gcap = getSubSystemDefByName("GalacticCapital");
	@bld_pcap = getSubSystemDefByName("Capital");
	@bld_city = getSubSystemDefByName("City");
	@bld_farm = getSubSystemDefByName("Farm");
	@bld_metl = getSubSystemDefByName("MetalMine");
	@bld_elec = getSubSystemDefByName("ElectronicFact");
	@bld_advp = getSubSystemDefByName("AdvPartFact");
	@bld_yard = getSubSystemDefByName("ShipYard");
	@bld_port = getSubSystemDefByName("SpacePort");
	@bld_crgo = getSubSystemDefByName("CargoBlock");
	@bld_scif = getSubSystemDefByName("SciLab");
	@bld_good = getSubSystemDefByName("GoodsFactory");
	@bld_luxr = getSubSystemDefByName("LuxsFactory");
	@bld_fuel = getSubSystemDefByName("FuelDepot");
	@bld_ammo = getSubSystemDefByName("AmmoDepot");
	@bld_bnkr = getSubSystemDefByName("Bunker");
	@bld_shld = getSubSystemDefByName("PlanetShields");
	@bld_cann = getSubSystemDefByName("PlanetCannon");
	@bld_lasr = getSubSystemDefByName("PlanetLaser");
	@bld_peng = getSubSystemDefByName("PlanetEngine");
	
	lvlcurve = getGameSetting("LEVEL_GAIN_CURVE", 1.4f);
	clvlcurve = 0.5f + (lvlcurve / 2);
	
	pref_WorkPopMult = getGameSetting("WORK_POP_MULTI",1.0);
	pref_TradeMult   = getGameSetting("TRADE_RATE_MULT",1.0);
	
	basefac = getGameSetting("RES_BASE_FACT", 0);
	pref_ResGenMult = getGameSetting("RES_GEN_MULT", 0.167f);
}

// Called by the game engine from build_queues.xml
// Return Vales:
//		true	Prevents the rest of the build queue from executing
//		false	rest of the build queue instructions will execute
bool onGovEvent(Planet@ pl) {
	string@ gov = pl.getGovernorType();
	Empire@ emp = pl.toObject().getOwner();
	
	if( @bld_gcap is null ) init_consts();
	
	if( !emp.isAI() ) {
		if(gov == "testing")
			return gov_testing(pl, emp);
	} else {
		if( emp.getSetting("Difficulty") == 0 )
			return false; //trivial AIs use xml govs
		
		//govs that dont apply to AIs
		if(gov == "testing")
			return gov_economic(pl, emp);
	}
	
	//NOTE: below this point only governors that are AI aware
	if(gov == "default" || gov == "economic")
		return gov_economic(pl, emp);
	if(gov == "metalworld")
		return gov_metalworld(pl, emp);
	if(gov == "resworld")
		return gov_resworld(pl, emp);
	if(gov == "agrarian")
		return gov_agrarian(pl, emp);
	if(gov == "luxworld")
		return gov_luxworld(pl, emp);
	if(gov == "elecworld")
		return gov_elecworld(pl, emp);
	if(gov == "advpartworld")
		return gov_advpartworld(pl, emp);
		
	if(gov == "shipworld")
		return gov_shipworld(pl, emp);
	
	if(gov == "rebuilder")
		return gov_rebuilder(pl, emp);
	
	return false; // default back to XML based gov when no scripted alternative available
}


//figure out population capacity assuming we renovate all our cities
//figure out population effeciency multiplier
//calculate output of each building type assuming its renovated
//calculate minimum population required to run current buildings
//locate building of each type most in need of renovation

void analyzePlanet( Planet@ pl, Empire@ emp,
		float &out pop_max, float &out pop_wreq, float &out pop_city, float &out pop_bnkr,
		
		float &out rate_metl, float &out rate_elec, float &out rate_advp,
		float &out rate_food, float &out rate_good, float &out rate_luxr,
		float &out rate_port, float &out rate_gcap, float &out rate_pcap,
		float &out rate_fuel, float &out rate_ammo,
		
		bldVals &inout rlvl,	bldVals &out olvl,	bldVals &out oloc,
		
		float &out fact_WorkRate
		) {
	
	//figure out all the final multipliers for various planetary stats
	float fact_MineRate = 1;
	float fact_ElecRate = 1;
	float fact_AdvpRate = 1;
	float fact_FarmRate = 1;
	float fact_Housing  = 1;
	float fact_StructHP = 1;
	float fact_PortRate = 1;
	float fact_GoodRate = 1;
	float fact_LuxrRate = 1;
	float fact_FuelRate = 1;
	float fact_AmmoRate = 1;
	float fact_BldCosts = 1;
	
	float fact_BldRate  = 1;
	float fact_PlanetSz = 1;
	
	bool ringworld = pl.hasCondition("ringworld_special");
	if( ringworld ) {
		fact_PlanetSz *= 10;
	}
	
	//ensure these multipliers match those in PlanetTypes.xml
	if( pl.hasCondition("unstable")) {
		fact_BldCosts *= 1.50f;
	}
	if( pl.hasCondition("ore_rich")) {
		fact_MineRate *= 1.50f;
	}
	if( pl.hasCondition("ore_poor")) {
		fact_MineRate *= 0.50f;
	}
	if( pl.hasCondition("dense_flora")) {
		fact_FarmRate *= 1.50f;
		fact_BldCosts *= 1.20f;
	}
	if( pl.hasCondition("cavernous")) {
		fact_Housing  *= 1.25f;
		fact_StructHP *= 1.25f;
	}
	if( pl.hasCondition("noxious")) {
		fact_Housing  *= 0.80f;
	}
	if( pl.hasCondition("plains")) {
		fact_BldCosts *= 0.90f;
	}
	if( pl.hasCondition("high_winds")) {
		fact_BldCosts *= 1.10f;
		fact_StructHP *= 0.75f;
	}
	if( pl.hasCondition("geotherm")) {
		fact_ElecRate *= 1.25f;
		fact_AdvpRate *= 1.25f;
	}
	if( pl.hasCondition("frigid")) {
		fact_Housing  *= 0.75f;
		fact_StructHP *= 0.75f;
	}
	if( pl.hasCondition("volcanic")) {
		fact_StructHP *= 0.67f;
	}
	
	
	float pop_city_base = 20 * million * fact_PlanetSz;
	pop_city = pop_city_base * pow(clvlcurve, rlvl.city) * fact_Housing;
	pop_bnkr = pop_city * 0.3f;
	
	pop_max = 0
		+ (pl.getStructureCount(bld_city) * pop_city)
		+ (pl.getStructureCount(bld_bnkr) * pop_bnkr)
		+ (pl.getStructureCount(bld_gcap) * 24 * million * fact_PlanetSz)
		+ (pl.getStructureCount(bld_pcap) *  6 * million * fact_PlanetSz);
	
	fact_WorkRate = baseWorkRate * (0.5f + ((pop_max / workPopulationLevel) * pref_WorkPopMult));
	
	bool hasCivilActs = !emp.hasTraitTag(strDisableCivilActs);
	popMode mode = PM_Normal;
	if (hasCivilActs) {
		if(emp.getSetting(actShortWorkWeek) == 1)
			mode = PM_Work_Slow;
		else if(emp.getSetting(actForcedLabor) == 1)
			mode = PM_Work_Hard;
	}
	
	switch(mode) {
		case PM_Work_Slow:
			fact_WorkRate *= 0.75f;
		case PM_Normal:
			if(!emp.hasTraitTag(strIndifferent)) {
				fact_WorkRate *= pow(workMoodImpact, 1.0);
			}
			break;
		case PM_Work_Hard:
			fact_WorkRate *= 0.8f;
			break;
	}
	
	float rate_metl_base = fact_PlanetSz;
	float rate_elec_base = fact_PlanetSz;
	float rate_advp_base = fact_PlanetSz;
	float rate_food_base = fact_PlanetSz;
	float rate_good_base = fact_PlanetSz;
	float rate_luxr_base = fact_PlanetSz;
	float rate_port_base = fact_PlanetSz;
	float rate_fuel_base = fact_PlanetSz;
	float rate_ammo_base = fact_PlanetSz;
	
	//tech zero base values as defined in structures.txt
	rate_metl_base *=  140.00f;
	rate_elec_base *=   27.00f;
	rate_advp_base *=   20.00f;
	rate_food_base *=    6.00f;
	rate_good_base *=  920.00f;
	rate_luxr_base *=   50.00f;
	rate_port_base *=  100.00f;
	rate_fuel_base *=  200.00f;
	rate_ammo_base *=  100.00f;
	
	//adjusted values scaled to account for tech levels, preference settings and planetary conditions
	rate_metl = rate_metl_base * (pow(lvlcurve, rlvl.metl) + basefac) * fact_MineRate * pref_ResGenMult * fact_WorkRate;
	rate_elec = rate_elec_base * (pow(lvlcurve, rlvl.metl) + basefac) * fact_ElecRate * pref_ResGenMult * fact_WorkRate;
	rate_advp = rate_advp_base * (pow(lvlcurve, rlvl.metl) + basefac) * fact_AdvpRate * pref_ResGenMult * fact_WorkRate;
	rate_food = rate_food_base *  pow(lvlcurve, rlvl.farm)            * fact_FarmRate;
	rate_good = rate_good_base *  pow(lvlcurve, rlvl.port)            * fact_GoodRate;
	rate_luxr = rate_luxr_base *  pow(lvlcurve, rlvl.port)            * fact_LuxrRate;
	rate_fuel = rate_fuel_base *  pow(lvlcurve, rlvl.fuel)            * fact_FuelRate;
	rate_ammo = rate_ammo_base *  pow(lvlcurve, rlvl.ammo)            * fact_AmmoRate;
	
	//adjustment to ore mining rate due to planetary depletion
	State@ ore = pl.toObject().getState(strOre);
	rate_metl = rate_metl * getRate(ore.val, pl.getStructureCount(bld_metl) * rate_metl , 0.2f);
	
	rate_port = rate_port_base * pow(lvlcurve, rlvl.port) * fact_PortRate * pref_TradeMult;
	
	rate_gcap = 0;
	rate_gcap += 500; //metal
	rate_gcap += 250; //elecs
	rate_gcap += 100; //advps
	rate_gcap +=  10; //food
	
	rate_pcap = 0;
	
	
	pop_wreq = 1;
	olvl.Copy(rlvl);
	oloc.SetAll( pl.getMaxStructureCount() );
	
	PlanetStructureList structlist;
	structlist.prepare(pl);
	const subSystemDef@ struct = null;
	float templvl;
	for (uint i = 0; i < structlist.getCount(); ++i) {
		@struct = structlist.getStructure(i).get_type();
		templvl = structlist.getStructure(i).get_level();
		
		if(struct is bld_city) {
			if(templvl <= olvl.city) {
				oloc.city = i;
				olvl.city = templvl;
			}
		}
		else if(struct is bld_metl) {
			if(templvl <= olvl.metl) {
				oloc.metl = i;
				olvl.metl = templvl;
			}
			pop_wreq += wreq_metl * fact_PlanetSz;
		}
		else if(struct is bld_elec) {
			if(templvl <= olvl.elec) {
				oloc.elec = i;
				olvl.elec = templvl;
			}
			pop_wreq += wreq_elec * fact_PlanetSz;
		}
		else if(struct is bld_advp) {
			if(templvl <= olvl.advp) {
				oloc.advp = i;
				olvl.advp = templvl;
			}
			pop_wreq += wreq_advp * fact_PlanetSz;
		}
		else if(struct is bld_farm) {
			if(templvl <= olvl.farm) {
				oloc.farm = i;
				olvl.farm = templvl;
			}
			pop_wreq += wreq_farm * fact_PlanetSz;
		}
		else if(struct is bld_good) {
			if(templvl <= olvl.good) {
				oloc.good = i;
				olvl.good = templvl;
			}
			pop_wreq += wreq_good * fact_PlanetSz;
		}
		else if(struct is bld_luxr) {
			if(templvl <= olvl.luxr) {
				oloc.luxr = i;
				olvl.luxr = templvl;
			}
			pop_wreq += wreq_luxr * fact_PlanetSz;
		}
		else if(struct is bld_port) {
			if(templvl <= olvl.port) {
				oloc.port = i;
				olvl.port = templvl;
			}
			pop_wreq += wreq_port * fact_PlanetSz;
		}
		else if(struct is bld_yard) {
			if(templvl <= olvl.yard) {
				oloc.yard = i;
				olvl.yard = templvl;
			}
			pop_wreq += wreq_yard * fact_PlanetSz;
		}
		else if(struct is bld_crgo) {
			if(templvl <= olvl.crgo) {
				oloc.crgo = i;
				olvl.crgo = templvl;
			}
			pop_wreq += wreq_crgo * fact_PlanetSz;
		}
		else if(struct is bld_fuel) {
			if(templvl <= olvl.fuel) {
				oloc.fuel = i;
				olvl.fuel = templvl;
			}
			pop_wreq += wreq_fuel * fact_PlanetSz;
		}
		else if(struct is bld_ammo) {
			if(templvl <= olvl.ammo) {
				oloc.ammo = i;
				olvl.ammo = templvl;
			}
			pop_wreq += wreq_ammo * fact_PlanetSz;
		}
		else if(struct is bld_bnkr) {
			if(templvl <= olvl.bnkr) {
				oloc.bnkr = i;
				olvl.bnkr = templvl;
			}
		}
		else if(struct is bld_shld) {
			if(templvl <= olvl.shld) {
				oloc.shld = i;
				olvl.shld = templvl;
			}
			pop_wreq += wreq_shld * fact_PlanetSz;
		}
		else if(struct is bld_cann) {
			if(templvl <= olvl.cann) {
				oloc.cann = i;
				olvl.cann = templvl;
			}
			pop_wreq += wreq_cann * fact_PlanetSz;
		}
		else if(struct is bld_lasr) {
			if(templvl <= olvl.lasr) {
				oloc.lasr = i;
				olvl.lasr = templvl;
			}
			pop_wreq += wreq_lasr * fact_PlanetSz;
		}
		else if(struct is bld_peng) {
			if(templvl <= olvl.peng) {
				oloc.peng = i;
				olvl.peng = templvl;
			}
			pop_wreq += wreq_peng * fact_PlanetSz;
		}
		else if(struct is bld_scif) {
			if(templvl <= olvl.scif) {
				oloc.scif = i;
				olvl.scif = templvl;
			}
			pop_wreq += wreq_scif * fact_PlanetSz;
		}
		else if(struct is bld_gcap) {
			if(templvl <= olvl.gcap) {
				oloc.gcap = i;
				olvl.gcap = templvl;
			}
		}
		else if(struct is bld_pcap) {
			if(templvl <= olvl.pcap) {
				oloc.pcap = i;
				olvl.pcap = templvl;
			}
		}
	}
}

int getEfficiency( Empire@ emp )
{
	float diff = emp.getSetting("Difficulty");
	if( diff < 0 || diff >= 5 ) return 5;
	return int(diff);
}


bool gov_rebuilder(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	if( rlvl.port > 0 + olvl.port ) {
		pl.rebuildStructure(oloc.port);
	}
	if( rlvl.yard > 0 + olvl.yard ) {
		pl.rebuildStructure(oloc.yard);
	}
	if( rlvl.city > 0 + olvl.city ) {
		pl.rebuildStructure(oloc.city);
	}
	if( rlvl.farm > 0 + olvl.farm ) {
		pl.rebuildStructure(oloc.farm);
	}
	if( rlvl.metl > 0 + olvl.metl ) {
		pl.rebuildStructure(oloc.metl);
	}
	if( rlvl.metl > 0 + olvl.elec ) {
		pl.rebuildStructure(oloc.elec);
	}
	if( rlvl.metl > 0 + olvl.advp ) {
		pl.rebuildStructure(oloc.advp);
	}
	if( rlvl.crgo > 0 + olvl.crgo ) {
		pl.rebuildStructure(oloc.crgo);
	}
	if( rlvl.scif > 0 + olvl.scif ) {
		pl.rebuildStructure(oloc.scif);
	}
	
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


//this is unused. its here for quick copy/paste when writing a new governor
bool gov_testing(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,

		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	rlvl.print( pl.toObject().getName() + ": rlvl" );
	olvl.print( pl.toObject().getName() + ": olvl" );
	oloc.print( pl.toObject().getName() + ": oloc" );
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	emp.postMessage(
			"#c:green#Val:#c##c:white#"+workers.val+"#c# "
		+	"#c:green#Max:#c##c:white#"+workers.max+"#c# "
		+	"#c:green#Req:#c##c:white#"+workers.required+"#c# "
		+	"#c:green#Cgo:#c##c:white#"+workers.inCargo+"#c# ");
	bool offline = (workers.val < workers.required);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	if( slots_free < 2 ) {
		//this section is for high priority building teardowns. Buildings that
		//  are not valid at all for this governor. 
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		//we have free slots. Build something helpful to our purpose
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_economic(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		if( pl.getStructureCount(bld_good) > 0) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_scif) > 0 && pl.getStructureCount(bld_gcap) < 1 ) {
			pl.removeStructure(oloc.scif);
			return true;
		}
		
		//allowed limited number of these depending on planet size
		uint limit = floor(slots_total / 9);
		if( pl.getStructureCount(bld_crgo) > limit+1 ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		if( pl.getStructureCount(bld_ammo) > limit ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > limit ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		float num_advp = pl.getStructureCount(bld_advp);
		float num_elec = pl.getStructureCount(bld_elec);
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			float a_profit =  num_advp * rate_advp;
			float e_profit = (num_elec * rate_elec) - a_profit;
			float m_profit = (num_metl * rate_metl) - (2*e_profit + 3*a_profit);
			total_export += (a_profit + e_profit + m_profit);
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		//The two numeric constants here are to balance the total ratio of
		//	one resource produced versus the others. Our goal is to attempt
		//	as close to a 6/3/2 ratio of metal/elecs/advps as we can with
		//	the number of slots available on planet
		float atoeratio = (rate_elec / rate_advp) * 0.425f;
		if( num_advp > 0 ) {
			if( num_advp > atoeratio * num_elec ) {
				pl.removeStructure(oloc.advp);
				return true;
			}
		}
		float etomratio = (rate_metl / rate_elec) * 0.275;
		if( num_elec > 0 ) {
			if( num_elec > etomratio * num_metl ) {
				pl.removeStructure(oloc.elec);
				return true;
			}
		}
		if( num_metl > 2 ) {
			if( (num_elec+1) <= etomratio * (num_metl-1) ) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		
		uint desired_cities = 2;
		switch( gov_efficiency ){
			case 0:
			case 1:
			case 2:
				desired_cities = uint( (num_advp + num_elec + num_metl)/3 );	// low efficiency
				break;
			case 3:
			case 4:
				desired_cities = uint( max( max(num_advp,num_elec),num_metl) );	// med efficiency
				break;
			case 5:
				desired_cities = uint(num_advp + num_elec + num_metl);			// max efficiency
				break;
		}
		if( pl.getStructureCount(bld_city) > desired_cities &&
			(pop_max - pop_city) > (pop_wreq + pop_buffer)
			) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		// Handle overworked population
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_scif) > 0 ) {
				pl.removeStructure(oloc.scif);
				return true;
			}
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		//we have free slots. Build something helpful to our purpose
		
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		if( slots_total > 16 ) {
			if( pl.getStructureCount(bld_crgo) < 1 ) {
				pl.buildStructure(bld_crgo);
				return true;
			}
		}
		
		uint limit = pl.getStructureCount(bld_gcap) > 0 ? 2 : 1;
		if( pl.getStructureCount(bld_farm) < limit ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp < outp || val < (npl * sqrt(rlvl.city) * 250) ) {
				pl.buildStructure(bld_farm);
				return true;
			}
		}
		if( pl.getStructureCount(bld_scif) < 2 && pl.getStructureCount(bld_gcap) > 0 ) {
			pl.buildStructure(bld_scif);
			return true;
		}
		
		float num_advp = pl.getStructureCount(bld_advp);
		float num_elec = pl.getStructureCount(bld_elec);
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		{	float a_profit =  num_advp * rate_advp;
			float e_profit = (num_elec * rate_elec) - a_profit;
			float m_profit = (num_metl * rate_metl) - (2*e_profit + 3*a_profit);
			total_export += (a_profit + e_profit + m_profit);
		}	
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		//we only use bonus cities after at least one advp factory has been built.
		if( num_advp > 0 ) {
			uint desired_cities = 2;
			switch( gov_efficiency ) {
				case 0:
				case 1:
				case 2:
					desired_cities = uint( (num_advp + num_elec + num_metl)/3 );	// low efficiency
					break;
				case 3:
				case 4:
					desired_cities = uint( max(max(num_advp,num_elec),num_metl) );	// med efficiency
					break;
				case 5:
					desired_cities = uint(num_advp + num_elec + num_metl);			// max efficiency
					break;
			}
			if( desired_cities > pl.getStructureCount(bld_city) ) {
				pl.buildStructure(bld_city);
				return true;
			}
		}
		
		float atoeratio = (rate_elec / rate_advp) * 0.425;
		if( (num_advp+1) <= (atoeratio * num_elec) ) {
			pl.buildStructure(bld_advp);
			return true;
		}
		
		float etomratio = (rate_metl / rate_elec) * 0.275;
		if( (num_elec+1) <= (etomratio * num_metl) ) {
			pl.buildStructure(bld_elec);
			return true;
		}
		
		pl.buildStructure(bld_metl);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_metalworld(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
	
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		//strip mining worlds have no need of such things
		if( pl.getStructureCount(bld_good) > 0 ) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0 ) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_advp) > 0 ) {
			pl.removeStructure(oloc.advp);
			return true;
		}
		if( pl.getStructureCount(bld_elec) > 0 ) {
			pl.removeStructure(oloc.elec);
			return true;
		}
		if( pl.getStructureCount(bld_scif) > 0 ) {
			pl.removeStructure(oloc.scif);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > 0 ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		//might be allowed limited number of these
		uint limit = slots_total < 14 ? 0 : 1;
		if( pl.getStructureCount(bld_crgo) > 1 ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		
		float num_metl = pl.getStructureCount(bld_metl);
		float num_ammo = pl.getStructureCount(bld_ammo);
		float mtl_ammo = rate_ammo * num_ammo * 0.1;
		
		if( mtl_ammo > (num_metl*rate_metl) ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		
		float num_port = pl.getStructureCount(bld_port);
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			total_export += (num_metl * rate_metl);
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > pl.getStructureCount(bld_metl) && 
			pl.getStructureCount(bld_city) > 1 && pop_max > pop_wreq + pop_buffer ) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
			if( pl.getStructureCount(bld_ammo) > 0 ) {
				pl.removeStructure(oloc.ammo);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		//we have free slots. Build something helpful to our purpose
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		total_export += (num_metl * rate_metl);
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		uint limit = pl.getStructureCount(bld_gcap) > 0 ? 2 : 1;
		if( pl.getStructureCount(bld_farm) < limit ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp < outp || val < (npl * sqrt(rlvl.city) * 250) ) {
				pl.buildStructure(bld_farm);
				return true;
			}
		}
		
		if( uint(num_metl) > pl.getStructureCount(bld_city)) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		pl.buildStructure(bld_metl);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_resworld(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		float num_metl = pl.getStructureCount(bld_metl);
		
		//we allow limited mines so that ore reserves dont go to waste
		if( num_metl > 0 ) if( ore.val <= 0 ) {
			pl.removeStructure(oloc.metl);
			return true;
		} else {
			if( pow(num_metl-1,2) > ceil(ore.val/5000000) 
				|| num_metl > int(gov_efficiency)
				) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		//research worlds have no need of such things
		if( pl.getStructureCount(bld_good) > 0) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_advp) > 0 ) {
			pl.removeStructure(oloc.advp);
			return true;
		}
		if( pl.getStructureCount(bld_elec) > 0 ) {
			pl.removeStructure(oloc.elec);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > 0 ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		if( pl.getStructureCount(bld_ammo) > 0 ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		//might be allowed limited number of these
		uint limit = slots_total < 14 ? 0 : 1;
		if( pl.getStructureCount(bld_crgo) > limit ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		
		
		float num_port = pl.getStructureCount(bld_port);
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			total_export += (num_metl * rate_metl);
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > pl.getStructureCount(bld_metl) && 
			pl.getStructureCount(bld_city) > 1 &&
			(pop_max - pop_city) > (pop_wreq + pop_buffer)
			) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		
		uint limit = pl.getStructureCount(bld_gcap) > 0 ? 2 : 1;
		if( pl.getStructureCount(bld_farm) < limit ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp < outp || val < (npl * sqrt(rlvl.city) * 250) ) {
				pl.buildStructure(bld_farm);
				return true;
			}
		}
		
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		total_export += (num_metl * rate_metl);
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		if( ore.val > 0 && num_metl < int(gov_efficiency)
				&& num_metl < floor(pl.getStructureCount(bld_scif)/2)
				&& pow(num_metl,2) < ceil(ore.val/5000000)
				) {
			pl.buildStructure(bld_metl);
			return true;
		}
		
		pl.buildStructure(bld_scif);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_agrarian(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		float num_metl = pl.getStructureCount(bld_metl);
		
		//we allow limited mines so that ore reserves dont go to waste
		if( num_metl > 0 ) if( ore.val <= 0 ) {
			pl.removeStructure(oloc.metl);
			return true;
		} else {
			if( pow(num_metl-1,2) > ceil(ore.val/5000000) 
				|| num_metl > int(gov_efficiency)
				) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		//farming worlds have no need of such things
		if( pl.getStructureCount(bld_good) > 0) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_advp) > 0 ) {
			pl.removeStructure(oloc.advp);
			return true;
		}
		if( pl.getStructureCount(bld_elec) > 0 ) {
			pl.removeStructure(oloc.elec);
			return true;
		}
		if( pl.getStructureCount(bld_ammo) > 0 ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		if( pl.getStructureCount(bld_scif) > 0 ) {
			pl.removeStructure(oloc.scif);
			return true;
		}
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		//might be allowed limited number of these
		uint limit = slots_total < 14 ? 0 : 1;
		if( pl.getStructureCount(bld_crgo) > limit ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		limit = floor( 1 + pl.getStructureCount(bld_farm)/4 );
		if( pl.getStructureCount(bld_fuel) > limit ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		
		float num_farm = pl.getStructureCount(bld_farm);
		float num_fuel = pl.getStructureCount(bld_fuel);
		float fud_fuel = rate_fuel * num_fuel * 0.1;
		
		if( fud_fuel > (num_farm*rate_food) ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		
		
		float num_port = pl.getStructureCount(bld_port);
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			total_export += (num_metl * rate_metl);
			total_export += (num_farm * rate_food);
		//	total_export += (num_fuel * rate_fuel); //TODO: add fuel transport to G.Bank
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > uint(num_metl) && 
			pl.getStructureCount(bld_city) > 1 && pop_max > pop_wreq + pop_buffer ) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_fuel) > 1 ) {
				pl.removeStructure(oloc.fuel);
				return true;
			}
			if( pl.getStructureCount(bld_metl) > 1 ) {
				pl.removeStructure(oloc.metl);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		
		float num_metl = pl.getStructureCount(bld_metl);
		float num_farm = pl.getStructureCount(bld_farm);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		total_export += (num_farm * rate_food);
		total_export += (num_metl * rate_metl);
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		if( ore.val > 0 && num_metl < int(gov_efficiency)
				&& num_metl < floor(num_farm/2)
				&& pow(num_metl,2) < ceil(ore.val/5000000)
				) {
			pl.buildStructure(bld_metl);
			return true;
		}
		
		pl.buildStructure(bld_farm);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_elecworld(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		if( pl.getStructureCount(bld_good) > 0) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_ammo) > 0 ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > 0 ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		if( pl.getStructureCount(bld_scif) > 0 ) {
			pl.removeStructure(oloc.scif);
			return true;
		}
		if( pl.getStructureCount(bld_advp) > 0 ) {
			pl.removeStructure(oloc.advp);
			return true;
		}
		
		//might be allowed limited number of these
		if( pl.getStructureCount(bld_crgo) > 0 && slots_total < 14 ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		float num_port = pl.getStructureCount(bld_port);
		float num_metl = pl.getStructureCount(bld_metl);
		float num_elec = pl.getStructureCount(bld_elec);
		
		float etomratio = (rate_metl / rate_elec) * 0.475;
		if( num_elec > 0 ) {
			if( num_elec > etomratio * num_metl ) {
				pl.removeStructure(oloc.elec);
				return true;
			}
		}
		if( num_metl > 1 ) {
			if( (num_elec+1) <= etomratio * (num_metl-1) ) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			total_export += (num_metl * rate_metl);
			total_export -= (num_elec * rate_elec);
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > uint(num_metl+num_elec) && 
			pl.getStructureCount(bld_city) > 1 && pop_max > pop_wreq + pop_buffer ) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.fuel);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		//we have free slots. Build something helpful to our purpose
		
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		
		uint limit = pl.getStructureCount(bld_gcap) > 0 ? 2 : 1;
		if( pl.getStructureCount(bld_farm) < limit ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp < outp || val < (npl * sqrt(rlvl.city) * 250) ) {
				pl.buildStructure(bld_farm);
				return true;
			}
		}
		
		float num_elec = pl.getStructureCount(bld_elec);
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		total_export += (num_metl * rate_metl);
		total_export -= (num_elec * rate_elec);
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		if( num_elec > 0 ) {
			//we only use bonus cities after at least one elec factory has been built.
			if( uint(num_metl) > pl.getStructureCount(bld_city) ||
				uint(num_elec) > pl.getStructureCount(bld_city) ) {
				pl.buildStructure(bld_city);
				return true;
			}
		}
		
		float etomratio = (rate_metl / rate_elec) * 0.475;
		if( (num_elec+1) <= (etomratio * num_metl) ) {
			pl.buildStructure(bld_elec);
			return true;
		}
		
		pl.buildStructure(bld_metl);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_advpartworld(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		if( pl.getStructureCount(bld_good) > 0) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_ammo) > 0 ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > 0 ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		if( pl.getStructureCount(bld_scif) > 0 ) {
			pl.removeStructure(oloc.scif);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		//might be allowed limited number of these
		if( pl.getStructureCount(bld_crgo) > 0 && slots_total < 14 ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		
		float num_port = pl.getStructureCount(bld_port);
		float num_metl = pl.getStructureCount(bld_metl);
		float num_elec = pl.getStructureCount(bld_elec);
		float num_advp = pl.getStructureCount(bld_advp);
		
		float atoeratio = (rate_elec / rate_advp) * 0.975;
		if( num_advp > 0 ) {
			if( num_advp > atoeratio * num_elec ) {
				pl.removeStructure(oloc.advp);
				return true;
			}
		}
		float etomratio = (rate_metl / rate_elec) * 0.325;
		if( num_elec > 0 ) {
			if( num_elec > etomratio * num_metl ) {
				pl.removeStructure(oloc.elec);
				return true;
			}
		}
		if( num_metl > 1 ) {
			if( (num_elec+1) <= etomratio * (num_metl-1) ) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			float a_profit = (num_advp * rate_advp);
			float e_profit = (num_elec * rate_elec) - a_profit;
			float m_profit = (num_metl * rate_metl) - (a_profit*3 + e_profit*2);
			total_export += (a_profit + e_profit + m_profit);
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > uint(num_metl+num_elec+num_advp) &&
			pl.getStructureCount(bld_city) > 1 && pop_max > pop_wreq + pop_buffer ) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.fuel);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		//we have free slots. Build something helpful to our purpose
		
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		
		uint limit = pl.getStructureCount(bld_gcap) > 0 ? 2 : 1;
		if( pl.getStructureCount(bld_farm) < limit ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp < outp || val < (npl * sqrt(rlvl.city) * 250) ) {
				pl.buildStructure(bld_farm);
				return true;
			}
		}
		
		float num_advp = pl.getStructureCount(bld_advp);
		float num_elec = pl.getStructureCount(bld_elec);
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		{	float a_profit =  num_advp * rate_advp;
			float e_profit = (num_elec * rate_elec) - a_profit;
			float m_profit = (num_metl * rate_metl) - (2*e_profit + 3*a_profit);
			total_export += (a_profit + e_profit + m_profit);
		}	
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		if( num_advp > 0 ) {
			//we only use bonus cities after at least one advp factory has been built.
			if( uint(num_advp+num_elec+num_metl) > pl.getStructureCount(bld_city) ) {
				pl.buildStructure(bld_city);
				return true;
			}
		}
		
		float atoeratio = (rate_elec / rate_advp) * 0.975;
		if( (num_advp+1) <= (atoeratio * num_elec) ) {
			pl.buildStructure(bld_advp);
			return true;
		}
		float etomratio = (rate_metl / rate_elec) * 0.325;
		if( (num_elec+1) <= (etomratio * num_metl) ) {
			pl.buildStructure(bld_elec);
			return true;
		}
		
		pl.buildStructure(bld_metl);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_luxworld(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		float num_metl = pl.getStructureCount(bld_metl);
		
		//we allow limited mines so that ore reserves dont go to waste
		if( num_metl > 0 ) if( ore.val <= 0 ) {
			pl.removeStructure(oloc.metl);
			return true;
		} else {
			if( pow(num_metl-1,2) > ceil(ore.val/5000000) 
				|| num_metl > int(gov_efficiency)
				) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		//luxury worlds have no need of such things
		if( pl.getStructureCount(bld_advp) > 0 ) {
			pl.removeStructure(oloc.advp);
			return true;
		}
		if( pl.getStructureCount(bld_elec) > 0 ) {
			pl.removeStructure(oloc.elec);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > 0 ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		if( pl.getStructureCount(bld_ammo) > 0 ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		
		//might be allowed limited number of these
		uint limit = (slots_total<14)?0:1;
		if( pl.getStructureCount(bld_crgo) > limit ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		double val=0, inp=0, outp=0, demand=0;
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		float num_port = pl.getStructureCount(bld_port);
		
		if( num_port > 1 ) {
			float avail_export = num_port * rate_port;
			float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
			total_export += (num_metl * rate_metl);
			
			if( total_export < avail_export - rate_port ) {
				pl.removeStructure(oloc.port);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_yard) > 0 ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > pl.getStructureCount(bld_metl) && 
			pl.getStructureCount(bld_city) > 1 &&
			(pop_max - pop_city) > (pop_wreq + pop_buffer)
			) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		float lastCheck = emp.getStat( strAdjTime_Guds );
		float checkInterval = max(10,60 - (10 * gov_efficiency));
		if( gameTime > (lastCheck + checkInterval) )
		{
			emp.getStatStats(strGoods, val, inp, outp, demand);
			if( inp < outp || demand > 0 ) {
				if( pl.getStructureCount(bld_luxr) > 0 )
				{
					pl.removeStructure(oloc.luxr);
					pl.buildStructure(bld_good);
					emp.setStat( strAdjTime_Guds, gameTime );
				} else
				if( pl.getStructureCount(bld_scif) > 0 )
				{
					pl.removeStructure(oloc.scif);
					pl.buildStructure(bld_good);
					emp.setStat( strAdjTime_Guds, gameTime );
				} else
				{
					//TODO: issue warning to player
				}
			}
			
			emp.getStatStats(strLuxuries, val, inp, outp, demand);
			if( inp < outp || demand > 0 ) {
				if( pl.getStructureCount(bld_scif) > 0 )
				{
					pl.removeStructure(oloc.scif);
					pl.buildStructure(bld_luxr);
					emp.setStat( strAdjTime_Guds, gameTime );
				} else
				{
					//TODO: issue warning to player
				}
			}
			
			//TODO: overproduction checks to convert factories into sci facilities
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_scif) > 0 ) {
				pl.removeStructure(oloc.scif);
				return true;
			}
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
			if( pl.getStructureCount(bld_luxr) > 0 ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		//before building anything else gaurentee we will have enough workers
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		if( slots_free > 6 ) {
			if( pl.getStructureCount(bld_yard) < 1 ) {
				pl.buildStructure(bld_yard);
				return true;
			}
		}
		
		uint limit = pl.getStructureCount(bld_gcap) > 0 ? 2 : 1;
		double npl=0, val=0, inp=0, outp=0, demand=0;
		if( pl.getStructureCount(bld_farm) < limit ) {
			emp.getStatStats(strFood, val, inp, outp, demand);
			npl = emp.getStat("Planet");
			if( inp < outp || val < (npl * sqrt(rlvl.city) * 250) ) {
				pl.buildStructure(bld_farm);
				return true;
			}
		}
		
		float num_metl = pl.getStructureCount(bld_metl);
		float num_port = pl.getStructureCount(bld_port);
		
		float avail_export = num_port * rate_port;
		float total_export = pl.getStructureCount(bld_gcap) * rate_gcap;
		total_export += (num_metl * rate_metl);
		
		if( num_port < 1 || total_export > avail_export ) {
			pl.buildStructure(bld_port);
			return true;
		}
		if( uint(num_metl) > pl.getStructureCount(bld_city)) {
			pl.buildStructure(bld_city);
			return true;
		}
		float num_scif = pl.getStructureCount(bld_scif);
		if( ore.val > 0 && num_metl < int(gov_efficiency)
				&& num_metl < floor(num_scif/2)
				&& pow(num_metl,2) < ceil(ore.val/5000000)
				) {
			pl.buildStructure(bld_metl);
			return true;
		}
		
		emp.getStatStats(strGoods, val, inp, outp, demand);
		if( inp < outp || demand > 0 ) {
			pl.buildStructure(bld_good);
			return true;
		}
		emp.getStatStats(strLuxuries, val, inp, outp, demand);
		if( inp < outp || demand > 0 ) {
			pl.buildStructure(bld_luxr);
			return true;
		}
		
		if(num_scif < int(gov_efficiency)) {
			pl.buildStructure(bld_scif);
			return true;
		}
		
		pl.buildStructure(bld_luxr);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}


bool gov_shipworld(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	float rate_fuel, rate_ammo;
	
	bldVals rlvl, olvl, oloc;
	
	popTechLvls( emp, rlvl );
	
	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,
		
		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,
		rate_fuel, rate_ammo,
		
		rlvl, olvl, oloc,
		
		fact_WorkRate
		);
	
	State@ ore = pl.toObject().getState(strOre);
	State@ workers = pl.toObject().getState(strWorkers);
	bool offline = (workers.val < workers.required);
	
	uint gov_efficiency = getEfficiency(emp);
	
	float slots_total = pl.getMaxStructureCount();
	float slots_used = pl.getStructureCount();
	float slots_free = slots_total-slots_used;
	
	if( slots_free < 2 ) {
		float num_metl = pl.getStructureCount(bld_metl);
		float num_yard = pl.getStructureCount(bld_yard);
		float num_port = pl.getStructureCount(bld_port);
		
		//we allow limited mines so that ore reserves dont go to waste
		if( num_metl > 0 ) if( ore.val <= 0 ) {
			pl.removeStructure(oloc.metl);
			return true;
		} else {
			if( num_metl > int(gov_efficiency) ||
				num_metl > ceil((num_port+num_yard)/2)
				) {
				pl.removeStructure(oloc.metl);
				return true;
			}
		}
		
		if( pl.getStructureCount(bld_good) > 0 ) {
			pl.removeStructure(oloc.good);
			return true;
		}
		if( pl.getStructureCount(bld_luxr) > 0 ) {
			pl.removeStructure(oloc.luxr);
			return true;
		}
		if( pl.getStructureCount(bld_scif) > 0 ) {
			pl.removeStructure(oloc.scif);
			return true;
		}
		
		if( pl.getStructureCount(bld_advp) > 0 ) {
			pl.removeStructure(oloc.advp);
			return true;
		}
		if( pl.getStructureCount(bld_elec) > 0 ) {
			pl.removeStructure(oloc.elec);
			return true;
		}
		
		if( pl.getStructureCount(bld_ammo) > 1 ) {
			pl.removeStructure(oloc.ammo);
			return true;
		}
		if( pl.getStructureCount(bld_fuel) > 1 ) {
			pl.removeStructure(oloc.fuel);
			return true;
		}
		
		//By the time we're this established we should have dedicated farm worlds
		if( pl.getStructureCount(bld_farm) > 0 && emp.getStat("Planet") > 12 ) {
			double val=0, inp=0, outp=0, demand=0;
			emp.getStatStats(strFood, val, inp, outp, demand);
			double npl = emp.getStat("Planet");
			if( inp > outp && val > (npl * sqrt(rlvl.city) * 500) ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
		}
		
		float avail_import = num_port * rate_port;
		
		float num_crgo = pl.getStructureCount(bld_crgo);
		float cargo_rate = 7500 * pow(lvlcurve,rlvl.crgo);
		if( pl.hasCondition("ringworld_special") ) cargo_rate *= 10;
		float avail_cargo = num_crgo * cargo_rate;
		
		if( avail_cargo > ((avail_import*2)+cargo_rate) ) {
			pl.removeStructure(oloc.crgo);
			return true;
		}
		
		if( num_yard > (slots_total/8) ) {
			pl.removeStructure(oloc.yard);
			return true;
		}
		
		if( avail_import > (avail_cargo/2 + rate_port*1.5) ) {
			pl.removeStructure(oloc.port);
			return true;
		}
		
		//cities are almost the last thing we want to dismantle
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pl.getStructureCount(bld_city) > pl.getStructureCount(bld_metl) && 
			pl.getStructureCount(bld_city) > 1 &&
			(pop_max - pop_city) > (pop_wreq + pop_buffer)
			) {
			pl.removeStructure(oloc.city);
			return true;
		}
		
		
		// Handle overworked population (maybe needs more considerations)
		if( pop_max < pop_wreq ) {
			if( pl.getStructureCount(bld_farm) > 0 ) {
				pl.removeStructure(oloc.farm);
				return true;
			}
			//If we get to this point then the player has built too many military
			//	buildings for the number of cities. Check if we should alert them.
			float gt = gameTime;
			int ttime = realTime;
			State@ lastWReqAlert = pl.toObject().getState(strAlertWReq);
			if( ttime > lastWReqAlert.max &&
				gt > (lastWReqAlert.val + 20.f)
				){
				Object@ obj = pl.toObject();
			emp.postMessage("#c:red#ALERT:#c# Governor on #link:o"+obj.uid+"##c:green#"+obj.getName()+"#c##link# reports not enough workers available!");	
				pl.toObject().setStateVals(strAlertWReq,gt,ttime,0,0);
			}
		} else {
				pl.toObject().setStateVals(strAlertWReq,0,0,0,0);
		}
	}
	
	if( offline ) {
		//if we have a building offline the only NEW buildings we will make are cities.
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		//we're still willing to renovate old buildings so no 'return' here.
	} else
	if( slots_free > 0 ) {
		
		//minimal population requirements
		float pop_buffer = 12000000;
		if( pl.hasCondition("ringworld_special") ) pop_buffer *= 10;
		if( pop_max < pop_wreq + pop_buffer) {
			pl.buildStructure(bld_city);
			return true;
		}
		
		//minimal infrastructure
		float num_port = pl.getStructureCount(bld_port);
		if( num_port < 1 ) {
			pl.buildStructure(bld_port);
			return true;
		}
		
		float num_crgo = pl.getStructureCount(bld_crgo);
		if( num_crgo < 1 ) {
			pl.buildStructure(bld_crgo);
			return true;
		}
		
		float num_yard = pl.getStructureCount(bld_yard);
		if( num_yard < floor(slots_total/8) ) {
			pl.buildStructure(bld_yard);
			return true;
		}
		
		//ore efficiency
		float num_city = pl.getStructureCount(bld_city);
		float num_metl = pl.getStructureCount(bld_metl);
		if( num_city < num_metl && num_city < int(gov_efficiency) ) {
			pl.buildStructure(bld_city);
			return true;
		}
		if( ore.val > 0 && num_metl < int(gov_efficiency)
				&& num_metl < floor((num_port+num_yard)/2)
				) {
			pl.buildStructure(bld_metl);
			return true;
		}
		
		
		//primary purpose
		float avail_import = num_port * rate_port;
		float cargo_rate = 7500 * pow(lvlcurve,rlvl.crgo);
		if( pl.hasCondition("ringworld_special") ) cargo_rate *= 10;
		float avail_cargo = num_crgo * cargo_rate;
		
		if( avail_cargo < (avail_import*2) ) {
			pl.buildStructure(bld_crgo);
			return true;
		}
		
		pl.buildStructure(bld_port);
		return true;
	}
	
	//all else fails.. RENOVATE
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}




