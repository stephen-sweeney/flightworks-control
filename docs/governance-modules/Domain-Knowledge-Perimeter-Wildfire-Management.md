# Domain Knowledge: Perimeter Wildfire Management

**Governance Module:** FireGovernance (FlightLaw)
**Prepared for:** GCS Use Case Brief — Drone/Drone Swarm Integration
**Version:** 1.1
**Date:** February 2026
**Status:** Domain Research

---

These notes focus on the operational core of **perimeter wildfire management** (the active edge or boundary of a wildland fire where suppression occurs). They draw from NWCG standards, ICS frameworks, and interagency practices. The goal is to inform GCS requirements for real-time drone/swarm oversight, data ingestion, tasking, and decision support in dynamic perimeter ops.

## 1. Glossary (Key Operational Terms)

Selected terms relevant to perimeter tactics, drawn primarily from NWCG PMS 205 (via cross-referenced standards), Wikipedia Glossary of Wildfire Terms (sourced from NWCG/agency docs), and NIFC references. Focus is on perimeter-specific concepts.

- **Anchor Point**: Secure starting location (e.g., road, rock, or water) from which fireline construction begins to prevent the line from being flanked.
- **Backburn / Burnout**: Controlled fire set along the inside of a control line to consume fuel between the line and the main fire edge.
- **Contain a Fire**: Moderately aggressive strategy to keep the fire within established constructed or natural firelines under prevailing conditions (percentage-based reporting, e.g., 50% contained).
- **Control (a Fire)**: Full suppression where lines surround the fire (including spot fires) and burning potential is reduced so it no longer threatens spread under foreseeable conditions.
- **Confine**: Least aggressive strategy; restrict spread to a predetermined area using natural barriers with minimal line construction. *Note: "Confine" is legacy terminology from pre-2009 federal wildfire policy. Modern federal wildfire management uses a strategy continuum rather than the suppress/contain/confine trichotomy. The term is retained here for operational awareness, as it may still appear in older literature and some state/local agency protocols.*
- **Control Line**: Inclusive term for all constructed/natural barriers and retardant-treated edges used to control a fire.
- **Fireline**: The scraped/dug portion of a control line taken to mineral soil (handline, dozer line, etc.).
- **Fire Perimeter**: Current boundary between burned/active fire and unburned fuel (updated daily; polygon in GIS).
- **Direct Attack**: Tactics applied directly to the burning edge (e.g., wetting, hand tools, or retardant drops).
- **Indirect Attack**: Control line built some distance from the active edge; often paired with burnout/backburn (used on fast-spreading or high-intensity fires).
- **Head of the Fire**: Fastest-spreading portion of the perimeter (usually downwind or upslope).
- **Flanks**: Sides of the perimeter running parallel to the main spread direction.
- **Heel / Rear**: Trailing, slower-burning portion of the perimeter.
- **Hot Spotting**: Rapid suppression of active points along the perimeter to prevent spread.
- **Mop-up**: Extinguishing smoldering material near control lines, trenching logs, and felling snags to secure the line.
- **Slopover / Spot Fire**: Fire crossing a control line (slopover) or new ignition ahead of the perimeter via embers (spotting).
- **LCES**: Lookouts, Communications, Escape Routes, Safety Zones — mandatory safety system for all perimeter operations.
- **Management Action Point (MAP)**: Geospatial trigger (e.g., "if fire reaches X ridge") that activates a specific perimeter tactic or strategy shift.
- **Blowup / Flare-up**: Sudden, violent increase in fire intensity or rate of spread that can overrun lines.

Additional tactical terms (e.g., **Parallel Attack**, **Knock Down**) follow similar NWCG definitions.

## 2. Typical Workflow Patterns

Perimeter management follows the Incident Command System (ICS) planning/operations cycle and NWCG risk-management processes (IRPG five-step: Situation Awareness → Hazard Assessment → Hazard Control → Decision Point → Evaluate). The "Decision Point" step is critical because it is where a firefighter can refuse an assignment they judge to be unsafe. The process is iterative and daily.

### High-Level Sequence (Initial Attack to Control)

1. **Detection/Size-Up** — Confirm ignition, estimate perimeter, identify head/flanks/heel, values at risk.
2. **Strategy Selection (via WFDSS or IAP)** — Full perimeter suppression, confine/contain, point/zone protection, or monitor. Document in Course of Action with MAPs.
3. **Tactical Execution (Operations Section)** — Anchor and build control lines (direct on flanks/head if feasible; indirect with burnout on head). Use hand crews, dozers, engines, air resources. Prioritize head, then flanks.
4. **Hold & Secure** — Patrol lines, hot spot, apply retardant/water. Burn out interior fuels. Update containment % daily.
5. **Mop-up & Patrol** — Extinguish near-line fuel; monitor for slopovers/spot fires (often 24–72+ hours).
6. **Transition to Control/Out** — Lines hold under forecast conditions; demobilize.

### Daily GIS/Planning Cycle (GISS Workflow — NWCG PMS 936-1)

- Ingest new perimeter data (aerial/ground/drone).
- Edit EventPolygon (daily fire perimeter) and PerimeterLine features in offline copy; calculate acres, containment, ownership.
- Sync to Master Incident GDB; produce progression maps, web maps, Geospatial PDFs.
- Integrate into IAP (ICS-202, ICS-215A safety analysis, maps).

### Risk-Management Overlay

Every perimeter action uses LCES + JHA/RA. Strategies are reevaluated at MAP triggers or weather shifts.

## 3. Common Hazards / Edge Cases

Perimeter work is the highest-risk phase (direct exposure to fire behavior, terrain, and fatigue). From NIFC Red Book Chapter 7 and IRPG.

> **Note:** Red Book chapter numbers may vary by edition year. Verify the chapter reference against the current annual edition of the Interagency Standards for Fire and Fire Aviation Operations (Red Book) available from NIFC.

- **Fire Behavior** — Blowups, rapid flanking runs, spotting (embers crossing lines), crown fire runs. Edge case: wind shift reverses head, causing the former heel to become active.
- **Terrain/Access** — Steep slopes (downhill line construction checklist required), poor visibility, snags/hazard trees.
- **Environmental** — Dense smoke (visibility + CO/HCN exposure), night ops, extreme heat.
- **Operational** — Fatigue (exceeding 2:1 work/rest), line breaches (slopover), WUI complexity (structures vs. wildland tactics), aerial drop gravity hazards.
- **Human Factors** — Right to refuse unsafe assignments; visitors on line without quals.

### High-Risk Edge Cases

- Multiple spot fires overwhelming patrol capacity.
- Fire in complex ownership (MAPs misaligned).
- Sudden blowup during mop-up or burnout ops.
- UXO, coal-seam gas, or hazardous materials in perimeter.

Mitigations: LCES briefings every shift, MAP triggers, smoke monitoring in IAP.

## 4. Common Artifacts / Outputs

- **GIS Layers** (GeoOps/NIFC standards): Daily Fire Perimeter Polygon, PerimeterLine, EventLine (control lines, MAPs, burnout lines), Values at Risk, TFRs.
- **Maps**: Progression maps, incident web maps, Geospatial PDFs (exported nightly), Situation Unit products.
- **ICS Forms**: IAP (with perimeter maps), ICS-209 (incident status/containment %), ICS-215A (safety analysis).
- **Reports**: Containment percentage, resource status, BAER (post-fire) inputs. *Note: BAER (Burned Area Emergency Response) post-fire assessment is a valuable use case for drone mapping of burn severity. High-resolution orthomosaics and multispectral imagery captured by drones can significantly accelerate BAER team assessments of soil burn severity, watershed damage, and erosion risk across the fire footprint.*
- **Digital Products**: Web maps for field crews/cooperators/public, photo points, tile packages for mobile devices.

## 5. Pain Points Currently Faced by Fire Departments

- **Limited Situational Awareness**: Smoke obscures visual scouting; ground crews have delayed/incomplete perimeter views, leading to reactive rather than proactive tactics.
- **Personnel Risk & Fatigue**: Manual line construction, hot spotting, and patrol expose crews to blowups, spotting, and long shifts; workforce shortages exacerbate this.
- **Slow Mapping & Updates**: Traditional aerial/ground perimeter capture lags (hours to daily); GISS editing is manual and bottlenecked.
- **Resource Strain**: Large perimeters require massive crews/dozers/aircraft; WUI diverts resources from pure perimeter control.
- **Cost & Scalability**: Manned aviation is expensive and weather-limited; night ops are high-risk.
- **Decision Latency**: MAP triggers and strategy shifts suffer from incomplete real-time data.

## 6. Advantages Drone & Drone Swarm Operations Bring to Perimeter Management

Drones directly address the above pain points and are already proven in wildfire response (thermal/IR, real-time mapping, hotspot detection).

- **Enhanced Real-Time SA**: Thermal/IR penetrates smoke for continuous perimeter mapping, hotspot identification, and spot-fire confirmation. Feeds live to GCS and ICS for faster GISS updates and higher-accuracy containment %.
- **Safer Operations**: Reduces ground crew exposure in high-risk zones (head/flanks scouting, line cooling assessment, post-burnout monitoring). LCES improves with drone-derived escape-route visuals.
- **Speed & Coverage**: Rapid deployment (minutes) vs. manned aircraft; swarms provide persistent, coordinated coverage of large or complex perimeters (head + both flanks simultaneously).
- **Cost & Efficiency**: Lower operating cost than helos; scalable for night/poor-weather persistence; AI-assisted perimeter digitization accelerates GIS workflow.
- **Tactical Enablers for GCS**: Swarm tasking for specific missions (e.g., confirm MAP trigger, guide burnout ignition if equipped, monitor slopover risk). Direct data ingestion into IAP/web maps. Supports strategy shifts (e.g., switch from indirect to direct when drone data shows fire intensity drop).
- **Integration Value**: GCS becomes the hub for swarm telemetry, video, thermal overlays, and automated alerts (e.g., "spot fire detected at coord X"), closing the loop between drone ops and IC/Operations/GISS.

## 7. Regulatory & Airspace Framework for UAS in Fire Operations

Integrating UAS into wildfire incident airspace requires strict compliance with federal aviation regulations and interagency coordination protocols. Unauthorized drone flights over wildfires have repeatedly forced manned firefighting aircraft to be grounded, directly endangering lives and property.

### Temporary Flight Restrictions (TFRs)

- The FAA issues TFRs over active wildfires under 14 CFR 91.137 to protect manned firefighting aircraft (air tankers, lead planes, helicopters).
- TFRs typically extend to a defined altitude and radius around the incident. All aircraft — including UAS — require explicit authorization to operate within a TFR.
- Unauthorized drone incursions into wildfire TFRs have caused air tanker and helicopter operations to be suspended ("If You Fly, We Can't"), resulting in direct loss of suppression capability during critical windows.
- GCS systems operating under incident authority must maintain real-time TFR awareness and enforce geofence compliance for all UAS in the fleet.

### FAA Part 107 Waivers

Operations beyond standard Part 107 limitations require FAA waivers, including:

| Waiver Type | Regulatory Basis | Relevance to Fire Operations |
|---|---|---|
| Beyond Visual Line of Sight (BVLOS) | 14 CFR 107.31 | Required for persistent perimeter patrol and large-fire coverage |
| Night Operations | 14 CFR 107.29 | Critical for nighttime hotspot monitoring and mop-up oversight |
| Operations Over People | 14 CFR 107.39 | Necessary when flying over ground crews on the fireline |
| Multiple UAS (Single Pilot) | 14 CFR 107.35 | Required for swarm operations with one remote PIC |
| Altitude Above 400 ft AGL | 14 CFR 107.51 | May be needed for smoke penetration and terrain clearance |

Waiver applications must demonstrate risk mitigations (detect-and-avoid capability, crew resource management, communication protocols) and are typically coordinated through the incident's Air Operations organization.

### NWCG UAS Standards

NWCG publishes standards for UAS integration into incident management (PMS 515 or equivalent guidance). Key elements include:

- UAS operations on incidents must be authorized by the Incident Commander and coordinated through the Air Operations Branch.
- UAS crews must meet NWCG qualification standards (see Section 8).
- Standard operating procedures cover launch/recovery zones, communication frequencies, lost-link procedures, and data management.
- UAS missions are documented in the IAP and coordinated during the Air Operations briefing.

### Airspace Coordination

On wildfire incidents with both manned and unmanned aircraft, airspace deconfliction is managed through the ICS Air Operations organization:

- **Air Operations Branch Director (AOBD)**: Oversees all air operations on the incident, including UAS integration.
- **Air Tactical Group Supervisor (ATGS)**: Coordinates airspace assignments, altitudes, and timing between manned aircraft and UAS from the air tactical platform.
- **UAS operations** are typically assigned specific altitude blocks, geographic sectors, or time windows to deconflict with manned aircraft (air tankers, lead planes, helicopters, and air attack).
- Real-time communication between UAS operators and ATGS is mandatory. GCS systems should support direct radio or data-link integration with the air operations communication net.

### Certificate of Authorization (COA) for Federal Agencies

Federal agencies (USFS, BLM, DOI, etc.) operate UAS under Certificates of Authorization issued by the FAA, which authorize specific operations in defined airspace. The COA process requires:

- Documented safety case and operational procedures
- Defined geographic and altitude boundaries
- Pilot qualification and training records
- Coordination with ATC facilities and local airports
- Incident-specific COAs can be expedited for emergency wildfire response under established interagency agreements

## 8. NWCG Qualification Standards

Personnel involved in wildfire operations must meet NWCG qualification standards. The following are relevant to UAS-integrated perimeter management:

### Basic Firefighter Training

- **S-130 (Firefighter Training)**: Entry-level course covering fireline safety, fire behavior basics, hand tool use, and suppression tactics. Required for all personnel on the fireline.
- **S-190 (Introduction to Wildland Fire Behavior)**: Companion to S-130 covering fire environment (fuels, weather, topography), fire behavior indicators, and safety implications. Required for all fireline personnel.

### Intermediate Fire Behavior

- **S-290 (Intermediate Wildland Fire Behavior)**: Advanced course covering fire behavior prediction, weather interpretation, fuel models, and topographic influences. Required for crew bosses, division supervisors, and operational planners who make tactical decisions based on fire behavior forecasts.

### UAS-Specific Qualifications

- **S-378 (UAS Mission Planning and Operations)** or equivalent NWCG UAS training: Covers UAS mission planning, airspace coordination, incident integration, data management, and safety procedures specific to wildfire UAS operations. Required for Remote Pilots in Command (RPIC) and UAS technical specialists operating on incidents.
- UAS operators must also maintain current FAA Part 107 Remote Pilot Certificates and any agency-specific endorsements.

### GISS Qualification

- **S-341 (GIS Specialist)** or equivalent: Covers geospatial data collection, editing, analysis, and map production in the incident environment. GISS personnel manage perimeter data, produce IAP maps, and maintain the incident geodatabase. Relevant to GCS integration because drone-captured geospatial data feeds directly into the GISS workflow.

## 9. Fire Behavior & Weather Tools

Effective perimeter management depends on accurate fire behavior prediction and weather intelligence. The following tools and systems are commonly used in wildfire operations:

### Fire Behavior Modeling

- **FARSITE (Fire Area Simulator)**: Spatially and temporally explicit fire growth simulation model that uses terrain, fuels, and weather data to project fire spread and intensity across a landscape.
- **FlamMap**: Companion to FARSITE; computes potential fire behavior characteristics (flame length, rate of spread, crown fire potential) across a landscape under a single set of weather conditions. Useful for pre-attack planning and identifying high-risk areas along the perimeter.
- **IFTDSS (Interagency Fuels Treatment Decision Support System)**: Web-based platform that integrates FARSITE, FlamMap, and other models into a unified workflow for fire behavior analysis, fuels treatment planning, and risk assessment. Increasingly used by incident management teams for operational fire behavior forecasts.

### Weather Intelligence

- **Spot Weather Forecasts**: Incident-specific weather forecasts issued by the National Weather Service (NWS) upon request from incident management teams. Provide localized predictions for wind speed/direction, temperature, relative humidity, and atmospheric stability at the incident location. Critical for tactical planning and safety.
- **Red Flag Warnings / Fire Weather Watches**: NWS-issued alerts indicating weather conditions (low humidity, strong winds, dry lightning) that significantly increase wildfire risk or fire behavior. Red Flag Warnings trigger heightened readiness and may prompt strategy reassessment on active incidents.

### Real-Time Monitoring Systems

- **ALERTWildfire**: Network of mountaintop cameras providing real-time pan-tilt-zoom imagery for early fire detection and situational awareness. Camera feeds can supplement drone data for broad-area monitoring and fire confirmation.
- **FIRIS (Fire Integrated Real-Time Intelligence System)**: California's airborne infrared mapping system that produces near-real-time fire perimeter and heat intensity maps from manned aircraft equipped with IR sensors. FIRIS products are a primary input to GISS workflows on California incidents and represent a direct analog to drone-based thermal mapping.

### Satellite-Based Fire Monitoring

- **GOES (Geostationary Operational Environmental Satellites)**: Provide near-continuous fire detection and monitoring at continental scale. GOES-16/17/18 carry the Advanced Baseline Imager (ABI) which detects active fire hotspots and produces Fire Detection and Characterization (FDC) products at 5-minute intervals.
- **VIIRS (Visible Infrared Imaging Radiometer Suite)**: Carried aboard Suomi-NPP and NOAA-20 polar-orbiting satellites. Provides higher spatial resolution fire detection (375m) than GOES, with global coverage approximately twice daily. VIIRS active fire data is widely used for large-fire monitoring and burned area mapping.

These tools collectively inform the operational picture that a GCS must integrate with. Drone-derived perimeter data can validate and refine fire behavior model predictions, while weather intelligence drives both manned and unmanned operational tempo and safety decisions.

## 10. GCS Integration Recommendations

These notes position a drone-swarm GCS as a force multiplier for perimeter containment: faster, safer, more precise control-line decisions with reduced human exposure. For the use-case brief, recommend GCS features such as:

- Live perimeter overlay on ICS maps
- Swarm autonomy modes (e.g., "patrol flanks")
- MAP trigger alerts
- Seamless export to GeoOps GDB
- TFR awareness and geofence enforcement
- Integration with air operations communication nets
- Automated fire behavior model validation using real-time thermal data

---

## Citations / Primary Sources

*Browsed/verified February 2026*

- NWCG PMS 936-1: GISS Workflow — <https://www.nwcg.gov/publications/pms936-1>
- USDA FS RMRS-GTR-298: Decision Making for Wildfires — <https://research.fs.usda.gov/treesearch/download/43638.pdf>
- NIFC Red Book Chapter 7: Safety & Risk Management — <https://www.nifc.gov/sites/default/files/redbook-files/Chapter07.pdf>
- Wikipedia Glossary of Wildfire Terms (NWCG-derived)
- Additional context from NWCG PMS 205 references and NIFC GeoOps standards
- FAA 14 CFR Part 107: Small Unmanned Aircraft Systems
- FAA 14 CFR 91.137: Temporary Flight Restrictions in the Vicinity of Disaster/Hazard Areas
- NWCG PMS 515: UAS Standards for Wildland Fire (or current equivalent)
- NWCG Training Courses: S-130, S-190, S-290, S-341, S-378
- IFTDSS: <https://iftdss.firenet.gov/>
- ALERTWildfire: <https://www.alertwildfire.org/>
- NOAA GOES Fire Detection: <https://www.ospo.noaa.gov/products/land/fire.html>
- NASA FIRMS (VIIRS Active Fire): <https://firms.modaps.eosdis.nasa.gov/>
