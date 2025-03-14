import pandas as pd

# Path to your Rosetta output file
file_path = "residue_breakdown.out"  # Update the file path if needed

# Read the file content
with open(file_path, "r") as file:
    content = file.readlines()

# Updating the classification to use multiple Rosetta energy terms for each interaction type

# Define updated energy thresholds
HBOND_THRESHOLD = 0  # Hydrogen bond
ELEC_THRESHOLD = 0   # Electrostatic interactions (including solvation)
VDW_THRESHOLD = 0    # Van der Waals (hydrophobic)

# Updated list to store classified interactions
interaction_data = []

# Loop through each line in the file and classify interactions
for line in content:
    if line.startswith("SCORE:"):  # Process only relevant lines
        parts = line.split()

        if len(parts) > 18:  # Ensure the line has enough columns
            try:
                fa_atr = float(parts[8])   # Attractive Van der Waals
                fa_rep = float(parts[9])   # Repulsive Van der Waals
                fa_sol = float(parts[10])  # Solvation effects
                fa_elec = float(parts[13]) # Electrostatic energy
                hbond_bb_sr = float(parts[15]) # Short-range backbone H-bond
                hbond_bb_lr = float(parts[16]) # Long-range backbone H-bond
                hbond_sc = float(parts[17])    # Side-chain H-bond
                
                chain1 = parts[3][-1]
                resi1 = int(parts[3][:-1])
                aa1 = parts[4]
                
                chain2 = parts[6][-1]
                resi2 = int(parts[6][:-1])
                aa2 = parts[7]
                
                # Combine residue index and chain with residue type for the "Residue" columns
                if (chain1[-1] == "R" and (chain2[-1] == "H" or chain2[-1] == "L")) or (chain2[-1] == "R" and (chain1[-1] == "H" or chain1[-1] == "L")):
                    residue1_info = f"{resi1} {chain1} ({aa1})"
                    residue2_info = f"{resi2} {chain2} ({aa2})"
                else:
                    continue
                
            except ValueError:
                continue  # Skip this entry if any values are invalid
                
            print (parts)

            # Van der Waals interactions (Including attractive + repulsive components)
            vdw_sum = fa_atr + fa_rep
            elec_sum = fa_elec + fa_sol
            hbond_sum = hbond_bb_sr + hbond_bb_lr + hbond_sc
            
            # Check if fa_atr + fa_rep is the minimum
            if vdw_sum <= elec_sum and vdw_sum <= hbond_sum:
                interaction_data.append([f"{residue1_info}", f"{residue2_info}", "Van der Waals", parts[27]])
            
            # Check if fa_elec + fa_sol is the minimum
            elif elec_sum <= vdw_sum and elec_sum <= hbond_sum:
                interaction_data.append([f"{residue1_info}", f"{residue2_info}", "Electrostatic", parts[27]])
            
            # Check if hydrogen bond is the minimum
            else:
                interaction_data.append([f"{residue1_info}", f"{residue2_info}", "Hydrogen Bond", parts[27]])

# Convert to a DataFrame for easy viewing
interaction_data = pd.DataFrame(interaction_data, columns=["Residue 1", "Residue 2", "Interaction Type", "Energy Contribution"])


# Save to CSV (Optional)
interaction_data.to_csv("interaction_results.csv", index=False)

# Print the first few rows to verify
print(interaction_data.head())