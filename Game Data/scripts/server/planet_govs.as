const string@ strOre = "Ore";
const string@ strDisableCivilActs = "disable_civil_acts", strDoubleLabor = "double_pop_labor", strIndifferent = "forever_indifferent";
const string@ actShortWorkWeek = "work_low", actForcedLabor = "work_forced";

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
	rlvl.city = max(1.00, emp.getStat(str_Sociology));
	rlvl.farm = max(0.75, emp.getStat(str_Biology));
	rlvl.metl = max(1.00, emp.getStat(str_Metallurgy));
	rlvl.yard = max(1.00, emp.getStat(str_ShipConstruction));
	rlvl.port = max(1.00, emp.getStat(str_Economics));
	rlvl.crgo = max(1.00, emp.getStat(str_Cargo));
	rlvl.scif = max(1.00, emp.getStat(str_Science));
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

// Return true to prevent the rest of the build queue from executing
bool onGovEvent(Planet@ pl) {
	string@ gov = pl.getGovernorType();
	Empire@ emp = pl.toObject().getOwner();

	if( @bld_gcap is null ) init_consts();

	if( emp.isAI() ) {
		//TODO: check the AI empires difficulty level and choose
		//	a governor option reflecting that setting.

		return false; //xml gov is good for weak AIs
	}

	if(gov == "rebuilder")
		return gov_rebuilder(pl, emp);

	return false;
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
	
	//tech zero base values as defined in structures.txt
	rate_metl_base *=  140.00f;
	rate_elec_base *=   27.00f;
	rate_advp_base *=   20.00f;
	rate_food_base *=    6.00f;
	rate_good_base *=  920.00f;
	rate_luxr_base *=   50.00f;
	rate_port_base *=  100.00f;
	
	//adjusted values scaled to account for tech levels, preference settings and planetary conditions
	rate_metl = rate_metl_base * (pow(lvlcurve, rlvl.metl) + basefac) * fact_MineRate * pref_ResGenMult * fact_WorkRate;
	rate_elec = rate_elec_base * (pow(lvlcurve, rlvl.metl) + basefac) * fact_ElecRate * pref_ResGenMult * fact_WorkRate;
	rate_advp = rate_advp_base * (pow(lvlcurve, rlvl.metl) + basefac) * fact_AdvpRate * pref_ResGenMult * fact_WorkRate;
	rate_food = rate_food_base *  pow(lvlcurve, rlvl.farm)            * fact_FarmRate;
	rate_good = rate_good_base *  pow(lvlcurve, rlvl.port)            * fact_GoodRate;
	rate_luxr = rate_luxr_base *  pow(lvlcurve, rlvl.port)            * fact_LuxrRate;

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
	float templvl = 1000;
	for (uint i = 0; i < structlist.getCount(); ++i) {
		@struct = structlist.getStructure(i).get_type();
		templvl = structlist.getStructure(i).get_level();

		if(struct is bld_city) {
			if(templvl < olvl.city) {
				oloc.city = i;
				olvl.city = templvl;
			}
		}
		else if(struct is bld_metl) {
			if(templvl < olvl.metl) {
				oloc.metl = i;
				olvl.metl = templvl;
			}
			pop_wreq += wreq_metl * fact_PlanetSz;
		}
		else if(struct is bld_elec) {
			if(templvl < olvl.elec) {
				oloc.elec = i;
				olvl.elec = templvl;
			}
			pop_wreq += wreq_elec * fact_PlanetSz;
		}
		else if(struct is bld_advp) {
			if(templvl < olvl.advp) {
				oloc.advp = i;
				olvl.advp = templvl;
			}
			pop_wreq += wreq_advp * fact_PlanetSz;
		}
		else if(struct is bld_farm) {
			if(templvl < olvl.farm) {
				oloc.farm = i;
				olvl.farm = templvl;
			}
			pop_wreq += wreq_farm * fact_PlanetSz;
		}
		else if(struct is bld_good) {
			if(templvl < olvl.good) {
				oloc.good = i;
				olvl.good = templvl;
			}
			pop_wreq += wreq_good * fact_PlanetSz;
		}
		else if(struct is bld_luxr) {
			if(templvl < olvl.luxr) {
				oloc.luxr = i;
				olvl.luxr = templvl;
			}
			pop_wreq += wreq_luxr * fact_PlanetSz;
		}
		else if(struct is bld_port) {
			if(templvl < olvl.port) {
				oloc.port = i;
				olvl.port = templvl;
			}
			pop_wreq += wreq_port * fact_PlanetSz;
		}
		else if(struct is bld_yard) {
			if(templvl < olvl.yard) {
				oloc.yard = i;
				olvl.yard = templvl;
			}
			pop_wreq += wreq_yard * fact_PlanetSz;
		}
		else if(struct is bld_crgo) {
			if(templvl < olvl.crgo) {
				oloc.crgo = i;
				olvl.crgo = templvl;
			}
			pop_wreq += wreq_crgo * fact_PlanetSz;
		}
		else if(struct is bld_fuel) {
			if(templvl < olvl.fuel) {
				oloc.fuel = i;
				olvl.fuel = templvl;
			}
			pop_wreq += wreq_fuel * fact_PlanetSz;
		}
		else if(struct is bld_ammo) {
			if(templvl < olvl.ammo) {
				oloc.ammo = i;
				olvl.ammo = templvl;
			}
			pop_wreq += wreq_ammo * fact_PlanetSz;
		}
		else if(struct is bld_bnkr) {
			if(templvl < olvl.bnkr) {
				oloc.bnkr = i;
				olvl.bnkr = templvl;
			}
		}
		else if(struct is bld_shld) {
			if(templvl < olvl.shld) {
				oloc.shld = i;
				olvl.shld = templvl;
			}
			pop_wreq += wreq_shld * fact_PlanetSz;
		}
		else if(struct is bld_cann) {
			if(templvl < olvl.cann) {
				oloc.cann = i;
				olvl.cann = templvl;
			}
			pop_wreq += wreq_cann * fact_PlanetSz;
		}
		else if(struct is bld_lasr) {
			if(templvl < olvl.lasr) {
				oloc.lasr = i;
				olvl.lasr = templvl;
			}
			pop_wreq += wreq_lasr * fact_PlanetSz;
		}
		else if(struct is bld_peng) {
			if(templvl < olvl.peng) {
				oloc.peng = i;
				olvl.peng = templvl;
			}
			pop_wreq += wreq_peng * fact_PlanetSz;
		}
		else if(struct is bld_scif) {
			if(templvl < olvl.scif) {
				oloc.scif = i;
				olvl.scif = templvl;
			}
			pop_wreq += wreq_scif * fact_PlanetSz;
		}
		else if(struct is bld_gcap) {
			if(templvl < olvl.gcap) {
				oloc.gcap = i;
				olvl.gcap = templvl;
			}
		}
		else if(struct is bld_pcap) {
			if(templvl < olvl.pcap) {
				oloc.pcap = i;
				olvl.pcap = templvl;
			}
		}
	}
}


bool gov_rebuilder(Planet@ pl, Empire@ emp) {
	float pop_max, pop_wreq, pop_city, pop_bnkr;
	
	float rate_metl, rate_elec, rate_advp, rate_food, rate_port;
	float rate_good, rate_luxr, rate_gcap, rate_pcap, fact_WorkRate;
	
	bldVals rlvl, olvl, oloc;

	popTechLvls( emp, rlvl );

	analyzePlanet( pl, emp, pop_max, pop_wreq, pop_city, pop_bnkr,

		rate_metl, rate_elec, rate_advp, rate_food, rate_good, 
		rate_luxr, rate_port, rate_gcap, rate_pcap,

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
	if( rlvl.scif > 0 + olvl.scif ) {
		pl.rebuildStructure(oloc.scif);
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
	
	int structCount = pl.getStructureCount();
	for(int structIndex = 0 ; structIndex < structCount && pl.toObject().getConstructionQueueSize() < 3 ; ++structIndex)
		pl.rebuildStructure(structIndex);
	return true;
}

