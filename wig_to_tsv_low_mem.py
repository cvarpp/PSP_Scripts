import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("-i", required=True, help="Input wig file path")
parser.add_argument("-r", required=True, help="Reference fasta file")
parser.add_argument("-o", required=True, help="Output tsv file path")
args = parser.parse_args()

def enhance_wig(data_path, ref_path, out_file):
    # Write header 
    header = "\t".join(["gene", "position", "base", "pileup", "mutation", "A", "C", "G", "T", "N"])
    with open(out_file, "w") as f:
        f.write(header)
    ref_dict = read_reference_fasta(ref_path)
    process_wig_file(data_path, ref_dict, out_file)

def read_reference_fasta(ref_path):
    """Read FASTA file and returns a dictionary {header: sequence} .
    Originally designed for custom FASTA for tRNA, but works okay for chr.fa files """
    ref_dict = {}
    name = None
    seq_parts = []
    with open(ref_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith(">"):
                if name:
                    ref_dict[name] = "".join(seq_parts).upper()
                name = line[1:].split()[0]
                seq_parts = []
            else:
                seq_parts.append(line)
        # Save the final record
        if name:
            ref_dict[name] = "".join(seq_parts).upper()
    return ref_dict

def process_wig_file(data_path, ref_dict, out_file):
    """Processes the wig file line by line, grouping by gene and printing output."""
    with open(data_path) as f:
        # Skip first two header lines
        next(f)
        next(f)
        gene_lines = []
        for line in f:
            parts = line.strip().split()
            if not parts:
                continue
            if parts[0] == "variableStep":
                if gene_lines:
                    print_one_gene(gene_lines, out_file, ref_dict)
                gene_lines = [parts]
            else:
                gene_lines.append(parts)
        # Process the final gene block
        if gene_lines:
            print_one_gene(gene_lines, out_file, ref_dict)

def print_one_gene(gene_lines, out_file, ref_dict):
    """
    If gene_lines is empty, write header.
    Otherwise, parse data lines, compute pileup and mutation rate,
    and append tab-delimited results to the output file.
    """
    if not gene_lines:
        header = "\t".join(["gene", "position", "base", "pileup", "mutation",
                             "A", "C", "G", "T", "N"])
        with open(out_file, "w") as f:
            f.write(header)
        return

    # Retrieve gene name from the variableStep line (e.g., "variableStep chrom=chr1")
    gene_info = gene_lines[0]
    try:
        gene_name = gene_info[1].split("=")[1]
    except IndexError:
        raise ValueError("Unexpected variableStep format in wig file: " + " ".join(gene_info))
    if gene_name not in ref_dict:
        raise ValueError(f"Gene {gene_name} not found in reference fasta.")
    seq = ref_dict[gene_name]

    # Parse data lines (skip the header line for this gene)
    positions = []
    bases = []
    count_A = []
    count_C = []
    count_G = []
    count_T = []
    count_N = []
    
    for line in gene_lines[1:]:
        # Expecting 8 columns: position, A, C, G, T, N, deletion, insertion
        pos = int(float(line[0]))
        positions.append(pos)
        # Get base from the reference sequence (1-indexed in wig file)
        bases.append(seq[pos - 1])
        count_A.append(int(float(line[1])))
        count_C.append(int(float(line[2])))
        count_G.append(int(float(line[3])))
        count_T.append(int(float(line[4])))
        count_N.append(int(float(line[5])))
        # If you add deletion and insertion later, remember to update the calculations.

    # Compute pileup using NumPy vectorized addition
    A = np.array(count_A)
    C = np.array(count_C)
    G = np.array(count_G)
    T = np.array(count_T)
    N = np.array(count_N)
    pileup = A + C + G + T + N

    # Map reference bases to indices: A->0, C->1, G->2, T->3.
    # Use .get() with a default value of -1 for any unknown base.
    mapping = {'A': 0, 'C': 1, 'G': 2, 'T': 3}
    ref_indices = np.array([mapping.get(b.upper(), -1) for b in bases])
    
    # Build counts matrix for A, C, G, T
    counts_mat = np.stack((A, C, G, T), axis=1)
    total_counts = counts_mat.sum(axis=1)
    
    # Create a mask for valid reference bases (i.e. those in A, C, G, T)
    valid_mask = ref_indices != -1
    ref_counts = np.zeros_like(total_counts)
    if valid_mask.any():
        valid_indices = np.arange(len(bases))[valid_mask]
        ref_counts[valid_indices] = counts_mat[valid_indices, ref_indices[valid_mask]]
    
    # Compute mutation counts: total counts minus the reference count.
    mutation_array = total_counts - ref_counts
    # For positions with an invalid reference base, set mutation rate to 0.
    with np.errstate(divide='ignore', invalid='ignore'):
        mut_rate_calc = np.divide(mutation_array, pileup, out=np.zeros_like(mutation_array, dtype=float), where=(pileup > 0))


    mutation_rate = np.round(mut_rate_calc, 4)
    # For positions with invalid reference bases, force mutation_rate to 0
    mutation_rate[~valid_mask] = 0

    # Build output lines (one per data point)
    output_lines = []
    for pos, base_val, pu, mut_rate, a, c, g, t, n in zip(
        positions, bases, pileup, mutation_rate, count_A, count_C, count_G, count_T, count_N
    ):
        line = "\t".join([
            gene_name,
            str(pos),
            base_val,
            str(pu),
            str(mut_rate),
            str(a),
            str(c),
            str(g),
            str(t),
            str(n),
        ])
        output_lines.append(line)
    
    # Append the gene's data to the output file
    with open(out_file, "a") as f:
        f.write("\n" + "\n".join(output_lines))

if __name__ == "__main__":
    enhance_wig(args.i, args.r, args.o)
