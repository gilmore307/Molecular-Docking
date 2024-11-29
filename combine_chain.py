from Bio import PDB

def merge_chains(input_pdb, output_pdb, chains_to_merge, new_chain_id):
    parser = PDB.PDBParser(QUIET=True)
    structure = parser.get_structure("structure", input_pdb)

    for model in structure:
        for chain in model:
            if chain.id in chains_to_merge:
                chain.id = new_chain_id

    io = PDB.PDBIO()
    io.set_structure(structure)
    io.save(output_pdb)

# Example usage:
input_pdb = "4_Tislelizumab/7CGW.pdb"
output_pdb = "4_Tislelizumab/7CGW_1.pdb"
chains_to_merge = ["H", "L"]  # Chains to merge
new_chain_id = "X"            # New chain ID
merge_chains(input_pdb, output_pdb, chains_to_merge, new_chain_id)
