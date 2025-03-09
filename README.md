# simulation
A group project created for MIS485 lecture

Agent-Based Modeling Proposal: Understanding Social Influence on Voting Behavior
1. Title and Group Information
•	Project Title: Votes of Influence: Simulating Social Dynamics in Turkish Politics
•	Group Members: Şevval Dere, Enes Döke, Ayşenur Say 

2. Research Question/Phenomenon
•	Primary Research Question:
•	How does social interactions between individuals of differing political opinions influence voting behavior in Turkey?
•	Additional Considerations:
•	How do demographic distributions and personality traits affect voting results over time?
•	What impact does social interaction have on political polarization?
•	Description of the Phenomenon:
•	This model draws inspiration from a prey-predator dynamic, where agents represent different political beliefs. Instead of "eating" or "eliminating" each other, agents attempt to persuade others to adopt their political stance. The simulation aims to explore the spread of political ideologies and how social interactions can transform an individual's political alignment, providing insights into how political opinions spread, stabilize, or shift in response to social dynamics.

3. Objectives and Goals
•	Model Objectives:
•	Investigate the relationship between personality traits and the density of political demographics on voting behavior.
•	Explore how persuasion and social influence drive shifts in voting patterns.
•	Understand the impact of segregation preferences on political polarization and community dynamics.
•	Expected Impact:
•	This model has potential applications in political science, particularly in understanding voter behavior, predicting electoral outcomes, and designing strategies for political campaigns. 

4. Agent Definitions
•	Types of Agents:
•	Right-side People: Strongly aligned with right-wing ideologies.
•	Left-side People: Strongly aligned with left-wing ideologies.
•	Middle-right People: Lean towards right-wing ideologies but open to persuasion.
•	Middle-left People: Lean towards left-wing ideologies but open to persuasion.
•	Neutral (Middle) People: Centrists who can be influenced by either side.
•	Agent Attributes:
•	Political Spectrum: Represents the agent's political leaning on a scale from left (-50) to right (+50).
•	Persuasiveness: Ability to influence others to change their political stance (numerical value, e.g., 0-10).
•	Susceptibility to Persuasion: Likelihood of being influenced by others (numerical value, e.g., 0-10).
•	Segregation Preference: Tendency to cluster with like-minded individuals, thus, not to migrate (numerical value, e.g., 0-10).
•	Color
•	Agent Behaviors:
•	Agents attempt to persuade others based on their persuasiveness score.
•	Susceptible agents may shift their political spectrum towards the persuader's side.
•	Agents with high segregation preferences move towards clusters with similar political beliefs.
•	Voting behavior will be simulated by having agents "vote" based on their political alignment at set intervals.

5. Interaction Design
•	Agent Interactions:
•	Agents interact with other agents within defined proximity.
•	During interactions, agents attempt to persuade each other, with the success rate influenced by persuasiveness and susceptibility attributes.
•	Social influence can lead to changes in an agent's political spectrum, potentially shifting their voting behavior.
•	Environmental Factors:
•	The environment will simulate various demographic densities and 7 regions’ social structures in Turkey.
•	External events (like simulated political campaigns or social media influence) may randomly affect agents' political alignments.

6. Data Sources and Assumptions
•	Data Utilization:
•	The model will use synthetic data based on the 2023 Turkish General Election results for initial conditions.
•	Demographic data such as migration rates and regional political leanings will be approximated using publicly available data from sources like TÜİK (Turkish Statistical Institute).
•	Key Assumptions:
•	Agents have limited information and primarily interact with nearby individuals.
•	Social influence is bidirectional, meaning agents can both persuade and be persuaded during an interaction.
•	The impact of social influence diminishes over time, requiring multiple interactions for significant ideological shifts.
•	Personality traits like persuasiveness and susceptibility are randomly distributed among the population.

7. Expected Outcomes and Metrics
•	Anticipated Results:
•	The model expects that higher densities of politically aligned groups will lead to stronger voting outcomes for that side over time.
•	The presence of highly persuasive agents could significantly shift the political landscape, converting neutral or opposing agents.
•	High segregation preference may lead to increased polarization, resulting in echo chambers.
•	Evaluation Metrics:
•	Vote Share: The proportion of votes each political group receives.
•	Persuasion Success Rate: The percentage of agents who change their political stance after interactions.
•	Segregation Index: A measure of how clustered agents are by political belief.
•	Polarization Score: The variance in political spectrum values across the population.
•	Shift Score: The number of people changing their ideas over time

8. References
•	2023 Turkish General Election Results by YSK (Supreme Electoral Council of Turkey).
•	Migration Statistics by TÜİK (Turkish Statistical Institute).
•	Epstein, J. M., & Axtell, R. (1996). Growing Artificial Societies: Social Science from the Bottom Up.
•	Gilbert, N., & Troitzsch, K. G. (2005). Simulation for the Social Scientist.
