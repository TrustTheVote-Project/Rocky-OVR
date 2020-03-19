module StateRegistrants::MIRegistrant::StreetType
  CODES= {
    "ALY" =>	"ALLEY",
    "ANX" =>	"ANNEX",
    "ARC" =>	"ARCADE",
    "AVE" =>	"AVENUE",
    "BYU" =>	"BAYOU",
    "BCH" =>	"BEACH",
    "BND" =>	"BEND",
    "BLF" =>	"BLUFF",
    "BTM" =>	"BOTTOM",
    "BLVD" =>	"BOULEVARD",
    "BR" =>	"BRANCH",
    "BRG" =>	"BRIDGE",
    "BRK" =>	"BROOK",
    "BG" =>	"BURG",
    "BYP" =>	"BYPASS",
    "CP" =>	"CAMP",
    "CYN" =>	"CANYON",
    "CPE" =>	"CAPE",
    "CSWY" =>	"CAUSEWAY",
    "CTR" =>	"CENTER",
    "CIR" =>	"CIRCLE",
    "CLFS" =>	"CLIFFS",
    "CLB" =>	"CLUB",
    "COR" =>	"CORNER",
    "CORS" =>	"CORNERS",
    "CRSE" =>	"COURSE",
    "CT" =>	"COURT",
    "CTS" =>	"COURTS",
    "CV" =>	"COVE",
    "CRK" =>	"CREEK",
    "CRES" =>	"CRESCENT",
    "XING" =>	"CROSSING",
    "DL" =>	"DALE",
    "DM" =>	"DAM",
    "DV" =>	"DIVIDE",
    "DR" =>	"DRIVE",
    "EST" =>	"ESTATES",
    "EXPY" =>	"EXPRESSWAY",
    "EXT" =>	"EXTENSION",
    "FALL" =>	"FALL",
    "FLS" =>	"FALLS",
    "FRY" =>	"FERRY",
    "FLD" =>	"FIELD",
    "FLDS" =>	"FIELDS",
    "FLT" =>	"FLATS",
    "FRD" =>	"FORD",
    "FRST" =>	"FOREST",
    "FRG" =>	"FORGE",
    "FRK" =>	"FORK",
    "FRKS" =>	"FORKS",
    "FT" =>	"FORT",
    "FWY" =>	"FREEWAY",
    "GDNS" =>	"GARDENS",
    "GTWY" =>	"GATEWAY",
    "GLN" =>	"GLEN",
    "GRN" =>	"GREEN",
    "GRV" =>	"GROVE",
    "HBR" =>	"HARBOR",
    "HVN" =>	"HAVEN",
    "HTS" =>	"HEIGHTS",
    "HWY" =>	"HIGHWAY",
    "HL" =>	"HILL",
    "HLS" =>	"HILLS",
    "HOLW" =>	"HOLLOW",
    "INLT" =>	"INLET",
    "IS" =>	"ISLAND",
    "ISS" =>	"ISLANDS",
    "ISLE" =>	"ISLE",
    "JCT" =>	"JUNCTION",
    "KY" =>	"KEY",
    "KNLS" =>	"KNOLLS",
    "LK" =>	"LAKE",
    "LKS" =>	"LAKES",
    "LNDG" =>	"LANDING",
    "LN" =>	"LANE",
    "LGT" =>	"LIGHT",
    "LF" =>	"LOAF",
    "LCKS" =>	"LOCKS",
    "LDG" =>	"LODGE",
    "LOOP" =>	"LOOP",
    "MALL" =>	"MALL",
    "MNR" =>	"MANOR",
    "MDWS" =>	"MEADOWS",
    "ML" =>	"MILL",
    "MLS" =>	"MILLS",
    "MSN" =>	"MISSION",
    "MT" =>	"MOUNT",
    "MTN" =>	"MOUNTAIN",
    "NCK" =>	"NECK",
    "ORCH" =>	"ORCHARD",
    "OVAL" =>	"OVAL",
    "PARK" =>	"PARK",
    "PKWY" =>	"PARKWAY",
    "PASS" =>	"PASS",
    "PATH" =>	"PATH",
    "PIKE" =>	"PIKE",
    "PNES" =>	"PINES",
    "PL" =>	"PLACE",
    "PLN" =>	"PLAIN",
    "PLNS" =>	"PLAINS",
    "PLZ" =>	"PLAZA",
    "PT" =>	"POINT",
    "PRT" =>	"PORT",
    "PR" =>	"PRAIRIE",
    "RADL" =>	"RADIAL",
    "RNCH" =>	"RANCH",
    "RPDS" =>	"RAPIDS",
    "RST" =>	"REST",
    "RDG" =>	"RIDGE",
    "RIV" =>	"RIVER",
    "RD" =>	"ROAD",
    "ROW" =>	"ROW",
    "RUN" =>	"RUN",
    "SHL" =>	"SHOAL",
    "SHLS" =>	"SHOALS",
    "SHR" =>	"SHORE",
    "SHRS" =>	"SHORES",
    "SPG" =>	"SPRING",
    "SPGS" =>	"SPRINGS",
    "SPUR" =>	"SPUR",
    "SQ" =>	"SQUARE",
    "STA" =>	"STATION",
    "STRA" =>	"STRAVENUE",
    "STRM" =>	"STREAM",
    "ST" =>	"STREET",
    "SMT" =>	"SUMMITT",
    "TER" =>	"TERRACE",
    "TRCE" =>	"TRACE",
    "TRAK" =>	"TRACK",
    "TRL" =>	"TRAIL",
    "TRLR" =>	"TRAILER",
    "TUNL" =>	"TUNNEL",
    "TPKE" =>	"TURNPIKE",
    "UN" =>	"UNION",
    "VLY" =>	"VALLEY",
    "VIA" =>	"VIADUCT",
    "VW" =>	"VIEW",
    "VLG" =>	"VILLAGE",
    "VL" =>	"VILLE",
    "VIS" =>	"VISTA",
    "WALK" =>	"WALK",
    "WAY" =>	"WAY",
    "WLS" =>	"WELLS",
    "ACRE" =>	"ACRES",
    "CRST" =>	"CREST",
    "CMMN" =>	"COMMON",
    "CMNS" =>	"COMMONS",
    "KNL" =>	"KNOLL",
    "BLFS" =>	"BLUFFS"
  }
  
  def street_types
    CODES
  end
  
  def street_type_code
    name = registration_address_street_type.downcase.strip
    street_types.each do |k,v|
      if [k.downcase, v.downcase].include?(name)
        return k
      end
    end    
    return nil
  end
  
  def all_street_types
    street_types.values.collect{|v| v.capitalize}.join(", ")
  end
  
  def matching_street_types
    if registration_address_street_type.blank?
      return all_street_types
    else
      letter = registration_address_street_type.downcase[0]
      street_types.values.select {|v| v.downcase.starts_with?(letter)}.collect{|v| v.capitalize}.join(", ")
    end
  end
  
  def registration_address_street_type=(value)
    street_types.each do |k,v|
      if [k.downcase, v.downcase].include?(value.downcase.strip.gsub(/[^a-z]/,""))
        return super(v.capitalize)
      end
    end
    super(value)
  end
  
  
end